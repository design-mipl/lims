import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../../design_system/app_theme.dart';
import '../../features/masters/bank_master/data/bank_master_api.dart';
import '../../features/masters/ferrography_master/data/ferrography_master_api.dart';
import '../../features/masters/hsn_master/data/hsn_master_api.dart';
import '../../features/masters/item_master/data/item_master_api.dart';
import '../../features/masters/problem_master/data/problem_master_api.dart';
import '../../features/masters/sub_assembly_master/data/sub_assembly_master_api.dart';
import '../../features/masters/unit_master/data/unit_master_api.dart';
import '../../features/user_management/departments/data/departments_api.dart';
import '../../features/user_management/modules/data/modules_api.dart';
import '../../features/user_management/roles/data/roles_api.dart';
import '../../features/user_management/users/data/user_permissions_api.dart';
import '../../features/user_management/users/data/users_api.dart';
import '../../features/user_management/users/state/user_permissions_provider.dart';

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

  sl.registerLazySingleton<BankMasterApi>(() => BankMasterApi());
  sl.registerLazySingleton<ItemMasterApi>(() => ItemMasterApi());
  sl.registerLazySingleton<UnitMasterApi>(() => UnitMasterApi());
  sl.registerLazySingleton<ProblemMasterApi>(() => ProblemMasterApi());
  sl.registerLazySingleton<SubAssemblyMasterApi>(() => SubAssemblyMasterApi());
  sl.registerLazySingleton<FerrographyMasterApi>(() => FerrographyMasterApi());
  sl.registerLazySingleton<HsnMasterApi>(() => HsnMasterApi());

  sl.registerLazySingleton<DepartmentsApi>(() => DepartmentsApi());
  sl.registerLazySingleton<RolesApi>(() => RolesApi());
  sl.registerLazySingleton<ModulesApi>(() => ModulesApi());
  sl.registerLazySingleton<UsersApi>(() => UsersApi());
  sl.registerLazySingleton<UserPermissionsApi>(() => UserPermissionsApi());
  sl.registerFactory<UserPermissionsProvider>(() => UserPermissionsProvider());
}
