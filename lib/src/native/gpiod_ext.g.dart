//
// Generated from native/rpi_gpio_ext.cc
//
// ignore_for_file: slash_for_doc_comments
// ignore_for_file: lines_longer_than_80_chars

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;
import 'package:rpi_gpio/src/native/gpiod_ext.dart';
import 'package:rpi_gpio/src/native/gpiod_ext32.g.dart';
import 'package:rpi_gpio/src/native/gpiod_ext64.g.dart';
import 'package:rpi_gpio/src/native/rpi_platform.dart';

class NativePgkLib {
  final ffi.DynamicLibrary dyLib;

  /**
   * Close a GPIO chip handle and release all allocated resources.
   *
   * @param chip The GPIO chip object.
   */
  final GpiodChipClose gpiodChipClose;

  /**
   * Find a GPIO line by name among lines associated with given GPIO chip.
   *
   * @param chip The GPIO chip object.
   *
   * @param name The name of the GPIO line.
   *
   * @return Pointer to the GPIO line handle or NULL if the line could not be
   *         found or an error occurred.
   *
   * @note In case a line with given name is not associated with given chip, the
   *       function sets errno to ENOENT.
   *
   * @attention GPIO line names are not unique in the linux kernel, neither
   *            globally nor within a single chip. This function finds the first
   *            line with given name.
   */
  final GpiodChipFindLine gpiodChipFindLine;

  /**
   * Find a set of GPIO lines by names among lines exposed by this chip.
   *
   * @param chip The GPIO chip object.
   *
   * @param names Array of pointers to C-strings containing the names of the
   *              lines to lookup. Must end with a NULL-pointer.
   *
   * @param bulk Line bulk object in which the located lines will be stored.
   *
   * @return 0 if all lines were located, -1 on error.
   *
   * @note If at least one line from the list could not be found among the lines
   *       exposed by this chip, the function sets errno to ENOENT.
   *
   * @attention GPIO line names are not unique in the linux kernel, neither
   *            globally nor within a single chip. This function finds the first
   *            line with given name.
   */
  final GpiodChipFindLines gpiodChipFindLines;

  /**
   * Retrieve all lines exposed by a chip and store them in a bulk object.
   *
   * @param chip The GPIO chip object.
   *
   * @param bulk Line bulk object in which to store the line handles.
   *
   * @return 0 on success, -1 on error.
   */
  final GpiodChipGetAllLines gpiodChipGetAllLines;

  /**
   * Get the handle to the GPIO line at given offset.
   *
   * @param chip The GPIO chip object.
   *
   * @param offset The offset of the GPIO line.
   *
   * @return Pointer to the GPIO line handle or NULL if an error occured.
   */
  final GpiodChipGetLine gpiodChipGetLine;

  /**
   * Retrieve a set of lines and store them in a line bulk object.
   *
   * @param chip The GPIO chip object.
   *
   * @param offsets Array of offsets of lines to retrieve.
   *
   * @param num_offsets Number of lines to retrieve.
   *
   * @param bulk Line bulk object in which to store the line handles.
   *
   * @return 0 on success, -1 on error.
   */
  final GpiodChipGetLines gpiodChipGetLines;

  /**
   * Release all resources allocated for the gpiochip iterator and close
   *        the most recently opened gpiochip (if any).
   *
   * @param iter The gpiochip iterator object.
   */
  final GpiodChipIterFree gpiodChipIterFree;

  /**
   * Release all resources allocated for the gpiochip iterator but
   *        don't close the most recently opened gpiochip (if any).
   *
   * @param iter The gpiochip iterator object.
   *
   * Users may want to break the loop when iterating over gpiochips and keep
   * the most recently opened chip active while freeing the iterator data.
   * This routine enables that.
   */
  final GpiodChipIterFreeNoclose gpiodChipIterFreeNoclose;

  /**
   * Create a new gpiochip iterator.
   *
   * @return Pointer to a new chip iterator object or NULL if an error occurred.
   *
   * Internally this routine scans the /dev/ directory for GPIO chip device
   * files, opens them and stores their the handles until ::gpiod_chip_iter_free
   * or ::gpiod_chip_iter_free_noclose is called.
   */
  final GpiodChipIterNew gpiodChipIterNew;

  /**
   * Get the next gpiochip handle.
   *
   * @param iter The gpiochip iterator object.
   *
   * @return Pointer to the next open gpiochip handle or NULL if no more chips
   *         are present in the system.
   *
   * @note The previous chip handle will be closed using ::gpiod_chip_iter_free.
   */
  final GpiodChipIterNext gpiodChipIterNext;

  /**
   * Get the next gpiochip handle without closing the previous one.
   *
   * @param iter The gpiochip iterator object.
   *
   * @return Pointer to the next open gpiochip handle or NULL if no more chips
   *         are present in the system.
   *
   * @note This function works just like ::gpiod_chip_iter_next but doesn't
   *       close the most recently opened chip handle.
   */
  final GpiodChipIterNextNoclose gpiodChipIterNextNoclose;

  /**
   * Get the GPIO chip label as represented in the kernel.
   *
   * @param chip The GPIO chip object.
   *
   * @return Pointer to a human-readable string containing the chip label.
   */
  final GpiodChipLabel gpiodChipLabel;

  /**
   * Get the GPIO chip name as represented in the kernel.
   *
   * @param chip The GPIO chip object.
   *
   * @return Pointer to a human-readable string containing the chip name.
   */
  final GpiodChipName gpiodChipName;

  /**
   * Get the number of GPIO lines exposed by this chip.
   *
   * @param chip The GPIO chip object.
   *
   * @return Number of GPIO lines.
   */
  final GpiodChipNumLines gpiodChipNumLines;

  /**
   * Open a gpiochip by path.
   *
   * @param path Path to the gpiochip device file.
   *
   * @return GPIO chip handle or NULL if an error occurred.
   */
  final GpiodChipOpen gpiodChipOpen;

  /**
   * Open a gpiochip by label.
   *
   * @param label Label of the gpiochip to open.
   *
   * @return GPIO chip handle or NULL if the chip with given label was not found
   *         or an error occured.
   *
   * @note If the chip cannot be found but no other error occurred, errno is set
   *       to ENOENT.
   */
  final GpiodChipOpenByLabel gpiodChipOpenByLabel;

  /**
   * Open a gpiochip by name.
   *
   * @param name Name of the gpiochip to open.
   *
   * @return GPIO chip handle or NULL if an error occurred.
   *
   * This routine appends name to '/dev/' to create the path.
   */
  final GpiodChipOpenByName gpiodChipOpenByName;

  /**
   * Open a gpiochip by number.
   *
   * @param num Number of the gpiochip.
   *
   * @return GPIO chip handle or NULL if an error occurred.
   *
   * This routine appends num to '/dev/gpiochip' to create the path.
   */
  final GpiodChipOpenByNumber gpiodChipOpenByNumber;

  /**
   * Open a gpiochip based on the best guess what the path is.
   *
   * @param descr String describing the gpiochip.
   *
   * @return GPIO chip handle or NULL if an error occurred.
   *
   * This routine tries to figure out whether the user passed it the path to the
   * GPIO chip, its name, label or number as a string. Then it tries to open it
   * using one of the gpiod_chip_open** variants.
   */
  final GpiodChipOpenLookup gpiodChipOpenLookup;

  /**
   * Wait for events on a single GPIO line.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param event_type Type of events to listen for.
   *
   * @param offset GPIO line offset to monitor.
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param timeout Maximum wait time for each iteration.
   *
   * @param poll_cb Callback function to call when waiting for events.
   *
   * @param event_cb Callback function to call for each line event.
   *
   * @param data User data passed to the callback.
   *
   * @return 0 if no errors were encountered, -1 if an error occurred.
   *
   * @note The way the ctxless event loop works is described in detail in
   *       ::gpiod_ctxless_event_monitor_multiple - this is just a wrapper aound
   *       this routine which calls it for a single GPIO line.
   */
  // final GpiodCtxlessEventMonitor gpiodCtxlessEventMonitor;

  /**
   * Wait for events on a single GPIO line.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param event_type Type of events to listen for.
   *
   * @param offset GPIO line offset to monitor.
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param timeout Maximum wait time for each iteration.
   *
   * @param poll_cb Callback function to call when waiting for events.
   *
   * @param event_cb Callback function to call for each line event.
   *
   * @param data User data passed to the callback.
   *
   * @param flags The flags for the line.
   *
   * @return 0 if no errors were encountered, -1 if an error occurred.
   *
   * @note The way the ctxless event loop works is described in detail in
   *       ::gpiod_ctxless_event_monitor_multiple - this is just a wrapper aound
   *       this routine which calls it for a single GPIO line.
   */
  // final GpiodCtxlessEventMonitorExt gpiodCtxlessEventMonitorExt;

  /**
   * Wait for events on multiple GPIO lines.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param event_type Type of events to listen for.
   *
   * @param offsets Array of GPIO line offsets to monitor.
   *
   * @param num_lines Number of lines to monitor.
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param timeout Maximum wait time for each iteration.
   *
   * @param poll_cb Callback function to call when waiting for events. Can
   *                be NULL.
   *
   * @param event_cb Callback function to call on event occurrence.
   *
   * @param data User data passed to the callback.
   *
   * @return 0 no errors were encountered, -1 if an error occurred.
   *
   * @note The poll callback can be NULL in which case the routine will fall
   *       back to a basic, ppoll() based callback.
   *
   * Internally this routine opens the GPIO chip, requests the set of lines for
   * the type of events specified in the event_type parameter and calls the
   * polling callback in a loop. The role of the polling callback is to detect
   * input events on a set of file descriptors and notify the caller about the
   * fds ready for reading.
   *
   * The ctxless event loop then reads each queued event from marked descriptors
   * and calls the event callback. Both callbacks can stop the loop at any
   * point.
   *
   * The poll_cb argument can be NULL in which case the function falls back to
   * a default, ppoll() based callback.
   */
  // final GpiodCtxlessEventMonitorMultiple gpiodCtxlessEventMonitorMultiple;

  /**
   * Wait for events on multiple GPIO lines.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param event_type Type of events to listen for.
   *
   * @param offsets Array of GPIO line offsets to monitor.
   *
   * @param num_lines Number of lines to monitor.
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param timeout Maximum wait time for each iteration.
   *
   * @param poll_cb Callback function to call when waiting for events. Can
   *                be NULL.
   *
   * @param event_cb Callback function to call on event occurrence.
   *
   * @param data User data passed to the callback.
   *
   * @param flags The flags for the lines.
   *
   * @return 0 no errors were encountered, -1 if an error occurred.
   *
   * @note The poll callback can be NULL in which case the routine will fall
   *       back to a basic, ppoll() based callback.
   *
   * Internally this routine opens the GPIO chip, requests the set of lines for
   * the type of events specified in the event_type parameter and calls the
   * polling callback in a loop. The role of the polling callback is to detect
   * input events on a set of file descriptors and notify the caller about the
   * fds ready for reading.
   *
   * The ctxless event loop then reads each queued event from marked descriptors
   * and calls the event callback. Both callbacks can stop the loop at any
   * point.
   *
   * The poll_cb argument can be NULL in which case the function falls back to
   * a default, ppoll() based callback.
   */
  // final GpiodCtxlessEventMonitorMultipleExt gpiodCtxlessEventMonitorMultipleExt;

  /**
   * Determine the chip name and line offset of a line with given name.
   *
   * @param name The name of the GPIO line to lookup.
   *
   * @param chipname Buffer in which the name of the GPIO chip will be stored.
   *
   * @param chipname_size Size of the chip name buffer.
   *
   * @param offset Pointer to an integer in which the line offset will be stored.
   *
   * @return -1 on error, 0 if the line with given name doesn't exist and 1 if
   *         the line was found. In the first two cases the contents of chipname
   *         and offset remain unchanged.
   *
   * @note The chip name is truncated if the buffer can't hold its entire size.
   *
   * @attention GPIO line names are not unique in the linux kernel, neither
   *            globally nor within a single chip. This function finds the first
   *            line with given name.
   */
  final GpiodCtxlessFindLine gpiodCtxlessFindLine;

  /**
   * Read current value from a single GPIO line.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param offset Offset of the GPIO line.
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 or 1 (GPIO value) if the operation succeeds, -1 on error.
   */
  final GpiodCtxlessGetValue gpiodCtxlessGetValue;

  /**
   * Read current value from a single GPIO line.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param offset Offset of the GPIO line.
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags The flags for the line.
   *
   * @return 0 or 1 (GPIO value) if the operation succeeds, -1 on error.
   */
  final GpiodCtxlessGetValueExt gpiodCtxlessGetValueExt;

  /**
   * Read current values from a set of GPIO lines.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param offsets Array of offsets of lines whose values should be read.
   *
   * @param values Buffer in which the values will be stored.
   *
   * @param num_lines Number of lines, must be > 0.
   *
   * @param active_low The active state of the lines - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 if the operation succeeds, -1 on error.
   */
  final GpiodCtxlessGetValueMultiple gpiodCtxlessGetValueMultiple;

  /**
   * Read current values from a set of GPIO lines.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param offsets Array of offsets of lines whose values should be read.
   *
   * @param values Buffer in which the values will be stored.
   *
   * @param num_lines Number of lines, must be > 0.
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags The flags for the lines.
   *
   * @return 0 if the operation succeeds, -1 on error.
   */
  final GpiodCtxlessGetValueMultipleExt gpiodCtxlessGetValueMultipleExt;

  /**
   * Set value of a single GPIO line.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param offset The offset of the GPIO line.
   *
   * @param value New value (0 or 1).
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param cb Optional callback function that will be called right after setting
   *           the value. Users can use this, for example, to pause the execution
   *           after toggling a GPIO.
   *
   * @param data Optional user data that will be passed to the callback function.
   *
   * @return 0 if the operation succeeds, -1 on error.
   */
  // final GpiodCtxlessSetValue gpiodCtxlessSetValue;

  /**
   * Set value of a single GPIO line.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param offset The offset of the GPIO line.
   *
   * @param value New value (0 or 1).
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param cb Optional callback function that will be called right after setting
   *           the value. Users can use this, for example, to pause the execution
   *           after toggling a GPIO.
   *
   * @param data Optional user data that will be passed to the callback function.
   *
   * @param flags The flags for the line.
   *
   * @return 0 if the operation succeeds, -1 on error.
   */
  // final GpiodCtxlessSetValueExt gpiodCtxlessSetValueExt;

  /**
   * Set values of multiple GPIO lines.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param offsets Array of offsets of lines the values of which should be set.
   *
   * @param values Array of integers containing new values.
   *
   * @param num_lines Number of lines, must be > 0.
   *
   * @param active_low The active state of the lines - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param cb Optional callback function that will be called right after setting
   *           all values. Works the same as in ::gpiod_ctxless_set_value.
   *
   * @param data Optional user data that will be passed to the callback function.
   *
   * @return 0 if the operation succeeds, -1 on error.
   */
  // final GpiodCtxlessSetValueMultiple gpiodCtxlessSetValueMultiple;

  /**
   * Set values of multiple GPIO lines.
   *
   * @param device Name, path, number or label of the gpiochip.
   *
   * @param offsets Array of offsets of lines the values of which should be set.
   *
   * @param values Array of integers containing new values.
   *
   * @param num_lines Number of lines, must be > 0.
   *
   * @param active_low The active state of this line - true if low.
   *
   * @param consumer Name of the consumer.
   *
   * @param cb Optional callback function that will be called right after setting
   *           all values. Works the same as in ::gpiod_ctxless_set_value.
   *
   * @param data Optional user data that will be passed to the callback function.
   *
   * @param flags The flags for the lines.
   *
   * @return 0 if the operation succeeds, -1 on error.
   */
  // final GpiodCtxlessSetValueMultipleExt gpiodCtxlessSetValueMultipleExt;

  /**
   * Read the GPIO line active state setting.
   *
   * @param line GPIO line object.
   *
   * @return Returns GPIOD_LINE_ACTIVE_STATE_HIGH or GPIOD_LINE_ACTIVE_STATE_LOW.
   */
  final GpiodLineActiveState gpiodLineActiveState;

  /**
   * Read the GPIO line bias setting.
   *
   * @param line GPIO line object.
   *
   * @return Returns GPIOD_LINE_BIAS_PULL_UP, GPIOD_LINE_BIAS_PULL_DOWN,
   *         GPIOD_LINE_BIAS_DISABLE or GPIOD_LINE_BIAS_AS_IS.
   */
  final GpiodLineBias gpiodLineBias;

  /**
   * Close a GPIO chip owning this line and release all resources.
   *
   * @param line GPIO line object
   *
   * After this function returns, the line must no longer be used.
   */
  final GpiodLineCloseChip gpiodLineCloseChip;

  /**
   * Read the GPIO line consumer name.
   *
   * @param line GPIO line object.
   *
   * @return Name of the GPIO consumer name as it is represented in the
   *         kernel. This routine returns a pointer to a null-terminated string
   *         or NULL if the line is not used.
   */
  final GpiodLineConsumer gpiodLineConsumer;

  /**
   * Read the GPIO line direction setting.
   *
   * @param line GPIO line object.
   *
   * @return Returns GPIOD_LINE_DIRECTION_INPUT or GPIOD_LINE_DIRECTION_OUTPUT.
   */
  final GpiodLineDirection gpiodLineDirection;

  /**
   * Get the event file descriptor.
   *
   * @param line GPIO line object.
   *
   * @return Number of the event file descriptor or -1 if the user tries to
   *         retrieve the descriptor from a line that wasn't configured for
   *         event monitoring.
   *
   * Users may want to poll the event file descriptor on their own. This routine
   * allows to access it.
   */
  final GpiodLineEventGetFd gpiodLineEventGetFd;

  /**
   * Read next pending event from the GPIO line.
   *
   * @param line GPIO line object.
   *
   * @param event Buffer to which the event data will be copied.
   *
   * @return 0 if the event was read correctly, -1 on error.
   *
   * @note This function will block if no event was queued for this line.
   */
  final GpiodLineEventRead gpiodLineEventRead;

  /**
   * Read the last GPIO event directly from a file descriptor.
   *
   * @param fd File descriptor.
   *
   * @param event Buffer in which the event data will be stored.
   *
   * @return 0 if the event was read correctly, -1 on error.
   *
   * Users who directly poll the file descriptor for incoming events can also
   * directly read the event data from it using this routine. This function
   * translates the kernel representation of the event to the libgpiod format.
   */
  final GpiodLineEventReadFd gpiodLineEventReadFd;

  /**
   * Read up to a certain number of events directly from a file descriptor.
   *
   * @param fd File descriptor.
   *
   * @param events Buffer to which the event data will be copied. Must hold at
   *               least the amount of events specified in num_events.
   *
   * @param num_events Specifies how many events can be stored in the buffer.
   *
   * @return On success returns the number of events stored in the buffer, on
   *         failure -1 is returned.
   */
  final GpiodLineEventReadFdMultiple gpiodLineEventReadFdMultiple;

  /**
   * Read up to a certain number of events from the GPIO line.
   *
   * @param line GPIO line object.
   *
   * @param events Buffer to which the event data will be copied. Must hold at
   *               least the amount of events specified in num_events.
   *
   * @param num_events Specifies how many events can be stored in the buffer.
   *
   * @return On success returns the number of events stored in the buffer, on
   *         failure -1 is returned.
   */
  final GpiodLineEventReadMultiple gpiodLineEventReadMultiple;

  /**
   * Wait for an event on a single line.
   *
   * @param line GPIO line object.
   *
   * @param timeout Wait time limit.
   *
   * @return 0 if wait timed out, -1 if an error occurred, 1 if an event
   *         occurred.
   */
  final GpiodLineEventWait gpiodLineEventWait;

  /**
   * Wait for events on a set of lines.
   *
   * @param bulk Set of GPIO lines to monitor.
   *
   * @param timeout Wait time limit.
   *
   * @param event_bulk Bulk object in which to store the line handles on which
   *                   events occurred. Can be NULL.
   *
   * @return 0 if wait timed out, -1 if an error occurred, 1 if at least one
   *         event occurred.
   */
  // final GpiodLineEventWaitBulk gpiodLineEventWaitBulk;

  /**
   * Find a GPIO line by its name.
   *
   * @param name Name of the GPIO line.
   *
   * @return Returns the GPIO line handle if the line exists in the system or
   *         NULL if it couldn't be located or an error occurred.
   *
   * @attention GPIO lines are not unique in the linux kernel, neither globally
   *            nor within a single chip. This function finds the first line with
   *            given name.
   *
   * If this routine succeeds, the user must manually close the GPIO chip owning
   * this line to avoid memory leaks. If the line could not be found, this
   * functions sets errno to ENOENT.
   */
  final GpiodLineFind gpiodLineFind;

  /**
   * Get a GPIO line handle by GPIO chip description and offset.
   *
   * @param device String describing the gpiochip.
   *
   * @param offset The offset of the GPIO line.
   *
   * @return GPIO line handle or NULL if an error occurred.
   *
   * This routine provides a shorter alternative to calling
   * ::gpiod_chip_open_lookup and ::gpiod_chip_get_line.
   *
   * If this function succeeds, the caller is responsible for closing the
   * associated GPIO chip.
   */
  final GpiodLineGet gpiodLineGet;

  /**
   * Get the handle to the GPIO chip controlling this line.
   *
   * @param line The GPIO line object.
   *
   * @return Pointer to the GPIO chip handle controlling this line.
   */
  final GpiodLineGetChip gpiodLineGetChip;

  /**
   * Read current value of a single GPIO line.
   *
   * @param line GPIO line object.
   *
   * @return 0 or 1 if the operation succeeds. On error this routine returns -1
   *         and sets the last error number.
   */
  final GpiodLineGetValue gpiodLineGetValue;

  /**
   * Read current values of a set of GPIO lines.
   *
   * @param bulk Set of GPIO lines to reserve.
   *
   * @param values An array big enough to hold line_bulk->num_lines values.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   *
   * If succeeds, this routine fills the values array with a set of values in
   * the same order, the lines are added to line_bulk. If the lines were not
   * previously requested together, the behavior is undefined.
   */
  final GpiodLineGetValueBulk gpiodLineGetValueBulk;

  /**
   * Check if the calling user has neither requested ownership of this
   *        line nor configured any event notifications.
   *
   * @param line GPIO line object.
   *
   * @return True if given line is free, false otherwise.
   */
  final GpiodLineIsFree gpiodLineIsFree;

  /**
   * Check if the line is an open-drain GPIO.
   *
   * @param line GPIO line object.
   *
   * @return True if the line is an open-drain GPIO, false otherwise.
   */
  final GpiodLineIsOpenDrain gpiodLineIsOpenDrain;

  /**
   * Check if the line is an open-source GPIO.
   *
   * @param line GPIO line object.
   *
   * @return True if the line is an open-source GPIO, false otherwise.
   */
  final GpiodLineIsOpenSource gpiodLineIsOpenSource;

  /**
   * Check if the calling user has ownership of this line.
   *
   * @param line GPIO line object.
   *
   * @return True if given line was requested, false otherwise.
   */
  final GpiodLineIsRequested gpiodLineIsRequested;

  /**
   * Check if the line is currently in use.
   *
   * @param line GPIO line object.
   *
   * @return True if the line is in use, false otherwise.
   *
   * The user space can't know exactly why a line is busy. It may have been
   * requested by another process or hogged by the kernel. It only matters that
   * the line is used and we can't request it.
   */
  final GpiodLineIsUsed gpiodLineIsUsed;

  /**
   * Free all resources associated with a GPIO line iterator.
   *
   * @param iter Line iterator object.
   */
  final GpiodLineIterFree gpiodLineIterFree;

  /**
   * Create a new line iterator.
   *
   * @param chip Active gpiochip handle over the lines of which we want
   *             to iterate.
   *
   * @return New line iterator or NULL if an error occurred.
   */
  final GpiodLineIterNew gpiodLineIterNew;

  /**
   * Get the next GPIO line handle.
   *
   * @param iter The GPIO line iterator object.
   *
   * @return Pointer to the next GPIO line handle or NULL if there are no more
   *         lines left.
   */
  final GpiodLineIterNext gpiodLineIterNext;

  /**
   * Read the GPIO line name.
   *
   * @param line GPIO line object.
   *
   * @return Name of the GPIO line as it is represented in the kernel. This
   *         routine returns a pointer to a null-terminated string or NULL if
   *         the line is unnamed.
   */
  final GpiodLineName gpiodLineName;

  /**
   * Read the GPIO line offset.
   *
   * @param line GPIO line object.
   *
   * @return Line offset.
   */
  final GpiodLineOffset gpiodLineOffset;

  /**
   * Release a previously reserved line.
   *
   * @param line GPIO line object.
   */
  final GpiodLineRelease gpiodLineRelease;

  /**
   * Release a set of previously reserved lines.
   *
   * @param bulk Set of GPIO lines to release.
   *
   * If the lines were not previously requested together, the behavior is
   * undefined.
   */
  final GpiodLineReleaseBulk gpiodLineReleaseBulk;

  /**
   * Reserve a single line.
   *
   * @param line GPIO line object.
   *
   * @param config Request options.
   *
   * @param default_val Initial line value - only relevant if we're setting
   *                    the direction to output.
   *
   * @return 0 if the line was properly reserved. In case of an error this
   *         routine returns -1 and sets the last error number.
   *
   * If this routine succeeds, the caller takes ownership of the GPIO line until
   * it's released.
   */
  final GpiodLineRequest gpiodLineRequest;

  /**
   * Request all event type notifications on a single line.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestBothEdgesEvents gpiodLineRequestBothEdgesEvents;

  /**
   * Request all event type notifications on a single line.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestBothEdgesEventsFlags gpiodLineRequestBothEdgesEventsFlags;

  /**
   * Reserve a set of GPIO lines.
   *
   * @param bulk Set of GPIO lines to reserve.
   *
   * @param config Request options.
   *
   * @param default_vals Initial line values - only relevant if we're setting
   *                     the direction to output.
   *
   * @return 0 if the all lines were properly requested. In case of an error
   *         this routine returns -1 and sets the last error number.
   *
   * If this routine succeeds, the caller takes ownership of the GPIO lines
   * until they're released. All the requested lines must be prodivided by the
   * same gpiochip.
   */
  final GpiodLineRequestBulk gpiodLineRequestBulk;

  /**
   * Request all event type notifications on a set of lines.
   *
   * @param bulk Set of GPIO lines to request.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestBulkBothEdgesEvents gpiodLineRequestBulkBothEdgesEvents;

  /**
   * Request all event type notifications on a set of lines.
   *
   * @param bulk Set of GPIO lines to request.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestBulkBothEdgesEventsFlags gpiodLineRequestBulkBothEdgesEventsFlags;

  /**
   * Request falling edge event notifications on a set of lines.
   *
   * @param bulk Set of GPIO lines to request.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestBulkFallingEdgeEvents gpiodLineRequestBulkFallingEdgeEvents;

  /**
   * Request falling edge event notifications on a set of lines.
   *
   * @param bulk Set of GPIO lines to request.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestBulkFallingEdgeEventsFlags gpiodLineRequestBulkFallingEdgeEventsFlags;

  /**
   * Reserve a set of GPIO lines, set the direction to input.
   *
   * @param bulk Set of GPIO lines to reserve.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 if the lines were properly reserved, -1 on failure.
   */
  final GpiodLineRequestBulkInput gpiodLineRequestBulkInput;

  /**
   * Reserve a set of GPIO lines, set the direction to input.
   *
   * @param bulk Set of GPIO lines to reserve.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @return 0 if the lines were properly reserved, -1 on failure.
   */
  final GpiodLineRequestBulkInputFlags gpiodLineRequestBulkInputFlags;

  /**
   * Reserve a set of GPIO lines, set the direction to output.
   *
   * @param bulk Set of GPIO lines to reserve.
   *
   * @param consumer Name of the consumer.
   *
   * @param default_vals Initial line values.
   *
   * @return 0 if the lines were properly reserved, -1 on failure.
   */
  final GpiodLineRequestBulkOutput gpiodLineRequestBulkOutput;

  /**
   * Reserve a set of GPIO lines, set the direction to output.
   *
   * @param bulk Set of GPIO lines to reserve.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @param default_vals Initial line values.
   *
   * @return 0 if the lines were properly reserved, -1 on failure.
   */
  final GpiodLineRequestBulkOutputFlags gpiodLineRequestBulkOutputFlags;

  /**
   * Request rising edge event notifications on a set of lines.
   *
   * @param bulk Set of GPIO lines to request.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestBulkRisingEdgeEvents gpiodLineRequestBulkRisingEdgeEvents;

  /**
   * Request rising edge event notifications on a set of lines.
   *
   * @param bulk Set of GPIO lines to request.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestBulkRisingEdgeEventsFlags gpiodLineRequestBulkRisingEdgeEventsFlags;

  /**
   * Request falling edge event notifications on a single line.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestFallingEdgeEvents gpiodLineRequestFallingEdgeEvents;

  /**
   * Request falling edge event notifications on a single line.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestFallingEdgeEventsFlags gpiodLineRequestFallingEdgeEventsFlags;

  /**
   * Reserve a single line, set the direction to input.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 if the line was properly reserved, -1 on failure.
   */
  final GpiodLineRequestInput gpiodLineRequestInput;

  /**
   * Reserve a single line, set the direction to input.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @return 0 if the line was properly reserved, -1 on failure.
   */
  final GpiodLineRequestInputFlags gpiodLineRequestInputFlags;

  /**
   * Reserve a single line, set the direction to output.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @param default_val Initial line value.
   *
   * @return 0 if the line was properly reserved, -1 on failure.
   */
  final GpiodLineRequestOutput gpiodLineRequestOutput;

  /**
   * Reserve a single line, set the direction to output.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @param default_val Initial line value.
   *
   * @return 0 if the line was properly reserved, -1 on failure.
   */
  final GpiodLineRequestOutputFlags gpiodLineRequestOutputFlags;

  /**
   * Request rising edge event notifications on a single line.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestRisingEdgeEvents gpiodLineRequestRisingEdgeEvents;

  /**
   * Request rising edge event notifications on a single line.
   *
   * @param line GPIO line object.
   *
   * @param consumer Name of the consumer.
   *
   * @param flags Additional request flags.
   *
   * @return 0 if the operation succeeds, -1 on failure.
   */
  final GpiodLineRequestRisingEdgeEventsFlags gpiodLineRequestRisingEdgeEventsFlags;

  /**
   * Update the configuration of a single GPIO line.
   *
   * @param line GPIO line object.
   *
   * @param direction Updated direction which may be one of
   *                  GPIOD_LINE_REQUEST_DIRECTION_AS_IS,
   *                  GPIOD_LINE_REQUEST_DIRECTION_INPUT, or
   *                  GPIOD_LINE_REQUEST_DIRECTION_OUTPUT.
   *
   * @param flags Replacement flags.
   *
   * @param value The new output value for the line when direction is
   *              GPIOD_LINE_REQUEST_DIRECTION_OUTPUT.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   */
  final GpiodLineSetConfig gpiodLineSetConfig;

  /**
   * Update the configuration of a set of GPIO lines.
   *
   * @param bulk Set of GPIO lines.
   *
   * @param direction Updated direction which may be one of
   *                  GPIOD_LINE_REQUEST_DIRECTION_AS_IS,
   *                  GPIOD_LINE_REQUEST_DIRECTION_INPUT, or
   *                  GPIOD_LINE_REQUEST_DIRECTION_OUTPUT.
   *
   * @param flags Replacement flags.
   *
   * @param values An array holding line_bulk->num_lines new logical values
   *               for lines when direction is
   *               GPIOD_LINE_REQUEST_DIRECTION_OUTPUT.
   *               A NULL pointer is interpreted as a logical low for all lines.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   *
   * If the lines were not previously requested together, the behavior is
   * undefined.
   */
  final GpiodLineSetConfigBulk gpiodLineSetConfigBulk;

  /**
   * Set the direction of a single GPIO line to input.
   *
   * @param line GPIO line object.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   */
  final GpiodLineSetDirectionInput gpiodLineSetDirectionInput;

  /**
   * Set the direction of a set of GPIO lines to input.
   *
   * @param bulk Set of GPIO lines.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   *
   * If the lines were not previously requested together, the behavior is
   * undefined.
   */
  final GpiodLineSetDirectionInputBulk gpiodLineSetDirectionInputBulk;

  /**
   * Set the direction of a single GPIO line to output.
   *
   * @param line GPIO line object.
   *
   * @param value The logical value output on the line.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   */
  final GpiodLineSetDirectionOutput gpiodLineSetDirectionOutput;

  /**
   * Set the direction of a set of GPIO lines to output.
   *
   * @param bulk Set of GPIO lines.
   *
   * @param values An array holding line_bulk->num_lines new logical values
   *               for lines.  A NULL pointer is interpreted as a logical low
   *               for all lines.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   *
   * If the lines were not previously requested together, the behavior is
   * undefined.
   */
  final GpiodLineSetDirectionOutputBulk gpiodLineSetDirectionOutputBulk;

  /**
   * Update the configuration flags of a single GPIO line.
   *
   * @param line GPIO line object.
   *
   * @param flags Replacement flags.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   */
  final GpiodLineSetFlags gpiodLineSetFlags;

  /**
   * Update the configuration flags of a set of GPIO lines.
   *
   * @param bulk Set of GPIO lines.
   *
   * @param flags Replacement flags.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   *
   * If the lines were not previously requested together, the behavior is
   * undefined.
   */
  final GpiodLineSetFlagsBulk gpiodLineSetFlagsBulk;

  /**
   * Set the value of a single GPIO line.
   *
   * @param line GPIO line object.
   *
   * @param value New value.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   */
  final GpiodLineSetValue gpiodLineSetValue;

  /**
   * Set the values of a set of GPIO lines.
   *
   * @param bulk Set of GPIO lines to reserve.
   *
   * @param values An array holding line_bulk->num_lines new values for lines.
   *               A NULL pointer is interpreted as a logical low for all lines.
   *
   * @return 0 is the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   *
   * If the lines were not previously requested together, the behavior is
   * undefined.
   */
  final GpiodLineSetValueBulk gpiodLineSetValueBulk;

  /**
   * Re-read the line info.
   *
   * @param line GPIO line object.
   *
   * @return 0 if the operation succeeds. In case of an error this routine
   *         returns -1 and sets the last error number.
   *
   * The line info is initially retrieved from the kernel by
   * gpiod_chip_get_line() and is later re-read after every successful request.
   * Users can use this function to manually re-read the line info when needed.
   *
   * We currently have no mechanism provided by the kernel for keeping the line
   * info synchronized and for the sake of speed and simplicity of this low-level
   * library we don't want to re-read the line info automatically everytime
   * a property is retrieved. Any daemon using this library must track the state
   * of lines on its own and call this routine if needed.
   *
   * The state of requested lines is kept synchronized (or rather cannot be
   * changed by external agents while the ownership of the line is taken) so
   * there's no need to call this function in that case.
   */
  final GpiodLineUpdate gpiodLineUpdate;

  /**
   * Get the API version of the library as a human-readable string.
   *
   * @return Human-readable string containing the library version.
   */
  final GpiodVersionString gpiodVersionString;

  factory NativePgkLib(ffi.DynamicLibrary dylib, {bool? is64Bit}) => //
      is64Bit ?? RpiPlatform.current.is64Bit //
          ? NativePgkLib64(dylib)
          : NativePgkLib32(dylib);

  NativePgkLib.base(
    this.dyLib,
    this.gpiodChipClose,
    this.gpiodChipFindLine,
    this.gpiodChipFindLines,
    this.gpiodChipGetAllLines,
    this.gpiodChipGetLine,
    this.gpiodChipGetLines,
    this.gpiodChipIterFree,
    this.gpiodChipIterFreeNoclose,
    this.gpiodChipIterNew,
    this.gpiodChipIterNext,
    this.gpiodChipIterNextNoclose,
    this.gpiodChipLabel,
    this.gpiodChipName,
    this.gpiodChipNumLines,
    this.gpiodChipOpen,
    this.gpiodChipOpenByLabel,
    this.gpiodChipOpenByName,
    this.gpiodChipOpenByNumber,
    this.gpiodChipOpenLookup,
    // this.gpiodCtxlessEventMonitor,
    // this.gpiodCtxlessEventMonitorExt,
    // this.gpiodCtxlessEventMonitorMultiple,
    // this.gpiodCtxlessEventMonitorMultipleExt,
    this.gpiodCtxlessFindLine,
    this.gpiodCtxlessGetValue,
    this.gpiodCtxlessGetValueExt,
    this.gpiodCtxlessGetValueMultiple,
    this.gpiodCtxlessGetValueMultipleExt,
    // this.gpiodCtxlessSetValue,
    // this.gpiodCtxlessSetValueExt,
    // this.gpiodCtxlessSetValueMultiple,
    // this.gpiodCtxlessSetValueMultipleExt,
    this.gpiodLineActiveState,
    this.gpiodLineBias,
    this.gpiodLineCloseChip,
    this.gpiodLineConsumer,
    this.gpiodLineDirection,
    this.gpiodLineEventGetFd,
    this.gpiodLineEventRead,
    this.gpiodLineEventReadFd,
    this.gpiodLineEventReadFdMultiple,
    this.gpiodLineEventReadMultiple,
    this.gpiodLineEventWait,
    // this.gpiodLineEventWaitBulk,
    this.gpiodLineFind,
    this.gpiodLineGet,
    this.gpiodLineGetChip,
    this.gpiodLineGetValue,
    this.gpiodLineGetValueBulk,
    this.gpiodLineIsFree,
    this.gpiodLineIsOpenDrain,
    this.gpiodLineIsOpenSource,
    this.gpiodLineIsRequested,
    this.gpiodLineIsUsed,
    this.gpiodLineIterFree,
    this.gpiodLineIterNew,
    this.gpiodLineIterNext,
    this.gpiodLineName,
    this.gpiodLineOffset,
    this.gpiodLineRelease,
    this.gpiodLineReleaseBulk,
    this.gpiodLineRequest,
    this.gpiodLineRequestBothEdgesEvents,
    this.gpiodLineRequestBothEdgesEventsFlags,
    this.gpiodLineRequestBulk,
    this.gpiodLineRequestBulkBothEdgesEvents,
    this.gpiodLineRequestBulkBothEdgesEventsFlags,
    this.gpiodLineRequestBulkFallingEdgeEvents,
    this.gpiodLineRequestBulkFallingEdgeEventsFlags,
    this.gpiodLineRequestBulkInput,
    this.gpiodLineRequestBulkInputFlags,
    this.gpiodLineRequestBulkOutput,
    this.gpiodLineRequestBulkOutputFlags,
    this.gpiodLineRequestBulkRisingEdgeEvents,
    this.gpiodLineRequestBulkRisingEdgeEventsFlags,
    this.gpiodLineRequestFallingEdgeEvents,
    this.gpiodLineRequestFallingEdgeEventsFlags,
    this.gpiodLineRequestInput,
    this.gpiodLineRequestInputFlags,
    this.gpiodLineRequestOutput,
    this.gpiodLineRequestOutputFlags,
    this.gpiodLineRequestRisingEdgeEvents,
    this.gpiodLineRequestRisingEdgeEventsFlags,
    this.gpiodLineSetConfig,
    this.gpiodLineSetConfigBulk,
    this.gpiodLineSetDirectionInput,
    this.gpiodLineSetDirectionInputBulk,
    this.gpiodLineSetDirectionOutput,
    this.gpiodLineSetDirectionOutputBulk,
    this.gpiodLineSetFlags,
    this.gpiodLineSetFlagsBulk,
    this.gpiodLineSetValue,
    this.gpiodLineSetValueBulk,
    this.gpiodLineUpdate,
    this.gpiodVersionString,
  );
}

// Structs

sealed class GpiodChip extends ffi.Opaque {}
sealed class GpiodChipIter extends ffi.Opaque {}
sealed class GpiodCtxlessEventPollFd extends ffi.Opaque {}
sealed class GpiodLine extends ffi.Opaque {}
sealed class GpiodLineBulk extends ffi.Opaque {}
sealed class GpiodLineIter extends ffi.Opaque {}
sealed class GpiodLineRequestConfig extends ffi.Opaque {}

// Functions

typedef GpiodChipClose = void Function(ffi.Pointer<GpiodChip>);
typedef GpiodChipFindLine = ffi.Pointer<GpiodLine> Function(ffi.Pointer<GpiodChip>, ffi.Pointer<ffi.Utf8>);
typedef GpiodChipFindLines = int Function(ffi.Pointer<GpiodChip>, ffi.Pointer<ffi.Pointer<ffi.Utf8>>, ffi.Pointer<GpiodLineBulk>);
typedef GpiodChipGetAllLines = int Function(ffi.Pointer<GpiodChip>, ffi.Pointer<GpiodLineBulk>);
typedef GpiodChipGetLine = ffi.Pointer<GpiodLine> Function(ffi.Pointer<GpiodChip>, int);
typedef GpiodChipGetLines = int Function(ffi.Pointer<GpiodChip>, ffi.Pointer, int, ffi.Pointer<GpiodLineBulk>);
typedef GpiodChipIterFree = void Function(ffi.Pointer<GpiodChipIter>);
typedef GpiodChipIterFreeNoclose = void Function(ffi.Pointer<GpiodChipIter>);
typedef GpiodChipIterNew = ffi.Pointer<GpiodChipIter> Function();
typedef GpiodChipIterNext = ffi.Pointer<GpiodChip> Function(ffi.Pointer<GpiodChipIter>);
typedef GpiodChipIterNextNoclose = ffi.Pointer<GpiodChip> Function(ffi.Pointer<GpiodChipIter>);
typedef GpiodChipLabel = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<GpiodChip>);
typedef GpiodChipName = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<GpiodChip>);
typedef GpiodChipNumLines = int Function(ffi.Pointer<GpiodChip>);
typedef GpiodChipOpen = ffi.Pointer<GpiodChip> Function(ffi.Pointer<ffi.Utf8>);
typedef GpiodChipOpenByLabel = ffi.Pointer<GpiodChip> Function(ffi.Pointer<ffi.Utf8>);
typedef GpiodChipOpenByName = ffi.Pointer<GpiodChip> Function(ffi.Pointer<ffi.Utf8>);
typedef GpiodChipOpenByNumber = ffi.Pointer<GpiodChip> Function(int);
typedef GpiodChipOpenLookup = ffi.Pointer<GpiodChip> Function(ffi.Pointer<ffi.Utf8>);
// typedef GpiodCtxlessEventMonitor = int Function(ffi.Pointer<ffi.Utf8>, int, int, bool, ffi.Pointer<ffi.Utf8>, ffi.Pointer<Timespec>, GpiodCtxlessEventPollCb, GpiodCtxlessEventHandleCb, ffi.Pointer<ffi.Void>);
// typedef GpiodCtxlessEventMonitorExt = int Function(ffi.Pointer<ffi.Utf8>, int, int, bool, ffi.Pointer<ffi.Utf8>, ffi.Pointer<Timespec>, GpiodCtxlessEventPollCb, GpiodCtxlessEventHandleCb, ffi.Pointer<ffi.Void>, int);
// typedef GpiodCtxlessEventMonitorMultiple = int Function(ffi.Pointer<ffi.Utf8>, int, ffi.Pointer, int, bool, ffi.Pointer<ffi.Utf8>, ffi.Pointer<Timespec>, GpiodCtxlessEventPollCb, GpiodCtxlessEventHandleCb, ffi.Pointer<ffi.Void>);
// typedef GpiodCtxlessEventMonitorMultipleExt = int Function(ffi.Pointer<ffi.Utf8>, int, ffi.Pointer, int, bool, ffi.Pointer<ffi.Utf8>, ffi.Pointer<Timespec>, GpiodCtxlessEventPollCb, GpiodCtxlessEventHandleCb, ffi.Pointer<ffi.Void>, int);
typedef GpiodCtxlessFindLine = int Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>, int, ffi.Pointer);
typedef GpiodCtxlessGetValue = int Function(ffi.Pointer<ffi.Utf8>, int, bool, ffi.Pointer<ffi.Utf8>);
typedef GpiodCtxlessGetValueExt = int Function(ffi.Pointer<ffi.Utf8>, int, bool, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodCtxlessGetValueMultiple = int Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer, ffi.Pointer, int, bool, ffi.Pointer<ffi.Utf8>);
typedef GpiodCtxlessGetValueMultipleExt = int Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer, ffi.Pointer, int, bool, ffi.Pointer<ffi.Utf8>, int);
// typedef GpiodCtxlessSetValue = int Function(ffi.Pointer<ffi.Utf8>, int, int, bool, ffi.Pointer<ffi.Utf8>, GpiodCtxlessSetValueCb, ffi.Pointer<ffi.Void>);
// typedef GpiodCtxlessSetValueExt = int Function(ffi.Pointer<ffi.Utf8>, int, int, bool, ffi.Pointer<ffi.Utf8>, GpiodCtxlessSetValueCb, ffi.Pointer<ffi.Void>, int);
// typedef GpiodCtxlessSetValueMultiple = int Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer, ffi.Pointer, int, bool, ffi.Pointer<ffi.Utf8>, GpiodCtxlessSetValueCb, ffi.Pointer<ffi.Void>);
// typedef GpiodCtxlessSetValueMultipleExt = int Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer, ffi.Pointer, int, bool, ffi.Pointer<ffi.Utf8>, GpiodCtxlessSetValueCb, ffi.Pointer<ffi.Void>, int);
typedef GpiodLineActiveState = int Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineBias = int Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineCloseChip = void Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineConsumer = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineDirection = int Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineEventGetFd = int Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineEventRead = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<GpiodLineEvent>);
typedef GpiodLineEventReadFd = int Function(int, ffi.Pointer<GpiodLineEvent>);
typedef GpiodLineEventReadFdMultiple = int Function(int, ffi.Pointer<GpiodLineEvent>, int);
typedef GpiodLineEventReadMultiple = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<GpiodLineEvent>, int);
typedef GpiodLineEventWait = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<Timespec>);
// typedef GpiodLineEventWaitBulk = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<Timespec>, ffi.Pointer<GpiodLineBulk>);
typedef GpiodLineFind = ffi.Pointer<GpiodLine> Function(ffi.Pointer<ffi.Utf8>);
typedef GpiodLineGet = ffi.Pointer<GpiodLine> Function(ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineGetChip = ffi.Pointer<GpiodChip> Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineGetValue = int Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineGetValueBulk = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer);
typedef GpiodLineIsFree = bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIsOpenDrain = bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIsOpenSource = bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIsRequested = bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIsUsed = bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIterFree = void Function(ffi.Pointer<GpiodLineIter>);
typedef GpiodLineIterNew = ffi.Pointer<GpiodLineIter> Function(ffi.Pointer<GpiodChip>);
typedef GpiodLineIterNext = ffi.Pointer<GpiodLine> Function(ffi.Pointer<GpiodLineIter>);
typedef GpiodLineName = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineOffset = int Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineRelease = void Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineReleaseBulk = void Function(ffi.Pointer<GpiodLineBulk>);
typedef GpiodLineRequest = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<GpiodLineRequestConfig>, int);
typedef GpiodLineRequestBothEdgesEvents = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBothEdgesEventsFlags = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineRequestBulk = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<GpiodLineRequestConfig>, ffi.Pointer);
typedef GpiodLineRequestBulkBothEdgesEvents = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBulkBothEdgesEventsFlags = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineRequestBulkFallingEdgeEvents = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBulkFallingEdgeEventsFlags = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineRequestBulkInput = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBulkInputFlags = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineRequestBulkOutput = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, ffi.Pointer);
typedef GpiodLineRequestBulkOutputFlags = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, int, ffi.Pointer);
typedef GpiodLineRequestBulkRisingEdgeEvents = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBulkRisingEdgeEventsFlags = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineRequestFallingEdgeEvents = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestFallingEdgeEventsFlags = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineRequestInput = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestInputFlags = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineRequestOutput = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineRequestOutputFlags = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, int, int);
typedef GpiodLineRequestRisingEdgeEvents = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestRisingEdgeEventsFlags = int Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, int);
typedef GpiodLineSetConfig = int Function(ffi.Pointer<GpiodLine>, int, int, int);
typedef GpiodLineSetConfigBulk = int Function(ffi.Pointer<GpiodLineBulk>, int, int, ffi.Pointer);
typedef GpiodLineSetDirectionInput = int Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineSetDirectionInputBulk = int Function(ffi.Pointer<GpiodLineBulk>);
typedef GpiodLineSetDirectionOutput = int Function(ffi.Pointer<GpiodLine>, int);
typedef GpiodLineSetDirectionOutputBulk = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer);
typedef GpiodLineSetFlags = int Function(ffi.Pointer<GpiodLine>, int);
typedef GpiodLineSetFlagsBulk = int Function(ffi.Pointer<GpiodLineBulk>, int);
typedef GpiodLineSetValue = int Function(ffi.Pointer<GpiodLine>, int);
typedef GpiodLineSetValueBulk = int Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer);
typedef GpiodLineUpdate = int Function(ffi.Pointer<GpiodLine>);
typedef GpiodVersionString = ffi.Pointer<ffi.Utf8> Function();
