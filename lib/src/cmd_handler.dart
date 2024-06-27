import 'dart:isolate';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/src/polling_node.dart';
import 'package:rpi_gpio/src/pwm_node.dart';
import 'package:rpi_gpio/src/rpi_gpio_comm.dart' as comm;

class RpiGpioCmdHandler implements comm.CommandHandler {
  final SendPort sendPort;
  final RpiGpioLib gpioLib;

  RpiGpioCmdHandler(this.sendPort, this.gpioLib) {
    var result = gpioLib.setupGpio();
    if (result != 0) {
      throw GpioException('Init Gpio failed: $result'
          '\n  Has Gpio been enabled via the Raspberry Pi Configuration Tool?');
    }
  }

  @override
  void setInputCmd(int bcmGpioPin, Pull pull) {
    var result = gpioLib.setGpioInput(bcmGpioPin, pull.index);
    sendPort.send(comm.setInputRsp(result));
  }

  @override
  void readCmd(int bcmGpioPin) {
    var value = gpioLib.readGpio(bcmGpioPin);
    sendPort.send(comm.readRsp(value));
  }

  @override
  void setPollingFrequencyCmd(Duration frequency) {
    setPollingFrequency(frequency);
  }

  @override
  void startPollingCmd(int bcmGpioPin) {
    var node = removePolledNode(bcmGpioPin) ??
        RpiPolledNode(gpioLib, sendPort, bcmGpioPin);
    addPolledNode(node);
  }

  @override
  void stopPollingCmd(int bcmGpioPin) {
    removePolledNode(bcmGpioPin);
  }

  @override
  void setOutputCmd(int bcmGpioPin) {
    gpioLib.setGpioOutput(bcmGpioPin);
  }

  @override
  void setPwmCmd(int bcmGpioPin, int dutyCycle) {
    removePwmNode(bcmGpioPin);
    addPwmNode(RpiPwmNode(gpioLib, bcmGpioPin, dutyCycle));
  }

  @override
  void writeCmd(int bcmGpioPin, bool newValue) {
    removePwmNode(bcmGpioPin);
    gpioLib.writeGpio(bcmGpioPin, newValue);
  }

  @override
  void testCmd(data) {
    gpioLib.testData(data);
  }

  @override
  void disposeCmd() {
    stopPwm();
    stopPollingTimer();
    var result = gpioLib.disposeGpio();
    if (result != 0) throw GpioException('RpiGpio dispose failed: $result');
    sendPort.send(comm.disposeCompleteRsp());
  }

  @override
  void unknownCmd(data) {
    throw GpioException('Unknown cmd: $data');
  }
}

class RpiPolledNode extends PolledNode {
  final RpiGpioLib gpioLib;
  final SendPort sendPort;

  RpiPolledNode(this.gpioLib, this.sendPort, int bcmGpioPin)
      : super(bcmGpioPin);

  @override
  void poll() {
    var currentValue = gpioLib.readGpio(bcmGpioPin);
    sendPort.send(comm.polledValueRsp(bcmGpioPin, currentValue));
  }
}

class RpiPwmNode extends PwmNode {
  final RpiGpioLib gpioLib;

  RpiPwmNode(this.gpioLib, int bcmGpioPin, int dutyCycle)
      : super(bcmGpioPin, dutyCycle);

  @override
  void write(bool newValue) {
    gpioLib.writeGpio(bcmGpioPin, newValue);
  }
}

abstract class RpiGpioLib {
  int setupGpio();
  int disposeGpio();

  int setGpioInput(int bcmGpioPin, int pullUpDown);
  bool readGpio(int bcmGpioPin);

  void setGpioOutput(int bcmGpioPin);
  void writeGpio(int bcmGpioPin, bool newValue);

  void testData(data);
}
