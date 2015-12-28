# Changelog

## 0.3.0
 * BREAKING CHANGES to match the [fletch gpio package](https://github.com/dart-lang/fletch/blob/master/pkg/gpio/lib/gpio.dart)
 * Renamed PinMode to Mode
 * Renamed GpioException GPIOException
 * Add Pin.physNum
 * Add Mode.other to match fletch gpio package
 * Removed Mode.pulsed in favor of Mode.output and pulseWidth
 * Removed pwm support for pins other than pin 1
 * Removed top level input, output, pulsed const
 * Removed Gpio.pin method in favor of top level pin function
 * Move classes similar to fletch gpio package into gpio.dart library

## 0.2.2

 * Update wiringPi native code for Pi v2
 * Add top level pin function and deprecated Gpio.pin method
 * Add gpioNum method to return GPIO number for pin
 * Rework isRaspberryPi to check /etc/os-release
 * Rework and simplify [examples](example)

## 0.2.1

 * Fix bug to track both rising and falling interrupt edge
 * Fix bug that prevented application from completing normally when interrupts were used
 * Switch tests to use package:test rather than package:unittest
 * Fix [read](example/read.dart), [polling](example/polling.dart), and [interrupts](example/interrupts.dart) examples
   to wait for rpi.loadLibrary() before proceeding.

## 0.2.0

 * Support for interrupts via Pin.events
 * Rename pin to pinNum
 * Improve build native library script
 * Rename repo to danrubel/rpi_gpio.dart

## 0.1.0

 * Read and write digital values
 * Hardware pulse width modulation on pin 1
 * Software simulated pwm for other pins (work in progress)
