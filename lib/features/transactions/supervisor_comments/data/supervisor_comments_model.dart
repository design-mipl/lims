/// Status for Supervisor Comments listing tabs.
abstract final class SupervisorCommentsStatus {
  const SupervisorCommentsStatus._();

  static const String pending = 'pending';
  static const String completed = 'completed';
}

class SupervisorCommentsRow {
  const SupervisorCommentsRow({
    required this.id,
    required this.companyName,
    required this.siteName,
    required this.typeOfSample,
    required this.samplingDate,
    required this.lotNo,
    required this.labId,
    required this.lubeHrs,
    required this.hmr,
    required this.topUpVolume,
    required this.dtOfReceipt,
    required this.sampleId,
    required this.make,
    required this.model,
    required this.serialNo,
    required this.oilBrand,
    required this.oilGrade,
    required this.samplingPoint,
    required this.customerNote,
    required this.labDate,
    required this.zone,
    required this.fluid,
    required this.status,
    this.supervisorComment = '',
  });

  final String id;
  final String companyName;
  final String siteName;
  final String typeOfSample;
  final DateTime samplingDate;
  final String lotNo;
  final String labId;
  final double lubeHrs;
  final double hmr;
  final double topUpVolume;
  final DateTime dtOfReceipt;
  final String sampleId;
  final String make;
  final String model;
  final String serialNo;
  final String oilBrand;
  final String oilGrade;
  final String samplingPoint;
  final String customerNote;
  final DateTime labDate;
  final String zone;
  final String fluid;
  final String status;
  final String supervisorComment;

  static String formatYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  SupervisorCommentsRow copyWith({
    String? supervisorComment,
    String? status,
  }) {
    return SupervisorCommentsRow(
      id: id,
      companyName: companyName,
      siteName: siteName,
      typeOfSample: typeOfSample,
      samplingDate: samplingDate,
      lotNo: lotNo,
      labId: labId,
      lubeHrs: lubeHrs,
      hmr: hmr,
      topUpVolume: topUpVolume,
      dtOfReceipt: dtOfReceipt,
      sampleId: sampleId,
      make: make,
      model: model,
      serialNo: serialNo,
      oilBrand: oilBrand,
      oilGrade: oilGrade,
      samplingPoint: samplingPoint,
      customerNote: customerNote,
      labDate: labDate,
      zone: zone,
      fluid: fluid,
      status: status ?? this.status,
      supervisorComment: supervisorComment ?? this.supervisorComment,
    );
  }
}
