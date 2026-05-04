class SiteModel {
  const SiteModel({
    required this.id,
    required this.code,
    this.typeOfContact,
    this.displayName,
    this.companyName,
    this.addressLine1,
    this.city,
    this.state,
    this.country,
    required this.gstRegistered,
    this.gstNo,
    required this.compositDealer,
    this.companyId,
    this.companyLabel,
    this.mergedItems,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String? typeOfContact;
  final String? displayName;
  final String? companyName;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? country;
  final bool gstRegistered;
  final String? gstNo;
  final bool compositDealer;
  final String? companyId;
  final String? companyLabel;
  final String? mergedItems;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;

  static const Object _sentinel = Object();

  SiteModel copyWith({
    String? id,
    String? code,
    Object? typeOfContact = _sentinel,
    Object? displayName = _sentinel,
    Object? companyName = _sentinel,
    Object? addressLine1 = _sentinel,
    Object? city = _sentinel,
    Object? state = _sentinel,
    Object? country = _sentinel,
    bool? gstRegistered,
    Object? gstNo = _sentinel,
    bool? compositDealer,
    Object? companyId = _sentinel,
    Object? companyLabel = _sentinel,
    Object? mergedItems = _sentinel,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return SiteModel(
      id: id ?? this.id,
      code: code ?? this.code,
      typeOfContact: typeOfContact == _sentinel
          ? this.typeOfContact
          : typeOfContact as String?,
      displayName: displayName == _sentinel
          ? this.displayName
          : displayName as String?,
      companyName: companyName == _sentinel
          ? this.companyName
          : companyName as String?,
      addressLine1: addressLine1 == _sentinel
          ? this.addressLine1
          : addressLine1 as String?,
      city: city == _sentinel ? this.city : city as String?,
      state: state == _sentinel ? this.state : state as String?,
      country: country == _sentinel ? this.country : country as String?,
      gstRegistered: gstRegistered ?? this.gstRegistered,
      gstNo: gstNo == _sentinel ? this.gstNo : gstNo as String?,
      compositDealer: compositDealer ?? this.compositDealer,
      companyId: companyId == _sentinel ? this.companyId : companyId as String?,
      companyLabel: companyLabel == _sentinel
          ? this.companyLabel
          : companyLabel as String?,
      mergedItems: mergedItems == _sentinel
          ? this.mergedItems
          : mergedItems as String?,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
