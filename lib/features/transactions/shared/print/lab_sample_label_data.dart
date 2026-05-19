import '../../lab_code/data/lab_code_model.dart';

/// Single printable sample label (LCN sticker).
class LabSampleLabelData {
  const LabSampleLabelData({
    required this.date,
    required this.sampleType,
    required this.labCodeNumber,
    this.sampleId,
  });

  final DateTime date;
  final String sampleType;
  final String labCodeNumber;
  final String? sampleId;

  /// Portal format: `16-05-2026`
  String get formattedDate {
    final d = date;
    return '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.year}';
  }

  String get sampleTypeDisplay => sampleType.trim().toUpperCase();

  factory LabSampleLabelData.fromLabCode(LabCodeModel row) {
    return LabSampleLabelData(
      date: row.recordedAt,
      sampleType: row.sampleType,
      labCodeNumber: row.labCode ?? '',
      sampleId: row.sampleId,
    );
  }
}
