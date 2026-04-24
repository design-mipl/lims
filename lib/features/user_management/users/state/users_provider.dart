import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../data/user_model.dart';
import '../data/users_api.dart';

class UsersProvider extends BaseProvider {
  UsersProvider({UsersApi? api}) : _api = api ?? sl<UsersApi>();

  final UsersApi _api;

  List<UserModel> _items = [];
  String _searchQuery = '';
  UserStatus? _selectedStatusFilter;
  int _currentPage = 1;
  int _pageSize = 10;

  List<UserModel> get items => List<UserModel>.unmodifiable(_items);

  String get searchQuery => _searchQuery;

  UserStatus? get selectedStatusFilter => _selectedStatusFilter;

  int get currentPage => _currentPage;

  int get effectiveCurrentPage {
    final n = filteredItems.length;
    if (n == 0) {
      return 1;
    }
    final lastPage = ((n - 1) ~/ _pageSize) + 1;
    return _currentPage.clamp(1, lastPage);
  }

  int get pageSize => _pageSize;

  int get statusTabIndex {
    if (_selectedStatusFilter == null) {
      return 0;
    }
    if (_selectedStatusFilter == UserStatus.active) {
      return 1;
    }
    return 2;
  }

  int get totalCount => _items.length;

  int get activeCount =>
      _items.where((e) => e.status == UserStatus.active).length;

  int get inactiveCount =>
      _items.where((e) => e.status == UserStatus.inactive).length;

  int get tabAllCount => _items.length;

  UserModel? userById(String id) {
    for (final u in _items) {
      if (u.id == id) {
        return u;
      }
    }
    return null;
  }

  List<UserModel> get filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    Iterable<UserModel> list = _items;
    if (_selectedStatusFilter != null) {
      list = list.where((e) => e.status == _selectedStatusFilter);
    }
    if (q.isEmpty) {
      return list.toList();
    }
    return list.where((e) {
      final name = e.name.toLowerCase();
      final email = e.email.toLowerCase();
      final phone = (e.phone ?? '').toLowerCase();
      final username = e.username.toLowerCase();
      final emp = (e.employeeId ?? '').toLowerCase();
      final dept = e.departmentName.toLowerCase();
      final role = e.roleName.toLowerCase();
      return name.contains(q) ||
          email.contains(q) ||
          phone.contains(q) ||
          username.contains(q) ||
          emp.contains(q) ||
          dept.contains(q) ||
          role.contains(q);
    }).toList();
  }

  List<UserModel> get pagedRows {
    final all = filteredItems;
    if (all.isEmpty) {
      return [];
    }
    final lastPage = ((all.length - 1) ~/ _pageSize) + 1;
    var page = _currentPage;
    if (page > lastPage) {
      page = lastPage;
    }
    if (page < 1) {
      page = 1;
    }
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  void _clampCurrentPage() {
    final n = filteredItems.length;
    if (n == 0) {
      _currentPage = 1;
      return;
    }
    final lastPage = ((n - 1) ~/ _pageSize) + 1;
    if (_currentPage > lastPage) {
      _currentPage = lastPage;
    }
    if (_currentPage < 1) {
      _currentPage = 1;
    }
  }

  Future<void> fetchAll() async {
    await runAsync(() async {
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  void setStatusFilter(UserStatus? status) {
    _selectedStatusFilter = status;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setPageSize(int size) {
    _pageSize = size;
    _currentPage = 1;
    notifyListeners();
  }

  Future<String?> createUser({
    required String name,
    required String email,
    String? phone,
    required String username,
    String? employeeId,
    required String departmentId,
    required String departmentName,
    required String roleId,
    required String roleName,
    required UserStatus status,
  }) async {
    String? newId;
    await runAsync(() async {
      final created = await _api.create(
        name: name,
        email: email,
        phone: phone,
        username: username,
        employeeId: employeeId,
        departmentId: departmentId,
        departmentName: departmentName,
        roleId: roleId,
        roleName: roleName,
        status: status,
      );
      newId = created.id;
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
    return newId;
  }

  Future<void> updateUser({
    required String id,
    required String name,
    required String email,
    String? phone,
    required String username,
    String? employeeId,
    required String departmentId,
    required String departmentName,
    required String roleId,
    required String roleName,
    required UserStatus status,
  }) async {
    await runAsync(() async {
      await _api.update(
        id: id,
        name: name,
        email: email,
        phone: phone,
        username: username,
        employeeId: employeeId,
        departmentId: departmentId,
        departmentName: departmentName,
        roleId: roleId,
        roleName: roleName,
        status: status,
      );
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> toggleUserStatus(String id) async {
    await runAsync(() async {
      await _api.toggleStatus(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }

  Future<void> deleteUser(String id) async {
    await runAsync(() async {
      await _api.delete(id);
      _items = await _api.fetchAll();
      _clampCurrentPage();
    });
  }
}
