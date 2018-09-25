import 'dart:async';

import 'package:rpi_gpio/gpio.dart';
import 'package:test/test.dart';

import '../example/exampleApp.dart';

main() {
  const timeout = const Duration(milliseconds: 100);
  const ms1 = const Duration(milliseconds: 1);
  const ms3 = const Duration(milliseconds: 3);

  final gpio = new MockGpio();
  Future finished;

  test('start', () async {
    Future<bool> blink = gpio.led.blinkTimes(3).timeout(timeout);
    finished = runExample(gpio, blink: ms1, debounce: 1);
    expect(await blink, isTrue);
  });

  test('button', () async {
    Future<bool> blink = gpio.led.blinkTimes(3).timeout(timeout);
    for (int count = 0; count < 3; ++count) {
      gpio.button.value = true;
      await new Future.delayed(ms3);
      gpio.button.value = false;
      await new Future.delayed(ms3);
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
  final button = new MockButton();
  final led = new MockLed();
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
    if (physicalPin == 12) {
      return led;
    }
    throw 'unsupported pin $physicalPin';
  }

  @override
  set pollingFrequency(Duration frequency) {
    throw 'not implemented';
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
    _valuesController = new StreamController(onListen: () {
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
    blinkCompleter = new Completer<bool>();
    return blinkCompleter.future;
  }
}
