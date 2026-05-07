import '../../../../../design_system/tokens.dart';

/// Column geometry for the sample data entry sheet: scrollable detail columns + sticky actions.
abstract final class SampleDataGridLayout {
  /// Slightly wider than listing gaps so many columns stay readable without overlap.
  static const double interColumnGap = AppTokens.space2;

  /// Matches [AppTokens.tableRowHeight] so row chrome aligns with listing tables.
  static const double dataEntryRowHeight = AppTokens.tableRowHeight;

  /// Slots per row for [NumericFocusOrder] tab traversal (`listIndex * tableFocusStride + slot`).
  static const int tableFocusStride = 50;

  /// Thirty scrollable columns: serial + checkbox, sample id, … invoice; then sticky [actionColumnWidth].
  static List<double> get scrollColumnWidths => <double>[
        76, // 0 serial + checkbox
        108, // 1 sample id
        92, // 2 equip sr *
        92, // 3 equip id
        112, // 4 site
        100, // 5 make
        104, // 6 model *
        120, // 7 type of sample *
        108, // 8 nature
        100, // 9 running hrs (total hmr) *
        100, // 10 sub asm no
        92, // 11 sub asm hrs
        108, // 12 sampling date
        108, // 13 brand of oil
        96, // 14 grade *
        96, // 15 lube hrs *
        88, // 16 top up
        88, // 17 sump
        116, // 18 sampling from *
        112, // 19 report expected
        64, // 20 qty
        108, // 21 bottle
        108, // 22 problem
        108, // 23 comments
        128, // 24 customer note
        92, // 25 severity
        88, // 26 oil drained
        100, // 27 image
        100, // 28 ftr
        128, // 29 invoice
      ];

  static double get actionColumnWidth => AppTokens.tableActionsColumnWidth;

  /// Display labels; trailing `*` denotes required (rendered with accent asterisk in header).
  static List<String> get columnLabels => <String>[
        'Serial No.',
        'Sample Id',
        'Equip Sr. No.*',
        'Equip Id No.',
        'Site Name',
        'Make',
        'Model*',
        'Type of Sample*',
        'Nature of Sample',
        'Running Hrs (Total HMR)*',
        'Sub Assembly No.',
        'Sub Assembly Hrs',
        'Sampling Date',
        'Brand of Oil',
        'Grade*',
        'Lube Hrs (Oil Running Hrs)*',
        'Top Up Volume (Ltr)',
        'Sump Capacity',
        'Sampling From*',
        'Report Expected',
        'Quantity',
        'Type of Bottle',
        'Problem',
        'Comments',
        'Customer Note',
        'Severity',
        'Oil Drained',
        'Image Attachment',
        'FTR Attachment',
        'Invoice',
      ];

  static double get scrollColumnsRunWidth {
    final ws = scrollColumnWidths;
    var sum = 0.0;
    for (final w in ws) {
      sum += w;
    }
    if (ws.length > 1) {
      sum += interColumnGap * (ws.length - 1);
    }
    return sum;
  }

  /// Width of the horizontally scrollable content (matches header + row [ConstrainedBox] logic).
  static double horizontalScrollContentWidth(double viewportWidth) {
    final pad = AppTokens.space2 * 2;
    final intrinsic = pad + scrollColumnsRunWidth;
    return viewportWidth > intrinsic ? viewportWidth : intrinsic;
  }
}
