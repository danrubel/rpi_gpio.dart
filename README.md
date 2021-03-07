# rpi_gpio.dart

[![pub package](https://img.shields.io/pub/v/rpi_gpio.svg)](https://pub.dartlang.org/packages/rpi_gpio)

rpi_gpio is a Dart package for accessing the Raspberry Pi GPIO pins.

## Overview

 * The [__Gpio__](lib/gpio.dart) library provides the API
   for accessing the various General Purpose I/O pins on the Raspberry Pi.

 * [__RpiGpio__](lib/rpi_gpio.dart) provides the implementation
   for the __Gpio__ API derived from the [WiringPi](http://wiringpi.com/) library.

## Setup

[__RpiGpio__](lib/rpi_gpio.dart) accesses the GPIO pins using a native library written in C.
For security reasons, authors cannot publish binary content
to [pub.dartlang.org](https://pub.dartlang.org/), so there are some extra
steps necessary to compile the native library on the RPi before this package
can be used. These two steps must be performed when you install and each time
you upgrade the rpi_gpio package.

1) Activate the rpi_gpio package using the
[pub global](https://www.dartlang.org/tools/pub/cmd/pub-global.html) command.
```
    pub global activate rpi_gpio
```

2) From your application directory (the application that references
the rpi_gpio package) run the following command to build the native library
```
    pub global run rpi_gpio:build_lib
```

[pub global activate](https://www.dartlang.org/tools/pub/cmd/pub-global.html#activating-a-package)
makes the Dart scripts in the rpi_gpio/bin directory runnable
from the command line.
[pub global run](https://www.dartlang.org/tools/pub/cmd/pub-global.html#running-a-script)
rpi_gpio:build_lib runs the [rpi_gpio/bin/build_lib.dart](bin/build_lib.dart)
program which in turn calls the [build_lib](lib/src/native/build_lib) script
to compile the native librpi_gpio_ext.so library for the rpi_gpio package.

## Example

The [example](example/example.dart) launches the [example app](example/exampleApp.dart)
to demonstrate:

 * Blinking an LED along with software based PWM on a second LED.

 * Responding to a button press by turning on an LED.

The example is structured such that the [example test](test/example_test.dart)
can inject a mock gpio to facilitate testing and allow test execution on platforms
other than the Raspberry Pi.
