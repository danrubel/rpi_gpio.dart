import 'dart:async';
import 'dart:isolate';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/src/rpi_gpio_impl.dart';
import 'package:test/test.dart';

import 'mock_isolate.dart';
import 'test_util.dart';

main() {
  test('const', () {
    expect(Pull.off.index, 0);
    expect(Pull.down.index, 1);
    expect(Pull.up.index, 2);
  });

  RpiGpio? gpio;
  ReceivePort? receivePort;
  StreamSubscription? subscription;

  test('instantiate', () async {
    receivePort = ReceivePort('basic test');
    subscription = receivePort!.listen((message) {
      print('basic test ack: $message');
    });
    gpio = await RpiGpio.init(
      isolateEntryPoint: isolateMockMain,
      testSendPort: receivePort!.sendPort,
    );
  });

  test('exceptions', () async {
    // Only one instance of GPIO factory
    try {
      await RpiGpio.init(
        isolateEntryPoint: isolateMockMain,
        testSendPort: receivePort!.sendPort,
      );
      fail('expected exception');
    } on GpioException {
      // Expected... fall through
    }

    // Cannot allocate non-GPIO pins
    expectThrows(() => gpio!.output(1)); // 3.3V
    expectThrows(() => gpio!.output(6)); // GND

    // Cannot allocate I2C or SPI pins
    expectThrows(() => gpio!.output(3)); // I2C
    expectThrows(() => gpio!.output(19)); // SPI0
  });

  test('dispose', () async {
    await gpio?.dispose();
    await subscription?.cancel();
    receivePort?.close();
    gpio = null;
    receivePort = null;
    subscription = null;
  });

  test('allow I2C and SPI as GPIO', () async {
    receivePort = ReceivePort('basic test');
    subscription = receivePort!.listen((message) {
      print('basic test ack: $message');
    });
    gpio = await RpiGpio.init(
      i2c: false,
      spi: false,
      isolateEntryPoint: isolateMockMain,
      testSendPort: receivePort!.sendPort,
    );
    expect(gpio!.output(3), isNotNull); // I2C
    expect(gpio!.output(19), isNotNull); // SPI0
  });

  test('dispose', () async {
    await gpio?.dispose();
    await subscription?.cancel();
    receivePort?.close();
    gpio = null;
    receivePort = null;
    subscription = null;
  });
}
