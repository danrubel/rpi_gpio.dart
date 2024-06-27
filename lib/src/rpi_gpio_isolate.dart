import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/src/cmd_handler.dart';
import 'package:rpi_gpio/src/native/gpiod_ext.dart' as gpio;
import 'package:rpi_gpio/src/native/rpi_platform.dart';
import 'package:rpi_gpio/src/rpi_gpio_comm.dart' as comm;

/// Entry point for GPIO isolate startup
void isolateMain(SendPort sendPort) {
  final gpioLib = RpiGpioLibImpl(gpio.nativePkgLib);
  final cmdHandler = RpiGpioCmdHandler(sendPort, gpioLib);

  var receivePort = ReceivePort();
  sendPort.send(comm.initCompleteRsp(receivePort.sendPort));

  receivePort.listen((data) {
    comm.dispatchCmd(data, cmdHandler);
  });
}

class RpiGpioLibImpl implements RpiGpioLib {
  final gpio.NativePgkLib gpioLib;

  Pointer<gpio.GpiodChip>? _gpioChip;
  Pointer<Utf8>? _gpioChipName;
  final _gpioChipLines = <int, RpiGpioLine>{};

  RpiGpioLibImpl(this.gpioLib);

  Pointer<gpio.GpiodChip> get gpioChip => _gpioChip ??= _gpioChipImpl();

  Pointer<gpio.GpiodChip> _gpioChipImpl() {
    var name = _gpioChipName = RpiPlatform.current.gpioChipName.toNativeUtf8();
    var chip = gpioLib.gpiodChipOpenByName(name);
    if (chip == nullptr) throw GpioException('Failed to open GPIO chip');
    return chip;
  }

  RpiGpioLine gpioChipLine(int bcmGpioPin) {
    return _gpioChipLines.putIfAbsent(bcmGpioPin, () {
      return RpiGpioLine(
          bcmGpioPin, gpioLib.gpiodChipGetLine(gpioChip, bcmGpioPin));
    });
  }

  @override
  int setupGpio() {
    // no additional setup needed
    return 0;
  }

  @override
  int disposeGpio() {
    // close any lines that have been opened
    _gpioChipLines.forEach((bcmGpioPin, line) {
      // Not sure why this crashes on Linux
      // gpioLib.gpiodLineCloseChip(line.line);
      line.dispose();
    });
    _gpioChipLines.clear();

    // close the chip
    if (_gpioChip != null) {
      gpioLib.gpiodChipClose(_gpioChip!);
      malloc.free(_gpioChipName!);
      _gpioChipName = null;
      _gpioChip = null;
    }

    gpioLib.close();

    return 0;
  }

  @override
  int setGpioInput(int bcmGpioPin, int pullUpDown) {
    int lineBias;
    switch (pullUpDown) {
      case 0:
        lineBias = gpio.lineRequestBiasDisable;
        break;
      case 1:
        lineBias = gpio.lineRequestBiasPullDown;
        break;
      case 2:
        lineBias = gpio.lineRequestBiasPullUp;
        break;
      default:
        return -17;
    }
    var line = gpioChipLine(bcmGpioPin);
    return gpioLib.gpiodLineRequestInputFlags(line.line, line.name, lineBias);
  }

  @override
  bool readGpio(int bcmGpioPin) {
    var line = gpioChipLine(bcmGpioPin);
    var result = gpioLib.gpiodLineGetValue(line.line);
    // TODO: check for and report error
    return result == 1;
  }

  @override
  void setGpioOutput(int bcmGpioPin) {
    var line = gpioChipLine(bcmGpioPin);
    // TODO: check for and report error
    gpioLib.gpiodLineRequestOutput(line.line, line.name, 0);
  }

  @override
  void writeGpio(int bcmGpioPin, bool newValue) {
    var line = gpioChipLine(bcmGpioPin);
    // TODO: check for and report error
    gpioLib.gpiodLineSetValue(line.line, newValue ? 1 : 0);
  }

  @override
  void testData(data) {
    // ignored
  }
}

/// [RpiGpioLine] contains information about a line on the GPIO chip
class RpiGpioLine {
  int bcmPin;
  Pointer<gpio.GpiodLine> line;

  Pointer<Utf8>? _name;

  RpiGpioLine(this.bcmPin, this.line);

  Pointer<Utf8> get name => _name ??= '$runtimeType $bcmPin'.toNativeUtf8();

  void dispose() {
    var name = _name;
    if (name != null) {
      malloc.free(name);
      _name = null;
    }
  }
}
