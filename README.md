# rpi_gpio.dart

[![pub package](https://img.shields.io/pub/v/rpi_gpio.svg)](https://pub.dartlang.org/packages/rpi_gpio)
[![Build Status](https://travis-ci.org/danrubel/rpi_gpio.dart.svg?branch=master)](https://travis-ci.org/danrubel/rpi_gpio.dart)
[![Coverage Status](https://coveralls.io/repos/danrubel/rpi_gpio.dart/badge.svg?branch=master&service=github)](https://coveralls.io/github/danrubel/rpi_gpio.dart?branch=master)

rpi_gpio is a Dart library for accessing the Raspberry Pi GPIO pins.

## Overview

 * [__Gpio__](lib/rpi_gpio.dart) provides a high level API for accessing
   the various General Purpose I/O pins on the Raspberry Pi.
 
 * [__RpiHardware__](lib/rpi_hardware.dart) provides a low level API
   for accessing the GPIO pins.

## Setup

The rpi_gpio library accesses the GPIO pins using a native library written
in C and built on top of the [wiringPi](http://wiringpi.com/) library.
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

 * A [read pins](example/read.dart) example demonstrates reading
   the current value for multiple pins.

 * A second [read pins](example/read_with_mocks.dart) example
   demonstrates mocking the hardware so that the logic can be run
   and tested on platforms other than the Raspberry Pi.

 * A [blinking LED](example/blink.dart) example
   and a [motor driver](example/pwm_motor_sample.dart) example
   demonstrate using the [high level GPIO library](lib/rpi_gpio.dart).
 
 * A second [blinking LED](example/blink_hardware_api.dart)
   demonstrates using the [low level hardware API](lib/rpi_hardware.dart).

 * The value of GPIO pins can be tracked over time
   via [interrupts](example/interrupts.dart)
   or [polling](example/polling.dart).

