# Changelog

## 0.2.2

 * rework isRaspberryPi to check /etc/os-release
 * rework and simplify [examples](example)

## 0.2.1

 * fix bug to track both rising and falling interrupt edge
 * fix bug that prevented application from completing normally when interrupts were used
 * switch tests to use package:test rather than package:unittest
 * fix [read](example/read.dart), [polling](example/polling.dart), and [interrupts](example/interrupts.dart) examples
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
