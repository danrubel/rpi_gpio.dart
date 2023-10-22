import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:rpi_gpio/src/cmd_handler.dart';
import 'package:rpi_gpio/src/native/rpi_gpio_ext.dart';
import 'package:rpi_gpio/src/rpi_gpio_comm.dart' as comm;

/// Entry point for GPIO isolate startup
void isolateMain(SendPort sendPort) {
  final gpioLib = RpiGpioLibImpl(findDynamicLibrary());
  final cmdHandler = RpiGpioCmdHandler(sendPort, gpioLib);

  var receivePort = ReceivePort();
  sendPort.send(comm.initCompleteRsp(receivePort.sendPort));

  receivePort.listen((data) {
    comm.dispatchCmd(data, cmdHandler);
  });
}

class RpiGpioLibImpl extends NativePgkLib implements RpiGpioLib {
  RpiGpioLibImpl(ffi.DynamicLibrary dylib) : super(dylib);

  @override
  int setupGpio() => setupGpioMth();
  @override
  int disposeGpio() => disposeGpioMth();

  @override
  int setGpioInput(int bcmGpioPin, int pullUpDown) =>
      setGpioInputMth(bcmGpioPin, pullUpDown);
  @override
  bool readGpio(int bcmGpioPin) => readGpioMth(bcmGpioPin) != 0;

  @override
  void setGpioOutput(int bcmGpioPin) => setGpioOutputMth(bcmGpioPin);
  @override
  void writeGpio(int bcmGpioPin, bool newValue) {
    writeGpioMth(bcmGpioPin, newValue ? 1 : 0);
  }

  @override
  void testData(data) {
    // ignored
  }
}
