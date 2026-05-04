import '../../../../../design_system/tokens.dart';

/// Column geometry — [columnLabels.length] columns.
abstract final class SampleDataGridLayout {
  /// One narrow index + 29 data + action (31 total).
  static List<double> get columnWidths => <double>[
        AppTokens.space6,
        ...List<double>.filled(
          29,
          AppTokens.space12 * AppTokens.radiusSm +
              AppTokens.space10 * AppTokens.radiusSm +
              AppTokens.space8,
        ),
        AppTokens.space12 * 4 + AppTokens.space4,
      ];

  static List<String> get columnLabels => <String>[
        '#',
        'Sample Id',
        'Equip Sr. No.',
        'Equip Id No.',
        'Site Name',
        'Make',
        'Model',
        'Type of Sample',
        'Nature of Sample',
        'Running Hrs\n(Total HMR)',
        'Sub Assembly No.',
        'Sub Assembly Hrs',
        'Sampling Date',
        'Brand of Oil',
        'Grade',
        'Lube Hrs',
        'Top Up Volume',
        'Sump Capacity',
        'Sampling From',
        'Report Expected',
        'Qty',
        'Type of Bottle',
        'Problem',
        'Comments',
        'Customer Note',
        'Severity',
        'Oil Drained',
        'Image',
        'FTR',
        'Invoice',
        'Action',
      ];

  /// Width of `[col0][gutter][col1]…[col30]` matching header/data [Row]s.
  static double get columnsRunWidth {
    final ws = columnWidths;
    var sum = 0.0;
    for (final w in ws) {
      sum += w;
    }
    if (ws.length > 1) {
      sum += AppTokens.space2 * (ws.length - 1);
    }
    return sum;
  }

  /// Borders + widest stripe + horizontal padding inside [SampleDataEntryRow].
  static double get rowChromeReserveWidth =>
      2 * AppTokens.borderWidthSm +
      AppTokens.borderWidthMd +
      2 * AppTokens.space2;

  /// Scroll viewport width: column run plus row chrome (worst-case active stripe).
  static double get totalWidth => columnsRunWidth + rowChromeReserveWidth;
}
