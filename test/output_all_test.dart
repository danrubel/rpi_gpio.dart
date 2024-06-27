import 'dart:async';

import 'package:rpi_gpio/src/rpi_gpio_impl.dart';
import 'package:test/test.dart';

import '../example/output_all_app.dart';
import 'mock_isolate.dart';

void main() {
  RpiGpio? gpio;
  late AckHandler ackHandler;

  test('setup', () async {
    ackHandler = AckHandler();
    gpio = await RpiGpio.init(
      i2c: false,
      spi: false,
      eeprom: false,
      isolateEntryPoint: isolateMockMain,
      testSendPort: ackHandler.receivePort.sendPort,
    );
    ackHandler.gpio = gpio;
    await ackHandler.isSetup.future;
  });

  test('run', () async {
    await runAllOutput(gpio!, false, false, false, false,
        blink: Duration(milliseconds: 1));
  });

  test('dispose', () async {
    await ackHandler.isDisposed.future;
  });

  test('output pins', () {
    expect(ackHandler.outputPins, hasLength(24));
  });

  test('unexpected ack', () async {
    // Allow time for unexpected gpio ack to propagate
    await Future.delayed(const Duration(milliseconds: 4));
    expect(ackHandler.unexpectedAck, isEmpty);
    expect(ackHandler.outputPins.length, ackHandler.ledState.length);
    for (var physicalPin in ackHandler.outputPins) {
      expect(ackHandler.ledState[physicalPin], false,
          reason: 'LED at pin $physicalPin should be off');
    }
  });

  tearDownAll(() async {
    await ackHandler.subscription.cancel();
    ackHandler.receivePort.close();
  });
}

class AckHandler extends BaseAckHandler {
  final outputPins = <int>[];
  final ledState = <int, bool>{};

  @override
  void handleAck(List ack) {
    switch (ack[0] as int) {
      case setOutputAck:
        outputPins.add(ack[1] as int);
        return;
      case writeAck:
        ledState[ack[1] as int] = ack[2] as bool;
        return;
    }
    super.handleAck(ack);
  }
}
