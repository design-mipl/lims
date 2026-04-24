import 'package:go_router/go_router.dart';

import '../../features/coming_soon/coming_soon_screen.dart';
import '../../features/shell/shell_screen.dart';

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
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Bank Master',
          ),
        ),
        GoRoute(
          path: '/masters/item',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Item Master',
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
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Unit Master',
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
          path: '/users',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'User Management',
            subtitle: 'Manage users, roles and permissions',
          ),
        ),
      ],
    ),
  ],
);
