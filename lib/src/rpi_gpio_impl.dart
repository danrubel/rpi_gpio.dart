import 'dart:async';
import 'dart:isolate';

import 'package:rpi_gpio/gpio.dart';

import 'package:rpi_gpio/src/gpio_const.dart';
import 'package:rpi_gpio/src/rpi_gpio_comm.dart' as comm;

/// GPIO interface used for accessing GPIO on the Raspberry Pi.
class RpiGpio extends Gpio {
  static bool _instantiatedGpio = false;

  late SendPort _sendPort;
  late StreamSubscription _receivePortSubscription;
  late StreamSubscription _onErrorSubscription;
  final Completer<GpioException>? _onError;
  late _RpiGpioResponseHandler _rspHandler;

  /// Instantiate a new GPIO manager.
  /// Clients should use [initialize_RpiGpio].
  static Future<RpiGpio> init({
    bool i2c = true,
    bool spi = true,
    bool eeprom = true,
    bool uart = true,
    Completer<GpioException>? onError,
    required Function(SendPort sendPort) isolateEntryPoint,
    SendPort? testSendPort,
  }) async {
    if (_instantiatedGpio) throw GpioException('RpiGpio already instantiated');
    _instantiatedGpio = true;

    const timeout = Duration(seconds: 30);
    final rpiGpio =
        RpiGpio._(onError, i2c: i2c, spi: spi, eeprom: eeprom, uart: uart);
    final receivePort = ReceivePort();
    final onErrorPort = ReceivePort();

    final rspHandler = _RpiGpioResponseHandler(rpiGpio);
    var receivePortSubscription = receivePort.listen((data) {
      comm.dispatchRsp(data, rspHandler);
    });
    var onErrorSubscription = onErrorPort.listen(rspHandler.onError);

    await Isolate.spawn(isolateEntryPoint, receivePort.sendPort,
        onError: onErrorPort.sendPort);
    try {
      await rspHandler.initCompleter.future.timeout(timeout);
      if (testSendPort != null) {
        rpiGpio._sendPort.send(comm.testCmd(testSendPort));
      }
    } on TimeoutException {
      await receivePortSubscription.cancel();
      await onErrorSubscription.cancel();
      throw GpioException('init timeout');
    } catch (error) {
      await receivePortSubscription.cancel();
      await onErrorSubscription.cancel();
      rethrow;
    }

    return rpiGpio
      .._receivePortSubscription = receivePortSubscription
      .._onErrorSubscription = onErrorSubscription
      .._rspHandler = rspHandler;
  }

  RpiGpio._(
    this._onError, {
    required bool i2c,
    required bool spi,
    required bool eeprom,
    required bool uart,
  }) {
    if (i2c) physI2CPins.forEach(allocatePin);
    if (spi) physSpiPins.forEach(allocatePin);
    if (eeprom) physEepromPins.forEach(allocatePin);
    if (uart) physUartPins.forEach(allocatePin);
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
  Future dispose() async {
    const timeout = Duration(seconds: 30);
    _sendPort.send(comm.disposeCmd());
    _rspHandler.disposeCompleter = Completer();
    await _rspHandler.disposeCompleter!.future.timeout(timeout, onTimeout: () {
      throw GpioException('dispose timeout');
    });
    await _cleanup();
  }

  void _handleIsolateError(GpioException error) async {
    await _cleanup();
    if (_onError == null) throw error;
    _onError!.completeError(error);
  }

  Future _cleanup() async {
    await _receivePortSubscription.cancel();
    await _onErrorSubscription.cancel();
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
    _sendPort.send(comm.setPollingFrequencyCmd(frequency));
  }

  /// For testing purposes only
  void testCmd(data) {
    _sendPort.send(comm.testCmd(data));
  }
}

class _RpiGpioResponseHandler implements comm.ResponseHandler {
  final RpiGpio rpiGpio;
  final initCompleter = Completer();
  final valueCompleters = <Completer<bool>>[];
  final pollingMap = <int, RpiGpioInput>{};
  Completer? disposeCompleter;

  _RpiGpioResponseHandler(this.rpiGpio);

  @override
  void initCompleteRsp(SendPort sendPort) {
    rpiGpio._sendPort = sendPort;
    initCompleter.complete(true);
  }

  @override
  void readRsp(bool newValue) {
    if (valueCompleters.isEmpty) throw GpioException('Unexpected readRsp');
    valueCompleters.removeAt(0).complete(newValue);
  }

  @override
  void polledValueRsp(int bcmGpioPin, bool currentValue) {
    pollingMap[bcmGpioPin]?._valuesController?.add(currentValue);
  }

  @override
  void disposeCompleteRsp() {
    disposeCompleter!.complete();
  }

  @override
  void setInputRsp(int result) {
    // print('setInputRsp response: $result');
  }

  @override
  void unknownRsp(data) {
    print('RpiGpio unknown response: $data');
  }

  /// Handle an error from the isolate
  void onError(message) {
    if (message is List && message.length == 2) {
      message = 'Isolate Exception: ${message[0]}\n${message[1]}\nMain Thread:';
    }
    var error = GpioException('$message');
    if (!initCompleter.isCompleted) {
      initCompleter.completeError(error);
    } else if (disposeCompleter?.isCompleted == false) {
      disposeCompleter!.completeError(error);
    } else {
      rpiGpio._handleIsolateError(error);
    }
  }
}

class _RpiGpioCommon {
  final RpiGpio gpio;
  final int physicalPin;
  final int bcmGpioPin;

  _RpiGpioCommon._(this.gpio, this.physicalPin)
      : bcmGpioPin = physToBcmGpioRPi2[physicalPin];
}

class RpiGpioInput extends _RpiGpioCommon with GpioInput {
  final Pull pull;

  StreamController<bool>? _valuesController;

  RpiGpioInput._(RpiGpio gpio, int physicalPin, this.pull)
      : super._(gpio, physicalPin) {
    gpio._sendPort.send(comm.setInputCmd(bcmGpioPin, pull));
  }

  @override
  Future<bool> get value {
    final completer = Completer<bool>();
    gpio._rspHandler.valueCompleters.add(completer);
    gpio._sendPort.send(comm.readCmd(bcmGpioPin));
    return completer.future;
  }

  @override
  Stream<bool> get allValues {
    if (_valuesController != null) {
      throw GpioException(
          'cancel existing values or allValues stream'
          ' before calling values or allValues again',
          physicalPin);
    }
    _valuesController = StreamController(onListen: () {
      gpio._rspHandler.pollingMap[bcmGpioPin] = this;
      gpio._sendPort.send(comm.startPollingCmd(bcmGpioPin));
    }, onCancel: () {
      gpio._sendPort.send(comm.stopPollingCmd(bcmGpioPin));
      gpio._rspHandler.pollingMap.remove(bcmGpioPin);
      _valuesController = null;
    });
    return _valuesController!.stream;
  }
}

class _RpiGpioCommonOutput extends _RpiGpioCommon {
  _RpiGpioCommonOutput._(RpiGpio gpio, int physicalPin)
      : super._(gpio, physicalPin) {
    gpio._sendPort.send(comm.setOutputCmd(bcmGpioPin));
  }
}

class RpiGpioOutput extends _RpiGpioCommonOutput with GpioOutput {
  RpiGpioOutput._(super.gpio, super.physicalPin) : super._();

  @override
  set value(bool newValue) {
    gpio._sendPort.send(comm.writeCmd(bcmGpioPin, newValue));
  }
}

class RpiGpioPwm extends _RpiGpioCommonOutput with GpioPwm {
  RpiGpioPwm._(super.gpio, super.physicalPin) : super._();

  @override
  set dutyCycle(int percentOn) {
    if (percentOn >= 100) {
      gpio._sendPort.send(comm.writeCmd(bcmGpioPin, true));
    } else if (percentOn > 0) {
      gpio._sendPort.send(comm.setPwmCmd(bcmGpioPin, percentOn));
    } else {
      gpio._sendPort.send(comm.writeCmd(bcmGpioPin, false));
    }
  }
}
