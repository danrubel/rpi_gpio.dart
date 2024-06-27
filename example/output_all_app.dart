import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/src/gpio_const.dart';

Future runAllOutput(
    Gpio gpio, bool skipI2c, bool skipSpi, bool skipEeprom, bool skipUart,
    {Duration? blink}) async {
  blink ??= Duration(seconds: 1);

  // Allocate all pins as output
  for (var physicalPin = 1; physicalPin <= 40; ++physicalPin) {
    if (physToBcmGpioRPi2[physicalPin] < 0) continue;
    if (skipI2c && physI2CPins.contains(physicalPin)) continue;
    if (skipSpi && physSpiPins.contains(physicalPin)) continue;
    if (skipEeprom && physEepromPins.contains(physicalPin)) continue;
    if (skipUart && physUartPins.contains(physicalPin)) continue;
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
  var pinOut = pins[physicalPin];
  if (pinOut == null) return;
  pinOut.value = true;
  await Future.delayed(blink);
  pinOut.value = false;
}

final pins = <int, GpioOutput>{};
