class CustomerModel {
  const CustomerModel({
    required this.id,
    this.groupName,
    required this.companyName,
    this.displayName,
    this.addressLine1,
    this.city,
    this.state,
    this.country,
    this.pincode,
    required this.gstRegistered,
    this.gstNo,
    required this.compositDealer,
    this.billingCycle,
    this.paymentTerms,
    this.salesPerson,
    this.creditControl,
    this.oem,
    this.kam,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.contacts = const <ContactPersonModel>[],
    this.sampleTypes = const <SampleTypeRowModel>[],
  });

  final String id;
  final String? groupName;
  final String companyName;
  final String? displayName;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final bool gstRegistered;
  final String? gstNo;
  final bool compositDealer;
  final String? billingCycle;
  final String? paymentTerms;
  final String? salesPerson;
  final String? creditControl;
  final String? oem;
  final String? kam;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final List<ContactPersonModel> contacts;
  final List<SampleTypeRowModel> sampleTypes;

  CustomerModel copyWith({
    String? id,
    Object? groupName = _sentinel,
    String? companyName,
    Object? displayName = _sentinel,
    Object? addressLine1 = _sentinel,
    Object? city = _sentinel,
    Object? state = _sentinel,
    Object? country = _sentinel,
    Object? pincode = _sentinel,
    bool? gstRegistered,
    Object? gstNo = _sentinel,
    bool? compositDealer,
    Object? billingCycle = _sentinel,
    Object? paymentTerms = _sentinel,
    Object? salesPerson = _sentinel,
    Object? creditControl = _sentinel,
    Object? oem = _sentinel,
    Object? kam = _sentinel,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    List<ContactPersonModel>? contacts,
    List<SampleTypeRowModel>? sampleTypes,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      groupName: groupName == _sentinel ? this.groupName : groupName as String?,
      companyName: companyName ?? this.companyName,
      displayName: displayName == _sentinel
          ? this.displayName
          : displayName as String?,
      addressLine1: addressLine1 == _sentinel
          ? this.addressLine1
          : addressLine1 as String?,
      city: city == _sentinel ? this.city : city as String?,
      state: state == _sentinel ? this.state : state as String?,
      country: country == _sentinel ? this.country : country as String?,
      pincode: pincode == _sentinel ? this.pincode : pincode as String?,
      gstRegistered: gstRegistered ?? this.gstRegistered,
      gstNo: gstNo == _sentinel ? this.gstNo : gstNo as String?,
      compositDealer: compositDealer ?? this.compositDealer,
      billingCycle: billingCycle == _sentinel
          ? this.billingCycle
          : billingCycle as String?,
      paymentTerms: paymentTerms == _sentinel
          ? this.paymentTerms
          : paymentTerms as String?,
      salesPerson: salesPerson == _sentinel
          ? this.salesPerson
          : salesPerson as String?,
      creditControl: creditControl == _sentinel
          ? this.creditControl
          : creditControl as String?,
      oem: oem == _sentinel ? this.oem : oem as String?,
      kam: kam == _sentinel ? this.kam : kam as String?,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      contacts: contacts ?? this.contacts,
      sampleTypes: sampleTypes ?? this.sampleTypes,
    );
  }

  static const Object _sentinel = Object();
}

class ContactPersonModel {
  const ContactPersonModel({
    required this.id,
    required this.name,
    this.mobile,
    this.email,
  });

  final String id;
  final String name;
  final String? mobile;
  final String? email;

  ContactPersonModel copyWith({
    String? id,
    String? name,
    Object? mobile = CustomerModel._sentinel,
    Object? email = CustomerModel._sentinel,
  }) {
    return ContactPersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile == CustomerModel._sentinel
          ? this.mobile
          : mobile as String?,
      email: email == CustomerModel._sentinel ? this.email : email as String?,
    );
  }
}

class SampleTypeRowModel {
  const SampleTypeRowModel({
    required this.id,
    required this.sampleTypeId,
    required this.sampleTypeName,
    required this.testId,
    required this.testName,
    this.limit,
    this.hmrLower,
    this.hmrUpper,
    this.lowerMinVal,
    this.lowerMaxVal,
    this.upperMinVal,
    this.upperMaxVal,
    this.modelId,
    this.modelName,
    this.brandId,
    this.brandName,
    this.fluidId,
    this.fluidName,
    this.rate,
  });

  final String id;
  final String sampleTypeId;
  final String sampleTypeName;
  final String testId;
  final String testName;
  final String? limit;
  final String? hmrLower;
  final String? hmrUpper;
  final String? lowerMinVal;
  final String? lowerMaxVal;
  final String? upperMinVal;
  final String? upperMaxVal;
  final String? modelId;
  final String? modelName;
  final String? brandId;
  final String? brandName;
  final String? fluidId;
  final String? fluidName;
  final double? rate;

  SampleTypeRowModel copyWith({
    String? id,
    String? sampleTypeId,
    String? sampleTypeName,
    String? testId,
    String? testName,
    Object? limit = CustomerModel._sentinel,
    Object? hmrLower = CustomerModel._sentinel,
    Object? hmrUpper = CustomerModel._sentinel,
    Object? lowerMinVal = CustomerModel._sentinel,
    Object? lowerMaxVal = CustomerModel._sentinel,
    Object? upperMinVal = CustomerModel._sentinel,
    Object? upperMaxVal = CustomerModel._sentinel,
    Object? modelId = CustomerModel._sentinel,
    Object? modelName = CustomerModel._sentinel,
    Object? brandId = CustomerModel._sentinel,
    Object? brandName = CustomerModel._sentinel,
    Object? fluidId = CustomerModel._sentinel,
    Object? fluidName = CustomerModel._sentinel,
    Object? rate = CustomerModel._sentinel,
  }) {
    return SampleTypeRowModel(
      id: id ?? this.id,
      sampleTypeId: sampleTypeId ?? this.sampleTypeId,
      sampleTypeName: sampleTypeName ?? this.sampleTypeName,
      testId: testId ?? this.testId,
      testName: testName ?? this.testName,
      limit: limit == CustomerModel._sentinel ? this.limit : limit as String?,
      hmrLower: hmrLower == CustomerModel._sentinel
          ? this.hmrLower
          : hmrLower as String?,
      hmrUpper: hmrUpper == CustomerModel._sentinel
          ? this.hmrUpper
          : hmrUpper as String?,
      lowerMinVal: lowerMinVal == CustomerModel._sentinel
          ? this.lowerMinVal
          : lowerMinVal as String?,
      lowerMaxVal: lowerMaxVal == CustomerModel._sentinel
          ? this.lowerMaxVal
          : lowerMaxVal as String?,
      upperMinVal: upperMinVal == CustomerModel._sentinel
          ? this.upperMinVal
          : upperMinVal as String?,
      upperMaxVal: upperMaxVal == CustomerModel._sentinel
          ? this.upperMaxVal
          : upperMaxVal as String?,
      modelId: modelId == CustomerModel._sentinel
          ? this.modelId
          : modelId as String?,
      modelName: modelName == CustomerModel._sentinel
          ? this.modelName
          : modelName as String?,
      brandId: brandId == CustomerModel._sentinel
          ? this.brandId
          : brandId as String?,
      brandName: brandName == CustomerModel._sentinel
          ? this.brandName
          : brandName as String?,
      fluidId: fluidId == CustomerModel._sentinel
          ? this.fluidId
          : fluidId as String?,
      fluidName: fluidName == CustomerModel._sentinel
          ? this.fluidName
          : fluidName as String?,
      rate: rate == CustomerModel._sentinel ? this.rate : rate as double?,
    );
  }
}
