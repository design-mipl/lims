import '../models/item_master_model.dart';
import '../../shared/master_status.dart';

class ItemMasterApi {
  ItemMasterApi() {
    final now = DateTime.now();
    _items = [
      ItemMasterModel(
        id: 'item-1',
        code: 'EO',
        name: 'Engine Oil',
        description: 'Lubricant for engines',
        status: MasterStatus.active,
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 40)),
        updatedBy: 'Lab Tech',
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
      ItemMasterModel(
        id: 'item-2',
        code: 'CO',
        name: 'Cutting Oil',
        description: null,
        status: MasterStatus.active,
        createdBy: 'QA Manager',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  late List<ItemMasterModel> _items;
  int _seq = 0;

  String? _normDescription(String? description) {
    if (description == null) return null;
    final t = description.trim();
    return t.isEmpty ? null : t;
  }

  bool _codeTaken(String code, {String? excludeId}) {
    final c = code.trim().toLowerCase();
    return _items.any(
      (e) =>
          e.code.trim().toLowerCase() == c &&
          (excludeId == null || e.id != excludeId),
    );
  }

  Future<List<ItemMasterModel>> fetchAll() async {
    return List<ItemMasterModel>.unmodifiable(_items);
  }

  Future<ItemMasterModel> create({
    required String code,
    required String name,
    String? description,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code)) throw Exception('Code already exists');
    final now = DateTime.now();
    _seq += 1;
    final model = ItemMasterModel(
      id: 'item-new-$_seq',
      code: code.trim(),
      name: name.trim(),
      description: _normDescription(description),
      status: status,
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
    _items = [..._items, model];
    return model;
  }

  Future<ItemMasterModel> update({
    required String id,
    required String code,
    required String name,
    String? description,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code, excludeId: id)) throw Exception('Code already exists');
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('Record not found');
    final prev = _items[idx];
    final next = prev.copyWith(
      code: code.trim(),
      name: name.trim(),
      description: _normDescription(description),
      status: status,
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
    if (idx < 0) return;
    final prev = _items[idx];
    final next = prev.copyWith(
      status: prev.status == MasterStatus.active
          ? MasterStatus.inactive
          : MasterStatus.active,
      updatedBy: 'Admin User',
      updatedAt: DateTime.now(),
    );
    _items = [..._items]..[idx] = next;
  }

  Future<void> updateStatus(String id, String status) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final next = _items[idx].copyWith(
      status: MasterStatus.values.byName(status),
      updatedBy: 'Admin User',
      updatedAt: DateTime.now(),
    );
    _items = [..._items]..[idx] = next;
  }
}
