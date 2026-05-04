import 'site_model.dart';

class SiteApi {
  SiteApi() {
    final now = DateTime.now();
    _items = [
      SiteModel(
        id: 'site-1',
        code: 'S-MUM-01',
        typeOfContact: 'Plant',
        displayName: 'Mumbai Plant',
        companyName: 'Ultra Labs Pvt Ltd',
        addressLine1: 'Plot 12, Phase 2, MIDC',
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        gstRegistered: true,
        gstNo: '27ABCDE1234F1Z5',
        compositDealer: false,
        companyId: 'cust-1',
        companyLabel: 'Ultra Labs Pvt Ltd',
        mergedItems: 'Oil, Grease',
        status: 'active',
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      SiteModel(
        id: 'site-2',
        code: 'S-PNQ-02',
        typeOfContact: 'Warehouse',
        displayName: 'Pune DC',
        companyName: 'Acme Industries',
        addressLine1: 'SR No 45, Hinjewadi',
        city: 'Pune',
        state: 'Maharashtra',
        country: 'India',
        gstRegistered: false,
        gstNo: null,
        compositDealer: false,
        companyId: null,
        companyLabel: null,
        mergedItems: null,
        status: 'inactive',
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      SiteModel(
        id: 'site-3',
        code: 'S-BLR-03',
        typeOfContact: 'Office',
        displayName: 'Bangalore Hub',
        companyName: 'TechChem Ltd',
        addressLine1: 'Electronic City Phase 1',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        gstRegistered: true,
        gstNo: '29XYZDE9876G2Z1',
        compositDealer: true,
        companyId: null,
        companyLabel: null,
        mergedItems: 'Coolant samples',
        status: 'active',
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }

  late List<SiteModel> _items;
  int _seq = 3;

  Future<List<SiteModel>> fetchAll() async {
    return List<SiteModel>.unmodifiable(_items);
  }

  Future<SiteModel> fetchById(String id) async {
    return _items.firstWhere((e) => e.id == id);
  }

  Future<SiteModel> create(Map<String, dynamic> data) async {
    _seq += 1;
    final now = DateTime.now();
    final model = SiteModel(
      id: 'site-$_seq',
      code: (data['code'] as String? ?? '').trim(),
      typeOfContact: data['typeOfContact'] as String?,
      displayName: data['displayName'] as String?,
      companyName: data['companyName'] as String?,
      addressLine1: data['addressLine1'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      country: data['country'] as String?,
      gstRegistered: data['gstRegistered'] == true,
      gstNo: data['gstNo'] as String?,
      compositDealer: data['compositDealer'] == true,
      companyId: data['companyId'] as String?,
      companyLabel: data['companyLabel'] as String?,
      mergedItems: data['mergedItems'] as String?,
      status: (data['status'] as String?) ?? 'active',
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
    _items = [..._items, model];
    return model;
  }

  Future<SiteModel> update(String id, Map<String, dynamic> data) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw Exception('Site not found');
    }
    final prev = _items[idx];
    final next = SiteModel(
      id: prev.id,
      code: data.containsKey('code')
          ? () {
              final raw = data['code'] as String?;
              final t = raw?.trim() ?? '';
              return t.isEmpty ? prev.code : t;
            }()
          : prev.code,
      typeOfContact: data.containsKey('typeOfContact')
          ? data['typeOfContact'] as String?
          : prev.typeOfContact,
      displayName: data.containsKey('displayName')
          ? data['displayName'] as String?
          : prev.displayName,
      companyName: data.containsKey('companyName')
          ? data['companyName'] as String?
          : prev.companyName,
      addressLine1: data.containsKey('addressLine1')
          ? data['addressLine1'] as String?
          : prev.addressLine1,
      city: data.containsKey('city') ? data['city'] as String? : prev.city,
      state: data.containsKey('state') ? data['state'] as String? : prev.state,
      country: data.containsKey('country')
          ? data['country'] as String?
          : prev.country,
      gstRegistered: data.containsKey('gstRegistered')
          ? data['gstRegistered'] == true
          : prev.gstRegistered,
      gstNo: data.containsKey('gstNo') ? data['gstNo'] as String? : prev.gstNo,
      compositDealer: data.containsKey('compositDealer')
          ? data['compositDealer'] == true
          : prev.compositDealer,
      companyId: data.containsKey('companyId')
          ? data['companyId'] as String?
          : prev.companyId,
      companyLabel: data.containsKey('companyLabel')
          ? data['companyLabel'] as String?
          : prev.companyLabel,
      mergedItems: data.containsKey('mergedItems')
          ? data['mergedItems'] as String?
          : prev.mergedItems,
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
    final item = await fetchById(id);
    await update(id, {
      'status': item.status == 'active' ? 'inactive' : 'active',
    });
  }
}
