abstract final class NablNoStatus {
  const NablNoStatus._();

  static const String pending = 'pending';
  static const String authenticated = 'authenticated';
  static const String duplicate = 'duplicate';
}

class NablNoRow {
  const NablNoRow({
    required this.id,
    required this.nablDate,
    required this.nablNo,
    required this.lcDate,
    required this.lcNo,
    required this.typeOfSample,
    required this.customerName,
    required this.sampleId,
    required this.status,
  });

  final String id;
  final DateTime nablDate;
  final String nablNo;
  final DateTime lcDate;
  final String lcNo;
  final String typeOfSample;
  final String customerName;
  final String sampleId;
  final String status;

  static String formatYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
