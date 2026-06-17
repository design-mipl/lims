import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/form_read_only_field.dart';
import '../../shared/lab_verification_progress.dart';
import '../../shared/lab_workflow_nested_table.dart';
import '../../shared/lab_workflow_test_line.dart';
import '../data/lab_verification_chemist_model.dart';
import '../state/lab_verification_chemist_provider.dart';

/// Read-only Lab Verification Chemist detail (View from listing).
class LabVerificationChemistDetailScreen extends StatefulWidget {
  const LabVerificationChemistDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<LabVerificationChemistDetailScreen> createState() =>
      _LabVerificationChemistDetailScreenState();
}

class _LabVerificationChemistDetailScreenState
    extends State<LabVerificationChemistDetailScreen>
    with SingleTickerProviderStateMixin {
  LabVerificationChemistProvider? _provider;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<LabVerificationChemistProvider>();
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
    _tabController.dispose();
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onCancel() {
    context.go('/transactions/lab-verification-chemist');
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _lubeHrsText(LabVerificationChemistModel r) {
    final v = r.lubeHrs;
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v.toString();
  }

  String _verificationSummaryLine(LabVerificationChemistModel r) {
    final progress = labWorkflowVerifiedProgressText(r.testLines);
    if (r.testLines.isEmpty) {
      return '$progress · No parameters loaded.';
    }
    final allDone = r.testLines.every((e) => e.lineVerified);
    return allDone
        ? '$progress · All listed parameters verified.'
        : '$progress · Verification in progress.';
  }

  Widget _sampleBody(LabVerificationChemistModel r) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormPageLayout(
        left: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Sample information',
            children: [
              FormReadOnlyField(label: 'Sample Id', value: r.sampleId),
              FormReadOnlyField(label: 'Type of Sample', value: r.typeOfSample),
              FormReadOnlyField(
                label: 'Date of Receipt',
                value: _formatDate(r.dateOfReceipt),
              ),
              FormReadOnlyField(label: 'Lot No.', value: r.lotNo),
              FormReadOnlyField(label: 'Report Id', value: r.reportId),
            ],
          ),
          AppFormSection(
            title: 'Lab details',
            children: [
              FormReadOnlyField(label: 'Lab Id', value: r.labId),
              FormReadOnlyField(label: 'Brand of Oil', value: r.brandOfOil),
              FormReadOnlyField(label: 'Grade', value: r.grade),
            ],
          ),
        ]),
        right: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Customer',
            children: [
              FormReadOnlyField(label: 'Contact', value: r.customerName),
              FormReadOnlyField(label: 'Company', value: r.customerCompany),
            ],
          ),
          AppFormSection(
            title: 'Equipment details',
            children: [
              FormReadOnlyField(label: 'Make', value: r.make),
              FormReadOnlyField(label: 'Model', value: r.model),
              FormReadOnlyField(label: 'Serial No.', value: r.serialNo),
              FormReadOnlyField(label: 'Equipment No.', value: r.equipmentNo),
              FormReadOnlyField(label: 'Lube Hrs', value: _lubeHrsText(r)),
              FormReadOnlyField(label: 'HMR', value: r.hmr),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _testsBody(LabVerificationChemistModel r) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: LabVerificationChemistNestedTable(lines: r.testLines),
    );
  }

  Widget _technicalValidationBody(LabVerificationChemistModel r) {
    final sorted = List<LabWorkflowTestLine>.from(r.testLines)
      ..sort((a, b) => a.lineNo.compareTo(b.lineNo));
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormSection(
        title: 'Technical validation',
        children: [
          if (sorted.isEmpty)
            FormReadOnlyField(label: 'Parameters', value: 'None'),
          for (final l in sorted)
            FormReadOnlyField(
              label: '${l.lineNo}. ${l.testName}',
              value:
                  'Result ${l.value}\n${labWorkflowTestLineTechnicalNotes(l)}',
            ),
        ],
      ),
    );
  }

  Widget _verificationHistoryBody(LabVerificationChemistModel r) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormSection(
        title: 'Verification history',
        children: [
          FormReadOnlyField(
            label: 'Receipt',
            value:
                'Sample ${_formatDate(r.dateOfReceipt)} · Lot ${r.lotNo} logged.',
          ),
          FormReadOnlyField(
            label: 'Lab workflow',
            value:
                'Assigned to chemist verification queue (${r.labId}).',
          ),
          FormReadOnlyField(
            label: 'Current state',
            value: _verificationSummaryLine(r),
          ),
        ],
      ),
    );
  }

  Widget _timelineBody(LabVerificationChemistModel r) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormSection(
        title: 'Timeline / audit',
        children: [
          FormReadOnlyField(
            label: _formatDate(r.dateOfReceipt),
            value: 'Receipt confirmed · Sample Id ${r.sampleId}',
          ),
          FormReadOnlyField(
            label: _formatDate(r.dateOfReceipt.add(const Duration(days: 1))),
            value: 'Lab intake · ${r.labId}',
          ),
          FormReadOnlyField(
            label: _formatDate(DateTime.now()),
            value:
                'System audit · View opened (${labWorkflowVerifiedProgressText(r.testLines)})',
          ),
        ],
      ),
    );
  }

  Widget _attachmentsBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormSection(
        title: 'Attachments / documents',
        children: [
          FormReadOnlyField(label: 'Files', value: 'None'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LabVerificationChemistProvider>();
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
                'Record not found',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textPrimary,
                  decoration: TextDecoration.none,
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

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Lab Verification Chemist',
        parentRoute: '/transactions/lab-verification-chemist',
        currentLabel: r.labId,
        tabController: _tabController,
        headerCard: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(
              name: r.labId,
              size: AppAvatarSize.lg,
            ),
            SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.labId,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textXl,
                      fontWeight: AppTokens.weightBold,
                      color: AppTokens.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: AppTokens.space1),
                  Text(
                    _verificationSummaryLine(r),
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textSm,
                      color: AppTokens.textMuted,
                      fontWeight: AppTokens.weightRegular,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: AppTokens.space2),
                  Wrap(
                    spacing: AppTokens.space4,
                    runSpacing: AppTokens.space1,
                    children: [
                      _InfoItem(
                        icon: LucideIcons.user,
                        label: '${r.customerName} · ${r.customerCompany}',
                      ),
                      _InfoItem(
                        icon: LucideIcons.flaskConical,
                        label: r.typeOfSample,
                      ),
                      _InfoItem(
                        icon: LucideIcons.calendar,
                        label: _formatDate(r.dateOfReceipt),
                      ),
                      _InfoItem(
                        icon: LucideIcons.hash,
                        label: 'Lot: ${r.lotNo}',
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
        tabLabels: const [
          'Sample',
          'Tests',
          'Technical validation',
          'Verification history',
          'Timeline',
          'Attachments',
        ],
        tabViews: [
          _sampleBody(r),
          _testsBody(r),
          _technicalValidationBody(r),
          _verificationHistoryBody(r),
          _timelineBody(r),
          _attachmentsBody(),
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
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
