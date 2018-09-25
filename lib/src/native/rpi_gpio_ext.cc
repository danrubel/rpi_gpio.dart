#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#include "include/dart_api.h"
#include "include/dart_native_api.h"

#define BLOCK_SIZE 4096
static volatile uint32_t *gpio;
static volatile uint32_t *pwm;
static volatile uint32_t *clk;

Dart_Handle HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) {
    Dart_PropagateError(handle);
  }
  return handle;
}

// === from wiringPi.c ===

// To prevent accidental writes to critical control registers,
// values written must be ORed with 0x5A000000.
// - clock management
// - power managements
// - reset/watchdog control

#define BCM_PASSWORD  0x5A000000

// The BCM2835 has 54 GPIO pins.
// BCM2835 data sheet, Page 90 onwards.
// There are 6 control registers, each control the functions of a block
// of 10 pins.
// Each control register has 10 sets of 3 bits per GPIO pin - the ALT values
//
// 000 = GPIO Pin X is an input
// 001 = GPIO Pin X is an output
// 100 = GPIO Pin X takes alternate function 0
// 101 = GPIO Pin X takes alternate function 1
// 110 = GPIO Pin X takes alternate function 2
// 111 = GPIO Pin X takes alternate function 3
// 011 = GPIO Pin X takes alternate function 4
// 010 = GPIO Pin X takes alternate function 5
//
// So the 3 bits for port X are:
// X / 10 + ((X % 10) * 3)

// Port function select bits

#define FSEL_INPT       0b000   // Input
#define FSEL_OUTP       0b001   // Output
#define FSEL_ALT0       0b100   // Pulse Width Modulation
#define FSEL_ALT1       0b101
#define FSEL_ALT2       0b110
#define FSEL_ALT3       0b111
#define FSEL_ALT4       0b011
#define FSEL_ALT5       0b010   // Pulse Width Modulation

// PWM
//        Word offsets into the PWM control region

#define PWM_CONTROL 0
#define PWM_STATUS  1
#define PWM0_RANGE  4
#define PWM0_DATA   5
#define PWM1_RANGE  8
#define PWM1_DATA   9

//        Clock regsiter offsets

#define PWMCLK_CNTL     40
#define PWMCLK_DIV      41

#define PWM_MODE_MS     0
#define PWM_MODE_BAL    1

#define PWM0_MS_MODE    0x0080  // Run in MS mode
#define PWM0_USEFIFO    0x0020  // Data from FIFO
#define PWM0_REVPOLAR   0x0010  // Reverse polarity
#define PWM0_OFFSTATE   0x0008  // Ouput Off state
#define PWM0_REPEATFF   0x0004  // Repeat last value if FIFO empty
#define PWM0_SERIAL     0x0002  // Run in serial mode
#define PWM0_ENABLE     0x0001  // Channel Enable

#define PWM1_MS_MODE    0x8000  // Run in MS mode
#define PWM1_USEFIFO    0x2000  // Data from FIFO
#define PWM1_REVPOLAR   0x1000  // Reverse polarity
#define PWM1_OFFSTATE   0x0800  // Ouput Off state
#define PWM1_REPEATFF   0x0400  // Repeat last value if FIFO empty
#define PWM1_SERIAL     0x0200  // Run in serial mode
#define PWM1_ENABLE     0x0100  // Channel Enable

// gpioToPwmALT
//        the ALT value to put a GPIO pin into PWM mode

static uint8_t gpioToPwmALT [] =
{
          0,         0,         0,         0,         0,         0,         0,         0,        //  0 ->  7
          0,         0,         0,         0, FSEL_ALT0, FSEL_ALT0,         0,         0,        //  8 -> 15
          0,         0, FSEL_ALT5, FSEL_ALT5,         0,         0,         0,         0,        // 16 -> 23
          0,         0,         0,         0,         0,         0,         0,         0,        // 24 -> 31
          0,         0,         0,         0,         0,         0,         0,         0,        // 32 -> 39
  FSEL_ALT0, FSEL_ALT0,         0,         0,         0, FSEL_ALT0,         0,         0,        // 40 -> 47
          0,         0,         0,         0,         0,         0,         0,         0,        // 48 -> 55
          0,         0,         0,         0,         0,         0,         0,         0,        // 56 -> 63
};

// gpioToPwmPort
//        The port value to put a GPIO pin into PWM mode

static uint8_t gpioToPwmPort [] =
{
          0,         0,         0,         0,         0,         0,         0,         0,        //  0 ->  7
          0,         0,         0,         0, PWM0_DATA, PWM1_DATA,         0,         0,        //  8 -> 15
          0,         0, PWM0_DATA, PWM1_DATA,         0,         0,         0,         0,        // 16 -> 23
          0,         0,         0,         0,         0,         0,         0,         0,        // 24 -> 31
          0,         0,         0,         0,         0,         0,         0,         0,        // 32 -> 39
  PWM0_DATA, PWM1_DATA,         0,         0,         0, PWM1_DATA,         0,         0,        // 40 -> 47
          0,         0,         0,         0,         0,         0,         0,         0,        // 48 -> 55
          0,         0,         0,         0,         0,         0,         0,         0,        // 56 -> 63

};

// Apparently a single call on the Pi to nanosleep takes some 80 to 130 microseconds
// and we need 5 microseconds, so delay in a hard loop, watching gettimeofday() instead.
void delayMicrosecondsHard(unsigned int howLong)
{
  struct timeval tNow, tLong, tEnd;

  gettimeofday (&tNow, NULL);
  tLong.tv_sec  = howLong / 1000000;
  tLong.tv_usec = howLong % 1000000;
  timeradd (&tNow, &tLong, &tEnd);

  while (timercmp (&tNow, &tEnd, <))
    gettimeofday (&tNow, NULL);
}

void delayMicroseconds(unsigned int howLong)
{
  struct timespec sleeper;
  unsigned int uSecs = howLong % 1000000;
  unsigned int wSecs = howLong / 1000000;

  if (howLong == 0)
    return;
  else if (howLong  < 100)
    delayMicrosecondsHard(howLong);
  else
  {
    sleeper.tv_sec  = wSecs;
    sleeper.tv_nsec = (long)(uSecs * 1000L);
    nanosleep(&sleeper, NULL);
  }
}

// === end from wiringPi.c ===

// Setup GPIO mapped memory access and return zero if successful.
// Negative return values indicate an error.
// int _setupGpio() native "setupGpio";
void setupGpio(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  int64_t result = 0;
  int fd = open("/dev/gpiomem", O_RDWR | O_SYNC | O_CLOEXEC);
  if (fd < 0) {
    result = -1;
  } else {

    void *gpio_map = mmap(
      0,                      // Any adddress in our space will do
      BLOCK_SIZE,             // Map length
      PROT_READ | PROT_WRITE, // Enable reading & writting to mapped memory
      MAP_SHARED,             // Shared with other processes
      fd,                     // File to map
      0x3F200000              // Offset to GPIO peripheral
    );

    void *pwm_map = mmap(
      0,                      // Any adddress in our space will do
      BLOCK_SIZE,             // Map length
      PROT_READ | PROT_WRITE, // Enable reading & writting to mapped memory
      MAP_SHARED,             // Shared with other processes
      fd,                     // File to map
      0x3F20C000              // Offset to pulse width modulation control
    );

    void *clk_map = mmap(
      0,                      // Any adddress in our space will do
      BLOCK_SIZE,             // Map length
      PROT_READ | PROT_WRITE, // Enable reading & writting to mapped memory
      MAP_SHARED,             // Shared with other processes
      fd,                     // File to map
      0x3F101000              // Offset to clock control
    );

    close(fd);
    if (gpio_map == MAP_FAILED) {
      result = -2;
    } else if (pwm_map == MAP_FAILED) {
      result = -3;
    } else if (clk_map == MAP_FAILED) {
      result = -4;
    } else {
      gpio = (volatile uint32_t *) gpio_map;
      pwm  = (volatile uint32_t *) pwm_map;
      clk  = (volatile uint32_t *) clk_map;
    }
  }

  Dart_SetIntegerReturnValue(arguments, result);
  Dart_ExitScope();
}

// Dispose of GPIO mapped memory access and return zero if successful.
// Negative return values indicate an error.
// int _disposeGpio() native "disposeGpio";
void disposeGpio(Dart_NativeArguments arguments) {
  Dart_EnterScope();

  int gpio_result = munmap((void *) gpio, BLOCK_SIZE);
  int pwm_result  = munmap((void *) pwm,  BLOCK_SIZE);
  int clk_result  = munmap((void *) clk,  BLOCK_SIZE);

  int64_t result = 0;
  if (gpio_result == -1) {
    result = -2;
  } else if (pwm_result == -1) {
    result = -3;
  } else if (clk_result == -1) {
    result = -4;
  }

  Dart_SetIntegerReturnValue(arguments, result);
  Dart_ExitScope();
}

// Set the GPIO pin mode, where
//   FSEL_INPT   = input
//   FSEL_OUTP   = output
//   FSEL_ALT0   = pulse width modulation (software based?)
//   FSEL_ALT5   = pulse width modulation (hardware based?)
void setGpioMode(int bcmGpioPin, int mode) {
  int offset = bcmGpioPin / 10;
  int shift = (bcmGpioPin % 10) * 3;
  *(gpio + offset) = (*(gpio + offset) & ~(7 << shift)) | ((mode & 0x7) << shift);
}

void pwmSetClock(int divisor) {
  divisor &= 4095;
  uint32_t pwm_control = *(pwm + PWM_CONTROL);  // preserve PWM_CONTROL

  // Stop PWM prior to stopping PWM clock in MS mode otherwise BUSY stays high.

  *(pwm + PWM_CONTROL) = 0;                     // Stop PWM

  // Stop PWM clock before changing divisor. The delay after this does need to
  // this big (95uS occasionally fails, 100uS OK), it's almost as though the BUSY
  // flag is not working properly in balanced mode. Without the delay when DIV is
  // adjusted the clock sometimes switches to very slow, once slow further DIV
  // adjustments do nothing and it's difficult to get out of this mode.

  *(clk + PWMCLK_CNTL) = BCM_PASSWORD | 0x01;   // Stop PWM Clock
  delayMicroseconds (110);   // prevents clock going sloooow

  while ((*(clk + PWMCLK_CNTL) & 0x80) != 0)    // Wait for clock to be !BUSY
    delayMicroseconds (1);

  *(clk + PWMCLK_DIV)  = BCM_PASSWORD | (divisor << 12);

  *(clk + PWMCLK_CNTL) = BCM_PASSWORD | 0x11;   // Start PWM clock
  *(pwm + PWM_CONTROL) = pwm_control;           // restore PWM_CONTROL
}

void pwmSetMode(int mode) {
  if (mode == PWM_MODE_MS)
    *(pwm + PWM_CONTROL) = PWM0_ENABLE | PWM1_ENABLE | PWM0_MS_MODE | PWM1_MS_MODE;
  else
    *(pwm + PWM_CONTROL) = PWM0_ENABLE | PWM1_ENABLE;
}

void pwmSetRange(unsigned int range) {
  *(pwm + PWM0_RANGE) = range; delayMicroseconds (10);
  *(pwm + PWM1_RANGE) = range; delayMicroseconds (10);
}

// Initialize a GPIO pin for input where pullUpDown is
//   0 = off
//   1 = pull down (low)
//   2 = pull up (high)
// void _setGpioInput(int bcmGpioPin, int pullUpDown) native "setGpioInput";
void setGpioInput(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle arg1 = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle arg2 = HandleError(Dart_GetNativeArgument(arguments, 2));

  int64_t bcmGpioPin;
  int64_t pullUpDown;
  HandleError(Dart_IntegerToInt64(arg1, &bcmGpioPin));
  HandleError(Dart_IntegerToInt64(arg2, &pullUpDown));

  setGpioMode(bcmGpioPin, FSEL_INPT);

  // 37 is GPIO up/down register, 38 and 39 are GPIO up/down set bits
  *(gpio + 37) = pullUpDown & 3;                                   delayMicroseconds (5);
  *(gpio + (bcmGpioPin < 32 ? 38 : 39)) = 1 << (bcmGpioPin & 31);  delayMicroseconds (5);

  *(gpio + 37) = 0;                                                delayMicroseconds (5);
  *(gpio + (bcmGpioPin < 32 ? 38 : 39)) = 0;                       delayMicroseconds (5);

  Dart_ExitScope();
}

// Initialize a GPIO pin for output.
// void _setGpioOutput(int bcmGpio) native "setGpioOutput";
void setGpioOutput(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle arg1 = HandleError(Dart_GetNativeArgument(arguments, 1));

  int64_t bcmGpioPin;
  HandleError(Dart_IntegerToInt64(arg1, &bcmGpioPin));

  setGpioMode(bcmGpioPin, FSEL_OUTP);

  Dart_ExitScope();
}

// Initialize a GPIO pin for pulse width modulated output.
// void _setGpioPwmOutput(int bcmGpio) native "setGpioPwmOutput";
void setGpioPwmOutput(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle arg1 = HandleError(Dart_GetNativeArgument(arguments, 1));

  int64_t bcmGpioPin;
  HandleError(Dart_IntegerToInt64(arg1, &bcmGpioPin));

  uint8_t pwmAlt = gpioToPwmALT[bcmGpioPin];
  if (pwmAlt != 0) {
    // From http://what-when-how.com/Tutorial/topic-535dm28c/Smart-Home-Automation-with-Linux-and-Raspberry-Pi-303.html

    *(pwm + PWM_CONTROL) = 0;                             // off

// ********************
//  Uncommenting pwmSetRange causes the RPi to lockup or go very sloooooooooowly
// ********************
//    pwmSetRange(1024);                                   // Default range of 1024
//    *(pwm + PWM0_RANGE) = 1024;

    pwmSetClock(32);                                     // 19.2 / 32 = 600KHz - Also starts the PWM

    setGpioMode(bcmGpioPin, pwmAlt);                     // turn on PWM for pin
    delayMicroseconds(110);                              // See comments in pwmSetClock

//    pwmSetMode(PWM_MODE_BAL);                             // Pi default mode
    *(pwm + PWM_CONTROL) = PWM0_ENABLE;                  // Pi default mode
//    *(pwm + PWM_CONTROL) = PWM0_ENABLE | PWM1_ENABLE;    // Pi default mode
  }

  Dart_ExitScope();
}

// Read the input voltage on a GPIO pin and return either true (high) or false (low).
// bool _readGpio(int bcmGpioPin) native "readGpio";
void readGpio(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle arg1 = HandleError(Dart_GetNativeArgument(arguments, 1));

  int64_t bcmGpioPin;
  HandleError(Dart_IntegerToInt64(arg1, &bcmGpioPin));

  // 13 and 14 are GPIO input bits
  bool value = (*(gpio + (bcmGpioPin < 32 ? 13 : 14)) & (1 << (bcmGpioPin & 31))) != 0;

  Dart_SetBooleanReturnValue(arguments, value);
  Dart_ExitScope();
}

// Set the output voltage on a GPIO pin to high (true) or low (false).
// void _writeGpio(int bcmGpioPin, bool newValue) native "writeGpio";
void writeGpio(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle arg1 = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle arg2 = HandleError(Dart_GetNativeArgument(arguments, 2));

  int64_t bcmGpioPin;
  bool newValue;
  HandleError(Dart_IntegerToInt64(arg1, &bcmGpioPin));
  HandleError(Dart_BooleanValue(arg2, &newValue));

  // 7 and 8 are set GPIO output HIGH bits, 10 and 11 are set GPIO output LOW bits.
  *(gpio + (newValue ? 7 : 10) + (bcmGpioPin < 32 ? 0 : 1)) = 1 << (bcmGpioPin & 31);

  Dart_ExitScope();
}

// Set the pulse width modulated output to a value between 0 (off) and 1024 (on).
// void _writePwmGpio(int bcmGpio, int newValue) native "writePwmGpio";
void writePwmGpio(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle arg1 = HandleError(Dart_GetNativeArgument(arguments, 1));
  Dart_Handle arg2 = HandleError(Dart_GetNativeArgument(arguments, 2));

  int64_t bcmGpioPin;
  int64_t newValue;
  HandleError(Dart_IntegerToInt64(arg1, &bcmGpioPin));
  HandleError(Dart_IntegerToInt64(arg2, &newValue));

  *(pwm + gpioToPwmPort[bcmGpioPin]) = newValue;

  Dart_ExitScope();
}

// ===== Infrastructure methods ===============================================

struct FunctionLookup {
  const char* name;
  Dart_NativeFunction function;
};

FunctionLookup function_list[] = {
  {"disposeGpio", disposeGpio},
  {"readGpio", readGpio},
  {"setGpioInput", setGpioInput},
  {"setGpioOutput", setGpioOutput},
  {"setGpioPwmOutput", setGpioPwmOutput},
  {"setupGpio", setupGpio},
  {"writeGpio", writeGpio},
  {"writePwmGpio", writePwmGpio},
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
  return Dart_Null();
}
