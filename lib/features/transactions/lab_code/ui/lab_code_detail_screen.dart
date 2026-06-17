import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/form_read_only_field.dart';
import '../data/lab_code_model.dart';
import '../state/lab_code_provider.dart';

/// Read-only Lab Code detail (View from listing).
class LabCodeDetailScreen extends StatefulWidget {
  const LabCodeDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<LabCodeDetailScreen> createState() => _LabCodeDetailScreenState();
}

class _LabCodeDetailScreenState extends State<LabCodeDetailScreen> {
  LabCodeProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<LabCodeProvider>();
      _provider!.addListener(_onProviderChanged);
      await _provider!.loadItemForView(widget.itemId);
    });
  }

  void _onProviderChanged() {
    final pr = _provider;
    if (pr == null || !pr.hasError || !mounted) return;
    final message = pr.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      pr.clearError();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onCancel() {
    context.go('/transactions/lab-code');
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _breadcrumbLabel(LabCodeModel r) {
    if (r.labCode != null && r.labCode!.trim().isNotEmpty) {
      return r.labCode!;
    }
    return r.sampleId;
  }

  /// Single title line: Sample Id / Lab Code (matches Customer header title density).
  String _headerTitleLine(LabCodeModel r) {
    final lab = r.labCode?.trim();
    final labPart = lab != null && lab.isNotEmpty ? lab : '—';
    return '${r.sampleId} / $labPart';
  }

  String _labIdMeta(LabCodeModel r) {
    final lab = r.labCode?.trim();
    if (lab == null || lab.isEmpty) return 'Lab Id: —';
    return 'Lab Id: $lab';
  }

  String _workOrderMeta(LabCodeModel r) {
    final wo = r.workOrderNo?.trim();
    if (wo == null || wo.isEmpty) return 'Work Order: —';
    return 'Work Order: $wo';
  }

  String _customerDisplay(LabCodeModel r) {
    final parts = <String>[
      r.customerName.trim(),
      r.customerCompany.trim(),
    ].where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    return parts.join(' · ');
  }

  String? _siteDisplay(LabCodeModel r) {
    final parts = <String>[
      if ((r.siteCompany ?? '').trim().isNotEmpty) r.siteCompany!.trim(),
      if ((r.siteContactPerson ?? '').trim().isNotEmpty)
        r.siteContactPerson!.trim(),
    ];
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LabCodeProvider>();
    final r = p.selected;

    if (p.isLoading && r == null) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: SizedBox(
            width: AppTokens.inlineProgressIndicatorSize + AppTokens.space3,
            height: AppTokens.inlineProgressIndicatorSize + AppTokens.space3,
            child: CircularProgressIndicator(
              strokeWidth: AppTokens.inlineProgressIndicatorStrokeWidth,
              color: AppTokens.primary800,
            ),
          ),
        ),
      );
    }

    if (r == null || r.id != widget.itemId) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lab code record not found',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space3),
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.primary,
                onPressed: _onCancel,
              ),
            ],
          ),
        ),
      );
    }

    final customerLine = _customerDisplay(r);
    final siteLine = _siteDisplay(r);

    final overviewBody = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormPageLayout(
        left: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Basic Details',
            children: [
              FormReadOnlyField(
                label: 'Lab Id',
                value: r.labCode?.trim().isNotEmpty == true ? r.labCode : null,
              ),
              FormReadOnlyField(label: 'Sample Id', value: r.sampleId),
              FormReadOnlyField(
                label: 'Date',
                value:
                    '${_formatDate(r.recordedAt)} ${_formatTime(r.recordedAt)}',
              ),
              FormReadOnlyField(label: 'Status', value: r.status),
            ],
          ),
          AppFormSection(
            title: 'Customer / Site Details',
            children: [
              FormReadOnlyField(
                label: 'Customer',
                value: customerLine.isNotEmpty ? customerLine : null,
              ),
              FormReadOnlyField(label: 'Site', value: siteLine),
            ],
          ),
        ]),
        right: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Lab Details',
            children: [
              FormReadOnlyField(label: 'Type of Sample', value: r.sampleType),
              FormReadOnlyField(
                label: 'Work Order',
                value: r.workOrderNo,
              ),
            ],
          ),
        ]),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Lab Code',
        parentRoute: '/transactions/lab-code',
        currentLabel: _breadcrumbLabel(r),
        tabController: null,
        headerCard: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(
              name: _headerTitleLine(r),
              size: AppAvatarSize.lg,
            ),
            SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _headerTitleLine(r),
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
                      StatusChip(status: r.status),
                    ],
                  ),
                  SizedBox(height: AppTokens.space2),
                  Wrap(
                    spacing: AppTokens.space4,
                    runSpacing: AppTokens.space1,
                    children: [
                      _InfoItem(
                        icon: LucideIcons.user,
                        label: customerLine.isNotEmpty ? customerLine : '—',
                      ),
                      _InfoItem(
                        icon: LucideIcons.flaskConical,
                        label: r.sampleType,
                      ),
                      _InfoItem(
                        icon: LucideIcons.calendar,
                        label: _formatDate(r.recordedAt),
                      ),
                      _InfoItem(
                        icon: LucideIcons.hash,
                        label: _labIdMeta(r),
                      ),
                      _InfoItem(
                        icon: LucideIcons.clipboardList,
                        label: _workOrderMeta(r),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.primary,
                  onPressed: _onCancel,
                ),
              ],
            ),
          ],
        ),
        tabLabels: const ['Overview'],
        tabViews: [
          overviewBody,
        ],
      ),
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
