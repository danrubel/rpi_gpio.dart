import 'dart:async';

import 'package:rpi_gpio/src/rpi_gpio_impl.dart';
import 'package:test/test.dart';

import '../example/example_app.dart';
import 'mock_isolate.dart';

void main() {
  RpiGpio? gpio;
  late AckHandler ackHandler;

  test('setup', () async {
    ackHandler = AckHandler();
    gpio = await RpiGpio.init(
      isolateEntryPoint: isolateMockMain,
      testSendPort: ackHandler.receivePort.sendPort,
    );
    ackHandler.gpio = gpio;
    await ackHandler.isSetup.future;
  });

  test('example start', () async {
    await runExample(gpio!, blink: Duration(milliseconds: 1), debounce: 1);
    await ackHandler.is18Setup.future;
    await ackHandler.is22Setup.future;
  });

  test('example blink', () async {
    await ackHandler.is17Setup.future;
    expect(ackHandler.write22Count, greaterThan(42)); // fixed blinking LED
    expect(ackHandler.write18Count, greaterThan(6)); // PWM LED
  });

  test('example button', () async {
    await ackHandler.is17Setup.future;
    await ackHandler.isDisposed.future;
    expect(ackHandler.buttonPolledCount, greaterThan(5));
    expect(ackHandler.buttonToggledCount, greaterThan(5));
  });

  test('dispose', () async {
    await ackHandler.isDisposed.future;
  });

  test('unexpected ack', () async {
    // Allow time for unexpected gpio ack to propagate
    await Future.delayed(const Duration(milliseconds: 4));
    expect(ackHandler.unexpectedAck, isEmpty);
  });

  tearDownAll(() async {
    await ackHandler.subscription.cancel();
    ackHandler.receivePort.close();
  });
}

class AckHandler extends BaseAckHandler {
  final is17Setup = Completer();
  final is18Setup = Completer();
  final is22Setup = Completer();
  var write18Count = 0;
  var write22Count = 0;
  var buttonState = false;
  var buttonPolledCount = 0;
  var buttonToggledCount = 0;

  @override
  void handleAck(List ack) {
    switch (ack[0] as int) {
      case setInputAck:
        switch (ack[1] as int) {
          case 17:
            is17Setup.complete();
            return;
        }
        break;
      case readAck:
        switch (ack[1] as int) {
          case 17:
            ++buttonPolledCount;
            if (gpio == null) return;
            buttonState = !buttonState;
            ++buttonToggledCount;
            gpio!.testCmd([17, buttonState]);
            return;
        }
        break;
      case setOutputAck:
        switch (ack[1] as int) {
          case 18:
            is18Setup.complete();
            return;
          case 22:
            is22Setup.complete();
            return;
        }
        break;
      case writeAck:
        switch (ack[1] as int) {
          case 18:
            ++write18Count;
            return;
          case 22:
            ++write22Count;
            return;
        }
    }
    super.handleAck(ack);
  }
}
