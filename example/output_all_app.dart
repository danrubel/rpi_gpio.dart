import 'package:rpi_gpio/gpio.dart';

Future runAllOutput(Gpio gpio, {Duration? blink}) async {
  blink ??= Duration(seconds: 1);

  // Allocate all pins as output
  for (var physicalPin = 1; physicalPin <= 40; ++physicalPin) {
    if (nonOutputPins.contains(physicalPin)) continue;
    pins[physicalPin] = gpio.output(physicalPin)..value = false;
  }

  // Blink the odd numbered pins
  for (var physicalPin = 1; physicalPin < 40; physicalPin += 2) {
    await blinkLed(physicalPin, gpio, blink);
  }

  // Blink the even numbered pins
  for (var physicalPin = 40; physicalPin > 0; physicalPin -= 2) {
    await blinkLed(physicalPin, gpio, blink);
  }
  await gpio.dispose();
  print('Complete');
}

Future<void> blinkLed(int physicalPin, Gpio gpio, Duration blink) async {
  if (nonOutputPins.contains(physicalPin)) return;
  var pinOut = pins[physicalPin]!;
  pinOut.value = true;
  await Future.delayed(blink);
  pinOut.value = false;
}

final pins = <int, GpioOutput>{};

var nonOutputPins = {
  1, // 3.3V
  2, // 5V
  4, // 5V
  6, // GND
  9, // GND
  14, // GND
  17, // 3.3V
  20, // GND
  25, // GND
  27, // Reserved
  28, // Reserved
  30, // GND
  34, // GND
  39, // GND
};
