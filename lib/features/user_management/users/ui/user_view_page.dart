import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/user_model.dart';
import '../state/users_provider.dart';

String _formatLastLogin(DateTime? d) {
  if (d == null) {
    return '—';
  }
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  final h = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$y-$m-$day $h:$min';
}

/// Read-only user profile.
class UserViewPage extends StatelessWidget {
  const UserViewPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final users = context.watch<UsersProvider>();
    final muted = theme.brightness == Brightness.dark
        ? AppTokens.neutral400
        : AppTokens.neutral600;

    void back() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/user-management/users');
      }
    }

    if (!users.isLoading && users.userById(userId) == null) {
      return AppFormPage(
        title: 'User',
        subtitle: 'Profile',
        onBack: back,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(AppTokens.space6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'User not found.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTokens.space4),
                AppButton(
                  label: 'Back to list',
                  onPressed: () => context.go('/user-management/users'),
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.md,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final UserModel? u = users.userById(userId);

    Widget pair(String label, String value) {
      return Padding(
        padding: EdgeInsets.only(bottom: AppTokens.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                fontSize: AppTokens.textXs,
              ),
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: AppTokens.textSm,
              ),
            ),
          ],
        ),
      );
    }

    return AppFormPage(
      title: 'User',
      subtitle: 'Profile and assignment',
      onBack: back,
      actions: u == null
          ? null
          : [
              AppButton(
                label: 'Edit',
                onPressed: () =>
                    context.push('/user-management/users/$userId/edit'),
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.sm,
              ),
              AppButton(
                label: 'Manage Permissions',
                onPressed: () =>
                    context.go('/user-management/users/$userId/permissions'),
                variant: AppButtonVariant.primary,
                size: AppButtonSize.sm,
              ),
            ],
      body: users.isLoading || u == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormSection(
                  title: 'Profile Summary',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAvatar(name: u.name, size: AppAvatarSize.lg),
                      SizedBox(width: AppTokens.space4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: AppTokens.weightSemibold,
                              ),
                            ),
                            SizedBox(height: AppTokens.space1),
                            Text(
                              u.roleName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                            ),
                            SizedBox(height: AppTokens.space2),
                            StatusChip(status: u.status.name),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTokens.space3),
                AppFormSection(
                  title: 'Basic Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      pair('Email', u.email),
                      if (u.phone != null && u.phone!.isNotEmpty)
                        pair('Phone', u.phone!)
                      else
                        pair('Phone', '—'),
                      pair('Username', u.username),
                      if (u.employeeId != null && u.employeeId!.isNotEmpty)
                        pair('Employee ID', u.employeeId!),
                    ],
                  ),
                ),
                SizedBox(height: AppTokens.space3),
                AppFormSection(
                  title: 'Department & Role',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      pair('Department', u.departmentName),
                      pair('Role', u.roleName),
                    ],
                  ),
                ),
                SizedBox(height: AppTokens.space3),
                AppFormSection(
                  title: 'Last Login',
                  child: Text(
                    _formatLastLogin(u.lastLogin),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: AppTokens.textSm,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
