import 'dart:isolate';

import 'package:rpi_gpio/src/cmd_handler.dart';
import 'package:rpi_gpio/src/rpi_gpio_comm.dart' as comm;

import 'dart-ext:rpi_gpio_ext';

/// Entry point for GPIO isolate startup
void isolateMain(SendPort sendPort) {
  final cmdHandler = RpiGpioCmdHandler(sendPort, RpiGpioLibImpl());

  ReceivePort receivePort = ReceivePort();
  sendPort.send(comm.initCompleteRsp(receivePort.sendPort));

  receivePort.listen((data) {
    comm.dispatchCmd(data, cmdHandler);
  });
}

class RpiGpioLibImpl implements RpiGpioLib {
  int setupGpio() native "setupGpio";
  int disposeGpio() native "disposeGpio";

  void setGpioInput(int bcmGpioPin, int pullUpDown) native "setGpioInput";
  bool readGpio(int bcmGpioPin) native "readGpio";

  void setGpioOutput(int bcmGpioPin) native "setGpioOutput";
  void writeGpio(int bcmGpioPin, bool newValue) native "writeGpio";

  @override
  void testData(data) {
    // ignored
  }
}
