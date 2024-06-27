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

  // This assumes button connected to GPIO 27 (pin 13)
  // connects to GND when pressed and is open/disconnected when released.
  // The internal bias resistor pulls up the line when the button is released.
  var inputGpio = 27;
  var inputLine = gpioLib.gpiodChipGetLine(chip, inputGpio);
  if (inputLine == nullptr) throw Exception('Failed to get input line');
  print('Got input line');

  var inputName = 'read_button'.toNativeUtf8();
  result = gpioLib.gpiodLineRequestInputFlags(
      inputLine, inputName, gpio.lineRequestBiasPullUp);
  if (result != 0) throw Exception('Request input failed');
  print('Request input with internal pull-up');

  print('Waiting for GPIO $inputGpio button press');

  var stopwatch = Stopwatch()..start();
  var count = 0;
  // Input is high / VCC / one by default
  var lastResult = 1;
  while (count < 5 && stopwatch.elapsedMilliseconds < 5000) {
    result = gpioLib.gpiodLineGetValue(inputLine);
    if (result < 0) throw Exception('Failed to read input');

    if (result != lastResult) {
      lastResult = result;
      if (result == 0) {
        // Input goes low / GND / zero when button is pressed
        print('Button pressed');
        result = gpioLib.gpiodLineSetValue(outputLine, 1);
      } else {
        // Input goes high / VCC / one when button is pressed
        print('Button released');
        result = gpioLib.gpiodLineSetValue(outputLine, 0);
        count++;
      }
      if (result != 0) throw Exception('Failed to set output');
    }
  }
  print('$count button presses');

  result = gpioLib.gpiodLineSetValue(outputLine, 0);
  if (result != 0) throw Exception('Failed to set output');

  gpioLib.gpiodLineRelease(inputLine);
  print('Released input line');

  gpioLib.gpiodLineRelease(outputLine);
  print('Released output line');

  gpioLib.gpiodChipClose(chip);
  print('Closed GPIO chip');

  malloc.free(inputName);
  malloc.free(outputName);
  malloc.free(chipName);
  gpioLib.close();

  print('Success');
}
