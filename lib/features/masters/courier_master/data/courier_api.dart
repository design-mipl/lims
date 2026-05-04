import 'courier_model.dart';

/// In-memory mock API for Courier Master.
class CourierApi {
  CourierApi() {
    final now = DateTime.now();
    _items = [
      _seed(
        id: 'courier-1',
        code: 'CR-DBL',
        companyName: 'BlueDart Express Ltd',
        personName: 'Ramesh Iyer',
        address: 'Cargo Bay 2, Sahar Cargo, Andheri East',
        city: 'Mumbai',
        state: 'Maharashtra',
        emails: ['ops.mum@bluedart-mock.in'],
        mobiles: ['9820012345'],
        areas: [
          const CourierAreaMapping(
            id: 'courier-1-a1',
            area: 'Western Suburbs',
            siteId: 'site-1',
            siteName: 'Mumbai Plant',
          ),
        ],
        contacts: [
          const CourierContactMapping(
            id: 'courier-1-c1',
            contactPerson: 'Pickup Desk',
            mobile: '9820012345',
            email: 'pickup@bluedart-mock.in',
          ),
        ],
        status: 'active',
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(hours: 4)),
        createdAt: now.subtract(const Duration(days: 100)),
      ),
      _seed(
        id: 'courier-2',
        code: 'CR-DTDC',
        companyName: 'DTDC India',
        personName: 'Sneha Patil',
        address: 'Plot 88, Logistics Park, Talegaon',
        city: 'Pune',
        state: 'Maharashtra',
        emails: ['pune.hub@dtdc-mock.in', 'svc@dtdc-mock.in'],
        mobiles: ['9876501234', '9876501235'],
        areas: [
          const CourierAreaMapping(
            id: 'courier-2-a1',
            area: 'Pune PCMC',
            siteId: 'site-2',
            siteName: 'Pune DC',
          ),
          const CourierAreaMapping(
            id: 'courier-2-a2',
            area: 'Hinjewadi',
            siteId: 'site-2',
            siteName: 'Pune DC',
          ),
        ],
        contacts: [
          const CourierContactMapping(
            id: 'courier-2-c1',
            contactPerson: 'Branch Manager',
            mobile: '9876501234',
            email: null,
          ),
        ],
        status: 'active',
        updatedBy: 'Ops Lead',
        updatedAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 80)),
      ),
      _seed(
        id: 'courier-3',
        code: 'CR-FEDX',
        companyName: 'FedEx Logistics',
        personName: 'Ananya Rao',
        address: 'Whitefield Industrial Area',
        city: 'Bengaluru',
        state: 'Karnataka',
        emails: [],
        mobiles: ['9988776655'],
        areas: [
          const CourierAreaMapping(
            id: 'courier-3-a1',
            area: 'Electronic City',
            siteId: 'site-3',
            siteName: 'Bangalore Hub',
          ),
        ],
        contacts: [],
        status: 'inactive',
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 20)),
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      _seed(
        id: 'courier-4',
        code: 'CR-EKRT',
        companyName: 'Ekart Logistics',
        personName: 'Vikram Singh',
        address: 'Warehouse Sector 18',
        city: 'Gurugram',
        state: 'Haryana',
        emails: ['north.courier@ekart-mock.in'],
        mobiles: ['9810203040'],
        areas: [
          const CourierAreaMapping(
            id: 'courier-4-a1',
            area: 'NCR Zone A',
            siteId: null,
            siteName: null,
          ),
        ],
        contacts: [
          const CourierContactMapping(
            id: 'courier-4-c1',
            contactPerson: 'Vikram Singh',
            mobile: '9810203040',
            email: 'vikram.s@ekart-mock.in',
          ),
        ],
        status: 'active',
        updatedBy: 'Warehouse Admin',
        updatedAt: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      _seed(
        id: 'courier-5',
        code: 'CR-DHL',
        companyName: 'DHL Supply Chain',
        personName: 'Meera Krishnan',
        address: 'Chennai Trade Centre, Nandambakkam',
        city: 'Chennai',
        state: 'Tamil Nadu',
        emails: ['chennai.ops@dhl-mock.in'],
        mobiles: ['9444012345', '9444012346'],
        areas: [
          const CourierAreaMapping(
            id: 'courier-5-a1',
            area: 'Porur',
            siteId: null,
            siteName: null,
          ),
          const CourierAreaMapping(
            id: 'courier-5-a2',
            area: 'Ambattur',
            siteId: 'site-3',
            siteName: 'Bangalore Hub',
          ),
        ],
        contacts: [
          const CourierContactMapping(
            id: 'courier-5-c1',
            contactPerson: 'Ground Ops',
            mobile: '9444012345',
            email: null,
          ),
        ],
        status: 'active',
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(hours: 8)),
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      _seed(
        id: 'courier-6',
        code: 'CR-XPRS',
        companyName: '',
        personName: 'Kumar Velu',
        address: 'Door 12, SIDCO Industrial Estate',
        city: 'Coimbatore',
        state: 'Tamil Nadu',
        emails: ['kumar.velu@express-mock.in'],
        mobiles: ['9842233445'],
        areas: [],
        contacts: [
          const CourierContactMapping(
            id: 'courier-6-c1',
            contactPerson: 'Kumar Velu',
            mobile: '9842233445',
            email: 'kumar.velu@express-mock.in',
          ),
        ],
        status: 'active',
        updatedBy: 'Kumar Velu',
        updatedAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      _seed(
        id: 'courier-7',
        code: 'CR-PTML',
        companyName: 'Professional Couriers',
        personName: 'Joseph Mathew',
        address: 'MG Road',
        city: 'Kochi',
        state: 'Kerala',
        emails: [],
        mobiles: [],
        areas: [
          const CourierAreaMapping(
            id: 'courier-7-a1',
            area: 'Ernakulam Central',
            siteId: null,
            siteName: null,
          ),
        ],
        contacts: [],
        status: 'inactive',
        updatedBy: 'Joseph Mathew',
        updatedAt: now.subtract(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 300)),
      ),
      _seed(
        id: 'courier-8',
        code: 'CR-SAFE',
        companyName: 'SafeReach Cargo',
        personName: 'Divya Shah',
        address: 'NH48 Service Road',
        city: 'Ahmedabad',
        state: 'Gujarat',
        emails: ['accounts@safereach-mock.in', 'dispatch@safereach-mock.in'],
        mobiles: ['9825011122'],
        areas: [
          const CourierAreaMapping(
            id: 'courier-8-a1',
            area: 'GIDC Vatva',
            siteId: null,
            siteName: null,
          ),
        ],
        contacts: [
          const CourierContactMapping(
            id: 'courier-8-c1',
            contactPerson: 'Dispatch',
            mobile: '9825011122',
            email: 'dispatch@safereach-mock.in',
          ),
          const CourierContactMapping(
            id: 'courier-8-c2',
            contactPerson: 'Billing',
            mobile: '9825013344',
            email: null,
          ),
        ],
        status: 'active',
        updatedBy: 'Divya Shah',
        updatedAt: now.subtract(const Duration(minutes: 30)),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  late List<CourierModel> _items;
  int _seq = 8;

  CourierModel _seed({
    required String id,
    required String code,
    required String companyName,
    required String personName,
    required String address,
    required String city,
    required String state,
    required List<String> emails,
    required List<String> mobiles,
    required List<CourierAreaMapping> areas,
    required List<CourierContactMapping> contacts,
    required String status,
    required String updatedBy,
    required DateTime updatedAt,
    required DateTime createdAt,
  }) {
    return CourierModel(
      id: id,
      code: code,
      companyName: companyName,
      personName: personName,
      address: address,
      city: city,
      state: state,
      emails: emails,
      mobiles: mobiles,
      areaMappings: areas,
      contactMappings: contacts,
      status: status,
      createdBy: 'Admin User',
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
    );
  }

  List<String> _parseEmails(dynamic raw) {
    final list = _parseStringList(raw);
    return list.length > 2 ? list.sublist(0, 2) : list;
  }

  List<String> _parseMobiles(dynamic raw) {
    final list = _parseStringList(raw);
    return list.length > 2 ? list.sublist(0, 2) : list;
  }

  List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .map((e) => (e ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  List<CourierAreaMapping> _parseAreas(
    dynamic raw, {
    required String courierIdForNewIds,
    int? mappingSeqStart,
  }) {
    if (raw is! List) return [];
    var n = mappingSeqStart ?? 1;
    return raw.map((e) {
      if (e is! Map) {
        n++;
        return CourierAreaMapping(
          id: '$courierIdForNewIds-a-$n',
          area: '',
        );
      }
      final m = Map<String, dynamic>.from(e);
      final idRaw = (m['id'] as String?)?.trim();
      final id = (idRaw != null && idRaw.isNotEmpty)
          ? idRaw
          : '$courierIdForNewIds-a-${n++}';
      return CourierAreaMapping(
        id: id,
        area: (m['area'] as String? ?? '').trim(),
        siteId: m['siteId'] as String?,
        siteName: (m['siteName'] as String?)?.trim().isEmpty == true
            ? null
            : m['siteName'] as String?,
      );
    }).toList();
  }

  List<CourierContactMapping> _parseContacts(
    dynamic raw, {
    required String courierIdForNewIds,
    int? mappingSeqStart,
  }) {
    if (raw is! List) return [];
    var n = mappingSeqStart ?? 1;
    return raw.map((e) {
      if (e is! Map) {
        n++;
        return CourierContactMapping(
          id: '$courierIdForNewIds-c-$n',
          contactPerson: '',
          mobile: '',
        );
      }
      final m = Map<String, dynamic>.from(e);
      final idRaw = (m['id'] as String?)?.trim();
      final id = (idRaw != null && idRaw.isNotEmpty)
          ? idRaw
          : '$courierIdForNewIds-c-${n++}';
      return CourierContactMapping(
        id: id,
        contactPerson: (m['contactPerson'] as String? ?? '').trim(),
        mobile: (m['mobile'] as String? ?? '').trim(),
        email: (m['email'] as String?)?.trim().isEmpty == true
            ? null
            : m['email'] as String?,
      );
    }).toList();
  }

  Future<List<CourierModel>> fetchAll() async {
    return List<CourierModel>.unmodifiable(_items);
  }

  Future<CourierModel> fetchById(String id) async {
    return _items.firstWhere((e) => e.id == id);
  }

  Future<CourierModel> create(Map<String, dynamic> data) async {
    _seq += 1;
    final id = 'courier-$_seq';
    final now = DateTime.now();
    final emails = _parseEmails(data['emails']);
    final mobiles = _parseMobiles(data['mobiles']);
    final areas = _parseAreas(data['areaMappings'], courierIdForNewIds: id);
    final contacts = _parseContacts(
      data['contactMappings'],
      courierIdForNewIds: id,
    );

    final model = CourierModel(
      id: id,
      code: (data['code'] as String? ?? '').trim(),
      companyName: (data['companyName'] as String? ?? '').trim(),
      personName: (data['personName'] as String? ?? '').trim(),
      address: (data['address'] as String? ?? '').trim(),
      city: (data['city'] as String? ?? '').trim(),
      state: (data['state'] as String? ?? '').trim(),
      emails: emails,
      mobiles: mobiles,
      areaMappings: areas,
      contactMappings: contacts,
      status: (data['status'] as String?) ?? 'active',
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
    _items = [..._items, model];
    return model;
  }

  Future<CourierModel> update(String id, Map<String, dynamic> data) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw Exception('Courier not found');
    }
    final prev = _items[idx];

    final emails = data.containsKey('emails')
        ? _parseEmails(data['emails'])
        : prev.emails;
    final mobiles = data.containsKey('mobiles')
        ? _parseMobiles(data['mobiles'])
        : prev.mobiles;
    final areas = data.containsKey('areaMappings')
        ? _parseAreas(data['areaMappings'], courierIdForNewIds: id)
        : prev.areaMappings;
    final contacts = data.containsKey('contactMappings')
        ? _parseContacts(data['contactMappings'], courierIdForNewIds: id)
        : prev.contactMappings;

    final next = CourierModel(
      id: prev.id,
      code: data.containsKey('code')
          ? (data['code'] as String? ?? '').trim().isEmpty
              ? prev.code
              : (data['code'] as String).trim()
          : prev.code,
      companyName: data.containsKey('companyName')
          ? (data['companyName'] as String? ?? '').trim()
          : prev.companyName,
      personName: data.containsKey('personName')
          ? (data['personName'] as String? ?? '').trim()
          : prev.personName,
      address: data.containsKey('address')
          ? (data['address'] as String? ?? '').trim()
          : prev.address,
      city: data.containsKey('city')
          ? (data['city'] as String? ?? '').trim()
          : prev.city,
      state: data.containsKey('state')
          ? (data['state'] as String? ?? '').trim()
          : prev.state,
      emails: emails,
      mobiles: mobiles,
      areaMappings: areas,
      contactMappings: contacts,
      status: data.containsKey('status')
          ? (data['status'] as String?) ?? prev.status
          : prev.status,
      createdBy: prev.createdBy,
      createdAt: prev.createdAt,
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
    final prev = await fetchById(id);
    await update(id, {
      'status': prev.status == 'active' ? 'inactive' : 'active',
    });
  }

  Future<void> bulkActivate(List<String> ids) async {
    for (final id in ids) {
      try {
        final c = await fetchById(id);
        if (c.status != 'active') {
          await update(id, {'status': 'active'});
        }
      } catch (_) {}
    }
  }

  Future<void> bulkDeactivate(List<String> ids) async {
    for (final id in ids) {
      try {
        final c = await fetchById(id);
        if (c.status != 'inactive') {
          await update(id, {'status': 'inactive'});
        }
      } catch (_) {}
    }
  }

  Future<void> bulkDelete(List<String> ids) async {
    for (final id in ids) {
      await delete(id);
    }
  }
}
