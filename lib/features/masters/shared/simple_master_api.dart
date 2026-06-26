import 'master_status.dart';
import 'simple_master_model.dart';

class SimpleMasterApi {
  SimpleMasterApi({
    required String idPrefix,
    required List<SimpleMasterSeed> seeds,
  })  : _idPrefix = idPrefix,
        _items = _buildInitialItems(idPrefix: idPrefix, seeds: seeds);

  final String _idPrefix;
  List<SimpleMasterModel> _items;
  int _seq = 0;

  static List<SimpleMasterModel> _buildInitialItems({
    required String idPrefix,
    required List<SimpleMasterSeed> seeds,
  }) {
    final now = DateTime.now();
    return [
      for (var i = 0; i < seeds.length; i++)
        SimpleMasterModel(
          id: '$idPrefix-${i + 1}',
          code: seeds[i].code,
          name: seeds[i].name,
          status: seeds[i].status,
          createdBy: 'Admin User',
          createdAt: now.subtract(Duration(days: 40 - (i * 5))),
          updatedBy: 'Admin User',
          updatedAt: now.subtract(Duration(days: 10 - i)),
        ),
    ];
  }

  bool _codeTaken(String code, {String? excludeId}) {
    final c = code.trim().toLowerCase();
    return _items.any(
      (e) =>
          e.code.trim().toLowerCase() == c &&
          (excludeId == null || e.id != excludeId),
    );
  }

  Future<List<SimpleMasterModel>> fetchAll() async {
    return List<SimpleMasterModel>.unmodifiable(_items);
  }

  Future<SimpleMasterModel> create({
    required String code,
    required String name,
    required MasterStatus status,
  }) async {
    if (_codeTaken(code)) throw Exception('Code already exists');
    final now = DateTime.now();
    _seq += 1;
    final model = SimpleMasterModel(
      id: '$_idPrefix-new-$_seq',
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

  Future<SimpleMasterModel> update({
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
