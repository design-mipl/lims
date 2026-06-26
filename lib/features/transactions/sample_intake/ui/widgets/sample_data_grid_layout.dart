import '../../../../../design_system/tokens.dart';

/// Full sheet vs operational datasheet workspace (subset columns).
enum SampleDataGridProfile {
  full,
  workspace,
}

/// Column geometry for the sample data entry sheet: scrollable detail columns + sticky actions.
abstract final class SampleDataGridLayout {
  /// Slightly wider than listing gaps so many columns stay readable without overlap.
  static const double interColumnGap = AppTokens.space2;

  /// Matches [AppTokens.tableRowHeight] so row chrome aligns with listing tables.
  static const double dataEntryRowHeight = AppTokens.tableRowHeight;

  /// Slots per row for [NumericFocusOrder] tab traversal (`listIndex * tableFocusStride + slot`).
  static const int tableFocusStride = 50;

  /// Uniform width for data columns (after serial/checkbox column).
  static const double uniformDataColumnWidth = 116;

  /// Serial no. + checkbox column (fixed narrow slot).
  static const double serialCheckboxColumnWidth = 84;

  /// Thirty scrollable columns: serial + checkbox, sample id, … invoice; then sticky [actionColumnWidth].
  static List<double> get scrollColumnWidths => <double>[
        serialCheckboxColumnWidth,
        ...List<double>.filled(29, uniformDataColumnWidth),
      ];

  /// Operational datasheet subset — mapped to existing row fields + attachments.
  static List<double> get workspaceScrollColumnWidths => <double>[
        serialCheckboxColumnWidth,
        ...List<double>.filled(
          workspaceColumnLabels.length - 1,
          uniformDataColumnWidth,
        ),
      ];

  static List<double> scrollColumnWidthsFor(SampleDataGridProfile profile) {
    switch (profile) {
      case SampleDataGridProfile.full:
        return scrollColumnWidths;
      case SampleDataGridProfile.workspace:
        return workspaceScrollColumnWidths;
    }
  }

  static List<String> columnLabelsFor(SampleDataGridProfile profile) {
    switch (profile) {
      case SampleDataGridProfile.full:
        return columnLabels;
      case SampleDataGridProfile.workspace:
        return workspaceColumnLabels;
    }
  }

  static List<String> get workspaceColumnLabels => <String>[
        'Serial No.',
        'Sample Id',
        'Type of Sample*',
        'Grade*',
        'Brand of Oil',
        'Running Hrs (Total HMR)*',
        'Top Up Volume (Ltr)',
        'Oil Condition',
        'Previous Lab Ref.',
        'Comments',
        'Image Attachment',
        'FTR Attachment',
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

  static double scrollColumnsRunWidthFor(SampleDataGridProfile profile) {
    final ws = scrollColumnWidthsFor(profile);
    var sum = 0.0;
    for (final w in ws) {
      sum += w;
    }
    if (ws.length > 1) {
      sum += interColumnGap * (ws.length - 1);
    }
    return sum;
  }

  static double get scrollColumnsRunWidth =>
      scrollColumnsRunWidthFor(SampleDataGridProfile.full);

  /// Width of the horizontally scrollable content (matches header + row [ConstrainedBox] logic).
  static double horizontalScrollContentWidth(
    double viewportWidth, [
    SampleDataGridProfile profile = SampleDataGridProfile.full,
  ]) {
    final pad = AppTokens.space2 * 2;
    final intrinsic = pad + scrollColumnsRunWidthFor(profile);
    return viewportWidth > intrinsic ? viewportWidth : intrinsic;
  }
}
