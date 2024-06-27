import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:rpi_gpio/src/native/gpiod_ext.g.dart';

export 'package:rpi_gpio/src/native/gpiod_ext.g.dart';

NativePgkLib? _nativePkgLib;
NativePgkLib get nativePkgLib => _nativePkgLib ??= _loadNativePkgLib();
set nativePkgLib(NativePgkLib nativePkgLib) => _nativePkgLib = nativePkgLib;

/// Find the GPIO native library
/// by running `ldconfig -p` and parsing the output
String findNativePkgLibPath() {
  ProcessResult result = Process.runSync('ldconfig', ['-p']);
  if (result.exitCode != 0) {
    throw Exception('Failed to find GPIO library: ${result.exitCode}'
        '\n${result.stdout}\n${result.stderr}');
  }

  const libName = 'libgpiod.so.2';
  var lines = result.stdout.toString().split('\n');
  for (var line in lines) {
    if (line.contains(libName)) {
      return line.split('=>').last.trim();
    }
  }
  throw Exception('Failed to find GPIO library named "$libName" in'
      '\n${result.stdout}\n${result.stderr}');
}

NativePgkLib _loadNativePkgLib() {
  return NativePgkLib(ffi.DynamicLibrary.open(findNativePkgLibPath()));
}

extension NativePgkLibUtil on NativePgkLib {
  void close() {
    dyLib.close();
  }
}

// Flags

const lineRequestOpenDrain = 1;
const lineRequestOpenSource = 2;
const lineRequestActiveLow = 4;
const lineRequestBiasDisable = 8;
const lineRequestBiasPullDown = 16;
const lineRequestBiasPullUp = 32;

const lineRequestDirectionAsIs = 1;
const lineRequestDirectionInput = 2;
const lineRequestDirectionOutput = 3;
const lineRequestEventFallingEdge = 4;
const lineRequestEventRisingEdge = 5;
const lineRequestEventBothEdges = 6;

// Struct

sealed class GpiodLineEvent extends ffi.Struct {
  @ffi.Int32()
  external int secSinceEpoch;
  @ffi.Int32()
  external int nanoSec;
  @ffi.Int64()
  external int eventType;
}

sealed class Timespec extends ffi.Struct {
  @ffi.Int32()
  external int secSinceEpoch;
  @ffi.Int32()
  external int nanoSec;
}
