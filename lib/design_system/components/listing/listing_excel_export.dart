import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../export/csv_download.dart' as csv_download;
import 'table_column.dart';

/// Resolves a plain-text cell for Excel export from a visible listing column.
String listingExportCellValue<T>(TableColumn<T> col, T row) {
  if (col.exportValue != null) {
    return col.exportValue!(row);
  }
  if (col.filterTextValue != null) {
    return col.filterTextValue!(row);
  }
  if (col.filterSelectValue != null) {
    return col.filterSelectValue!(row);
  }
  final sortVal = col.sortValue?.call(row);
  if (sortVal == null) return '';
  if (sortVal is num && sortVal > 10000000000) {
    try {
      final d = DateTime.fromMillisecondsSinceEpoch(sortVal.toInt());
      return _formatYmd(d);
    } catch (_) {
      return sortVal.toString();
    }
  }
  return sortVal.toString();
}

String _formatYmd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _sanitizeModuleName(String raw) {
  final cleaned = raw
      .trim()
      .replaceAll(RegExp(r'[^\w\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '_');
  return cleaned.isEmpty ? 'Listing' : cleaned;
}

String buildListingExportCsv<T>({
  required List<TableColumn<T>> columns,
  required List<T> rows,
}) {
  final buffer = StringBuffer();
  buffer.writeln(columns.map((c) => _csvCell(c.label)).join(','));
  for (final row in rows) {
    buffer.writeln(
      columns.map((c) => _csvCell(listingExportCellValue(c, row))).join(','),
    );
  }
  return buffer.toString();
}

String _csvCell(String raw) {
  final needsQuotes =
      raw.contains(',') || raw.contains('"') || raw.contains('\n');
  if (!needsQuotes) return raw;
  return '"${raw.replaceAll('"', '""')}"';
}

/// Downloads listing data as an Excel-compatible file (`Transaction_*_date.xlsx`).
Future<void> exportListingToExcel<T>({
  required String moduleName,
  required List<TableColumn<T>> columns,
  required List<T> rows,
}) async {
  if (rows.isEmpty || columns.isEmpty) return;
  final csv = '\uFEFF${buildListingExportCsv(columns: columns, rows: rows)}';
  final stamp = DateTime.now();
  final date =
      '${stamp.year}-${stamp.month.toString().padLeft(2, '0')}-${stamp.day.toString().padLeft(2, '0')}';
  final filename =
      'Transaction_${_sanitizeModuleName(moduleName)}_$date.xlsx';
  if (kIsWeb) {
    csv_download.downloadCsvFile(filename, csv);
    return;
  }
  await Clipboard.setData(ClipboardData(text: csv));
}
