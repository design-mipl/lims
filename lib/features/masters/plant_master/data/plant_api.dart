import 'plant_model.dart';

/// In-memory mock API for plant master.
class PlantApi {
  PlantApi() {
    final now = DateTime.now();
    _items = [
      PlantModel(
        id: 'plant-1',
        code: 'PLT001',
        plant: 'Mumbai Manufacturing',
        status: 'active',
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      PlantModel(
        id: 'plant-2',
        code: 'PLT002',
        plant: 'Pune Packaging Unit',
        status: 'active',
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedBy: 'Lab Tech',
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      PlantModel(
        id: 'plant-3',
        code: 'PLT003',
        plant: 'Chennai Warehouse',
        status: 'inactive',
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 120)),
        updatedBy: 'QA Manager',
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  late List<PlantModel> _items;
  int _seq = 3;

  Future<List<PlantModel>> fetchAll() async {
    return List<PlantModel>.unmodifiable(_items);
  }

  Future<PlantModel> create(Map<String, dynamic> data) async {
    _seq += 1;
    final now = DateTime.now();
    final model = PlantModel(
      id: 'plant-$_seq',
      code: (data['code'] as String? ?? '').trim(),
      plant: (data['plant'] as String? ?? '').trim(),
      status: (data['status'] as String?) ?? 'active',
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
    _items = [..._items, model];
    return model;
  }

  Future<PlantModel> update(String id, Map<String, dynamic> data) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('Plant not found');
    final prev = _items[idx];
    final next = prev.copyWith(
      code: data.containsKey('code')
          ? (data['code'] as String?)?.trim() ?? prev.code
          : null,
      plant: data.containsKey('plant')
          ? (data['plant'] as String?)?.trim() ?? prev.plant
          : null,
      status: data.containsKey('status') ? data['status'] as String? : null,
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
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('Plant not found');
    final prev = _items[idx];
    final next = prev.copyWith(
      status: prev.status == 'active' ? 'inactive' : 'active',
      updatedBy: 'Admin User',
      updatedAt: DateTime.now(),
    );
    _items = [..._items]..[idx] = next;
  }
}
