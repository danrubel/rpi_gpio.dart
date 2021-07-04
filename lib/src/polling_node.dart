import 'dart:async';

/// The current list of nodes being polled.
final polledNodes = <PolledNode>[];

/// A Gpio pin being periodically polled for it's current state.
abstract class PolledNode {
  final int bcmGpioPin;

  PolledNode(this.bcmGpioPin);

  @override
  String toString() => '$runtimeType($bcmGpioPin)';

  /// Poll the associated pin for it's current value.
  /// Subclasses should override and implement.
  void poll();
}

/// Add a node to the list of polled nodes and start polling.
/// This assumes that [newNode] is not already in the list.
void addPolledNode(PolledNode newNode) {
  polledNodes.add(newNode);
  newNode.poll();
  if (polledNodes.length == 1) startPollingTimer();
}

/// Remove and return the [PolledNode] associated with the specified pin
/// or return `null` if no such node is found in the list.
PolledNode removePolledNode(int bcmGpioPin) {
  for (int index = 0; index < polledNodes.length; ++index) {
    if (polledNodes[index].bcmGpioPin == bcmGpioPin) {
      var node = polledNodes.removeAt(index);
      if (polledNodes.isEmpty) stopPollingTimer();
      return node;
    }
  }
  return null;
}

/// The frequency at which polling occurs.
Duration pollingFrequency = Duration(milliseconds: 10);

/// The timer for polling or `null` if no pins are being polled.
Timer pollingTimer;

void setPollingFrequency(Duration frequency) {
  if (pollingFrequency != frequency) {
    pollingFrequency = frequency;
    stopPollingTimer();
    startPollingTimer();
  }
}

void stopPollingTimer() {
  pollingTimer?.cancel();
  pollingTimer = null;
}

void startPollingTimer() {
  if (polledNodes.isNotEmpty && pollingFrequency != null) {
    pollingTimer ??= Timer.periodic(pollingFrequency, pollInputs);
  }
}

void pollInputs([_]) {
  for (var node in polledNodes) node.poll();
}

void stopAllPolling() {
  stopPollingTimer();
  polledNodes.clear();
}
