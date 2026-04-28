import '../../shared/master_status.dart';

class HsnMasterModel {
  const HsnMasterModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.status,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final double igst;
  final double cgst;
  final double sgst;
  final MasterStatus status;
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime updatedAt;

  HsnMasterModel copyWith({
    String? id,
    String? code,
    String? name,
    Object? description = _sentinel,
    double? igst,
    double? cgst,
    double? sgst,
    MasterStatus? status,
    Object? createdBy = _sentinel,
    DateTime? createdAt,
    Object? updatedBy = _sentinel,
    DateTime? updatedAt,
  }) {
    return HsnMasterModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description == _sentinel
          ? this.description
          : description as String?,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      status: status ?? this.status,
      createdBy: createdBy == _sentinel
          ? this.createdBy
          : createdBy as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy == _sentinel
          ? this.updatedBy
          : updatedBy as String?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const Object _sentinel = Object();
}
