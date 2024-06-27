import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:rpi_gpio/src/native/gpiod_ext.dart' as gpio;
import 'package:rpi_gpio/src/native/rpi_platform.dart';

void main() async {
  var gpioLib = gpio.nativePkgLib;
  print('Loaded GPIO library');

  // See https://www.ics.com/blog/gpio-programming-exploring-libgpiod-library
  // and https://github.com/starnight/libgpiod-example/blob/master/libgpiod-led/main.c

  // Install dev tools
  // sudo apt-get install libgpiod-dev

  // Get GPIO chip path by opening a terminal and running:
  // gpiodetect
  // gpioinfo

  final chipName = RpiPlatform.current.gpioChipName.toNativeUtf8();
  var chip = gpioLib.gpiodChipOpenByName(chipName);
  if (chip == nullptr) throw Exception('Failed to open GPIO chip');
  print('Opened GPIO chip');

  // This assumes an LED and resistor are connected in series to GPIO 17 (pin 11) and GND
  var outputGpio = 17;
  var outputLine = gpioLib.gpiodChipGetLine(chip, outputGpio);
  if (outputLine == nullptr) throw Exception('Failed to get output line');
  print('Got output line');

  var outputName = 'blink_led'.toNativeUtf8();
  var result = gpioLib.gpiodLineRequestOutput(outputLine, outputName, 0);
  if (result != 0) throw Exception('Request output failed');
  print('Request output');

  for (var count = 0; count < 5; count++) {
    await Future.delayed(const Duration(milliseconds: 500));

    result = gpioLib.gpiodLineSetValue(outputLine, 1);
    if (result != 0) throw Exception('Failed to turn on');
    print('Turn on');

    await Future.delayed(const Duration(milliseconds: 500));

    result = gpioLib.gpiodLineSetValue(outputLine, 0);
    if (result != 0) throw Exception('Failed to turn off');
    print('Turn off');
  }

  gpioLib.gpiodLineRelease(outputLine);
  print('Released output line');

  gpioLib.gpiodChipClose(chip);
  print('Closed GPIO chip');

  malloc.free(outputName);
  malloc.free(chipName);
  gpioLib.close();

  print('Success');
}
