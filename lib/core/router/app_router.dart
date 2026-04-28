import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../di/service_locator.dart';
import '../../features/coming_soon/coming_soon_screen.dart';
import '../../features/masters/bank_master/state/bank_master_provider.dart';
import '../../features/masters/bank_master/ui/bank_master_screen.dart';
import '../../features/masters/ferrography_master/state/ferrography_master_provider.dart';
import '../../features/masters/ferrography_master/ui/ferrography_master_screen.dart';
import '../../features/masters/hsn_master/state/hsn_master_provider.dart';
import '../../features/masters/hsn_master/ui/hsn_master_screen.dart';
import '../../features/masters/item_master/state/item_master_provider.dart';
import '../../features/masters/item_master/ui/item_master_screen.dart';
import '../../features/masters/problem_master/state/problem_master_provider.dart';
import '../../features/masters/problem_master/ui/problem_master_screen.dart';
import '../../features/masters/sub_assembly_master/state/sub_assembly_master_provider.dart';
import '../../features/masters/sub_assembly_master/ui/sub_assembly_master_screen.dart';
import '../../features/masters/unit_master/state/unit_master_provider.dart';
import '../../features/masters/unit_master/ui/unit_master_screen.dart';
import '../../features/ui_kit/ui_kit_screen.dart';
import '../../features/dev/form_template_preview_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/user_management/departments/state/departments_provider.dart';
import '../../features/user_management/departments/ui/departments_screen.dart';
import '../../features/user_management/modules/state/modules_provider.dart';
import '../../features/user_management/modules/ui/modules_screen.dart';
import '../../features/user_management/roles/state/roles_provider.dart';
import '../../features/user_management/roles/ui/roles_screen.dart';
import '../../features/user_management/users/state/user_permissions_provider.dart';
import '../../features/user_management/users/state/users_provider.dart';
import '../../features/user_management/users/ui/user_form_page.dart';
import '../../features/user_management/users/ui/user_permissions_screen.dart';
import '../../features/user_management/users/ui/user_view_page.dart';
import '../../features/user_management/users/ui/users_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/dashboard',
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ShellScreen(
          state: state,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Dashboard',
            subtitle: 'Overview and analytics',
          ),
        ),
        GoRoute(
          path: '/dev/form-preview',
          builder: (context, _) => const FormTemplatePreviewScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Transactions',
          ),
        ),
        GoRoute(
          path: '/transactions/sample-receipt',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Sample Receipt',
          ),
        ),
        GoRoute(
          path: '/transactions/lab-code',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Lab Code',
          ),
        ),
        GoRoute(
          path: '/masters',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Masters',
          ),
        ),
        GoRoute(
          path: '/masters/customer',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Customer Master',
          ),
        ),
        GoRoute(
          path: '/masters/site',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Site Master',
          ),
        ),
        GoRoute(
          path: '/masters/courier',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Courier Master',
          ),
        ),
        GoRoute(
          path: '/masters/plant',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Plant Master',
          ),
        ),
        GoRoute(
          path: '/masters/bank',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => BankMasterProvider()..fetchAll(),
            child: const BankMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/item',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => ItemMasterProvider()..fetchAll(),
            child: const ItemMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/equipment',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Equipment Master',
          ),
        ),
        GoRoute(
          path: '/masters/sample-type',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Type of Sample Master',
          ),
        ),
        GoRoute(
          path: '/masters/grade',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Grade Master',
          ),
        ),
        GoRoute(
          path: '/masters/department',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Department Master',
          ),
        ),
        GoRoute(
          path: '/masters/designation',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Designation Master',
          ),
        ),
        GoRoute(
          path: '/masters/test',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Test Master',
          ),
        ),
        GoRoute(
          path: '/masters/method',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Method Master',
          ),
        ),
        GoRoute(
          path: '/masters/instrument',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Instrument Master',
          ),
        ),
        GoRoute(
          path: '/masters/parameter',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Parameter Master',
          ),
        ),
        GoRoute(
          path: '/masters/unit',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => UnitMasterProvider()..fetchAll(),
            child: const UnitMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/problem',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => ProblemMasterProvider()..fetchAll(),
            child: const ProblemMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/sub-assembly',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => SubAssemblyMasterProvider()..fetchAll(),
            child: const SubAssemblyMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/ferrography',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => FerrographyMasterProvider()..fetchAll(),
            child: const FerrographyMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/hsn',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => HsnMasterProvider()..fetchAll(),
            child: const HsnMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/storage',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Storage Master',
          ),
        ),
        GoRoute(
          path: '/housekeeping',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Housekeeping',
          ),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Reports',
          ),
        ),
        GoRoute(
          path: '/ui-kit',
          builder: (context, _) => const UIKitScreen(),
        ),
        GoRoute(
          path: '/users',
          redirect: (context, state) => '/user-management/departments',
        ),
        GoRoute(
          path: '/user-management',
          redirect: (context, state) {
            if (state.uri.path == '/user-management') {
              return '/user-management/departments';
            }
            return null;
          },
          routes: [
            GoRoute(
              path: 'departments',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => DepartmentsProvider()..fetchAll(),
                child: const DepartmentsScreen(),
              ),
            ),
            GoRoute(
              path: 'users/create',
              builder: (context, state) => MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => UsersProvider()..fetchAll(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => DepartmentsProvider()..fetchAll(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => RolesProvider()..fetchAll(),
                  ),
                ],
                child: const UserFormPage(),
              ),
            ),
            GoRoute(
              path: 'users/:id/edit',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (_) => UsersProvider()..fetchAll(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => DepartmentsProvider()..fetchAll(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => RolesProvider()..fetchAll(),
                    ),
                  ],
                  child: UserFormPage(userId: id),
                );
              },
            ),
            GoRoute(
              path: 'users/:id/permissions',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final extra = state.extra as Map<String, dynamic>?;
                final name = extra?['name'] as String? ?? '';
                final role = extra?['role'] as String?;
                final isAdmin = extra?['isAdmin'] as bool? ?? false;
                return ChangeNotifierProvider(
                  create: (_) => sl<UserPermissionsProvider>()
                    ..load(
                      userId: id,
                      userName: name,
                      userRole: role,
                      isAdmin: isAdmin,
                    ),
                  child: UserPermissionsScreen(
                    userId: id,
                    userName: name,
                    userRole: role,
                    isAdmin: isAdmin,
                  ),
                );
              },
            ),
            GoRoute(
              path: 'users/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ChangeNotifierProvider(
                  create: (_) => UsersProvider()..fetchAll(),
                  child: UserViewPage(userId: id),
                );
              },
            ),
            GoRoute(
              path: 'users',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => UsersProvider()..fetchAll(),
                child: const UsersScreen(),
              ),
            ),
            GoRoute(
              path: 'roles',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => RolesProvider()..fetchAll(),
                child: const RolesScreen(),
              ),
            ),
            GoRoute(
              path: 'modules',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => ModulesProvider()..fetchAll(),
                child: const ModulesScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
