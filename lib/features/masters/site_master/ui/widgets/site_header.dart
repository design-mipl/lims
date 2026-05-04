import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/site_model.dart';
import '../../state/site_provider.dart';

class SiteHeader extends StatelessWidget {
  const SiteHeader({
    super.key,
    required this.site,
    required this.isEditing,
    required this.saving,
    required this.onStartEdit,
    required this.onCancelEdit,
    required this.onSaveEdit,
  });

  final SiteModel? site;
  final bool isEditing;
  final bool saving;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;
  final Future<void> Function() onSaveEdit;

  Future<void> _confirmDeactivate(BuildContext context, SiteModel s) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Deactivate Site',
      message:
          'Deactivate "${s.displayName ?? s.code}"? It will be marked inactive.',
      confirmLabel: 'Deactivate',
      variant: AppConfirmDialogVariant.warning,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SiteProvider>().toggleStatus(s.id);
  }

  Future<void> _confirmActivate(BuildContext context, SiteModel s) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Activate Site',
      message: 'Activate "${s.displayName ?? s.code}"?',
      confirmLabel: 'Activate',
      variant: AppConfirmDialogVariant.info,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SiteProvider>().toggleStatus(s.id);
  }

  void _showMoreMenu(BuildContext context, SiteModel s) {
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
    if (s.status == 'active') {
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
              if (context.mounted) _confirmDeactivate(context, s);
            });
          },
        ),
      );
    } else if (s.status == 'inactive') {
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
              if (context.mounted) _confirmActivate(context, s);
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
    if (site == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'New Site',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.pageTitleSize,
                fontWeight: AppTokens.weightBold,
                color: AppTokens.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.tertiary,
            onPressed: onCancelEdit,
          ),
          SizedBox(width: AppTokens.space2),
          AppButton(
            label: 'Save',
            variant: AppButtonVariant.primary,
            isLoading: saving,
            onPressed: saving ? null : () => onSaveEdit(),
          ),
        ],
      );
    }

    final s = site!;
    final titleText = (s.displayName ?? s.code).trim().isEmpty
        ? s.code
        : (s.displayName ?? s.code).trim();
    final companyLine = (s.companyLabel ?? s.companyName)?.trim() ?? '';
    final cityLine = s.city?.trim() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(name: s.displayName ?? s.code, size: AppAvatarSize.lg),
        SizedBox(width: AppTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
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
                children: [StatusChip(status: s.status)],
              ),
              SizedBox(height: AppTokens.space2),
              Wrap(
                spacing: AppTokens.space4,
                runSpacing: AppTokens.space1,
                children: [
                  if (companyLine.isNotEmpty)
                    _InfoItem(icon: LucideIcons.building2, label: companyLine),
                  if (cityLine.isNotEmpty)
                    _InfoItem(icon: LucideIcons.mapPin, label: cityLine),
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
                    label: 'Save',
                    variant: AppButtonVariant.primary,
                    isLoading: saving,
                    onPressed: saving ? null : () => onSaveEdit(),
                  ),
                ]
              : [
                  AppButton(
                    label: 'Edit Site',
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
                      onPressed: () => _showMoreMenu(buttonContext, s),
                    ),
                  ),
                ],
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppTokens.textSm, color: AppTokens.textMuted),
        SizedBox(width: AppTokens.space1),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textSm,
            color: AppTokens.textMuted,
            fontWeight: AppTokens.weightRegular,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
