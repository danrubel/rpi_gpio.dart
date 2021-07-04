/// The PWM node having the smallest duty cycle, or `null` if none.
PwmNode firstPwmNode;

/// A Gpio pin having a specific pulse width modulated duty cycle enabled.
abstract class PwmNode {
  final int bcmGpioPin;
  final int dutyCycle;

  /// The next PWM node having the next larger duty cycle or `null` if none.
  PwmNode nextNode;

  PwmNode(this.bcmGpioPin, this.dutyCycle);

  @override
  String toString() => '$runtimeType($bcmGpioPin)';

  /// Set the output state of the PWM pin represented by this node.
  /// Subclasses should override and implement.
  void write(bool newValue);
}

/// Insert [newNode] into the list of [PwmNode]s sorted by duty cycle.
/// This assumes that [newNode] is not already in the list.
void addPwmNode(PwmNode newNode) {
  PwmNode previousNode;
  PwmNode node = firstPwmNode;
  while (node != null) {
    if (newNode.dutyCycle < node.dutyCycle) break;
    previousNode = node;
    node = node.nextNode;
  }
  if (previousNode == null) {
    newNode.nextNode = firstPwmNode;
    firstPwmNode = newNode;
  } else {
    newNode.nextNode = node;
    previousNode.nextNode = newNode;
  }
  _runPwm();
}

/// Remove and return the [PwmNode] associated with the specified pin
/// or return `null` if no such node is found in the list.
PwmNode removePwmNode(int bcmGpioPin) {
  PwmNode previousNode;
  PwmNode node = firstPwmNode;
  while (node != null) {
    if (node.bcmGpioPin == bcmGpioPin) {
      if (previousNode == null)
        firstPwmNode = node.nextNode;
      else
        previousNode.nextNode = node.nextNode;
      break;
    }
    previousNode = node;
    node = node.nextNode;
  }
  return node;
}

/// Stop all PWM and discard all [PwmNode]s.
void stopPwm() {
  firstPwmNode = null;
}

/// The current state in the duty cycle (0 to 100).
/// Each [PwmNode] is turned on at tick 0
/// and turned off when [currentPwmTick] >= [PwmNode.dutyCycle].
var currentPwmTick = 0;

/// The amount of time in a single duty cycle tick where 100 ticks comprise a cycle.
var pwmTickDuration = Duration(microseconds: 100);

/// `true` if [_runPwm] is processing PWM output
var _isPwnRunning = false;

/// Call to start processing PWM output.
/// Does not return until there are no PWM nodes.
/// If PWM output is already being processed,
/// then this returns immediately without doing anything.
void _runPwm() async {
  if (_isPwnRunning) return;
  _isPwnRunning = true;
  var durationUntilNextUpdate = updatePwm();
  while (durationUntilNextUpdate != null) {
    await Future.delayed(durationUntilNextUpdate);
    durationUntilNextUpdate = updatePwm();
  }
  _isPwnRunning = false;
}

/// Update the [PwmNode]s and advance the [currentPwmTick].
/// Return the [Duration] until the next time that [updatePwm] should be called
/// or `null` if there are no [PwmNode]s.
Duration updatePwm() {
  var node = firstPwmNode;
  if (node == null) {
    currentPwmTick = 0;
    return null;
  }

  int nextPwmTick;

  if (currentPwmTick == 0) {
    nextPwmTick = node.dutyCycle; // smallest/first duty cycle
    while (node != null) {
      // Turn all PWM nodes on at the beginning of the cycle
      node.write(true);
      node = node.nextNode;
    }
  } else {
    while (node != null && currentPwmTick >= node.dutyCycle) {
      // Turn off each PWM node whose time is up
      if (currentPwmTick == node.dutyCycle) node.write(false);
      node = node.nextNode;
    }
    nextPwmTick = node?.dutyCycle ?? 100;
  }

  var numTicksUntilNextUpdate = nextPwmTick - currentPwmTick;
  currentPwmTick = nextPwmTick;
  if (currentPwmTick >= 100) currentPwmTick = 0;
  return Duration(
      microseconds: pwmTickDuration.inMicroseconds * numTicksUntilNextUpdate);
}
