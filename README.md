# rpi_gpio.dart

[![pub package](https://img.shields.io/pub/v/rpi_gpio.svg)](https://pub.dartlang.org/packages/rpi_gpio)

rpi_gpio is a Dart package for accessing the Raspberry Pi GPIO pins.

## Overview

 * The [__Gpio__](lib/gpio.dart) library provides the API
   for accessing the various General Purpose I/O pins on the Raspberry Pi.

 * [__RpiGpio__](lib/rpi_gpio.dart) provides the implementation
   for the __Gpio__ API derived from the WiringPi library.

## Setup

**Installing `libgpiod`** (should already be installed)

[__RpiGpio__](lib/rpi_gpio.dart) accesses the GPIO pins using the native `libgpiod.so.2` library.
If you are running the latest Raspberry Pi OS (formerly Raspbian),
then this library should already be installed by default on your Raspberry Pi.
If you are unsure, see #2 below in the troubleshooting section.
If it is not already installed, open a terminal and run
```
sudo apt update
sudo apt install libgpiod2
```

## Example

The [example](example/example.dart) launches the [example app](example/example_app.dart)
to demonstrate:

 * Blinking an LED along with software based PWM on a second LED.

 * Responding to a button press by turning on an LED.

The example is structured such that the [example test](test/example_test.dart)
can inject a mock gpio to facilitate testing and allow test execution on platforms
other than the Raspberry Pi.

## Testing

Latest Raspberry Pi OS (2024-05-29)

| Raspberry Pi Hardware | Dart version |
| --- | --- |
| Pi 5 Model B Rev 1.0 | 3.3.4 (stable) (Tue Apr 16 19:56:12 2024 +0000) on "linux_arm64" |
| Pi 3 Model B Rev 1.2 | 3.3.4 (stable) (Tue Apr 16 19:56:12 2024 +0000) on "linux_arm64" |
| Pi 2 Model B Rev 1.1 | 3.3.4 - 32 bit |

## Troubleshooting

1) Run `test/src/native/show_hardware_and_os.dart` and record the output

2) Run `test/src/native/show_lib_version.dart` to see if the `libgpiod.so.2` library can be located

3) If running `test/src/native/blink_led.dart` crashes then there may be a 32 bit / 64 bit mismatch. Check that the board, the OS, and the Dart SDK are all either 32 bit or 64 bit.

4) If running `test/src/native/blink_led.dart` doesn't crash, but doesn't blink the LED
(where the LED and resistor are connected in series to GPIO 17 (pin 11) and ground) then
```
sudo apt-get install libgpiod-dev
gpioinfo
```
and and check to see that the `gpiochip#` listing all of the `GPIO#`
(for example "gpiochip4" below)
```
$ gpioinfo
gpiochip0 - 32 lines:
  ...
gpiochip4 - 54 lines:
	line   0:     "ID_SDA"       unused   input  active-high
	line   1:     "ID_SCL"       unused   input  active-high
	line   2:      "GPIO2"       unused   input  active-high
	line   3:      "GPIO3"       unused   input  active-high
	line   4:      "GPIO4"       unused   input  active-high
  ...
```
matches the `Gpio Chip` information in #1 above.
(for example "gpiochip4" below)
```
$ dart test/src/native/show_hardware_and_os.dart
CPU          : aarch64
  ...
Is Rpi 5     : true
Gpio Chip    : gpiochip4

```
