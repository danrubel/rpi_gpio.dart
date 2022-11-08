# Changelog

## 0.8.1
* add `platforms` to pubspec indicating only Linux is supported

## 0.8.0
* convert code to use dart:ffi
* add GpioInput.allValues

## 0.7.2
* another native build script fix for Windows

## 0.7.1
* minor pubspec.yaml updates for better null-safety
* minor build cleanup
* make native build script more lenient

## 0.7.0
* migrate to null safety
* update build script to work on Windows

## 0.6.0
* rename `build_lib` to `build_native`
* move all native operations to separate isolate so that PWM and polling continue to work
  regardless of whether the main isolate is blocked (e.g. dart:io `sleep`)
* BREAKING: `RpiGpio` requires async init to spin up isolate
* BREAKING: GpioInput.value returns `Future<bool>`
* `RpiGpio.dispose` returns a `Future` that completes when cleanup is complete
* loosen SDK requirements to allow execution on older Rasberry Pi models

## 0.5.1-dev.1
* add `GpioPwm` pin for software based PWM
* update SDK requirement to 2.8.4
* update dependencies
* code style cleanup

## 0.5.0
* BREAKING: automatically allocate I2C, SPI, and EEPROM pins
    unless flag in RpiGpio constructor is set to false
* consolidate all examples into single example.dart with debouncer
* add example_test.dart with mock gpio
* add Gpio dispose for cleaning up native resources
* code cleanup

## 0.4.0-dev.1
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
