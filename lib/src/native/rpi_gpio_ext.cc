#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include "include/dart_api.h"
#include "include/dart_native_api.h"
#include "wiringPi/wiringPi.h"

Dart_Handle HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) {
    Dart_PropagateError(handle);
  }
  return handle;
}

// ===== gpio.c ===============================================================
// The wiringPiISR method calls the global gpio method to configure interrupts.
// Rather than requiring the user to separately install the gpio utility,
// the interrupt configuration methods in gpio.c are copied here and called
// directly.

// New const for turning off interrupts
#define	INT_EDGE_NONE  -1

/*
 * changeOwner:
 *  >>> copied and modified from the wiringPi gpio global utility <<<
 *  Change the ownership of the file to the real userId of the calling
 *  program so we can access it.
 *********************************************************************************
 */

static void changeOwner (char *file)
{
  uid_t uid = getuid () ;
  uid_t gid = getgid () ;

  if (chown (file, uid, gid) != 0)
  {
    if (errno == ENOENT)  // Warn that it's not there
    {
      //fprintf (stderr, "%s: Warning: File not present: %s\n", cmd, file) ;
    }
    else
    {
      //fprintf (stderr, "%s: Unable to change ownership of %s: %s\n", cmd, file, strerror (errno)) ;
      //exit (1) ;
      HandleError(Dart_NewApiError("Unable to change file ownership"));
    }
  }
}

/*
 * doEdge:
 *  >>> copied and modified from the wiringPi gpio global utility <<<
 *  Easy access to changing the edge trigger on a GPIO pin
 *  This uses the /sys/class/gpio device interface.
 *********************************************************************************
 */

void doEdge (int gpio_pin_num, int edge)
{
  FILE *fd ;
  char fName [128] ;

  // Export the GPIO pin via the special "export" file
  // See https://www.kernel.org/doc/Documentation/gpio/sysfs.txt

  if ((fd = fopen ("/sys/class/gpio/export", "w")) == NULL)
  {
    //fprintf (stderr, "%s: Unable to open GPIO export interface: %s\n", argv [0], strerror (errno)) ;
    //exit (1) ;
    HandleError(Dart_NewApiError("Unable to open GPIO export interface"));
  }

  fprintf (fd, "%d\n", gpio_pin_num) ;
  fclose (fd) ;

  // Set the direction of the GPIO pin to input via the special "direction" file
  // See https://www.kernel.org/doc/Documentation/gpio/sysfs.txt

  sprintf (fName, "/sys/class/gpio/gpio%d/direction", gpio_pin_num) ;
  if ((fd = fopen (fName, "w")) == NULL)
  {
    //fprintf (stderr, "%s: Unable to open GPIO direction interface for pin %d: %s\n", argv [0], pin, strerror (errno)) ;
    //exit (1) ;
    HandleError(Dart_NewApiError("Unable to open GPIO direction interface"));
  }

  fprintf (fd, "in\n") ;
  fclose (fd) ;

  // Set the interrupt state of the GPIO pin via the special "edge" file
  // See https://www.kernel.org/doc/Documentation/gpio/sysfs.txt

  sprintf (fName, "/sys/class/gpio/gpio%d/edge", gpio_pin_num) ;
  if ((fd = fopen (fName, "w")) == NULL)
  {
    //fprintf (stderr, "%s: Unable to open GPIO edge interface for pin %d: %s\n", argv [0], pin, strerror (errno)) ;
    //exit (1) ;
    HandleError(Dart_NewApiError("Unable to open GPIO edge interface"));
  }

  /**/ if (edge == INT_EDGE_NONE)    fprintf (fd, "none\n") ;
  else if (edge == INT_EDGE_RISING)  fprintf (fd, "rising\n") ;
  else if (edge == INT_EDGE_FALLING) fprintf (fd, "falling\n") ;
  else if (edge == INT_EDGE_BOTH)    fprintf (fd, "both\n") ;
  else
  {
    //fprintf (stderr, "%s: Invalid mode: %s. Should be none, rising, falling or both\n", argv [1], mode) ;
    //exit (1) ;
    fclose (fd) ;
    HandleError(Dart_NewApiError("Invalid edge mode specified"));
  }

  // Change ownership of the value and edge files, so the current user can actually use it!

  sprintf (fName, "/sys/class/gpio/gpio%d/value", gpio_pin_num) ;
  changeOwner (fName) ;

  sprintf (fName, "/sys/class/gpio/gpio%d/edge", gpio_pin_num) ;
  changeOwner (fName) ;

  fclose (fd) ;
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
  Dart_Handle pin_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  int64_t pin_num;
  HandleError(Dart_IntegerToInt64(pin_obj, &pin_num));
  int value = digitalRead(pin_num);
  Dart_Handle result = HandleError(Dart_NewInteger(value));
  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}

// Set the output voltage on a GPIO pin either high (1) or low (0).
// void _digitalWrite(int pin, int value) native "digitalWrite";
void digitalWrite(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle value_obj = HandleError(Dart_GetNativeArgument(arguments, 2));
  int64_t pin_num, value;
  HandleError(Dart_IntegerToInt64(pin_obj, &pin_num));
  HandleError(Dart_IntegerToInt64(value_obj, &value));
  digitalWrite(pin_num, value);
  Dart_ExitScope();
}

// Set the state of a pin to accept an input voltage or produce an output voltage
// void _pinMode(int pin, int mode) native "pinMode";
void pinMode(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle mode_obj = HandleError(Dart_GetNativeArgument(arguments, 2));
  int64_t pin_num, mode;
  HandleError(Dart_IntegerToInt64(pin_obj, &pin_num));
  HandleError(Dart_IntegerToInt64(mode_obj, &mode));
  pinMode(pin_num, mode);
  Dart_ExitScope();
}

// Sets the pull-up or pull-down resistor mode on the given pin.
// The internal pull up/down resistors have a value of approximately 50KΩ on the Raspberry Pi.
// The given pin should be already set as an input.
void pullUpDnControl (Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle pud_obj = HandleError(Dart_GetNativeArgument(arguments, 2));
  int64_t pin_num, pud;
  HandleError(Dart_IntegerToInt64(pin_obj, &pin_num));
  HandleError(Dart_IntegerToInt64(pud_obj, &pud));
  pullUpDnControl(pin_num, pud);
  Dart_ExitScope();
}

// Writes the value to the PWM register for the given pin.
// The Raspberry Pi has one on-board PWM pin, pin 1 (BMC_GPIO 18, Phys 12), 
// and the range is 0-1024.
void pwmWrite(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle pulseWidth_obj = HandleError(Dart_GetNativeArgument(arguments, 2));
  int64_t pin_num, pulseWidth;
  HandleError(Dart_IntegerToInt64(pin_obj, &pin_num));
  HandleError(Dart_IntegerToInt64(pulseWidth_obj, &pulseWidth));
  pwmWrite(pin_num, pulseWidth);
  Dart_ExitScope();
}

// ===== Interrupts ===============================================

// Main interrupt handler
void gpioInterrupt(int pin);

// The port to which interrupt events are posted
// or null if initInterrupts has not yet been called.
static Dart_Port interruptEventPort = -1;

// The maximum number of active interrupts
static const int interruptToPinMax = 10;

// A map of interrupt # to pin #
// A value of -1 indicates an unused interrupt #
static int interruptToPin[interruptToPinMax];

// Interrupt handlers 0 through interruptToPinMax - 1
void gpioInterrupt0 (void) { gpioInterrupt(interruptToPin[0]); }
void gpioInterrupt1 (void) { gpioInterrupt(interruptToPin[1]); }
void gpioInterrupt2 (void) { gpioInterrupt(interruptToPin[2]); }
void gpioInterrupt3 (void) { gpioInterrupt(interruptToPin[3]); }
void gpioInterrupt4 (void) { gpioInterrupt(interruptToPin[4]); }
void gpioInterrupt5 (void) { gpioInterrupt(interruptToPin[5]); }
void gpioInterrupt6 (void) { gpioInterrupt(interruptToPin[6]); }
void gpioInterrupt7 (void) { gpioInterrupt(interruptToPin[7]); }
void gpioInterrupt8 (void) { gpioInterrupt(interruptToPin[8]); }
void gpioInterrupt9 (void) { gpioInterrupt(interruptToPin[9]); }

void (*gpioInterruptMap[interruptToPinMax])() = {
  gpioInterrupt0,
  gpioInterrupt1,
  gpioInterrupt2,
  gpioInterrupt3,
  gpioInterrupt4,
  gpioInterrupt5,
  gpioInterrupt6,
  gpioInterrupt7,
  gpioInterrupt8,
  gpioInterrupt9,
};

// Main interrupt handler
void gpioInterrupt(int pin_num) {
  if (interruptEventPort != -1 && pin_num != -1) {
    int value = digitalRead(pin_num);
    Dart_CObject message;
    message.type = Dart_CObject_kInt32;
    message.value.as_int32 = pin_num | (value != 0 ? 0x80 : 0);
    Dart_PostCObject(interruptEventPort, &message);
  }
}

// Start the service that listens for interrupt configuration requests
// and posts interrupt events to the given port.
// \param SendPort the port to which interrupt events are posted
void initInterrupts(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  if (interruptEventPort != -1) {
    HandleError(Dart_NewApiError("interrupts already initialized"));
  }
  Dart_Handle port_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  HandleError(Dart_SendPortGetId(port_obj, &interruptEventPort));
  Dart_ExitScope();
}

// Enable interrupts for the given pin.
// \param the number of the pin for which interrupts should be enabled.
// TODO provide the ability to disable interrupts for a given pin.
void enableInterrupt(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle pin_obj = HandleError(Dart_GetNativeArgument(arguments, 1));
  int64_t pin_num;
  HandleError(Dart_IntegerToInt64(pin_obj, &pin_num));
  // Determine if this interrupt is already enabled
  int interruptNum = -1;
  for (int i = 0; i < interruptToPinMax; ++i) {
    if (interruptToPin[i] == pin_num) {
      interruptNum = i;
      break;
    }
  }
  // If not already enabled then find an unused interrupt
  if (interruptNum == -1) {
    for (int i = 0; i < interruptToPinMax; ++i) {
      if (interruptToPin[i] == -1) {
        interruptToPin[i] = pin_num;
        interruptNum = i;
        break;
      }
    }
    if (interruptNum != -1) {
      if (interruptEventPort == -1) {
        HandleError(Dart_NewApiError("must call initInterrupts first"));
      }
      // This is the method we would call,
      // but calling wiringPiISR with any value other than INT_EDGE_SETUP
      // requires the global gpio utility to be installed.
      //wiringPiISR(pin_num, INT_EDGE_BOTH, gpioInterruptMap[interruptNum]);

      // Instead, call doEdge which is inlined from the gpio.c
      // global utility which is part of the wiringPi library,
      // and then call wiringPiISR with INT_EDGE_SETUP
      int gpio_pin_num = wpiPinToGpio(pin_num);
      doEdge(gpio_pin_num, INT_EDGE_BOTH);
      wiringPiISR(pin_num, INT_EDGE_SETUP, gpioInterruptMap[interruptNum]);

    } else {
      // If no unused interrupt slots, throw exception
      HandleError(Dart_NewApiError("too many active interrupts"));
    }
  }
  Dart_Handle result = HandleError(Dart_NewInteger(interruptNum));
  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}

// Stop the service that forwards interrupts.
void disableAllInterrupts(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  interruptEventPort = -1;
  // TODO turn off interrupts at the hardware level
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
  {"disableAllInterrupts", disableAllInterrupts},
  {"enableInterrupt", enableInterrupt},
  {"initInterrupts", initInterrupts},
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
  // Initialize the interrupt forwarding table
  for (int i = 0; i < interruptToPinMax; ++i) {
    interruptToPin[i] = -1;
  }
  result_code = rpi_gpio_wiringPi_init();
  if (Dart_IsError(result_code)) {
    return result_code;
  }
  return Dart_Null();
}
