import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/courier_model.dart';
import '../../state/courier_provider.dart';

/// Detail header — mirrors Site / Customer headers with courier-specific lines.
class CourierHeader extends StatelessWidget {
  const CourierHeader({
    super.key,
    required this.courier,
    required this.isEditing,
    required this.saving,
    required this.onStartEdit,
    required this.onCancelEdit,
    required this.onSaveEdit,
  });

  /// Null while creating a new courier at `/couriers/create`.
  final CourierModel? courier;
  final bool isEditing;
  final bool saving;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;
  final Future<void> Function() onSaveEdit;

  String get _avatarSeed =>
      courier == null
          ? 'New'
          : (courier!.companyName.trim().isNotEmpty
              ? courier!.companyName
              : courier!.personName);

  String get _title =>
      courier == null
          ? 'New Courier'
          : (courier!.companyName.trim().isNotEmpty
              ? courier!.companyName
              : courier!.personName);

  Future<void> _confirmDeactivate(BuildContext context, CourierModel c) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Deactivate Courier',
      message:
          'Deactivate "${c.companyName.isNotEmpty ? c.companyName : c.personName}"?',
      confirmLabel: 'Deactivate',
      variant: AppConfirmDialogVariant.warning,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<CourierProvider>().toggleStatus(c.id);
  }

  Future<void> _confirmActivate(BuildContext context, CourierModel c) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Activate Courier',
      message:
          'Activate "${c.companyName.isNotEmpty ? c.companyName : c.personName}"?',
      confirmLabel: 'Activate',
      variant: AppConfirmDialogVariant.info,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<CourierProvider>().toggleStatus(c.id);
  }

  void _showMoreMenu(BuildContext context, CourierModel c) {
    if (isEditing) return;
    final box = context.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final items = <PopupMenuEntry<void>>[];
    if (c.status == 'active') {
      items.add(
        PopupMenuItem<void>(
          child: Row(
            children: [
              Icon(
                LucideIcons.ban,
                size: AppTokens.iconButtonIconMd,
                color: AppTokens.warning500,
              ),
              SizedBox(width: AppTokens.space2),
              Text(
                'Deactivate',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.warning500,
                ),
              ),
            ],
          ),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) _confirmDeactivate(context, c);
            });
          },
        ),
      );
    } else if (c.status == 'inactive') {
      items.add(
        PopupMenuItem<void>(
          child: Row(
            children: [
              Icon(
                LucideIcons.check,
                size: AppTokens.iconButtonIconMd,
                color: AppTokens.success500,
              ),
              SizedBox(width: AppTokens.space2),
              Text(
                'Activate',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.success500,
                ),
              ),
            ],
          ),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) _confirmActivate(context, c);
            });
          },
        ),
      );
    }

    if (items.isEmpty) return;

    showMenu<void>(context: context, position: position, items: items);
  }

  @override
  Widget build(BuildContext context) {
    final c = courier;

    if (c == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(name: _avatarSeed, size: AppAvatarSize.lg),
              SizedBox(width: AppTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.textXl,
                        fontWeight: AppTokens.weightBold,
                        color: AppTokens.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: AppTokens.space1),
                    Text(
                      'Create courier details, communication, area mapping and contact mapping',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.pageSubtitleSize,
                        fontWeight: AppTokens.pageSubtitleWeight,
                        color: AppTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.tertiary,
                    onPressed: onCancelEdit,
                  ),
                  SizedBox(width: AppTokens.space2),
                  AppButton(
                    label: 'Save Courier',
                    variant: AppButtonVariant.primary,
                    isLoading: saving,
                    onPressed: saving ? null : () => onSaveEdit(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    final mobile =
        c.mobiles.isNotEmpty ? c.mobiles.first : '';
    final email = c.emails.isNotEmpty ? c.emails.first : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(name: _avatarSeed, size: AppAvatarSize.lg),
        SizedBox(width: AppTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textXl,
                  fontWeight: AppTokens.weightBold,
                  color: AppTokens.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: AppTokens.space1),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [StatusChip(status: c.status)],
              ),
              SizedBox(height: AppTokens.space2),
              Wrap(
                spacing: AppTokens.space4,
                runSpacing: AppTokens.space1,
                children: [
                  if (c.personName.trim().isNotEmpty)
                    _InfoChip(icon: LucideIcons.user, label: c.personName),
                  if (c.city.trim().isNotEmpty || c.state.trim().isNotEmpty)
                    _InfoChip(
                      icon: LucideIcons.mapPin,
                      label:
                          '${c.city}${c.city.isNotEmpty && c.state.isNotEmpty ? ', ' : ''}${c.state}',
                    ),
                  if (mobile.isNotEmpty)
                    _InfoChip(icon: LucideIcons.phone, label: mobile),
                  if (email.isNotEmpty)
                    _InfoChip(icon: LucideIcons.mail, label: email),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: isEditing
              ? [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.tertiary,
                    onPressed: onCancelEdit,
                  ),
                  SizedBox(width: AppTokens.space2),
                  AppButton(
                    label: 'Save Courier',
                    variant: AppButtonVariant.primary,
                    isLoading: saving,
                    onPressed: saving ? null : () => onSaveEdit(),
                  ),
                ]
              : [
                  AppButton(
                    label: 'Edit Courier',
                    variant: AppButtonVariant.primary,
                    icon: LucideIcons.pencil,
                    onPressed: onStartEdit,
                  ),
                  SizedBox(width: AppTokens.space2),
                  Builder(
                    builder: (buttonContext) => AppIconButton(
                      icon: Icon(LucideIcons.moreVertical),
                      variant: AppIconButtonVariant.outlined,
                      tooltip: 'More',
                      onPressed: () => _showMoreMenu(buttonContext, c),
                    ),
                  ),
                ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppTokens.textSm, color: AppTokens.textMuted),
        SizedBox(width: AppTokens.space1),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textSm,
              color: AppTokens.textMuted,
              fontWeight: AppTokens.weightRegular,
              decoration: TextDecoration.none,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
