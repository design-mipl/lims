import '../models/hsn_master_model.dart';
import '../../shared/master_status.dart';

class HsnMasterApi {
  HsnMasterApi() {
    final now = DateTime.now();
    _items = [
      HsnMasterModel(
        id: 'hsn-1',
        code: '27101980',
        name: 'Lubricating oils',
        description: 'Industrial oils',
        igst: 18,
        cgst: 9,
        sgst: 9,
        status: MasterStatus.active,
        createdBy: 'Admin User',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedBy: 'Lab Tech',
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      HsnMasterModel(
        id: 'hsn-2',
        code: '90271000',
        name: 'Gas analysis instruments',
        description: null,
        igst: 0,
        cgst: 0,
        sgst: 0,
        status: MasterStatus.active,
        createdBy: 'QA Manager',
        createdAt: now.subtract(const Duration(days: 50)),
        updatedBy: 'Admin User',
        updatedAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }

  late List<HsnMasterModel> _items;
  int _seq = 0;

  bool _codeTaken(String code, {String? excludeId}) {
    final c = code.trim().toLowerCase();
    return _items.any(
      (e) =>
          e.code.trim().toLowerCase() == c &&
          (excludeId == null || e.id != excludeId),
    );
  }

  String? _normalizeDescription(String? description) {
    if (description == null) return null;
    final t = description.trim();
    return t.isEmpty ? null : t;
  }

  Future<List<HsnMasterModel>> fetchAll() async {
    return List<HsnMasterModel>.unmodifiable(_items);
  }

  Future<HsnMasterModel> create({
    required String code,
    required String name,
    String? description,
    required double igst,
    required double cgst,
    required double sgst,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code)) throw Exception('Code already exists');
    final now = DateTime.now();
    _seq += 1;
    final model = HsnMasterModel(
      id: 'hsn-new-$_seq',
      code: code.trim(),
      name: name.trim(),
      description: _normalizeDescription(description),
      igst: igst,
      cgst: cgst,
      sgst: sgst,
      status: status,
      createdBy: 'Admin User',
      createdAt: now,
      updatedBy: 'Admin User',
      updatedAt: now,
    );
    _items = [..._items, model];
    return model;
  }

  Future<HsnMasterModel> update({
    required String id,
    required String code,
    required String name,
    String? description,
    required double igst,
    required double cgst,
    required double sgst,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code, excludeId: id)) throw Exception('Code already exists');
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('Record not found');
    final prev = _items[idx];
    final next = prev.copyWith(
      code: code.trim(),
      name: name.trim(),
      description: _normalizeDescription(description),
      igst: igst,
      cgst: cgst,
      sgst: sgst,
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
