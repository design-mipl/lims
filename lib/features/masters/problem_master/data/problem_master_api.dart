import '../models/problem_master_model.dart';
import '../../shared/master_status.dart';

class ProblemMasterApi {
  ProblemMasterApi() {
    final now = DateTime.now();
    _items = [
      ProblemMasterModel(
        id: 'prob-1',
        code: 'WEAR',
        name: 'Wear debris',
        status: MasterStatus.active,
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 35)),
        updatedBy: 'Lab Tech',
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      ProblemMasterModel(
        id: 'prob-2',
        code: 'OXID',
        name: 'Oxidation',
        status: MasterStatus.active,
        createdBy: 'QA Manager',
        createdAt: now.subtract(const Duration(days: 18)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  late List<ProblemMasterModel> _items;
  int _seq = 0;

  bool _codeTaken(String code, {String? excludeId}) {
    final c = code.trim().toLowerCase();
    return _items.any(
      (e) =>
          e.code.trim().toLowerCase() == c &&
          (excludeId == null || e.id != excludeId),
    );
  }

  Future<List<ProblemMasterModel>> fetchAll() async {
    return List<ProblemMasterModel>.unmodifiable(_items);
  }

  Future<ProblemMasterModel> create({
    required String code,
    required String name,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code)) throw Exception('Code already exists');
    final now = DateTime.now();
    _seq += 1;
    final model = ProblemMasterModel(
      id: 'prob-new-$_seq',
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

  Future<ProblemMasterModel> update({
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
