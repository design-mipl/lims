import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/nabl_no_model.dart';
import 'nabl_csv_download.dart' as csv_download;

/// Visible NABL listing columns (matches [NablNoListingPane] table).
const List<({String header, String Function(NablNoRow row) value})>
    kNablListingExportColumns = [
  (header: 'NABL Date', value: _nablDate),
  (header: 'NABL No.', value: _nablNo),
  (header: 'LC Date', value: _lcDate),
  (header: 'LC No.', value: _lcNo),
  (header: 'Type Of Sample', value: _typeOfSample),
  (header: 'Customer Name', value: _customerName),
  (header: 'Sample', value: _sampleId),
];

String _nablDate(NablNoRow r) => NablNoRow.formatYmd(r.nablDate);
String _nablNo(NablNoRow r) => r.nablNo;
String _lcDate(NablNoRow r) => NablNoRow.formatYmd(r.lcDate);
String _lcNo(NablNoRow r) => r.lcNo;
String _typeOfSample(NablNoRow r) => r.typeOfSample;
String _customerName(NablNoRow r) => r.customerName;
String _sampleId(NablNoRow r) => r.sampleId;

String buildNablListingCsv(Iterable<NablNoRow> rows) {
  final buffer = StringBuffer();
  buffer.writeln(
    kNablListingExportColumns.map((c) => _csvCell(c.header)).join(','),
  );
  for (final row in rows) {
    buffer.writeln(
      kNablListingExportColumns
          .map((c) => _csvCell(c.value(row)))
          .join(','),
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

/// Exports [rows] as CSV (opens in Excel). Web triggers download; desktop copies
/// to clipboard for paste into Excel.
Future<void> exportNablListingToExcel(List<NablNoRow> rows) async {
  if (rows.isEmpty) return;
  final csv = buildNablListingCsv(rows);
  final stamp = DateTime.now();
  final filename =
      'nabl_no_${stamp.year}${stamp.month.toString().padLeft(2, '0')}${stamp.day.toString().padLeft(2, '0')}_${stamp.hour.toString().padLeft(2, '0')}${stamp.minute.toString().padLeft(2, '0')}.csv';
  if (kIsWeb) {
    csv_download.downloadCsvFile(filename, csv);
    return;
  }
  await Clipboard.setData(ClipboardData(text: csv));
}
