import 'dart:isolate';

import 'package:rpi_gpio/src/cmd_handler.dart';
import 'package:rpi_gpio/src/rpi_gpio_comm.dart' as comm;

/// Entry point for GPIO isolate startup
void isolateMockMain(SendPort sendPort) {
  final cmdHandler = RpiGpioCmdHandler(sendPort, MockGpioLibImpl());

  ReceivePort receivePort = ReceivePort();
  sendPort.send(comm.initCompleteRsp(receivePort.sendPort));

  receivePort.listen((data) {
    comm.dispatchCmd(data, cmdHandler);
  });
}

const setupAck = 0;
const disposeAck = 1;
const setInputAck = 2;
const readAck = 3;
const setOutputAck = 4;
const writeAck = 5;

class MockGpioLibImpl implements RpiGpioLib {
  bool setupComplete = false;
  bool disposed = false;
  SendPort? testSendPort;
  final gpioInputValues = <int, bool>{};

  int setupGpio() {
    if (setupComplete) throw 'setup already called';
    setupComplete = true;
    return 0;
  }

  int disposeGpio() {
    if (disposed) throw 'dispose already called';
    testSendPort!.send([disposeAck]);
    return 0;
  }

  void setGpioInput(int bcmGpioPin, int pullUpDown) {
    _checkSetup();
    testSendPort!.send([setInputAck, bcmGpioPin, pullUpDown]);
  }

  bool readGpio(int bcmGpioPin) {
    _checkSetup();
    testSendPort!.send([readAck, bcmGpioPin]);
    return gpioInputValues[bcmGpioPin] ?? false;
  }

  void setGpioOutput(int bcmGpioPin) {
    _checkSetup();
    testSendPort!.send([setOutputAck, bcmGpioPin]);
  }

  void writeGpio(int bcmGpioPin, bool newValue) {
    _checkSetup();
    testSendPort!.send([writeAck, bcmGpioPin, newValue]);
  }

  @override
  void testData(data) {
    if (data is SendPort) {
      if (testSendPort != null) throw 'test send port already set';
      testSendPort = data;
      if (setupComplete) testSendPort!.send([setupAck]);
      return;
    }
    if (data is List && data.length == 2) {
      gpioInputValues[data[0] as int] = data[1] as bool;
      return;
    }
    throw 'unknown test data: $data';
  }

  void _checkSetup() {
    if (!setupComplete) throw 'must call setup first';
    if (disposed) throw 'already disposed';
  }
}
