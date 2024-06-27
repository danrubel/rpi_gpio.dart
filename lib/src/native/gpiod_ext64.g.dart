//
// Generated from native/rpi_gpio_ext.cc
//
// ignore_for_file: slash_for_doc_comments
// ignore_for_file: lines_longer_than_80_chars

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;
import 'package:rpi_gpio/src/native/gpiod_ext.dart';

class NativePgkLib64 extends NativePgkLib {
  NativePgkLib64(ffi.DynamicLibrary dylib) : super.base(
        dylib,
        dylib
          .lookup<ffi.NativeFunction<GpiodChipCloseFfi>>('gpiod_chip_close')
          .asFunction<GpiodChipClose>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipFindLineFfi>>('gpiod_chip_find_line')
          .asFunction<GpiodChipFindLine>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipFindLinesFfi>>('gpiod_chip_find_lines')
          .asFunction<GpiodChipFindLines>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipGetAllLinesFfi>>('gpiod_chip_get_all_lines')
          .asFunction<GpiodChipGetAllLines>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipGetLineFfi>>('gpiod_chip_get_line')
          .asFunction<GpiodChipGetLine>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipGetLinesFfi>>('gpiod_chip_get_lines')
          .asFunction<GpiodChipGetLines>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipIterFreeFfi>>('gpiod_chip_iter_free')
          .asFunction<GpiodChipIterFree>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipIterFreeNocloseFfi>>('gpiod_chip_iter_free_noclose')
          .asFunction<GpiodChipIterFreeNoclose>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipIterNewFfi>>('gpiod_chip_iter_new')
          .asFunction<GpiodChipIterNew>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipIterNextFfi>>('gpiod_chip_iter_next')
          .asFunction<GpiodChipIterNext>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipIterNextNocloseFfi>>('gpiod_chip_iter_next_noclose')
          .asFunction<GpiodChipIterNextNoclose>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipLabelFfi>>('gpiod_chip_label')
          .asFunction<GpiodChipLabel>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipNameFfi>>('gpiod_chip_name')
          .asFunction<GpiodChipName>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipNumLinesFfi>>('gpiod_chip_num_lines')
          .asFunction<GpiodChipNumLines>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipOpenFfi>>('gpiod_chip_open')
          .asFunction<GpiodChipOpen>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipOpenByLabelFfi>>('gpiod_chip_open_by_label')
          .asFunction<GpiodChipOpenByLabel>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipOpenByNameFfi>>('gpiod_chip_open_by_name')
          .asFunction<GpiodChipOpenByName>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipOpenByNumberFfi>>('gpiod_chip_open_by_number')
          .asFunction<GpiodChipOpenByNumber>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodChipOpenLookupFfi>>('gpiod_chip_open_lookup')
          .asFunction<GpiodChipOpenLookup>(),
        // dylib
        //   .lookup<ffi.NativeFunction<GpiodCtxlessEventMonitorFfi>>('gpiod_ctxless_event_monitor')
        //   .asFunction<GpiodCtxlessEventMonitor>(),
        // dylib
        //   .lookup<ffi.NativeFunction<GpiodCtxlessEventMonitorExtFfi>>('gpiod_ctxless_event_monitor_ext')
        //   .asFunction<GpiodCtxlessEventMonitorExt>(),
        // dylib
        //   .lookup<ffi.NativeFunction<GpiodCtxlessEventMonitorMultipleFfi>>('gpiod_ctxless_event_monitor_multiple')
        //   .asFunction<GpiodCtxlessEventMonitorMultiple>(),
        // dylib
        //   .lookup<ffi.NativeFunction<GpiodCtxlessEventMonitorMultipleExtFfi>>('gpiod_ctxless_event_monitor_multiple_ext')
        //   .asFunction<GpiodCtxlessEventMonitorMultipleExt>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodCtxlessFindLineFfi>>('gpiod_ctxless_find_line')
          .asFunction<GpiodCtxlessFindLine>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodCtxlessGetValueFfi>>('gpiod_ctxless_get_value')
          .asFunction<GpiodCtxlessGetValue>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodCtxlessGetValueExtFfi>>('gpiod_ctxless_get_value_ext')
          .asFunction<GpiodCtxlessGetValueExt>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodCtxlessGetValueMultipleFfi>>('gpiod_ctxless_get_value_multiple')
          .asFunction<GpiodCtxlessGetValueMultiple>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodCtxlessGetValueMultipleExtFfi>>('gpiod_ctxless_get_value_multiple_ext')
          .asFunction<GpiodCtxlessGetValueMultipleExt>(),
        // dylib
        //   .lookup<ffi.NativeFunction<GpiodCtxlessSetValueFfi>>('gpiod_ctxless_set_value')
        //   .asFunction<GpiodCtxlessSetValue>(),
        // dylib
        //   .lookup<ffi.NativeFunction<GpiodCtxlessSetValueExtFfi>>('gpiod_ctxless_set_value_ext')
        //   .asFunction<GpiodCtxlessSetValueExt>(),
        // dylib
        //   .lookup<ffi.NativeFunction<GpiodCtxlessSetValueMultipleFfi>>('gpiod_ctxless_set_value_multiple')
        //   .asFunction<GpiodCtxlessSetValueMultiple>(),
        // dylib
        //   .lookup<ffi.NativeFunction<GpiodCtxlessSetValueMultipleExtFfi>>('gpiod_ctxless_set_value_multiple_ext')
        //   .asFunction<GpiodCtxlessSetValueMultipleExt>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineActiveStateFfi>>('gpiod_line_active_state')
          .asFunction<GpiodLineActiveState>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineBiasFfi>>('gpiod_line_bias')
          .asFunction<GpiodLineBias>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineCloseChipFfi>>('gpiod_line_close_chip')
          .asFunction<GpiodLineCloseChip>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineConsumerFfi>>('gpiod_line_consumer')
          .asFunction<GpiodLineConsumer>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineDirectionFfi>>('gpiod_line_direction')
          .asFunction<GpiodLineDirection>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineEventGetFdFfi>>('gpiod_line_event_get_fd')
          .asFunction<GpiodLineEventGetFd>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineEventReadFfi>>('gpiod_line_event_read')
          .asFunction<GpiodLineEventRead>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineEventReadFdFfi>>('gpiod_line_event_read_fd')
          .asFunction<GpiodLineEventReadFd>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineEventReadFdMultipleFfi>>('gpiod_line_event_read_fd_multiple')
          .asFunction<GpiodLineEventReadFdMultiple>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineEventReadMultipleFfi>>('gpiod_line_event_read_multiple')
          .asFunction<GpiodLineEventReadMultiple>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineEventWaitFfi>>('gpiod_line_event_wait')
          .asFunction<GpiodLineEventWait>(),
        // dylib
        //   .lookup<ffi.NativeFunction<GpiodLineEventWaitBulkFfi>>('gpiod_line_event_wait_bulk')
        //   .asFunction<GpiodLineEventWaitBulk>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineFindFfi>>('gpiod_line_find')
          .asFunction<GpiodLineFind>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineGetFfi>>('gpiod_line_get')
          .asFunction<GpiodLineGet>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineGetChipFfi>>('gpiod_line_get_chip')
          .asFunction<GpiodLineGetChip>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineGetValueFfi>>('gpiod_line_get_value')
          .asFunction<GpiodLineGetValue>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineGetValueBulkFfi>>('gpiod_line_get_value_bulk')
          .asFunction<GpiodLineGetValueBulk>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineIsFreeFfi>>('gpiod_line_is_free')
          .asFunction<GpiodLineIsFree>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineIsOpenDrainFfi>>('gpiod_line_is_open_drain')
          .asFunction<GpiodLineIsOpenDrain>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineIsOpenSourceFfi>>('gpiod_line_is_open_source')
          .asFunction<GpiodLineIsOpenSource>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineIsRequestedFfi>>('gpiod_line_is_requested')
          .asFunction<GpiodLineIsRequested>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineIsUsedFfi>>('gpiod_line_is_used')
          .asFunction<GpiodLineIsUsed>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineIterFreeFfi>>('gpiod_line_iter_free')
          .asFunction<GpiodLineIterFree>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineIterNewFfi>>('gpiod_line_iter_new')
          .asFunction<GpiodLineIterNew>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineIterNextFfi>>('gpiod_line_iter_next')
          .asFunction<GpiodLineIterNext>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineNameFfi>>('gpiod_line_name')
          .asFunction<GpiodLineName>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineOffsetFfi>>('gpiod_line_offset')
          .asFunction<GpiodLineOffset>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineReleaseFfi>>('gpiod_line_release')
          .asFunction<GpiodLineRelease>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineReleaseBulkFfi>>('gpiod_line_release_bulk')
          .asFunction<GpiodLineReleaseBulk>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestFfi>>('gpiod_line_request')
          .asFunction<GpiodLineRequest>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBothEdgesEventsFfi>>('gpiod_line_request_both_edges_events')
          .asFunction<GpiodLineRequestBothEdgesEvents>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBothEdgesEventsFlagsFfi>>('gpiod_line_request_both_edges_events_flags')
          .asFunction<GpiodLineRequestBothEdgesEventsFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkFfi>>('gpiod_line_request_bulk')
          .asFunction<GpiodLineRequestBulk>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkBothEdgesEventsFfi>>('gpiod_line_request_bulk_both_edges_events')
          .asFunction<GpiodLineRequestBulkBothEdgesEvents>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkBothEdgesEventsFlagsFfi>>('gpiod_line_request_bulk_both_edges_events_flags')
          .asFunction<GpiodLineRequestBulkBothEdgesEventsFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkFallingEdgeEventsFfi>>('gpiod_line_request_bulk_falling_edge_events')
          .asFunction<GpiodLineRequestBulkFallingEdgeEvents>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkFallingEdgeEventsFlagsFfi>>('gpiod_line_request_bulk_falling_edge_events_flags')
          .asFunction<GpiodLineRequestBulkFallingEdgeEventsFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkInputFfi>>('gpiod_line_request_bulk_input')
          .asFunction<GpiodLineRequestBulkInput>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkInputFlagsFfi>>('gpiod_line_request_bulk_input_flags')
          .asFunction<GpiodLineRequestBulkInputFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkOutputFfi>>('gpiod_line_request_bulk_output')
          .asFunction<GpiodLineRequestBulkOutput>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkOutputFlagsFfi>>('gpiod_line_request_bulk_output_flags')
          .asFunction<GpiodLineRequestBulkOutputFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkRisingEdgeEventsFfi>>('gpiod_line_request_bulk_rising_edge_events')
          .asFunction<GpiodLineRequestBulkRisingEdgeEvents>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestBulkRisingEdgeEventsFlagsFfi>>('gpiod_line_request_bulk_rising_edge_events_flags')
          .asFunction<GpiodLineRequestBulkRisingEdgeEventsFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestFallingEdgeEventsFfi>>('gpiod_line_request_falling_edge_events')
          .asFunction<GpiodLineRequestFallingEdgeEvents>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestFallingEdgeEventsFlagsFfi>>('gpiod_line_request_falling_edge_events_flags')
          .asFunction<GpiodLineRequestFallingEdgeEventsFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestInputFfi>>('gpiod_line_request_input')
          .asFunction<GpiodLineRequestInput>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestInputFlagsFfi>>('gpiod_line_request_input_flags')
          .asFunction<GpiodLineRequestInputFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestOutputFfi>>('gpiod_line_request_output')
          .asFunction<GpiodLineRequestOutput>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestOutputFlagsFfi>>('gpiod_line_request_output_flags')
          .asFunction<GpiodLineRequestOutputFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestRisingEdgeEventsFfi>>('gpiod_line_request_rising_edge_events')
          .asFunction<GpiodLineRequestRisingEdgeEvents>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineRequestRisingEdgeEventsFlagsFfi>>('gpiod_line_request_rising_edge_events_flags')
          .asFunction<GpiodLineRequestRisingEdgeEventsFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetConfigFfi>>('gpiod_line_set_config')
          .asFunction<GpiodLineSetConfig>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetConfigBulkFfi>>('gpiod_line_set_config_bulk')
          .asFunction<GpiodLineSetConfigBulk>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetDirectionInputFfi>>('gpiod_line_set_direction_input')
          .asFunction<GpiodLineSetDirectionInput>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetDirectionInputBulkFfi>>('gpiod_line_set_direction_input_bulk')
          .asFunction<GpiodLineSetDirectionInputBulk>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetDirectionOutputFfi>>('gpiod_line_set_direction_output')
          .asFunction<GpiodLineSetDirectionOutput>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetDirectionOutputBulkFfi>>('gpiod_line_set_direction_output_bulk')
          .asFunction<GpiodLineSetDirectionOutputBulk>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetFlagsFfi>>('gpiod_line_set_flags')
          .asFunction<GpiodLineSetFlags>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetFlagsBulkFfi>>('gpiod_line_set_flags_bulk')
          .asFunction<GpiodLineSetFlagsBulk>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetValueFfi>>('gpiod_line_set_value')
          .asFunction<GpiodLineSetValue>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineSetValueBulkFfi>>('gpiod_line_set_value_bulk')
          .asFunction<GpiodLineSetValueBulk>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodLineUpdateFfi>>('gpiod_line_update')
          .asFunction<GpiodLineUpdate>(),
        dylib
          .lookup<ffi.NativeFunction<GpiodVersionStringFfi>>('gpiod_version_string')
          .asFunction<GpiodVersionString>(),
  );
}

// Functions

typedef GpiodChipCloseFfi = ffi.Void Function(ffi.Pointer<GpiodChip>);
typedef GpiodChipFindLineFfi = ffi.Pointer<GpiodLine> Function(ffi.Pointer<GpiodChip>, ffi.Pointer<ffi.Utf8>);
typedef GpiodChipFindLinesFfi = ffi.Int64 Function(ffi.Pointer<GpiodChip>, ffi.Pointer<ffi.Pointer<ffi.Utf8>>, ffi.Pointer<GpiodLineBulk>);
typedef GpiodChipGetAllLinesFfi = ffi.Int64 Function(ffi.Pointer<GpiodChip>, ffi.Pointer<GpiodLineBulk>);
typedef GpiodChipGetLineFfi = ffi.Pointer<GpiodLine> Function(ffi.Pointer<GpiodChip>, ffi.Int64);
typedef GpiodChipGetLinesFfi = ffi.Int64 Function(ffi.Pointer<GpiodChip>, ffi.Pointer, ffi.Int64, ffi.Pointer<GpiodLineBulk>);
typedef GpiodChipIterFreeFfi = ffi.Void Function(ffi.Pointer<GpiodChipIter>);
typedef GpiodChipIterFreeNocloseFfi = ffi.Void Function(ffi.Pointer<GpiodChipIter>);
typedef GpiodChipIterNewFfi = ffi.Pointer<GpiodChipIter> Function();
typedef GpiodChipIterNextFfi = ffi.Pointer<GpiodChip> Function(ffi.Pointer<GpiodChipIter>);
typedef GpiodChipIterNextNocloseFfi = ffi.Pointer<GpiodChip> Function(ffi.Pointer<GpiodChipIter>);
typedef GpiodChipLabelFfi = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<GpiodChip>);
typedef GpiodChipNameFfi = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<GpiodChip>);
typedef GpiodChipNumLinesFfi = ffi.Int64 Function(ffi.Pointer<GpiodChip>);
typedef GpiodChipOpenFfi = ffi.Pointer<GpiodChip> Function(ffi.Pointer<ffi.Utf8>);
typedef GpiodChipOpenByLabelFfi = ffi.Pointer<GpiodChip> Function(ffi.Pointer<ffi.Utf8>);
typedef GpiodChipOpenByNameFfi = ffi.Pointer<GpiodChip> Function(ffi.Pointer<ffi.Utf8>);
typedef GpiodChipOpenByNumberFfi = ffi.Pointer<GpiodChip> Function(ffi.Int64);
typedef GpiodChipOpenLookupFfi = ffi.Pointer<GpiodChip> Function(ffi.Pointer<ffi.Utf8>);
// typedef GpiodCtxlessEventMonitorFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, ffi.Pointer<Timespec>, GpiodCtxlessEventPollCb, GpiodCtxlessEventHandleCb, ffi.Pointer<ffi.Void>);
// typedef GpiodCtxlessEventMonitorExtFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, ffi.Pointer<Timespec>, GpiodCtxlessEventPollCb, GpiodCtxlessEventHandleCb, ffi.Pointer<ffi.Void>, ffi.Int64);
// typedef GpiodCtxlessEventMonitorMultipleFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Pointer, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, ffi.Pointer<Timespec>, GpiodCtxlessEventPollCb, GpiodCtxlessEventHandleCb, ffi.Pointer<ffi.Void>);
// typedef GpiodCtxlessEventMonitorMultipleExtFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Pointer, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, ffi.Pointer<Timespec>, GpiodCtxlessEventPollCb, GpiodCtxlessEventHandleCb, ffi.Pointer<ffi.Void>, ffi.Int64);
typedef GpiodCtxlessFindLineFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Pointer);
typedef GpiodCtxlessGetValueFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>);
typedef GpiodCtxlessGetValueExtFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodCtxlessGetValueMultipleFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer, ffi.Pointer, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>);
typedef GpiodCtxlessGetValueMultipleExtFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer, ffi.Pointer, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, ffi.Int64);
// typedef GpiodCtxlessSetValueFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, GpiodCtxlessSetValueCb, ffi.Pointer<ffi.Void>);
// typedef GpiodCtxlessSetValueExtFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, GpiodCtxlessSetValueCb, ffi.Pointer<ffi.Void>, ffi.Int64);
// typedef GpiodCtxlessSetValueMultipleFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer, ffi.Pointer, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, GpiodCtxlessSetValueCb, ffi.Pointer<ffi.Void>);
// typedef GpiodCtxlessSetValueMultipleExtFfi = ffi.Int64 Function(ffi.Pointer<ffi.Utf8>, ffi.Pointer, ffi.Pointer, ffi.Int64, ffi.Bool, ffi.Pointer<ffi.Utf8>, GpiodCtxlessSetValueCb, ffi.Pointer<ffi.Void>, ffi.Int64);
typedef GpiodLineActiveStateFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineBiasFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineCloseChipFfi = ffi.Void Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineConsumerFfi = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineDirectionFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineEventGetFdFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineEventReadFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<GpiodLineEvent>);
typedef GpiodLineEventReadFdFfi = ffi.Int64 Function(ffi.Int64, ffi.Pointer<GpiodLineEvent>);
typedef GpiodLineEventReadFdMultipleFfi = ffi.Int64 Function(ffi.Int64, ffi.Pointer<GpiodLineEvent>, ffi.Int64);
typedef GpiodLineEventReadMultipleFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<GpiodLineEvent>, ffi.Int64);
typedef GpiodLineEventWaitFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<Timespec>);
// typedef GpiodLineEventWaitBulkFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<Timespec>, ffi.Pointer<GpiodLineBulk>);
typedef GpiodLineFindFfi = ffi.Pointer<GpiodLine> Function(ffi.Pointer<ffi.Utf8>);
typedef GpiodLineGetFfi = ffi.Pointer<GpiodLine> Function(ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineGetChipFfi = ffi.Pointer<GpiodChip> Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineGetValueFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineGetValueBulkFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer);
typedef GpiodLineIsFreeFfi = ffi.Bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIsOpenDrainFfi = ffi.Bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIsOpenSourceFfi = ffi.Bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIsRequestedFfi = ffi.Bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIsUsedFfi = ffi.Bool Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineIterFreeFfi = ffi.Void Function(ffi.Pointer<GpiodLineIter>);
typedef GpiodLineIterNewFfi = ffi.Pointer<GpiodLineIter> Function(ffi.Pointer<GpiodChip>);
typedef GpiodLineIterNextFfi = ffi.Pointer<GpiodLine> Function(ffi.Pointer<GpiodLineIter>);
typedef GpiodLineNameFfi = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineOffsetFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineReleaseFfi = ffi.Void Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineReleaseBulkFfi = ffi.Void Function(ffi.Pointer<GpiodLineBulk>);
typedef GpiodLineRequestFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<GpiodLineRequestConfig>, ffi.Int64);
typedef GpiodLineRequestBothEdgesEventsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBothEdgesEventsFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineRequestBulkFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<GpiodLineRequestConfig>, ffi.Pointer);
typedef GpiodLineRequestBulkBothEdgesEventsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBulkBothEdgesEventsFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineRequestBulkFallingEdgeEventsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBulkFallingEdgeEventsFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineRequestBulkInputFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBulkInputFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineRequestBulkOutputFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, ffi.Pointer);
typedef GpiodLineRequestBulkOutputFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Pointer);
typedef GpiodLineRequestBulkRisingEdgeEventsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestBulkRisingEdgeEventsFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineRequestFallingEdgeEventsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestFallingEdgeEventsFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineRequestInputFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestInputFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineRequestOutputFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineRequestOutputFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, ffi.Int64, ffi.Int64);
typedef GpiodLineRequestRisingEdgeEventsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>);
typedef GpiodLineRequestRisingEdgeEventsFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Pointer<ffi.Utf8>, ffi.Int64);
typedef GpiodLineSetConfigFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Int64, ffi.Int64, ffi.Int64);
typedef GpiodLineSetConfigBulkFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Int64, ffi.Int64, ffi.Pointer);
typedef GpiodLineSetDirectionInputFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>);
typedef GpiodLineSetDirectionInputBulkFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>);
typedef GpiodLineSetDirectionOutputFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Int64);
typedef GpiodLineSetDirectionOutputBulkFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer);
typedef GpiodLineSetFlagsFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Int64);
typedef GpiodLineSetFlagsBulkFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Int64);
typedef GpiodLineSetValueFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>, ffi.Int64);
typedef GpiodLineSetValueBulkFfi = ffi.Int64 Function(ffi.Pointer<GpiodLineBulk>, ffi.Pointer);
typedef GpiodLineUpdateFfi = ffi.Int64 Function(ffi.Pointer<GpiodLine>);
typedef GpiodVersionStringFfi = ffi.Pointer<ffi.Utf8> Function();
