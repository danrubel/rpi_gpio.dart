//
// Generated from native/rpi_gpio_ext.cc
//
import 'dart:ffi' as ffi;

const nativePkgName = 'rpi_gpio';

class NativePgkLib {
  final DisposeGpio disposeGpioMth;
  final ReadGpio readGpioMth;
  final SetGpioInput setGpioInputMth;
  final SetGpioOutput setGpioOutputMth;
  final SetGpioPwmOutput setGpioPwmOutputMth;
  final SetupGpio setupGpioMth;
  final WriteGpio writeGpioMth;
  final WritePwmGpio writePwmGpioMth;

  NativePgkLib(ffi.DynamicLibrary dylib)
      : disposeGpioMth = dylib
            .lookup<ffi.NativeFunction<DisposeGpioFfi>>('disposeGpio')
            .asFunction<DisposeGpio>(),
        readGpioMth = dylib
            .lookup<ffi.NativeFunction<ReadGpioFfi>>('readGpio')
            .asFunction<ReadGpio>(),
        setGpioInputMth = dylib
            .lookup<ffi.NativeFunction<SetGpioInputFfi>>('setGpioInput')
            .asFunction<SetGpioInput>(),
        setGpioOutputMth = dylib
            .lookup<ffi.NativeFunction<SetGpioOutputFfi>>('setGpioOutput')
            .asFunction<SetGpioOutput>(),
        setGpioPwmOutputMth = dylib
            .lookup<ffi.NativeFunction<SetGpioPwmOutputFfi>>('setGpioPwmOutput')
            .asFunction<SetGpioPwmOutput>(),
        setupGpioMth = dylib
            .lookup<ffi.NativeFunction<SetupGpioFfi>>('setupGpio')
            .asFunction<SetupGpio>(),
        writeGpioMth = dylib
            .lookup<ffi.NativeFunction<WriteGpioFfi>>('writeGpio')
            .asFunction<WriteGpio>(),
        writePwmGpioMth = dylib
            .lookup<ffi.NativeFunction<WritePwmGpioFfi>>('writePwmGpio')
            .asFunction<WritePwmGpio>();
}

typedef DisposeGpio = int Function();
typedef DisposeGpioFfi = ffi.Int64 Function();

typedef ReadGpio = int Function(int bcmGpioPin);
typedef ReadGpioFfi = ffi.Int64 Function(ffi.Int64 bcmGpioPin);

typedef SetGpioInput = int Function(int bcmGpioPin, int pullUpDown);
typedef SetGpioInputFfi = ffi.Int64 Function(
    ffi.Int64 bcmGpioPin, ffi.Int64 pullUpDown);

typedef SetGpioOutput = void Function(int bcmGpioPin);
typedef SetGpioOutputFfi = ffi.Void Function(ffi.Int64 bcmGpioPin);

typedef SetGpioPwmOutput = void Function(int bcmGpioPin);
typedef SetGpioPwmOutputFfi = ffi.Void Function(ffi.Int64 bcmGpioPin);

typedef SetupGpio = int Function();
typedef SetupGpioFfi = ffi.Int64 Function();

typedef WriteGpio = void Function(int bcmGpioPin, int newValue);
typedef WriteGpioFfi = ffi.Void Function(
    ffi.Int64 bcmGpioPin, ffi.Int64 newValue);

typedef WritePwmGpio = void Function(int bcmGpioPin, int newValue);
typedef WritePwmGpioFfi = ffi.Void Function(
    ffi.Int64 bcmGpioPin, ffi.Int64 newValue);
