class CourierAreaMapping {
  const CourierAreaMapping({
    required this.id,
    required this.area,
    this.siteId,
    this.siteName,
  });

  static const Object _sentinel = Object();

  final String id;
  final String area;
  final String? siteId;
  final String? siteName;

  CourierAreaMapping copyWith({
    String? id,
    String? area,
    Object? siteId = _sentinel,
    Object? siteName = _sentinel,
  }) {
    return CourierAreaMapping(
      id: id ?? this.id,
      area: area ?? this.area,
      siteId: siteId == _sentinel ? this.siteId : siteId as String?,
      siteName: siteName == _sentinel ? this.siteName : siteName as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'area': area,
        'siteId': siteId,
        'siteName': siteName,
      };

  static CourierAreaMapping fromJson(Map<String, dynamic> m) {
    return CourierAreaMapping(
      id: m['id'] as String? ?? '',
      area: m['area'] as String? ?? '',
      siteId: m['siteId'] as String?,
      siteName: m['siteName'] as String?,
    );
  }
}

class CourierContactMapping {
  const CourierContactMapping({
    required this.id,
    required this.contactPerson,
    required this.mobile,
    this.email,
  });

  static const Object _sentinel = Object();

  final String id;
  final String contactPerson;
  final String mobile;
  final String? email;

  CourierContactMapping copyWith({
    String? id,
    String? contactPerson,
    String? mobile,
    Object? email = _sentinel,
  }) {
    return CourierContactMapping(
      id: id ?? this.id,
      contactPerson: contactPerson ?? this.contactPerson,
      mobile: mobile ?? this.mobile,
      email: email == _sentinel ? this.email : email as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contactPerson': contactPerson,
        'mobile': mobile,
        'email': email,
      };

  static CourierContactMapping fromJson(Map<String, dynamic> m) {
    return CourierContactMapping(
      id: m['id'] as String? ?? '',
      contactPerson: m['contactPerson'] as String? ?? '',
      mobile: m['mobile'] as String? ?? '',
      email: m['email'] as String?,
    );
  }
}

class CourierModel {
  const CourierModel({
    required this.id,
    required this.code,
    required this.companyName,
    required this.personName,
    required this.address,
    required this.city,
    required this.state,
    required this.emails,
    required this.mobiles,
    required this.areaMappings,
    required this.contactMappings,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String companyName;
  final String personName;
  final String address;
  final String city;
  final String state;
  final List<String> emails;
  final List<String> mobiles;
  final List<CourierAreaMapping> areaMappings;
  final List<CourierContactMapping> contactMappings;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;

  CourierModel copyWith({
    String? id,
    String? code,
    String? companyName,
    String? personName,
    String? address,
    String? city,
    String? state,
    List<String>? emails,
    List<String>? mobiles,
    List<CourierAreaMapping>? areaMappings,
    List<CourierContactMapping>? contactMappings,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return CourierModel(
      id: id ?? this.id,
      code: code ?? this.code,
      companyName: companyName ?? this.companyName,
      personName: personName ?? this.personName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      emails: emails ?? this.emails,
      mobiles: mobiles ?? this.mobiles,
      areaMappings: areaMappings ?? this.areaMappings,
      contactMappings: contactMappings ?? this.contactMappings,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toCreateUpdateMap() {
    return {
      'code': code,
      'companyName': companyName,
      'personName': personName,
      'address': address,
      'city': city,
      'state': state,
      'emails': List<String>.from(emails),
      'mobiles': List<String>.from(mobiles),
      'areaMappings': areaMappings.map((e) => e.toJson()).toList(),
      'contactMappings': contactMappings.map((e) => e.toJson()).toList(),
      'status': status,
    };
  }
}
