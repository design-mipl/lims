import '../models/sub_assembly_master_model.dart';
import '../../shared/master_status.dart';

class SubAssemblyMasterApi {
  SubAssemblyMasterApi() {
    final now = DateTime.now();
    _items = [
      SubAssemblyMasterModel(
        id: 'sub-1',
        code: 'PUMP',
        name: 'Hydraulic pump',
        status: MasterStatus.active,
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedBy: 'Lab Tech',
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      SubAssemblyMasterModel(
        id: 'sub-2',
        code: 'GEAR',
        name: 'Gearbox assembly',
        status: MasterStatus.active,
        createdBy: 'QA Manager',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  late List<SubAssemblyMasterModel> _items;
  int _seq = 0;

  bool _codeTaken(String code, {String? excludeId}) {
    final c = code.trim().toLowerCase();
    return _items.any(
      (e) =>
          e.code.trim().toLowerCase() == c &&
          (excludeId == null || e.id != excludeId),
    );
  }

  Future<List<SubAssemblyMasterModel>> fetchAll() async {
    return List<SubAssemblyMasterModel>.unmodifiable(_items);
  }

  Future<SubAssemblyMasterModel> create({
    required String code,
    required String name,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code)) throw Exception('Code already exists');
    final now = DateTime.now();
    _seq += 1;
    final model = SubAssemblyMasterModel(
      id: 'sub-new-$_seq',
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

  Future<SubAssemblyMasterModel> update({
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
