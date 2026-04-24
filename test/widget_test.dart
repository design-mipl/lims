import 'package:flutter_test/flutter_test.dart';
import 'package:limsv1/core/di/service_locator.dart';
import 'package:limsv1/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:limsv1/design_system/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
  });

  testWidgets('App shows router placeholder', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeNotifier>.value(
        value: sl<ThemeNotifier>(),
        child: const AppRoot(),
      ),
    );
    await tester.pump();
    expect(find.text('Router placeholder'), findsOneWidget);
  });
}
