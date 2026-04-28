import '../models/ferrography_master_model.dart';
import '../../shared/master_status.dart';

class FerrographyMasterApi {
  FerrographyMasterApi() {
    final now = DateTime.now();
    _items = [
      FerrographyMasterModel(
        id: 'ferro-1',
        code: 'PQ',
        name: 'PQ Index',
        status: MasterStatus.active,
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 28)),
        updatedBy: 'Lab Tech',
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      FerrographyMasterModel(
        id: 'ferro-2',
        code: 'WPC',
        name: 'Wear particle concentration',
        status: MasterStatus.active,
        createdBy: 'QA Manager',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  late List<FerrographyMasterModel> _items;
  int _seq = 0;

  bool _codeTaken(String code, {String? excludeId}) {
    final c = code.trim().toLowerCase();
    return _items.any(
      (e) =>
          e.code.trim().toLowerCase() == c &&
          (excludeId == null || e.id != excludeId),
    );
  }

  Future<List<FerrographyMasterModel>> fetchAll() async {
    return List<FerrographyMasterModel>.unmodifiable(_items);
  }

  Future<FerrographyMasterModel> create({
    required String code,
    required String name,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code)) throw Exception('Code already exists');
    final now = DateTime.now();
    _seq += 1;
    final model = FerrographyMasterModel(
      id: 'ferro-new-$_seq',
      code: code.trim(),
      name: name.trim(),
      status: status,
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
    _items = [..._items, model];
    return model;
  }

  Future<FerrographyMasterModel> update({
    required String id,
    required String code,
    required String name,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code, excludeId: id)) throw Exception('Code already exists');
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('Record not found');
    final prev = _items[idx];
    final next = prev.copyWith(
      code: code.trim(),
      name: name.trim(),
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
