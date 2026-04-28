import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../../modules/data/module_model.dart';
import '../../modules/data/modules_api.dart';
import '../data/user_permission_model.dart';
import '../data/user_permissions_api.dart';

class UserPermissionsProvider extends BaseProvider {
  UserPermissionsProvider({
    UserPermissionsApi? permissionsApi,
    ModulesApi? modulesApi,
  })  : _api = permissionsApi ?? sl<UserPermissionsApi>(),
        _modulesApi = modulesApi ?? sl<ModulesApi>();

  final UserPermissionsApi _api;
  final ModulesApi _modulesApi;

  String? _userId;
  String? _userName;
  String? _userRole;

  List<ModuleModel> _allModules = [];
  Map<String, UserPermission> _permissions = {};

  List<ModuleModel> get parentModules => _allModules
      .where((m) => m.parentId == null || m.parentId!.isEmpty)
      .toList();

  List<ModuleModel> subModulesOf(String parentId) => _allModules
      .where((m) => m.parentId == parentId)
      .toList();

  UserPermission permissionFor(String moduleId, {String? subModuleId}) {
    final key = subModuleId ?? moduleId;
    return _permissions[key] ??
        UserPermission(
          moduleId: moduleId,
          subModuleId: subModuleId,
        );
  }

  Future<void> load({
    required String userId,
    required String userName,
    required String? userRole,
    required bool isAdmin,
  }) async {
    _userId = userId;
    _userName = userName;
    _userRole = userRole;

    await runAsync(() async {
      final allMods = await _modulesApi.fetchAll();
      _allModules = allMods
          .where((m) => m.status == ModuleStatus.active)
          .toList();

      final existing = await _api.fetchByUserId(userId);

      _permissions = {};

      if (existing.isEmpty && isAdmin) {
        _initAllTrue();
      } else {
        for (final p in existing) {
          final key = p.subModuleId ?? p.moduleId;
          _permissions[key] = p;
        }
      }
    });
  }

  void _initAllTrue() {
    for (final mod in _allModules) {
      final subs = subModulesOf(mod.id);
      if (subs.isEmpty) {
        _permissions[mod.id] = UserPermission(
          moduleId: mod.id,
          canView: true,
          canCreate: true,
          canEdit: true,
          canDelete: true,
        );
      } else {
        for (final sub in subs) {
          _permissions[sub.id] = UserPermission(
            moduleId: mod.id,
            subModuleId: sub.id,
            canView: true,
            canCreate: true,
            canEdit: true,
            canDelete: true,
          );
        }
      }
    }
  }

  void updatePermission(
    String moduleId,
    String? subModuleId,
    String field,
    bool value,
  ) {
    final key = subModuleId ?? moduleId;
    final current = _permissions[key] ??
        UserPermission(
          moduleId: moduleId,
          subModuleId: subModuleId,
        );

    switch (field) {
      case 'view':
        current.setView(value);
        break;
      case 'create':
        current.setCreate(value);
        break;
      case 'edit':
        current.setEdit(value);
        break;
      case 'delete':
        current.setDelete(value);
        break;
    }

    _permissions[key] = current;
    notifyListeners();
  }

  void selectAll(
    String moduleId,
    String? subModuleId,
    bool value,
  ) {
    final key = subModuleId ?? moduleId;
    final p = UserPermission(
      moduleId: moduleId,
      subModuleId: subModuleId,
      canView: value,
      canCreate: value,
      canEdit: value,
      canDelete: value,
    );
    _permissions[key] = p;
    notifyListeners();
  }

  Future<void> save() async {
    await runAsync(() async {
      final list = _permissions.values.toList();
      await _api.save(_userId!, list);
    });
  }

  String get userName => _userName ?? '';

  String get userRole => _userRole ?? '';
}
