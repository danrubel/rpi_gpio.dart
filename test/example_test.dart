import 'dart:async';

import 'package:rpi_gpio/gpio.dart';
import 'package:test/test.dart';

import '../example/exampleApp.dart';

main() {
  const timeout = Duration(milliseconds: 200);
  const ms1 = Duration(milliseconds: 1);
  const ms3 = Duration(milliseconds: 3);

  final gpio = MockGpio();
  Future finished;

  test('start', () async {
    Future<bool> blink = gpio.led.blinkTimes(3 * dutyCycleValues.length).timeout(timeout);
    finished = runExample(gpio, blink: ms1, debounce: 1);
    expect(await blink, isTrue);
    expect(gpio.pwmLed.dutyCycleValue, 100);
    await Future.delayed(ms3);
    expect(gpio.pwmLed.dutyCycleValue, 0);
  });

  test('button', () async {
    Future<bool> blink = gpio.led.blinkTimes(3).timeout(timeout);
    for (int count = 0; count < 3; ++count) {
      gpio.button.value = true;
      await Future.delayed(ms3);
      gpio.button.value = false;
      await Future.delayed(ms3);
    }
    expect(await blink, isTrue);
  });

  test('cleanup', () async {
    await finished;
    expect(gpio.button.subscriptionCanceled, isTrue);
    expect(gpio.disposed, isTrue);
  });
}

class MockGpio extends Gpio {
  final button = MockButton();
  final led = MockLed();
  final pwmLed = MockPwmLed();
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
  }

  @override
  GpioInput input(int physicalPin, [Pull pull = Pull.off]) {
    if (physicalPin == 11) {
      return button;
    }
    throw 'unsupported pin $physicalPin';
  }

  @override
  GpioOutput output(int physicalPin) {
    if (physicalPin == 15) {
      return led;
    }
    throw 'unsupported pin $physicalPin';
  }

  @override
  set pollingFrequency(Duration frequency) {
    throw 'not implemented';
  }

  @override
  GpioPwm pwm(int physicalPin) {
    if (physicalPin == 12) {
      return pwmLed;
    }
    throw 'unsupported pin $physicalPin';
  }
}

class MockButton extends GpioInput {
  bool _value = false;
  StreamController<bool> _valuesController;
  bool subscriptionCanceled = false;

  @override
  bool get value => _value;

  set value(bool newValue) {
    if (_value != newValue) {
      _value = newValue;
      _valuesController?.add(newValue);
    }
  }

  @override
  Stream<bool> get values {
    if (_valuesController != null) throw 'invalid call';
    _valuesController = StreamController(onListen: () {
      _valuesController.add(_value);
    }, onCancel: () {
      _valuesController = null;
      subscriptionCanceled = true;
    });
    return _valuesController.stream;
  }
}

class MockLed extends GpioOutput {
  bool _value;
  int blinkCount;
  Completer<bool> blinkCompleter;

  @override
  set value(bool newValue) {
    if (blinkCount != null && _value == true && !newValue) {
      if (--blinkCount == 0) {
        blinkCount = null;
        blinkCompleter.complete(true);
      }
    }
    _value = newValue;
  }

  Future<bool> blinkTimes(int count) {
    if (blinkCount != null) throw 'already waiting for blink';
    blinkCount = count;
    blinkCompleter = Completer<bool>();
    return blinkCompleter.future;
  }
}

class MockPwmLed extends GpioPwm {
  int dutyCycleValue;

  @override
  void set dutyCycle(int percentOn) {
    dutyCycleValue = percentOn;
  }
}
