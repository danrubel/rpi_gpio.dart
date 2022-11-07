import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart';
import 'package:rpi_gpio/src/cmd_handler.dart';
import 'package:rpi_gpio/src/rpi_gpio_comm.dart' as comm;

/// Entry point for GPIO isolate startup
void isolateMain(SendPort sendPort) {
  final gpioLib = RpiGpioLibImpl(findDynamicLibrary());
  final cmdHandler = RpiGpioCmdHandler(sendPort, gpioLib);

  var receivePort = ReceivePort();
  sendPort.send(comm.initCompleteRsp(receivePort.sendPort));

  receivePort.listen((data) {
    comm.dispatchCmd(data, cmdHandler);
  });
}

class RpiGpioLibImpl implements RpiGpioLib {
  final int Function() _setupGpio;
  final int Function() _disposeGpio;

  final void Function(int, int) _setGpioInput;
  final int Function(int) _readGpio;

  final void Function(int) _setGpioOutput;
  final void Function(int, int) _writeGpio;

  RpiGpioLibImpl(ffi.DynamicLibrary dylib)
      : _setupGpio = dylib
            .lookup<ffi.NativeFunction<ffi.Int64 Function()>>('setupGpio')
            .asFunction<int Function()>(),
        _disposeGpio = dylib
            .lookup<ffi.NativeFunction<ffi.Int64 Function()>>('disposeGpio')
            .asFunction<int Function()>(),
        _setGpioInput = dylib
            .lookup<
                ffi.NativeFunction<
                    ffi.Void Function(ffi.Int64, ffi.Int64)>>('setGpioInput')
            .asFunction<void Function(int, int)>(),
        _readGpio = dylib
            .lookup<
                ffi.NativeFunction< //
                    ffi.Int64 Function(ffi.Int64)>>('readGpio')
            .asFunction<int Function(int)>(),
        _setGpioOutput = dylib
            .lookup<
                ffi.NativeFunction< //
                    ffi.Void Function(ffi.Int64)>>('setGpioOutput')
            .asFunction<void Function(int)>(),
        _writeGpio = dylib
            .lookup<
                ffi.NativeFunction<
                    ffi.Void Function(ffi.Int64, ffi.Int64)>>('writeGpio')
            .asFunction<void Function(int, int)>();

  @override
  int setupGpio() => _setupGpio();
  @override
  int disposeGpio() => _disposeGpio();

  @override
  void setGpioInput(int bcmGpioPin, int pullUpDown) =>
      _setGpioInput(bcmGpioPin, pullUpDown);
  @override
  bool readGpio(int bcmGpioPin) => _readGpio(bcmGpioPin) != 0;

  @override
  void setGpioOutput(int bcmGpioPin) => _setGpioOutput(bcmGpioPin);
  @override
  void writeGpio(int bcmGpioPin, bool newValue) {
    _writeGpio(bcmGpioPin, newValue ? 1 : 0);
  }

  @override
  void testData(data) {
    // ignored
  }
}

ffi.DynamicLibrary findDynamicLibrary() {
  String libName;
  if (Platform.isLinux) {
    libName = 'librpi_gpio_ext.so';
  } else {
    // Windows: Debug\rpi_gpio_ext.dll
    // MacOS:   librpi_gpio_ext.dylib
    throw 'Unsupported OS: ${Platform.operatingSystem}';
  }

  var pkgRootDir = findRpiGpioPkgRootDir(File.fromUri(Platform.script).parent);
  var libPath = join(pkgRootDir.path, 'lib', 'src', 'native', libName);
  if (!File(libPath).existsSync()) throw 'failed to find $libPath';
  return ffi.DynamicLibrary.open(libPath);
}

/// Find the rpi_gpio package directory
Directory findRpiGpioPkgRootDir(Directory appDir) {
  // Find the app root dir containing the pubspec.yaml
  while (true) {
    if (File(join(appDir.path, 'pubspec.yaml')).existsSync()) break;
    var parentDir = appDir.parent;
    if (parentDir.path == appDir.path)
      throw 'Failed to find application directory '
          'containing the pubspec.yaml file starting from ${Platform.script}';
    appDir = parentDir;
  }

  // Load the package configuration information
  var pkgConfigFile =
      File(join(appDir.path, '.dart_tool', 'package_config.json'));
  if (!pkgConfigFile.existsSync())
    throw 'Failed to find ${pkgConfigFile.path}'
        '\nPlease be sure to run pub get in ${appDir.path}';
  var pkgConfig =
      jsonDecode(pkgConfigFile.readAsStringSync()) as Map<String, dynamic>;
  var pkgList = pkgConfig['packages'] as List;

  // Determine the location of the GPIO package being used
  const pkgName = 'rpi_gpio';
  var pkgInfo = pkgList.firstWhere((info) => (info as Map)['name'] == pkgName,
      orElse: () => throw 'Failed to find $pkgName in ${pkgConfigFile.path}'
          '\nPlease be sure that the pubspec.yaml contains $pkgName, then re-run pub get');
  var pkgPath = pkgInfo['rootUri'] as String;
  return Directory.fromUri(pkgConfigFile.uri.resolve(pkgPath));
}
