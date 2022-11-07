import 'dart:io';

import 'package:path/path.dart';
import 'package:rpi_gpio/src/rpi_gpio_isolate.dart';

const pkgName = 'rpi_gpio';
const buildScriptVersion = 2;

void main(List<String> args) {
  var pkgRootDir = findRpiGpioPkgRootDir(Directory.current);
  print('Building library in ${pkgRootDir.path}');

  // Display the version of the rpi_gpio being built
  final pubspecFile = File(join(pkgRootDir.path, 'pubspec.yaml'));
  abortIf(!pubspecFile.existsSync(), 'Failed to find ${pubspecFile.path}');
  final pubspec = pubspecFile.readAsStringSync();
  print('$pkgName version ${parseVersion(pubspec)}');

  // Build the native library
  final nativeDir = Directory(join(pkgRootDir.path, 'lib', 'src', 'native'));
  final buildScriptFile = File(join(nativeDir.path, 'build_native'));
  assertRunningOnRaspberryPi();
  final buildResult = Process.runSync(buildScriptFile.path, []);
  print(buildResult.stdout);
  if (buildResult.exitCode != 0) {
    print(buildResult.stderr);
    print('Build failed: ${buildResult.exitCode}');
    exit(buildResult.exitCode);
  }
  print('Build suceeded');
}

/// Parse the given content and return the version string
String parseVersion(String pubspec) {
  var key = 'version:';
  var start = pubspec.indexOf(key) + key.length;
  var end = pubspec.indexOf('\n', start);
  return pubspec.substring(start, end).trim();
}

/// Abort if the specified condition is true.
void abortIf(bool condition, String message) {
  if (condition) {
    print(message);
    throw 'Aborting build';
  }
}

/// Assert that this script is executing on the Raspberry Pi.
void assertRunningOnRaspberryPi() {
  // Check for Windows 11 running on RPi
  if (Platform.isWindows) {
    // TODO detect typical install on RPi
    print('Running Windows... hopefully on the Raspberry Pi...');
    return;
  }
  if (Platform.isMacOS || Platform.isIOS) {
    print('Not running on Raspberry Pi... skipping build');
    throw 'Aborting build';
  }
  // Check for typical Raspbian install
  if (Directory('/home/pi').existsSync()) return;
  print('Typical setup not found... hopefully running on the Raspberry Pi...');
}

String get runBuildNativeInstructions => '''
Must run ${Platform.script.pathSegments.last} from application directory that contains the pubspec.yaml file

  cd /path/to/your/dart/application
  dart ${Platform.script.path}
''';
