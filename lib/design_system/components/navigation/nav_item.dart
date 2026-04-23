import 'package:flutter/widgets.dart';

/// Side navigation item. Pass a [Widget] for [icon], typically
/// `Icon(LucideIcons.*, size: 16, color: …)` from `lucide_flutter`.
@immutable
class NavItem {
  const NavItem({
    required this.path,
    required this.label,
    required this.icon,
    this.sectionLabel,
    this.children,
  });

  final String path;
  final String label;
  final Widget icon;
  final String? sectionLabel;
  final List<NavItem>? children;

  /// Whether this row can expand to show [children].
  bool get isExpandable => children != null && children!.isNotEmpty;
}

@immutable
class UserInfo {
  const UserInfo({
    required this.name,
    required this.id,
    this.avatarUrl,
    this.initials,
  });

  final String name;
  final String id;
  final String? avatarUrl;
  final String? initials;
}
