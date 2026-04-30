import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/customer_model.dart';
import '../../state/customer_provider.dart';

class CustomerHeader extends StatelessWidget {
  const CustomerHeader({
    super.key,
    required this.customer,
    required this.isEditing,
    required this.saving,
    required this.onStartEdit,
    required this.onCancelEdit,
    required this.onSaveEdit,
  });

  final CustomerModel customer;
  final bool isEditing;
  final bool saving;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;
  final Future<void> Function() onSaveEdit;

  Future<void> _confirmDeactivate(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Deactivate Customer',
      message:
          'Deactivate "${customer.companyName}"? They will be marked inactive.',
      confirmLabel: 'Deactivate',
      variant: AppConfirmDialogVariant.warning,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<CustomerProvider>().toggleStatus(customer.id);
  }

  Future<void> _confirmActivate(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Activate Customer',
      message: 'Activate "${customer.companyName}"?',
      confirmLabel: 'Activate',
      variant: AppConfirmDialogVariant.info,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<CustomerProvider>().toggleStatus(customer.id);
  }

  void _showMoreMenu(BuildContext context) {
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
    if (customer.status == 'active') {
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
              if (context.mounted) _confirmDeactivate(context);
            });
          },
        ),
      );
    } else if (customer.status == 'inactive') {
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
              if (context.mounted) _confirmActivate(context);
            });
          },
        ),
      );
    }

    if (items.isEmpty) return;

    showMenu<void>(
      context: context,
      position: position,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupLabel = customer.groupName?.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          name: customer.companyName,
          size: AppAvatarSize.lg,
        ),
        SizedBox(width: AppTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.companyName,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textXl,
                  fontWeight: AppTokens.weightBold,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space1),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusChip(status: customer.status),
                ],
              ),
              SizedBox(height: AppTokens.space2),
              Wrap(
                spacing: AppTokens.space4,
                runSpacing: AppTokens.space1,
                children: [
                  if (groupLabel != null && groupLabel.isNotEmpty)
                    _InfoItem(
                      icon: LucideIcons.building2,
                      label: groupLabel,
                    ),
                  if (customer.gstRegistered)
                    const _InfoItem(
                      icon: LucideIcons.shield,
                      label: 'GST: Registered',
                    ),
                  if (customer.city != null && customer.city!.trim().isNotEmpty)
                    _InfoItem(
                      icon: LucideIcons.mapPin,
                      label: customer.city!.trim(),
                    ),
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
                    label: 'Edit Customer',
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
                      onPressed: () => _showMoreMenu(buttonContext),
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
        Icon(
          icon,
          size: AppTokens.textSm,
          color: AppTokens.textMuted,
        ),
        SizedBox(width: AppTokens.space1),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.textSm,
            color: AppTokens.textMuted,
            fontWeight: AppTokens.weightRegular,
          ),
        ),
      ],
    );
  }
}
