import 'dart:async';

import 'package:rpi_gpio/gpio.dart';

/// To test your application, have your test method pass in an instance
/// of your own [MockGpio] that extends [Gpio].
main() async {
  runApp(new MockGpio());
}

void runApp(Gpio gpio) {
  final inputs = <int, GpioInput>{};

  const [3, 5, 7, 11, 12, 13].forEach((int physicalPin) {
    inputs[physicalPin] = gpio.input(physicalPin);
  });

  inputs.forEach((int physicalPin, GpioInput input) {
    print('pin $physicalPin = ${input.value}');
  });
}

class MockGpio extends Gpio {
  @override
  GpioInput input(int physicalPin, [Pull pull = Pull.off]) {
    allocatePin(physicalPin);
    return new MockGpioInput(physicalPin.isEven);
  }

  @override
  GpioOutput output(int physicalPin) {
    throw 'not implemented';
  }

  @override
  set pollingFrequency(Duration frequency) {
    throw 'not implemented';
  }

  @override
  GpioPwmOutput pwmOutput(int physicalPin) {
    throw 'not implemented';
  }
}

class MockGpioInput implements GpioInput {
  bool value;

  MockGpioInput(this.value);

  @override
  Stream<bool> get values => throw 'not implemented';
}
