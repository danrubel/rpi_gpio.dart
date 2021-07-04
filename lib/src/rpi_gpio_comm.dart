// Functions for communicating with the gpio isolate

import 'dart:isolate';

import 'package:rpi_gpio/gpio.dart';

const _setInputCmd = 0;
const _readCmd = 1;
const _setPollingFrequencyCmd = 2;
const _startPollingCmd = 3;
const _stopPollingCmd = 4;

const _setOutputCmd = 5;
const _writeCmd = 6;
const _setPwmCmd = 7;

const _testCmd = 8;
const _disposeCmd = 9;

setInputCmd(int bcmGpioPin, Pull pull) =>
    [_setInputCmd, bcmGpioPin, pull.index];
readCmd(int bcmGpioPin) => [_readCmd, bcmGpioPin];
setPollingFrequencyCmd(Duration frequency) =>
    [_setPollingFrequencyCmd, frequency.inMilliseconds];
startPollingCmd(int bcmGpioPin) => [_startPollingCmd, bcmGpioPin];
stopPollingCmd(int bcmGpioPin) => [_stopPollingCmd, bcmGpioPin];

setOutputCmd(int bcmGpioPin) => [_setOutputCmd, bcmGpioPin];
writeCmd(int bcmGpioPin, bool newValue) => [_writeCmd, bcmGpioPin, newValue];
setPwmCmd(int bcmGpioPin, int dutyCycle) => [_setPwmCmd, bcmGpioPin, dutyCycle];

testCmd(data) => [_testCmd, data];
disposeCmd() => [_disposeCmd];

void dispatchCmd(data, CommandHandler handler) {
  if (data is List && data.isNotEmpty) {
    var code = data[0];
    if (code is int) {
      switch (code) {
        case _setInputCmd:
          handler.setInputCmd(data[1] as int, Pull.values[data[2] as int]);
          return;
        case _readCmd:
          handler.readCmd(data[1] as int);
          return;
        case _setPollingFrequencyCmd:
          handler
              .setPollingFrequencyCmd(Duration(milliseconds: data[1] as int));
          return;
        case _startPollingCmd:
          handler.startPollingCmd(data[1] as int);
          return;
        case _stopPollingCmd:
          handler.stopPollingCmd(data[1] as int);
          return;
        case _setOutputCmd:
          handler.setOutputCmd(data[1] as int);
          return;
        case _writeCmd:
          handler.writeCmd(data[1] as int, data[2] as bool);
          return;
        case _setPwmCmd:
          handler.setPwmCmd(data[1] as int, data[2] as int);
          return;
        case _testCmd:
          handler.testCmd(data[1]);
          return;
        case _disposeCmd:
          handler.disposeCmd();
          return;
      }
    }
  }
  handler.unknownCmd(data);
}

abstract class CommandHandler {
  void setInputCmd(int bcmGpioPin, Pull pull);
  void setPollingFrequencyCmd(Duration frequency);
  void readCmd(int bcmGpioPin);
  void startPollingCmd(int bcmGpioPin);
  void stopPollingCmd(int bcmGpioPin);

  void setOutputCmd(int bcmGpioPin);
  void writeCmd(int bcmGpioPin, bool newValue);
  void setPwmCmd(int bcmGpioPin, int dutyCycle);

  void testCmd(data);
  void disposeCmd();
  void unknownCmd(data);
}

const _initCompleteRsp = 0;
const _readRsp = 1;
const _polledValueRsp = 2;
const _disposeCompleteRsp = 3;

initCompleteRsp(SendPort sendPort) => [_initCompleteRsp, sendPort];
readRsp(bool value) => [_readRsp, value];
polledValueRsp(int bcmGpioPin, bool currentValue) =>
    [_polledValueRsp, bcmGpioPin, currentValue];
disposeCompleteRsp() => [_disposeCompleteRsp];

void dispatchRsp(data, ResponseHandler handler) {
  if (data is List && data.isNotEmpty) {
    var code = data[0];
    if (code is int) {
      switch (code) {
        case _initCompleteRsp:
          handler.initCompleteRsp(data[1] as SendPort);
          return;
        case _readRsp:
          handler.readRsp(data[1] as bool);
          return;
        case _polledValueRsp:
          handler.polledValueRsp(data[1] as int, data[2] as bool);
          return;
        case _disposeCompleteRsp:
          handler.disposeCompleteRsp();
          return;
      }
    }
  }
  handler.unknownRsp(data);
}

abstract class ResponseHandler {
  void initCompleteRsp(SendPort sendPort);
  void readRsp(bool newValue);
  void polledValueRsp(int bcmGpioPin, bool currentValue);
  void disposeCompleteRsp();
  void unknownRsp(data);
}
