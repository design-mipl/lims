import '../models/bank_master_model.dart';
import '../../shared/master_status.dart';

/// In-memory mock API for bank master.
class BankMasterApi {
  BankMasterApi() {
    final now = DateTime.now();
    _items = [
      BankMasterModel(
        id: 'bank-1',
        code: 'BOB',
        branch: 'Bank of Baroda',
        status: MasterStatus.active,
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedBy: 'Lab Tech',
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      BankMasterModel(
        id: 'bank-2',
        code: 'SBI',
        branch: 'State Bank of India',
        status: MasterStatus.active,
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedBy: 'QA Manager',
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
    ];
  }

  late List<BankMasterModel> _items;
  int _seq = 0;

  bool _codeTaken(String code, {String? excludeId}) {
    final c = code.trim().toLowerCase();
    return _items.any(
      (e) =>
          e.code.trim().toLowerCase() == c &&
          (excludeId == null || e.id != excludeId),
    );
  }

  Future<List<BankMasterModel>> fetchAll() async {
    return List<BankMasterModel>.unmodifiable(_items);
  }

  Future<BankMasterModel> create({
    required String code,
    required String branch,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code)) {
      throw Exception('Code already exists');
    }
    final now = DateTime.now();
    _seq += 1;
    final model = BankMasterModel(
      id: 'bank-new-$_seq',
      code: code.trim(),
      branch: branch.trim(),
      status: status,
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
    _items = [..._items, model];
    return model;
  }

  Future<BankMasterModel> update({
    required String id,
    required String code,
    required String branch,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code, excludeId: id)) {
      throw Exception('Code already exists');
    }
    final now = DateTime.now();
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('Record not found');
    final prev = _items[idx];
    final next = prev.copyWith(
      code: code.trim(),
      branch: branch.trim(),
      status: status,
      updatedBy: 'Admin User',
      updatedAt: now,
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
