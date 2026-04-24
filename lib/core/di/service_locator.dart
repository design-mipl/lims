import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../design_system/app_theme.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // SharedPreferences — singleton
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ThemeNotifier — singleton, loaded from prefs
  final themeConfig = await ThemeConfig.load();
  final themeNotifier = ThemeNotifier(themeConfig);
  sl.registerSingleton<ThemeNotifier>(themeNotifier);
}
