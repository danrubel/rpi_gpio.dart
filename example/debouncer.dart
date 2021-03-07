import 'dart:async';

/// [Debouncer] is a stream transformer for debouncing pin events
class Debouncer implements StreamTransformerBase<bool, bool> {
  bool value;
  bool _lastValue;
  StreamController<bool> _controller;

  final Duration debounceDuration;
  Timer _debounceTimer;

  Debouncer(this.value, int debounceMilliseconds)
      : debounceDuration = Duration(milliseconds: debounceMilliseconds);

  @override
  Stream<bool> bind(Stream<bool> stream) {
    if (_controller != null) throw 'cannout use debouncer twice';
    StreamSubscription<bool> subscription;
    _controller = StreamController<bool>(onListen: () {
      subscription = stream.listen((bool newValue) {
        _lastValue = newValue;
        _debounceTimer?.cancel();
        _debounceTimer = Timer(debounceDuration, () {
          if (value != _lastValue) {
            value = _lastValue;
            _controller.add(_lastValue);
          }
        });
      });
    }, onCancel: () {
      subscription.cancel();
    });
    return _controller.stream;
  }

  StreamTransformer<RS, RT> cast<RS, RT>() =>
      StreamTransformer.castFrom<bool, bool, RS, RT>(this);
}
