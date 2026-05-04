import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../di/service_locator.dart';
import '../../features/coming_soon/coming_soon_screen.dart';
import '../../features/masters/bank_master/state/bank_master_provider.dart';
import '../../features/masters/bank_master/ui/bank_master_screen.dart';
import '../../features/masters/courier_master/state/courier_provider.dart';
import '../../features/masters/courier_master/ui/courier_detail_screen.dart';
import '../../features/masters/courier_master/ui/courier_screen.dart';
import '../../features/masters/customer_master/state/customer_provider.dart';
import '../../features/masters/customer_master/ui/customer_detail_screen.dart';
import '../../features/masters/customer_master/ui/customer_form_page.dart';
import '../../features/masters/customer_master/ui/customer_screen.dart';
import '../../features/masters/site_master/state/site_provider.dart';
import '../../features/masters/site_master/ui/site_detail_screen.dart';
import '../../features/masters/site_master/ui/site_screen.dart';
import '../../features/masters/ferrography_master/state/ferrography_master_provider.dart';
import '../../features/masters/ferrography_master/ui/ferrography_master_screen.dart';
import '../../features/masters/hsn_master/state/hsn_master_provider.dart';
import '../../features/masters/hsn_master/ui/hsn_master_screen.dart';
import '../../features/masters/item_master/state/item_master_provider.dart';
import '../../features/masters/item_master/ui/item_master_screen.dart';
import '../../features/masters/plant_master/state/plant_provider.dart';
import '../../features/masters/plant_master/ui/plant_screen.dart';
import '../../features/masters/problem_master/state/problem_master_provider.dart';
import '../../features/masters/problem_master/ui/problem_master_screen.dart';
import '../../features/masters/sub_assembly_master/state/sub_assembly_master_provider.dart';
import '../../features/masters/sub_assembly_master/ui/sub_assembly_master_screen.dart';
import '../../features/masters/unit_master/state/unit_master_provider.dart';
import '../../features/masters/unit_master/ui/unit_master_screen.dart';
import '../../features/ui_kit/ui_kit_screen.dart';
import '../../features/dev/form_template_preview_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/transactions/sample_intake/state/sample_intake_provider.dart';
import '../../features/transactions/sample_intake/ui/create_sample_receipt_page.dart';
import '../../features/transactions/sample_intake/ui/sample_intake_detail_page.dart';
import '../../features/transactions/sample_intake/ui/sample_intake_screen.dart';
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
    GoRoute(path: '/', redirect: (context, state) => '/dashboard'),
    ShellRoute(
      builder: (context, state, child) {
        return ShellScreen(state: state, child: child);
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
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Transactions'),
        ),
        GoRoute(
          path: '/transactions/sample-receipt',
          redirect: (context, state) => '/transactions/sample-intake',
        ),
        GoRoute(
          path: '/transactions/sample-intake/create',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<SampleIntakeProvider>(),
            child: const CreateSampleReceiptPage(),
          ),
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id/enter-data',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ComingSoonScreen(
              moduleName: 'Enter Sample Data',
              subtitle: 'Receipt $id — under construction.',
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ComingSoonScreen(
              moduleName: 'Edit Receipt',
              subtitle: 'Receipt $id — under construction.',
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<SampleIntakeProvider>(),
              child: SampleIntakeDetailPage(receiptId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<SampleIntakeProvider>(),
            child: const SampleIntakeScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/lab-code',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Lab Code',
            subtitle: 'Lab ID generation and tracking.',
          ),
        ),
        GoRoute(
          path: '/transactions/lab-assignment',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Lab Manager Assignment',
            subtitle: 'Assign tests and samples to lab users.',
          ),
        ),
        GoRoute(
          path: '/transactions/verification',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Verification',
            subtitle:
                'Lab manager verification and lab chemist verification.',
          ),
        ),
        GoRoute(
          path: '/transactions/report-review',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Report Review & Authorization',
            subtitle:
                'Supervisor comments, severity, NABL, and final authorization.',
          ),
        ),
        GoRoute(
          path: '/transactions/action-taken',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Action Taken',
            subtitle: 'Post-report actions and customer follow-ups.',
          ),
        ),
        GoRoute(
          path: '/masters',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Masters'),
        ),
        GoRoute(
          path: '/masters/customer',
          redirect: (context, state) => '/customers',
        ),
        GoRoute(
          path: '/customers',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => CustomerProvider()..fetchAll(),
            child: const CustomerScreen(),
          ),
        ),
        GoRoute(
          path: '/customers/create',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => CustomerProvider()..fetchAll(),
            child: const CustomerFormPage(),
          ),
        ),
        GoRoute(
          path: '/customers/:id',
          builder: (context, state) {
            final extra = state.extra as Map?;
            return ChangeNotifierProvider(
              create: (_) => CustomerProvider()..fetchAll(),
              child: CustomerDetailScreen(
                customerId: state.pathParameters['id']!,
                initialTab: extra?['tab']?.toString() ?? 'overview',
                startInlineEdit: extra?['edit'] == true,
              ),
            );
          },
        ),
        GoRoute(path: '/masters/site', redirect: (context, state) => '/sites'),
        GoRoute(
          path: '/sites',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => SiteProvider()..fetchAll(),
            child: const SiteScreen(),
          ),
        ),
        GoRoute(
          path: '/sites/create',
          builder: (context, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => SiteProvider()..fetchAll()),
              ChangeNotifierProvider(
                create: (_) => CustomerProvider()..fetchAll(),
              ),
            ],
            child: const SiteDetailScreen(startEdit: true),
          ),
        ),
        GoRoute(
          path: '/sites/:id',
          builder: (context, state) {
            final extra = state.extra as Map?;
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => SiteProvider()..fetchAll(),
                ),
                ChangeNotifierProvider(
                  create: (_) => CustomerProvider()..fetchAll(),
                ),
              ],
              child: SiteDetailScreen(
                siteId: state.pathParameters['id']!,
                startEdit: extra?['startEdit'] == true,
              ),
            );
          },
        ),
        GoRoute(
          path: '/masters/courier',
          redirect: (context, state) => '/couriers',
        ),
        GoRoute(
          path: '/couriers',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => CourierProvider()..fetchAll(),
            child: const CourierScreen(),
          ),
        ),
        GoRoute(
          path: '/couriers/create',
          builder: (context, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => CourierProvider()..fetchAll(),
              ),
              ChangeNotifierProvider(
                create: (_) => SiteProvider()..fetchAll(),
              ),
            ],
            child: const CourierDetailScreen(
              courierId: null,
              startEdit: true,
            ),
          ),
        ),
        GoRoute(
          path: '/couriers/:id',
          builder: (context, state) {
            final extra = state.extra as Map?;
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => CourierProvider()..fetchAll(),
                ),
                ChangeNotifierProvider(
                  create: (_) => SiteProvider()..fetchAll(),
                ),
              ],
              child: CourierDetailScreen(
                courierId: state.pathParameters['id']!,
                startEdit: extra?['startEdit'] == true,
              ),
            );
          },
        ),
        GoRoute(
          path: '/masters/plant',
          redirect: (context, state) => '/plants',
        ),
        GoRoute(
          path: '/plants',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => PlantProvider()..fetchAll(),
            child: const PlantScreen(),
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
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Equipment Master'),
        ),
        GoRoute(
          path: '/masters/sample-type',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Type of Sample Master'),
        ),
        GoRoute(
          path: '/masters/grade',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Grade Master'),
        ),
        GoRoute(
          path: '/masters/department',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Department Master'),
        ),
        GoRoute(
          path: '/masters/designation',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Designation Master'),
        ),
        GoRoute(
          path: '/masters/test',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Test Master'),
        ),
        GoRoute(
          path: '/masters/method',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Method Master'),
        ),
        GoRoute(
          path: '/masters/instrument',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Instrument Master'),
        ),
        GoRoute(
          path: '/masters/parameter',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Parameter Master'),
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
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Storage Master'),
        ),
        GoRoute(
          path: '/housekeeping',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Housekeeping'),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Reports'),
        ),
        GoRoute(path: '/ui-kit', builder: (context, _) => const UIKitScreen()),
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
