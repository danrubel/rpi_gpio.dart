#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <wiringPi.h>
#include "include/dart_api.h"
#include "include/dart_native_api.h"

Dart_Handle HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) {
    Dart_PropagateError(handle);
  }
  return handle;
}

// Native library connecting rpi_gpio.dart to the wiringPi library
// See http://wiringpi.com/
// and http://wiringpi.com/reference/core-functions/
//
// This code is heavily based on the article
// Native Extensions for the Standalone Dart VM
// https://www.dartlang.org/articles/native-extensions-for-standalone-dart-vm/#appendix-compiling-and-linking-extensions
// and the example code
// http://dart.googlecode.com/svn/trunk/dart/samples/sample_extension/ 

// ===== Native methods ===============================================
// Each native method must have an entry in either function_list or no_scope_function_list

// Initialize the native library.
// This is called once by the rpi_gpio_ext_Init method in the Infrastructure section below.
Dart_Handle rpi_gpio_wiringPi_init() {
  int result = wiringPiSetup();
  if (result != 0) {
    // Apparently wiringPiSetup never returns if there is an initialization problem
    return Dart_NewApiError("wiringPiSetup failed");
  }
  return Dart_Null();
}

// Read the input voltage on a GPIO pin and return either high (1) or low (0).
// int _digitalRead(int pin) native "digitalRead";
void digitalRead(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_object = HandleError(Dart_GetNativeArgument(arguments, 1));
  int64_t pin;
  HandleError(Dart_IntegerToInt64(pin_object, &pin));
  int value = digitalRead(pin);
  Dart_Handle result = HandleError(Dart_NewInteger(value));
  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}

// Set the output voltage on a GPIO pin either high (1) or low (0).
// void _digitalWrite(int pin, int value) native "digitalWrite";
void digitalWrite(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_object = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle value_object = HandleError(Dart_GetNativeArgument(arguments, 2));
  int64_t pin, value;
  HandleError(Dart_IntegerToInt64(pin_object, &pin));
  HandleError(Dart_IntegerToInt64(value_object, &value));
  digitalWrite(pin, value);
  Dart_ExitScope();
}

// Set the state of a pin to accept an input voltage or produce an output voltage
// void _pinMode(int pin, int mode) native "pinMode";
void pinMode(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_object = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle mode_object = HandleError(Dart_GetNativeArgument(arguments, 2));
  int64_t pin, mode;
  HandleError(Dart_IntegerToInt64(pin_object, &pin));
  HandleError(Dart_IntegerToInt64(mode_object, &mode));
  pinMode(pin, mode);
  Dart_ExitScope();
}

// Sets the pull-up or pull-down resistor mode on the given pin.
// The internal pull up/down resistors have a value of approximately 50KΩ on the Raspberry Pi.
// The given pin should be already set as an input.
void pullUpDnControl (Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_object = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle pud_object = HandleError(Dart_GetNativeArgument(arguments, 2));
  int64_t pin, pud;
  HandleError(Dart_IntegerToInt64(pin_object, &pin));
  HandleError(Dart_IntegerToInt64(pud_object, &pud));
  pullUpDnControl(pin, pud);
  Dart_ExitScope();
}

// Writes the value to the PWM register for the given pin.
// The Raspberry Pi has one on-board PWM pin, pin 1 (BMC_GPIO 18, Phys 12), 
// and the range is 0-1024.
void pwmWrite(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_object = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle pulseWidth_object = HandleError(Dart_GetNativeArgument(arguments, 2));
  int64_t pin, pulseWidth;
  HandleError(Dart_IntegerToInt64(pin_object, &pin));
  HandleError(Dart_IntegerToInt64(pulseWidth_object, &pulseWidth));
  pwmWrite(pin, pulseWidth);
  Dart_ExitScope();
}

// ===== Infrastructure methods ===============================================

struct FunctionLookup {
  const char* name;
  Dart_NativeFunction function;
};

FunctionLookup function_list[] = {
  {"digitalRead", digitalRead},
  {"digitalWrite", digitalWrite},
  {"pinMode", pinMode},
  {"pullUpDnControl", pullUpDnControl},
  {"pwmWrite", pwmWrite},
  {NULL, NULL}
};

FunctionLookup no_scope_function_list[] = {
  {NULL, NULL}
};

// Resolve the Dart name of the native function into a C function pointer.
// This is called once per native method.
Dart_NativeFunction ResolveName(Dart_Handle name,
                                int argc,
                                bool* auto_setup_scope) {
  if (!Dart_IsString(name)) {
    return NULL;
  }
  Dart_NativeFunction result = NULL;
  if (auto_setup_scope == NULL) {
    return NULL;
  }

  Dart_EnterScope();
  const char* cname;
  HandleError(Dart_StringToCString(name, &cname));

  for (int i=0; function_list[i].name != NULL; ++i) {
    if (strcmp(function_list[i].name, cname) == 0) {
      *auto_setup_scope = true;
      result = function_list[i].function;
      break;
    }
  }

  if (result != NULL) {
    Dart_ExitScope();
    return result;
  }

  for (int i=0; no_scope_function_list[i].name != NULL; ++i) {
    if (strcmp(no_scope_function_list[i].name, cname) == 0) {
      *auto_setup_scope = false;
      result = no_scope_function_list[i].function;
      break;
    }
  }

  Dart_ExitScope();
  return result;
}

// Initialize the native library.
// This is called once when the native library is loaded.
DART_EXPORT Dart_Handle rpi_gpio_ext_Init(Dart_Handle parent_library) {
  if (Dart_IsError(parent_library)) {
    return parent_library;
  }
  Dart_Handle result_code =
      Dart_SetNativeResolver(parent_library, ResolveName, NULL);
  if (Dart_IsError(result_code)) {
    return result_code;
  }
  result_code = rpi_gpio_wiringPi_init();
  if (Dart_IsError(result_code)) {
    return result_code;
  }
  return Dart_Null();
}

