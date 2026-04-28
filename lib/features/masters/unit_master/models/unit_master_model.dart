import '../../shared/master_status.dart';

class UnitMasterModel {
  const UnitMasterModel({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String name;
  final MasterStatus status;
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime updatedAt;

  UnitMasterModel copyWith({
    String? id,
    String? code,
    String? name,
    MasterStatus? status,
    Object? createdBy = _sentinel,
    DateTime? createdAt,
    Object? updatedBy = _sentinel,
    DateTime? updatedAt,
  }) {
    return UnitMasterModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
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
