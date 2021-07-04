import 'dart:async';

import 'package:rpi_gpio/src/polling_node.dart';
import 'package:test/test.dart';

void main() {
  test('remove null', () {
    expect(polledNodes.isEmpty, isTrue);
    var node = removePolledNode(7);
    expect(node, isNull);
    expect(polledNodes.isEmpty, isTrue);
    expect(pollingTimer, isNull);
  });

  test('add/remove one', () async {
    final newNode = MockPolledNode(6);
    addPolledNode(newNode);
    expect(polledNodes.length, 1);
    expect(pollingTimer, isNotNull);

    newNode.polled = Completer();
    await newNode.polled!.future;

    var node = removePolledNode(8);
    expect(node, isNull);
    expect(polledNodes.length, 1);
    expect(pollingTimer, isNotNull);

    newNode.polled = Completer();
    await newNode.polled!.future;

    node = removePolledNode(6);
    expect(node, same(newNode));
    expect(polledNodes.isEmpty, isTrue);
    expect(pollingTimer, isNull);
  });

  test('add/remove two', () async {
    final newNode1 = MockPolledNode(6);
    final newNode2 = MockPolledNode(9);

    addPolledNode(newNode1);
    expect(polledNodes.length, 1);
    expect(pollingTimer, isNotNull);

    addPolledNode(newNode2);
    expect(polledNodes.length, 2);
    expect(pollingTimer, isNotNull);

    newNode2.polled = Completer();
    await newNode2.polled!.future;

    var node = removePolledNode(8);
    expect(node, isNull);
    expect(polledNodes.length, 2);
    expect(pollingTimer, isNotNull);

    newNode1.polled = Completer();
    await newNode1.polled!.future;

    node = removePolledNode(6);
    expect(node, same(newNode1));
    expect(polledNodes.length, 1);
    expect(pollingTimer, isNotNull);

    newNode2.polled = Completer();
    await newNode2.polled!.future;

    node = removePolledNode(9);
    expect(node, same(newNode2));
    expect(polledNodes.isEmpty, isTrue);
    expect(pollingTimer, isNull);
  });

  tearDown(() {
    stopAllPolling();
  });
}

class MockPolledNode extends PolledNode {
  Completer<void>? polled;

  MockPolledNode(int bcmGpioPin) : super(bcmGpioPin);

  @override
  void poll() {
    polled?.complete();
    polled = null;
  }
}
