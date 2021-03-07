import 'dart:async';

import 'package:rpi_gpio/gpio.dart';

import 'dart-ext:rpi_gpio_ext';
import 'package:rpi_gpio/src/gpio_const.dart';

/// GPIO interface used for accessing GPIO on the Raspberry Pi.
class RpiGpio extends Gpio {
  static bool _instantiatedGpio = false;

  final _polledInputs = <RpiGpioInput>[];
  Duration _pollingFrequency = Duration(milliseconds: 10);
  Timer _pollingTimer;

  /// Instantiate a new GPIO manager.
  /// By default, you cannot allocate the I2C or SPI pins as GPIO pins.
  /// If you want to use the I2C pins as GPIO pins, pass `i2c: false`.
  /// If you want to use the SPI pins as GPIO pins, pass `spi: false`.
  RpiGpio({bool i2c = true, bool spi = true, bool eeprom = true}) {
    if (_instantiatedGpio) throw GpioException('RpiGpio already instantiated');
    _instantiatedGpio = true;
    int result = _setupGpio();
    if (result != 0)
      throw GpioException('RpiGpio initialization failed: $result');
    if (i2c) physI2CPins.forEach(allocatePin);
    if (spi) physSpiPins.forEach(allocatePin);
    if (eeprom) physEepromPins.forEach(allocatePin);
  }

  @override
  void throwPinAlreadyAllocated(int physicalPin) {
    if (physI2CPins.contains(physicalPin)) {
      throw GpioException(
          'If you want to use I2C pins for GPIO,'
          ' pass "i2c: false" into the RpiGpio constructor\n'
          'Already allocated',
          physicalPin);
    }
    if (physSpiPins.contains(physicalPin)) {
      throw GpioException(
          'If you want to use SPI pins for GPIO,'
          ' pass "spi: false" into the RpiGpio constructor\n'
          'Already allocated',
          physicalPin);
    }
    if (physEepromPins.contains(physicalPin)) {
      throw GpioException(
          'If you want to use EEPROM pins for GPIO,'
          ' pass "eeprom: false" into the RpiGpio constructor\n'
          'Already allocated',
          physicalPin);
    }
    super.throwPinAlreadyAllocated(physicalPin);
  }

  @override
  void dispose() {
    int result = _disposeGpio();
    if (result != 0) throw GpioException('RpiGpio dispose failed: $result');
    _instantiatedGpio = false;
  }

  @override
  GpioInput input(int physicalPin, [Pull pull = Pull.off]) {
    allocatePin(physicalPin);
    return RpiGpioInput._(this, physicalPin, pull);
  }

  @override
  GpioOutput output(int physicalPin) {
    allocatePin(physicalPin);
    return RpiGpioOutput._(this, physicalPin);
  }

  @override
  GpioPwm pwm(int physicalPin) {
    allocatePin(physicalPin);
    return RpiGpioPwm._(this, physicalPin);
  }

  @override
  set pollingFrequency(Duration frequency) {
    if (_pollingFrequency != frequency) {
      _pollingFrequency = frequency;
      _stopPollingTimer();
      _startPollingTimer();
    }
  }

  void _startPolling(RpiGpioInput input) {
    _polledInputs.add(input);
    _startPollingTimer();
  }

  void _startPollingTimer() {
    if (_polledInputs.isNotEmpty && _pollingFrequency != null) {
      _pollingTimer ??= Timer.periodic(_pollingFrequency, _pollInputs);
    }
  }

  void _pollInputs(_) {
    final polledInputs = List<RpiGpioInput>.from(_polledInputs);
    for (RpiGpioInput input in polledInputs) {
      input._poll();
    }
  }

  void _stopPolling(RpiGpioInput input) {
    _polledInputs.remove(input);
    if (_polledInputs.isEmpty) _stopPollingTimer();
  }

  void _stopPollingTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  int _setupGpio() native "setupGpio";
  int _disposeGpio() native "disposeGpio";
}

class _RpiGpioCommon {
  final RpiGpio gpio;
  final int physicalPin;
  final int bcmGpio;

  _RpiGpioCommon._(this.gpio, this.physicalPin)
      : bcmGpio = physToBcmGpioRPi2[physicalPin];
}

class RpiGpioInput extends _RpiGpioCommon with GpioInput {
  final Pull pull;

  StreamController<bool> _valuesController;
  bool _lastValue;

  RpiGpioInput._(RpiGpio gpio, int physicalPin, this.pull)
      : super._(gpio, physicalPin) {
    _setGpioInput(bcmGpio, pull.index);
  }

  @override
  bool get value => _readGpio(bcmGpio);

  @override
  Stream<bool> get values {
    if (_valuesController != null)
      throw GpioException(
          'cancel existing values stream before calling values again',
          physicalPin);
    _valuesController = StreamController(onListen: () {
      _poll();
      gpio._startPolling(this);
    }, onCancel: () {
      gpio._stopPolling(this);
      _valuesController = null;
      _lastValue = null;
    });
    return _valuesController.stream;
  }

  void _poll() {
    bool currentValue = value;
    if (_lastValue != currentValue) {
      _lastValue = currentValue;
      _valuesController?.add(currentValue);
    }
  }

  void _setGpioInput(int bcmGpioPin, int pullUpDown) native "setGpioInput";
  bool _readGpio(int bcmGpioPin) native "readGpio";
}

class _RpiGpioCommonOutput extends _RpiGpioCommon {
  _RpiGpioCommonOutput._(RpiGpio gpio, int physicalPin) : super._(gpio, physicalPin) {
    _setGpioOutput(bcmGpio);
  }

  void _setGpioOutput(int bcmGpio) native "setGpioOutput";
  void _writeGpio(int bcmGpioPin, bool newValue) native "writeGpio";
}

class RpiGpioOutput extends _RpiGpioCommonOutput with GpioOutput {
  RpiGpioOutput._(RpiGpio gpio, int physicalPin) : super._(gpio, physicalPin) {
    _setGpioOutput(bcmGpio);
  }

  @override
  set value(bool newValue) {
    if (newValue == null) throw GpioException('Invalid value', physicalPin);
    _writeGpio(bcmGpio, newValue);
  }
}

class RpiGpioPwm extends _RpiGpioCommonOutput with GpioPwm {
  int _dutyCycle = 0;
  Timer _currentTimer;

  RpiGpioPwm._(RpiGpio gpio, int physicalPin) : super._(gpio, physicalPin);

  @override
  void set dutyCycle(int percentOn) {
    if (percentOn <= 0) {
      if (_dutyCycle == 0) return;
      _dutyCycle = 0;
      _writeGpio(bcmGpio, false);
      _currentTimer?.cancel();
      _currentTimer = null;
      return;
    } else if (percentOn >= 100) {
      if (_dutyCycle == 100) return;
      _dutyCycle = 100;
      _writeGpio(bcmGpio, true);
      _currentTimer?.cancel();
      _currentTimer = null;
      return;
    }
    if (_dutyCycle == percentOn) return;
    _dutyCycle = percentOn;
    if (_currentTimer == null) {
      _currentTimer = Timer.periodic(const Duration(microseconds: 100), _pulse);
      _pulse(_currentTimer);
    }
  }

  void _pulse(Timer timer) async {
    _writeGpio(bcmGpio, true);
    int currentTick = timer.tick;
    await Future.delayed(Duration(microseconds: _dutyCycle));
    if (!timer.isActive || timer.tick != currentTick) return;
    _writeGpio(bcmGpio, false);
  }
}
