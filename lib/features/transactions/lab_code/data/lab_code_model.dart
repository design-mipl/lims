/// Status values for Lab Code listing rows.
abstract final class LabCodeStatus {
  const LabCodeStatus._();

  static const String pending = 'pending';
  static const String completed = 'completed';
}

class LabCodeModel {
  const LabCodeModel({
    required this.id,
    required this.recordedAt,
    required this.sampleId,
    this.labCode,
    required this.customerName,
    required this.customerCompany,
    required this.sampleType,
    required this.status,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final DateTime recordedAt;
  final String sampleId;
  /// Assigned when lab code is generated (`Lab Id` tab / Delete column).
  final String? labCode;
  final String customerName;
  final String customerCompany;
  final String sampleType;
  final String status;

  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime updatedAt;

  static const Object _sentinel = Object();

  LabCodeModel copyWith({
    String? id,
    DateTime? recordedAt,
    String? sampleId,
    Object? labCode = _sentinel,
    String? customerName,
    String? customerCompany,
    String? sampleType,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return LabCodeModel(
      id: id ?? this.id,
      recordedAt: recordedAt ?? this.recordedAt,
      sampleId: sampleId ?? this.sampleId,
      labCode: labCode == _sentinel ? this.labCode : labCode as String?,
      customerName: customerName ?? this.customerName,
      customerCompany: customerCompany ?? this.customerCompany,
      sampleType: sampleType ?? this.sampleType,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'sampleId': sampleId,
        'labCode': labCode,
        'customerName': customerName,
        'customerCompany': customerCompany,
        'sampleType': sampleType,
        'status': status,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedBy': updatedBy,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static LabCodeModel fromJson(Map<String, dynamic> m) {
    final now = DateTime.now();
    return LabCodeModel(
      id: m['id'] as String? ?? '',
      recordedAt: DateTime.tryParse(m['recordedAt'] as String? ?? '') ?? now,
      sampleId: m['sampleId'] as String? ?? '',
      labCode: m['labCode'] as String?,
      customerName: m['customerName'] as String? ?? '',
      customerCompany: m['customerCompany'] as String? ?? '',
      sampleType: m['sampleType'] as String? ?? '',
      status: m['status'] as String? ?? LabCodeStatus.pending,
      createdBy: m['createdBy'] as String?,
      createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? now,
      updatedBy: m['updatedBy'] as String?,
      updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? '') ?? now,
    );
  }
}
