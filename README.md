# rpi_gpio.dart

[![pub package](https://img.shields.io/pub/v/rpi_gpio.svg)](https://pub.dartlang.org/packages/rpi_gpio)
[![Build Status](https://travis-ci.org/danrubel/rpi_gpio.dart.svg?branch=master)](https://travis-ci.org/danrubel/rpi_gpio.dart)
[![Coverage Status](https://coveralls.io/repos/danrubel/rpi_gpio.dart/badge.svg?branch=master&service=github)](https://coveralls.io/github/danrubel/rpi_gpio.dart?branch=master)

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

## Examples

 * A [blinking LED](example/blink.dart) example demonstrates GPIO output
   by flashing an LED.

 * A [read](example/read.dart) example demonstrates GPIO input
   by reading the current value for multiple pins.

 * A second [read](example/read_with_mocks.dart) example
   demonstrates mocking the hardware so that the logic can be run and tested
   on platforms other than the Raspberry Pi.

 * A [button](example/button.dart) example demonstrates reacting to GPIO input
   by turning on an LED whenever a button is pressed.
