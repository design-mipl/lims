import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../../design_system/app_theme.dart';
import '../../features/user_management/departments/data/departments_api.dart';
import '../../features/user_management/modules/data/modules_api.dart';
import '../../features/user_management/roles/data/roles_api.dart';
import '../../features/user_management/users/data/users_api.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // SharedPreferences — singleton
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ThemeNotifier — singleton, loaded from prefs
  final themeConfig = await ThemeConfig.load();
  final themeNotifier = ThemeNotifier(themeConfig);
  sl.registerSingleton<ThemeNotifier>(themeNotifier);

  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  sl.registerLazySingleton<DepartmentsApi>(() => DepartmentsApi());
  sl.registerLazySingleton<RolesApi>(() => RolesApi());
  sl.registerLazySingleton<ModulesApi>(() => ModulesApi());
  sl.registerLazySingleton<UsersApi>(() => UsersApi());
}
