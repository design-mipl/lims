import 'user_permission_model.dart';

/// Mock permissions API. Real backend: GET/PUT `/users/:id/permissions` via [ApiClient].
class UserPermissionsApi {
  Future<List<UserPermission>> fetchByUserId(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [];
  }

  Future<void> save(String userId, List<UserPermission> permissions) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
