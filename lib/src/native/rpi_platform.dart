import 'dart:io';

/// This provides Raspberry Pi specific information
/// See https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#best-practices-for-revision-code-usage
class RpiPlatform {
  static RpiPlatform? _current;
  static RpiPlatform get current => _current ??= _loadCurrent();
  static set current(RpiPlatform platform) => _current = platform;

  final String boardMake;
  final String boardModel;
  final String cpuMake;
  final String cpuModel;

  bool get isPi => boardMake == 'raspberrypi';
  bool get isPi5 => isPi && boardModel == '5-model-b';

  /// Return true if the board is based on a 64 bit chip
  /// and assume a 64 bit OS and Dart SDK to match
  bool get is64Bit => cpuModel != 'bcm2835' && cpuModel != 'bcm2836';

  /// Return the name used by the native library to access the GPIO pins
  String get gpioChipName => current.isPi5 //
      ? 'gpiochip4'
      : 'gpiochip0';

  RpiPlatform({
    required this.boardMake,
    required this.boardModel,
    required this.cpuMake,
    required this.cpuModel,
  });

  static RpiPlatform _loadCurrent() {
    var split = compatFile.readAsStringSync().split('\x00');
    split = [...split[0].split(','), ...split[1].split(',')];

    return _current = RpiPlatform(
      boardMake: split[0],
      boardModel: split[1],
      cpuMake: split[2],
      cpuModel: split[3],
    );
  }

  static final compatFile = File('/proc/device-tree/compatible');

  @override
  String toString() => '$runtimeType('
      'boardMake: $boardMake, '
      'boardModel: $boardModel, '
      'cpuMake: $cpuMake, '
      'cpuModel: $cpuModel)';
}
