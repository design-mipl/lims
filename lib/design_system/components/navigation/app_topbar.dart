import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';
import '../display/app_avatar.dart';
import '../primitives/app_icon_button.dart';
import 'nav_item.dart';

/// App header: optional menu, search, notifications, and user menu.
class AppTopbar extends StatelessWidget {
  const AppTopbar({
    super.key,
    required this.searchWidth,
    this.showMenuButton = false,
    this.onMenuPressed,
    this.onSearchTap,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.currentUser,
    this.onProfileTap,
    this.onSettingsTap,
    this.onSignOutTap,
    this.showUserText = false,
  });

  final double searchWidth;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchTap;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final UserInfo? currentUser;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onSignOutTap;
  final bool showUserText;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showHint = AppBreakpoints.isDesktopWidth(width);
    final showHamburger =
        showMenuButton && AppBreakpoints.isMobileWidth(width);

    return Material(
      color: AppTokens.white,
      elevation: 0,
      child: Container(
        height: AppTokens.topbarHeight,
        decoration: const BoxDecoration(
          color: AppTokens.white,
          border: Border(
            bottom: BorderSide(
              color: AppTokens.border,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
          child: Row(
            children: [
              if (showHamburger) ...[
                AppIconButton(
                  icon: const Icon(LucideIcons.menu),
                  onPressed: onMenuPressed,
                  size: AppIconButtonSize.md,
                  variant: AppIconButtonVariant.ghost,
                ),
                SizedBox(width: AppTokens.space2),
              ],
              _SearchPill(
                width: searchWidth,
                onSearchTap: onSearchTap,
                showKeyboardHint: showHint,
              ),
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppIconButton(
                    icon: const Icon(LucideIcons.bell),
                    onPressed: onNotificationTap,
                    size: AppIconButtonSize.md,
                    variant: AppIconButtonVariant.ghost,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: AppTokens.space0,
                      top: AppTokens.space0,
                      child: Container(
                        width: AppTokens.space2,
                        height: AppTokens.space2,
                        decoration: const BoxDecoration(
                          color: AppTokens.accent500,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppTokens.space2),
              const SizedBox(
                height: 20,
                child: VerticalDivider(
                  color: AppTokens.neutral200,
                  width: 20,
                  thickness: AppTokens.borderWidthSm,
                ),
              ),
              SizedBox(width: AppTokens.space2),
              if (currentUser != null)
                _UserMenu(
                  currentUser!,
                  showText: showUserText,
                  onProfileTap: onProfileTap,
                  onSettingsTap: onSettingsTap,
                  onSignOutTap: onSignOutTap,
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({
    required this.width,
    this.onSearchTap,
    this.showKeyboardHint = false,
  });

  final double width;
  final VoidCallback? onSearchTap;
  final bool showKeyboardHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compactW = AppTokens.buttonHeightMd + AppTokens.space1;
    return Material(
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onSearchTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        child: Container(
          width: width,
          height: AppTokens.buttonHeightMd,
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTokens.neutral200,
              width: AppTokens.borderWidthSm,
            ),
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.search,
                size: AppTokens.iconButtonIconSm,
                color: AppTokens.neutral400,
              ),
              if (width > compactW) ...[
                SizedBox(width: AppTokens.space1),
                Expanded(
                  child: Text(
                    'Search…',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: AppTokens.textSm,
                          color: AppTokens.neutral400,
                        ) ??
                        const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTokens.textSm,
                          color: AppTokens.neutral400,
                        ),
                  ),
                ),
                if (showKeyboardHint) ...[
                  Text(
                    '⌘K',
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTokens.neutral300,
                        ) ??
                        const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTokens.textXs,
                          color: AppTokens.neutral300,
                        ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu(
    this.user, {
    required this.showText,
    this.onProfileTap,
    this.onSettingsTap,
    this.onSignOutTap,
  });

  final UserInfo user;
  final bool showText;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onSignOutTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      offset: const Offset(0, AppTokens.buttonHeightLg),
      onSelected: (v) {
        if (v == 'profile') {
          onProfileTap?.call();
        } else if (v == 'settings') {
          onSettingsTap?.call();
        } else if (v == 'signout') {
          onSignOutTap?.call();
        }
      },
      itemBuilder: (c) {
        return [
          PopupMenuItem(
            value: 'profile',
            child: Text(
              'Profile',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          PopupMenuItem(
            value: 'settings',
            child: Text(
              'Settings',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'signout',
            child: Text(
              'Sign out',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTokens.error500,
              ),
            ),
          ),
        ];
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAvatar(
            name: user.name,
            size: AppAvatarSize.sm,
            imageUrl: user.avatarUrl,
            customInitials: user.initials,
          ),
          if (showText) ...[
            SizedBox(width: AppTokens.space2),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: AppTokens.textSm,
                    color: AppTokens.neutral800,
                    fontWeight: AppTokens.weightMedium,
                  ),
                ),
                Text(
                  user.id,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTokens.neutral500,
                  ),
                ),
              ],
            ),
            const Icon(
              LucideIcons.chevronDown,
              size: AppTokens.iconButtonIconSm,
              color: AppTokens.neutral600,
            ),
          ],
        ],
      ),
    );
  }
}
