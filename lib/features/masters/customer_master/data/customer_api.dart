import 'customer_model.dart';

class CustomerApi {
  CustomerApi() {
    final now = DateTime.now();
    _items = [
      CustomerModel(
        id: 'cust-1',
        groupName: 'Industrial',
        companyName: 'Ultra Labs Pvt Ltd',
        displayName: 'Ultra Labs',
        addressLine1: 'Plot 12, Phase 2',
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        pincode: '400001',
        gstRegistered: true,
        gstNo: '27ABCDE1234F1Z5',
        compositDealer: false,
        billingCycle: 'monthly',
        paymentTerms: 'Net 30',
        salesPerson: 'R Mehta',
        creditControl: 'Standard',
        oem: 'OEM Alpha',
        kam: 'A Khanna',
        status: 'active',
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 40)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 2)),
        contacts: const [
          ContactPersonModel(
            id: 'c1',
            name: 'Arun Singh',
            mobile: '9999999999',
            email: 'arun@ultra.in',
          ),
        ],
        sampleTypes: const [
          SampleTypeRowModel(
            id: 's1',
            sampleTypeId: 'stype-1',
            sampleTypeName: 'Oil',
            testId: 'test-1',
            testName: 'Viscosity',
            rate: 250.0,
          ),
        ],
      ),
    ];
  }

  late List<CustomerModel> _items;
  int _seq = 1;
  int _contactSeq = 10;
  int _sampleSeq = 10;

  Future<List<CustomerModel>> fetchAll() async {
    return List<CustomerModel>.unmodifiable(_items);
  }

  Future<CustomerModel> fetchById(String id) async {
    return _items.firstWhere((e) => e.id == id);
  }

  Future<CustomerModel> create(Map<String, dynamic> data) async {
    _seq += 1;
    final now = DateTime.now();
    final model = CustomerModel(
      id: 'cust-$_seq',
      groupName: data['groupName'] as String?,
      companyName: (data['companyName'] as String? ?? '').trim(),
      displayName: data['displayName'] as String?,
      addressLine1: data['addressLine1'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      country: data['country'] as String?,
      pincode: data['pincode'] as String?,
      gstRegistered: data['gstRegistered'] == true,
      gstNo: data['gstNo'] as String?,
      compositDealer: data['compositDealer'] == true,
      billingCycle: data['billingCycle'] as String?,
      paymentTerms: data['paymentTerms'] as String?,
      salesPerson: data['salesPerson'] as String?,
      creditControl: data['creditControl'] as String?,
      oem: data['oem'] as String?,
      kam: data['kam'] as String?,
      status: (data['status'] as String?) ?? 'active',
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
      updatedAt: now,
      contacts: const [],
      sampleTypes: const [],
    );
    _items = [..._items, model];
    return model;
  }

  Future<CustomerModel> update(String id, Map<String, dynamic> data) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw Exception('Customer not found');
    }
    final prev = _items[idx];
    final next = prev.copyWith(
      groupName: data['groupName'] as String?,
      companyName: (data['companyName'] as String?)?.trim(),
      displayName: data['displayName'] as String?,
      addressLine1: data['addressLine1'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      country: data['country'] as String?,
      pincode: data['pincode'] as String?,
      gstRegistered: data['gstRegistered'] as bool?,
      gstNo: data['gstNo'] as String?,
      compositDealer: data['compositDealer'] as bool?,
      billingCycle: data['billingCycle'] as String?,
      paymentTerms: data['paymentTerms'] as String?,
      salesPerson: data['salesPerson'] as String?,
      creditControl: data['creditControl'] as String?,
      oem: data['oem'] as String?,
      kam: data['kam'] as String?,
      status: data['status'] as String?,
      updatedBy: 'Admin User',
      updatedAt: DateTime.now(),
    );
    _items = [..._items]..[idx] = next;
    return next;
  }

  Future<void> delete(String id) async {
    _items = _items.where((e) => e.id != id).toList();
  }

  Future<void> toggleStatus(String id) async {
    final item = await fetchById(id);
    await update(id, {
      'status': item.status == 'active' ? 'inactive' : 'active',
    });
  }

  Future<void> addContact(String customerId, Map<String, dynamic> data) async {
    _contactSeq += 1;
    final customer = await fetchById(customerId);
    final contact = ContactPersonModel(
      id: 'ct-$_contactSeq',
      name: (data['name'] as String? ?? '').trim(),
      mobile: data['mobile'] as String?,
      email: data['email'] as String?,
    );
    await update(customerId, {
      '_contacts': [...customer.contacts, contact],
    });
    final idx = _items.indexWhere((e) => e.id == customerId);
    _items = [..._items]
      ..[idx] = _items[idx].copyWith(
        contacts: [...customer.contacts, contact],
        updatedBy: 'Admin User',
        updatedAt: DateTime.now(),
      );
  }

  Future<void> updateContact(
    String customerId,
    String contactId,
    Map<String, dynamic> data,
  ) async {
    final customer = await fetchById(customerId);
    final contacts = customer.contacts.map((e) {
      if (e.id != contactId) return e;
      return e.copyWith(
        name: (data['name'] as String?)?.trim(),
        mobile: data['mobile'] as String?,
        email: data['email'] as String?,
      );
    }).toList();
    final idx = _items.indexWhere((e) => e.id == customerId);
    _items = [..._items]
      ..[idx] = customer.copyWith(
        contacts: contacts,
        updatedBy: 'Admin User',
        updatedAt: DateTime.now(),
      );
  }

  Future<void> deleteContact(String customerId, String contactId) async {
    final customer = await fetchById(customerId);
    final contacts = customer.contacts.where((e) => e.id != contactId).toList();
    final idx = _items.indexWhere((e) => e.id == customerId);
    _items = [..._items]
      ..[idx] = customer.copyWith(
        contacts: contacts,
        updatedBy: 'Admin User',
        updatedAt: DateTime.now(),
      );
  }

  Future<void> addSampleRow(
    String customerId,
    Map<String, dynamic> data,
  ) async {
    _sampleSeq += 1;
    final customer = await fetchById(customerId);
    final row = SampleTypeRowModel(
      id: 'sr-$_sampleSeq',
      sampleTypeId: data['sampleTypeId'] as String? ?? '',
      sampleTypeName: data['sampleTypeName'] as String? ?? '',
      testId: data['testId'] as String? ?? '',
      testName: data['testName'] as String? ?? '',
      limit: data['limit'] as String?,
      hmrLower: data['hmrLower'] as String?,
      hmrUpper: data['hmrUpper'] as String?,
      lowerMinVal: data['lowerMinVal'] as String?,
      lowerMaxVal: data['lowerMaxVal'] as String?,
      upperMinVal: data['upperMinVal'] as String?,
      upperMaxVal: data['upperMaxVal'] as String?,
      modelId: data['modelId'] as String?,
      modelName: data['modelName'] as String?,
      brandId: data['brandId'] as String?,
      brandName: data['brandName'] as String?,
      fluidId: data['fluidId'] as String?,
      fluidName: data['fluidName'] as String?,
      rate: (data['rate'] as num?)?.toDouble(),
    );
    final idx = _items.indexWhere((e) => e.id == customerId);
    _items = [..._items]
      ..[idx] = customer.copyWith(
        sampleTypes: [...customer.sampleTypes, row],
        updatedBy: 'Admin User',
        updatedAt: DateTime.now(),
      );
  }

  Future<void> updateSampleRow(
    String customerId,
    String rowId,
    Map<String, dynamic> data,
  ) async {
    final customer = await fetchById(customerId);
    final rows = customer.sampleTypes.map((e) {
      if (e.id != rowId) return e;
      return e.copyWith(
        sampleTypeId: data['sampleTypeId'] as String?,
        sampleTypeName: data['sampleTypeName'] as String?,
        testId: data['testId'] as String?,
        testName: data['testName'] as String?,
        limit: data['limit'] as String?,
        hmrLower: data['hmrLower'] as String?,
        hmrUpper: data['hmrUpper'] as String?,
        lowerMinVal: data['lowerMinVal'] as String?,
        lowerMaxVal: data['lowerMaxVal'] as String?,
        upperMinVal: data['upperMinVal'] as String?,
        upperMaxVal: data['upperMaxVal'] as String?,
        modelId: data['modelId'] as String?,
        modelName: data['modelName'] as String?,
        brandId: data['brandId'] as String?,
        brandName: data['brandName'] as String?,
        fluidId: data['fluidId'] as String?,
        fluidName: data['fluidName'] as String?,
        rate: (data['rate'] as num?)?.toDouble(),
      );
    }).toList();
    final idx = _items.indexWhere((e) => e.id == customerId);
    _items = [..._items]
      ..[idx] = customer.copyWith(
        sampleTypes: rows,
        updatedBy: 'Admin User',
        updatedAt: DateTime.now(),
      );
  }

  Future<void> deleteSampleRow(String customerId, String rowId) async {
    final customer = await fetchById(customerId);
    final rows = customer.sampleTypes.where((e) => e.id != rowId).toList();
    final idx = _items.indexWhere((e) => e.id == customerId);
    _items = [..._items]
      ..[idx] = customer.copyWith(
        sampleTypes: rows,
        updatedBy: 'Admin User',
        updatedAt: DateTime.now(),
      );
  }

  Future<void> clearAllSamples(String customerId) async {
    final customer = await fetchById(customerId);
    final idx = _items.indexWhere((e) => e.id == customerId);
    _items = [..._items]
      ..[idx] = customer.copyWith(
        sampleTypes: const [],
        updatedBy: 'Admin User',
        updatedAt: DateTime.now(),
      );
  }
}
