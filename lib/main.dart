import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'design_system/app_theme.dart';
import 'design_system/scroll/lims_scroll_behavior.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(
    ChangeNotifierProvider<ThemeNotifier>.value(
      value: sl<ThemeNotifier>(),
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    print('AppRoot build');
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp.router(
      title: 'Ultra LIMS',
      scrollBehavior: const LimsScrollBehavior(),
      theme: AppTheme.light(primary: themeNotifier.config.brandColor),
      darkTheme: AppTheme.dark(primary: themeNotifier.config.brandColor),
      themeMode: themeNotifier.config.mode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
