import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';

/// Placeholder until the permissions matrix is implemented.
class UserPermissionsPlaceholderScreen extends StatelessWidget {
  const UserPermissionsPlaceholderScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.brightness == Brightness.dark
        ? AppTokens.neutral400
        : AppTokens.neutral600;

    void back() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/user-management/users/$userId');
      }
    }

    return AppFormPage(
      title: 'Permissions',
      subtitle: 'User $userId',
      onBack: back,
      actions: [
        AppButton(
          label: 'View user',
          onPressed: () => context.go('/user-management/users/$userId'),
          variant: AppButtonVariant.tertiary,
          size: AppButtonSize.sm,
        ),
      ],
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Permissions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTokens.weightSemibold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTokens.space3),
                Text(
                  'Permission matrix and module access will be configured here. '
                  'This screen is a placeholder for now.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
