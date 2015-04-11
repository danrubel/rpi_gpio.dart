library rpi.hardware.isolate;

import 'dart:async';
import 'dart:isolate';

import 'package:rpi_gpio/rpi_gpio.dart';

/// The function used to spawn the GpioServer
typedef GpioServerSpawnFunction(SendPort sendPort);

/// [GpioClient] fowards all hardware interaction [GpioServer]
/// which interacts with the Raspberry Pi hardware directly.
/// The isolate can then simulate pulse width modulation for pins which
/// do not have hardware based PWM.
class GpioClient implements GpioHardware {
  SendPort _sendPort;
  ReceivePort _receivePort;
  Completer _initCompleter;

  /// A sparse map of pin number to digital value
  Map<int, int> _pinValues = <int, int>{};

  @override
  int digitalRead(int pin) {
    return _pinValues[pin];
  }

  @override
  void digitalWrite(int pin, int value) {
    _sendPort.send(new _GpioRequestDigitalWrite(pin, value));
  }

  @override
  void pinMode(int pin, int mode) {
    if (mode != input.index) _pinValues.remove(pin);
    _sendPort.send(new _GpioRequestPinMode(pin, mode));
  }

  @override
  void pullUpDnControl(int pin, int pud) {
    _sendPort.send(new _GpioRequestPullUpDnControl(pin, pud));
  }

  @override
  void pwmWrite(int pin, int pulseWidth) {
    _sendPort.send(new _GpioRequestPwmWrite(pin, pulseWidth));
  }

  /// Spawn and manage an isolate for interacting with the hardware
  /// using the specified [spawnFunction].
  /// The future completes when the hardware can be accessed.
  Future spawn(GpioServerSpawnFunction spawnFunction) async {
    if (_receivePort != null) throw 'already running';
    _receivePort = new ReceivePort();
    await Isolate.spawn(spawnFunction, _receivePort.sendPort);
    _initCompleter = new Completer();
    _receivePort.listen((_GpioNotification n) => n.perform(this));
    return _initCompleter.future;
  }

  /// Stop the background isolate
  void stop() {
    if (_receivePort != null) {
      _receivePort.close();
      _receivePort = null;
      _sendPort = null;
    }
  }

  /// Complete initialization via a notification from the server.
  void _init(SendPort sendPort) {
    this._sendPort = sendPort;
    this._initCompleter.complete();
  }

  /// Update the current pin value via a notification from the server.
  void _updateValue(int pin, int value) {
    _pinValues[pin] = value;
  }
}

/// [GpioServer] responds to requests from [GpioClient]
/// and interacts with the Raspberry Pi hardware directly.
class GpioServer {
  final GpioHardware hardware;
  final SendPort _sendPort;
  ReceivePort _receivePort;

  /// A sparse map of pin number to digital value
  Map<int, int> _pinValues = <int, int>{};

  /// 64 ms software simulated pulse cycle time
  static const int _pulseCycleTime = 64;

  /// A sparse map of pin number to pulse width in milliseconds
  /// where a value of 0 - 1024 maps to 0 - 64 milliseconds
  Map<int, int> _pulseWidths = <int, int>{};

  /// Instantiate a new instance to processes requests
  /// and interact directly with the given [hardware].
  GpioServer(this.hardware, this._sendPort);

  /// Connect and start processing requests from [GpioClient].
  void run() {
    // Send a communication port to the client
    if (_receivePort != null) throw 'already running';
    _receivePort = new ReceivePort();
    _receivePort.listen((_GpioRequest r) => r.perform(this));
    _sendPort.send(new _GpioNotificationInit(_receivePort.sendPort));
    new Timer.periodic(new Duration(milliseconds: 3), _update);
  }

  /// Enable or disable polling for the given pin
  void _setInputPolling(int pin, bool watchPin) {
    if (watchPin) {
      _valueChanged(pin, hardware.digitalRead(pin));
    } else {
      _pinValues.remove(pin);
    }
  }

  /// Called periodically to simulate pulse width modulation on pins
  /// without hardware PWM support and to poll inputs.
  void _update(Timer timer) {
    int cycleTime = new DateTime.now().millisecondsSinceEpoch % _pulseCycleTime;
    _pulseWidths.forEach((pin, pulseWidth) {
      hardware.digitalWrite(pin, cycleTime <= pulseWidth ? 1 : 0);
    });
    _pinValues.forEach((pin, oldValue) {
      var newValue = hardware.digitalRead(pin);
      if (newValue != oldValue) _valueChanged(pin, newValue);
    });
  }

  /// Record the current value for the given pin
  /// and send a notification to the client indicating the change.
  void _valueChanged(int pin, int value) {
    _pinValues[pin] = value;
    _sendPort.send(new _GpioNotificationUpdateValue(pin, value));
  }

  /// Enable software simulated pulse width modulation for the given pin.
  void _setPulsed(int pin, bool enabled) {
    if (enabled) {
      _pulseWidths[pin] = 0;
    } else {
      _pulseWidths.remove(pin);
    }
  }

  /// Set the pulse width for the given pin.
  void _setPulseWidth(int pin, int pulseWidth) {
    // Ignore request if not in pulsed mode
    if (_pulseWidths[pin] != null) {
      _pulseWidths[pin] = pulseWidth.clamp(0, 1024) * _pulseCycleTime ~/ 1024;
    }
  }
}

/// A message passed from [GpioServer] to [GpioClient].
/// Subclasses implement [perform] to update the client
abstract class _GpioNotification {
  void perform(GpioClient client);
}

class _GpioNotificationInit implements _GpioNotification {
  final SendPort sendPort;
  _GpioNotificationInit(this.sendPort);

  @override
  void perform(GpioClient client) {
    client._init(sendPort);
  }
}

class _GpioNotificationUpdateValue implements _GpioNotification {
  final int pin;
  final int value;
  _GpioNotificationUpdateValue(this.pin, this.value);

  @override
  void perform(GpioClient client) {
    client._updateValue(pin, value);
  }
}

/// A message passed from [GpioClient] to [GpioServer].
/// Subclasses implement [perform] to carry out the request.
abstract class _GpioRequest {
  void perform(GpioServer server);
}

class _GpioRequestDigitalWrite implements _GpioRequest {
  final int pin;
  final int value;
  _GpioRequestDigitalWrite(this.pin, this.value);

  @override
  void perform(GpioServer server) {
    server.hardware.digitalWrite(pin, value);
  }
}

class _GpioRequestPinMode implements _GpioRequest {
  final int pin;
  final int mode;
  _GpioRequestPinMode(this.pin, this.mode);

  @override
  void perform(GpioServer server) {
    if (mode == pulsed.index && pin != 1) {
      // Simulate pwm on pins other than pin 1
      server.hardware.pinMode(pin, output.index);
      server._setInputPolling(pin, false);
      server._setPulsed(pin, true);
    } else {
      server.hardware.pinMode(pin, mode);
      server._setInputPolling(pin, mode == input.index);
      server._setPulsed(pin, false);
    }
  }
}

class _GpioRequestPullUpDnControl implements _GpioRequest {
  final int pin;
  final int pud;
  _GpioRequestPullUpDnControl(this.pin, this.pud);

  @override
  void perform(GpioServer server) {
    server.hardware.pullUpDnControl(pin, pud);
  }
}

class _GpioRequestPwmWrite implements _GpioRequest {
  final int pin;
  final int pulseWidth;
  _GpioRequestPwmWrite(this.pin, this.pulseWidth);

  @override
  void perform(GpioServer server) {
    if (pin != 1) {
      // Simulate pwm on pins other than pin 1
      server._setPulseWidth(pin, pulseWidth);
    } else {
      server.hardware.pwmWrite(pin, pulseWidth);
    }
  }
}
