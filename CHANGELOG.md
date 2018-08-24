# Changelog

## 0.4.0
 * BREAKING CHANGES rework and simplify API
 * Upgrade for pre-2.0 and fix analyzer issues
 * Format dart code using dartfmt

## 0.3.0
 * BREAKING CHANGES so that the rpi_gpio package much more closely matches
    [fletch gpio package](https://github.com/dart-lang/fletch/blob/master/pkg/gpio/lib/gpio.dart)
 * Removed GpioHardware.pinMode         in favor of GPIO.setMode
 * Removed GpioHardware.digitalRead     in favor of GPIO.getPin
 * Removed GpioHardware.digitalWrite    in favor of GPIO.setPin
 * Removed Mode.pulsed                  in favor of Mode.output and pulseWidth
 * Removed GpioHardware.enableInterrupt in favor of RpiGPIO.setTrigger
 * Removed PWM (Pulse Width Modulation) support for pins other than pin 1
 * Removed top level input, output, pulsed const
 * Removed top level pullup, pulldown, pullOff const
 * Removed Gpio.pin method in favor of top level pin function
 * Removed RpiGPIO.gpioNum and Pin.gpioNum in favor of RpiGPIO.description
 * Moved classes similar to fletch gpio package into gpio.dart library
 * Moved Pin and related code into new gpio_pins.dart library
 * Renamed PinMode to Mode
 * Renamed PinPull to Pull
 * Renamed GpioException           to GPIOException
 * Renamed GpioHardware            to RpiGPIO
 * Renamed RpiHardware             to WiringPiGPIO
 * Renamed MockHardware            to MockGPIO
 * Renamed RecordingHardware       to RecordingGPIO
 * Renamed RpiGPIO.pullUpDnControl to setPull
 * Renamed RpiGPIO.pwmWrite        to setPulseWidth
 * Changed Pin.events from getter to a method that takes an optional parameter
 * Changed Pin.value and PinEvent.value from int to bool
 * Changed Gpio.hardware= to Pin.gpio=
 * Added optional RpiGPIO.description method
 * Added Mode.other to match fletch gpio package
 * Added abstract GPIO class to match fletch gpio package

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
