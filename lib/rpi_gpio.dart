import 'dart:async';

import 'package:rpi_gpio/gpio.dart';

import 'dart-ext:rpi_gpio_ext';
import 'package:rpi_gpio/src/gpio_const.dart';

/// GPIO interface used for accessing GPIO on the Raspberry Pi.
class RpiGpio extends Gpio {
  static bool _instantiatedGpio = false;

  final _polledInputs = <RpiGpioInput>[];
  Duration _pollingFrequency = new Duration(milliseconds: 10);
  Timer _pollingTimer;

  RpiGpio() {
    if (_instantiatedGpio)
      throw new GpioException('RpiGpio already instantiated');
    _instantiatedGpio = true;
    int result = _setupGpio();
    if (result != 0)
      throw new GpioException('RpiGpio initialization failed: $result');
  }

  @override
  GpioInput input(int physicalPin, [Pull pull = Pull.off]) {
    allocatePin(physicalPin);
    return new RpiGpioInput._(this, physicalPin, pull);
  }

  @override
  GpioOutput output(int physicalPin) {
    allocatePin(physicalPin);
    return new RpiGpioOutput._(physicalPin);
  }

  @override
  set pollingFrequency(Duration frequency) {
    if (_pollingFrequency != frequency) {
      _pollingFrequency = frequency;
      _stopPollingTimer();
      _startPollingTimer();
    }
  }

  @override
  GpioPwmOutput pwmOutput(int physicalPin) {
    allocatePwmPin(physicalPin);
    return new RpiGpioPwmOutput._(physicalPin);
  }

  void _startPolling(RpiGpioInput input) {
    _polledInputs.add(input);
    _startPollingTimer();
  }

  void _startPollingTimer() {
    if (_polledInputs.isNotEmpty && _pollingFrequency != null) {
      _pollingTimer ??= new Timer.periodic(_pollingFrequency, _pollInputs);
    }
  }

  void _pollInputs(_) {
    final polledInputs = new List<RpiGpioInput>.from(_polledInputs);
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
}

class RpiGpioInput extends GpioInput {
  final RpiGpio gpio;
  final int physicalPin;
  final int bcmGpio;
  final Pull pull;

  StreamController<bool> _valuesController;
  bool _lastValue;

  RpiGpioInput._(this.gpio, this.physicalPin, this.pull)
      : bcmGpio = physToBcmGpioRPi2[physicalPin] {
    _setGpioInput(bcmGpio, pull.index);
  }

  @override
  bool get value => _readGpio(bcmGpio);

  @override
  Stream<bool> get values {
    if (_valuesController != null)
      throw new GpioException(
          'cancel existing values stream before calling values again',
          physicalPin);
    _valuesController = new StreamController(onListen: () {
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
      _valuesController.add(currentValue);
    }
  }

  void _setGpioInput(int bcmGpioPin, int pullUpDown) native "setGpioInput";
  bool _readGpio(int bcmGpioPin) native "readGpio";
}

class RpiGpioOutput extends GpioOutput {
  final int physicalPin;
  final int bcmGpio;

  RpiGpioOutput._(this.physicalPin) : bcmGpio = physToBcmGpioRPi2[physicalPin] {
    _setGpioOutput(bcmGpio);
  }

  @override
  set value(bool newValue) {
    if (newValue == null) throw new GpioException('Invalid value', physicalPin);
    _writeGpio(bcmGpio, newValue);
  }

  void _setGpioOutput(int bcmGpio) native "setGpioOutput";
  void _writeGpio(int bcmGpioPin, bool newValue) native "writeGpio";
}

class RpiGpioPwmOutput extends GpioPwmOutput {
  final int physicalPin;
  final int bcmGpio;

  RpiGpioPwmOutput._(this.physicalPin)
      : bcmGpio = physToBcmGpioRPi2[physicalPin] {
    _setGpioPwmOutput(bcmGpio);
  }

  @override
  set pwmValue(int newValue) {
    if (newValue == null || newValue < 0 || 1024 < newValue)
      throw new GpioException('Invalid value $newValue', physicalPin);
    _writePwmGpio(bcmGpio, newValue);
  }

  @override
  set value(bool newValue) {
    if (newValue == null) throw new GpioException('Invalid value', physicalPin);
    _writePwmGpio(bcmGpio, newValue ? 1024 : 0);
  }

  void _setGpioPwmOutput(int bcmGpio) native "setGpioPwmOutput";
  void _writePwmGpio(int bcmGpio, int newValue) native "writePwmGpio";
}
