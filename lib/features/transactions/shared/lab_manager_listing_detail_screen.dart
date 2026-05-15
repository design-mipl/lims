import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens.dart';
import '../lab_manager_certification/data/lab_manager_certification_api.dart';
import '../lab_manager_verification/data/lab_manager_verification_api.dart';
import 'form_read_only_field.dart';
import 'lab_manager_listing_row.dart';
import 'lab_verification_progress.dart';
import 'lab_workflow_nested_table.dart';

/// Which listing module owns this view (drives mock [fetchById]).
enum LabManagerListingDetailModule {
  verification,
  certification,
}

/// Read-only detail for Lab Manager Verification / Certification (Lab Code view pattern).
class LabManagerListingDetailScreen extends StatefulWidget {
  const LabManagerListingDetailScreen({
    super.key,
    required this.rowId,
    required this.module,
  });

  final String rowId;
  final LabManagerListingDetailModule module;

  String get _parentLabel => switch (module) {
        LabManagerListingDetailModule.verification =>
          'Lab Manager Verification',
        LabManagerListingDetailModule.certification =>
          'Lab Manager Certification',
      };

  String get _parentRoute => switch (module) {
        LabManagerListingDetailModule.verification =>
          '/transactions/verification',
        LabManagerListingDetailModule.certification =>
          '/transactions/lab-manager-certification',
      };

  @override
  State<LabManagerListingDetailScreen> createState() =>
      _LabManagerListingDetailScreenState();
}

class _LabManagerListingDetailScreenState extends State<LabManagerListingDetailScreen>
    with SingleTickerProviderStateMixin {
  LabManagerListingRow? _row;
  bool _loading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if (widget.module == LabManagerListingDetailModule.verification) {
      _tabController = TabController(length: 6, vsync: this);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.rowId;
    final row = switch (widget.module) {
      LabManagerListingDetailModule.verification =>
        await sl<LabManagerVerificationApi>().fetchById(id),
      LabManagerListingDetailModule.certification =>
        await sl<LabManagerCertificationApi>().fetchById(id),
    };
    if (!mounted) return;
    setState(() {
      _row = row;
      _loading = false;
    });
  }

  void _onCancel() {
    context.go(widget._parentRoute);
  }

  String _formatYmd(DateTime d) => LabManagerListingRow.formatYmd(d);

  String _chipStatus(LabManagerListingRow r) =>
      r.verified ? 'active' : 'pending';

  Widget _verificationOverviewBody(LabManagerListingRow r) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormPageLayout(
        left: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Basic Details',
            children: [
              FormReadOnlyField(label: 'Lot No.', value: r.lotNo),
              FormReadOnlyField(label: 'Lab Id', value: r.labId),
              FormReadOnlyField(
                label: 'Sampling Date',
                value: _formatYmd(r.samplingDate),
              ),
              FormReadOnlyField(
                label: 'Lab Date',
                value: _formatYmd(r.labDate),
              ),
              FormReadOnlyField(
                label: 'Date Of Receipt',
                value: _formatYmd(r.dateOfReceipt),
              ),
              FormReadOnlyField(
                label: 'Parameters verified',
                value: labWorkflowVerifiedProgressText(r.testLines),
              ),
            ],
          ),
          AppFormSection(
            title: 'Sample Details',
            children: [
              FormReadOnlyField(label: 'Sample Id', value: r.sampleId),
              FormReadOnlyField(label: 'Type Of Sample', value: r.typeOfSample),
              FormReadOnlyField(label: 'Make', value: r.make),
              FormReadOnlyField(label: 'Model', value: r.model),
              FormReadOnlyField(label: 'Serial No.', value: r.serialNo),
              FormReadOnlyField(label: 'Brand of Oil', value: r.brandOfOil),
              FormReadOnlyField(label: 'Grade', value: r.grade),
            ],
          ),
        ]),
        right: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Equipment Details',
            children: [
              FormReadOnlyField(label: 'Equipment No.', value: r.equipmentNo),
              FormReadOnlyField(
                label: 'Lube Hrs',
                value: r.lubeHrs.toStringAsFixed(0),
              ),
              FormReadOnlyField(label: 'HMR', value: r.hmr),
            ],
          ),
          AppFormSection(
            title: 'Report Details',
            children: [
              FormReadOnlyField(label: 'Report Id', value: r.reportId),
              FormReadOnlyField(label: 'Reference No.', value: r.referenceNo),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _verificationCustomerBody(LabManagerListingRow r) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormSection(
        title: 'Customer',
        children: [
          FormReadOnlyField(label: 'Company Name', value: r.companyName),
          FormReadOnlyField(label: 'Site Name', value: r.siteName),
        ],
      ),
    );
  }

  Widget _verificationTestsBody(LabManagerListingRow r) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: LabManagerVerificationNestedTable(lines: r.testLines),
    );
  }

  Widget _verificationRemarksBody(LabManagerListingRow r) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormSection(
        title: 'Remarks',
        children: [
          FormReadOnlyField(label: 'Narration', value: r.narration),
          FormReadOnlyField(
            label: 'Additional Remarks',
            value: r.additionalRemarks,
          ),
          FormReadOnlyField(label: 'Customer Notes', value: r.customerNotes),
        ],
      ),
    );
  }

  Widget _verificationAttachmentsBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormSection(
        title: 'Attachments',
        children: [
          FormReadOnlyField(label: 'Files', value: 'None'),
        ],
      ),
    );
  }

  Widget _verificationTimelineBody(LabManagerListingRow r) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormSection(
        title: 'Timeline',
        children: [
          FormReadOnlyField(
            label: _formatYmd(r.dateOfReceipt),
            value: 'Sample received at lab',
          ),
          FormReadOnlyField(
            label: _formatYmd(r.labDate),
            value: 'Lab processing',
          ),
          FormReadOnlyField(
            label: _formatYmd(r.samplingDate),
            value: 'Sampling date (reference)',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
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

    final r = _row;
    if (r == null) {
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

    final titleLine = '${r.labId} / ${r.reportId}';

    final certificationOverviewBody = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormPageLayout(
        left: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Basic Details',
            children: [
              FormReadOnlyField(label: 'Lot No.', value: r.lotNo),
              FormReadOnlyField(label: 'Lab Id', value: r.labId),
              FormReadOnlyField(
                label: 'Sampling Date',
                value: _formatYmd(r.samplingDate),
              ),
              FormReadOnlyField(
                label: 'Lab Date',
                value: _formatYmd(r.labDate),
              ),
              FormReadOnlyField(
                label: 'Date Of Receipt',
                value: _formatYmd(r.dateOfReceipt),
              ),
              FormReadOnlyField(
                label: 'Verified',
                value: r.verified ? 'Yes' : 'No',
              ),
            ],
          ),
          AppFormSection(
            title: 'Sample Details',
            children: [
              FormReadOnlyField(label: 'Sample Id', value: r.sampleId),
              FormReadOnlyField(label: 'Type Of Sample', value: r.typeOfSample),
              FormReadOnlyField(label: 'Make', value: r.make),
              FormReadOnlyField(label: 'Model', value: r.model),
              FormReadOnlyField(label: 'Serial No.', value: r.serialNo),
              FormReadOnlyField(label: 'Brand of Oil', value: r.brandOfOil),
              FormReadOnlyField(label: 'Grade', value: r.grade),
            ],
          ),
        ]),
        right: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Equipment Details',
            children: [
              FormReadOnlyField(label: 'Equipment No.', value: r.equipmentNo),
              FormReadOnlyField(
                label: 'Lube Hrs',
                value: r.lubeHrs.toStringAsFixed(0),
              ),
              FormReadOnlyField(label: 'HMR', value: r.hmr),
            ],
          ),
          AppFormSection(
            title: 'Report Details',
            children: [
              FormReadOnlyField(label: 'Report Id', value: r.reportId),
              FormReadOnlyField(label: 'Reference No.', value: r.referenceNo),
            ],
          ),
          AppFormSection(
            title: 'Remarks',
            children: [
              FormReadOnlyField(label: 'Narration', value: r.narration),
              FormReadOnlyField(
                label: 'Additional Remarks',
                value: r.additionalRemarks,
              ),
              FormReadOnlyField(label: 'Customer Notes', value: r.customerNotes),
            ],
          ),
        ]),
      ),
    );

    final verificationMetaLine =
        '${labWorkflowVerifiedProgressText(r.testLines)} · '
        '${labManagerListingVerificationComplete(r) ? 'Complete' : 'In progress'}';

    final headerVerification = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          name: titleLine,
          size: AppAvatarSize.lg,
        ),
        SizedBox(width: AppTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleLine,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textXl,
                  fontWeight: AppTokens.weightBold,
                  color: AppTokens.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: AppTokens.space1),
              Text(
                verificationMetaLine,
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
                    icon: LucideIcons.building2,
                    label: r.companyName,
                  ),
                  _InfoItem(
                    icon: LucideIcons.mapPin,
                    label: r.siteName,
                  ),
                  _InfoItem(
                    icon: LucideIcons.flaskConical,
                    label: r.typeOfSample,
                  ),
                  _InfoItem(
                    icon: LucideIcons.calendar,
                    label: _formatYmd(r.samplingDate),
                  ),
                  _InfoItem(
                    icon: LucideIcons.package,
                    label: r.lotNo,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.primary,
          onPressed: _onCancel,
        ),
      ],
    );

    final headerCertification = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          name: titleLine,
          size: AppAvatarSize.lg,
        ),
        SizedBox(width: AppTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleLine,
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
                children: [
                  StatusChip(
                    status: _chipStatus(r),
                    customLabel: r.verified ? 'Verified' : 'Pending',
                  ),
                ],
              ),
              SizedBox(height: AppTokens.space2),
              Wrap(
                spacing: AppTokens.space4,
                runSpacing: AppTokens.space1,
                children: [
                  _InfoItem(
                    icon: LucideIcons.building2,
                    label: r.companyName,
                  ),
                  _InfoItem(
                    icon: LucideIcons.mapPin,
                    label: r.siteName,
                  ),
                  _InfoItem(
                    icon: LucideIcons.flaskConical,
                    label: r.typeOfSample,
                  ),
                  _InfoItem(
                    icon: LucideIcons.calendar,
                    label: _formatYmd(r.samplingDate),
                  ),
                  _InfoItem(
                    icon: LucideIcons.package,
                    label: r.lotNo,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.primary,
          onPressed: _onCancel,
        ),
      ],
    );

    if (widget.module == LabManagerListingDetailModule.certification) {
      return Material(
        type: MaterialType.transparency,
        child: DetailTemplate(
          parentLabel: widget._parentLabel,
          parentRoute: widget._parentRoute,
          currentLabel: r.labId,
          tabController: null,
          headerCard: headerCertification,
          tabLabels: const ['Overview'],
          tabViews: [
            certificationOverviewBody,
          ],
        ),
      );
    }

    final tc = _tabController!;
    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: widget._parentLabel,
        parentRoute: widget._parentRoute,
        currentLabel: r.labId,
        tabController: tc,
        headerCard: headerVerification,
        tabLabels: const [
          'Overview',
          'Customer',
          'Tests',
          'Remarks',
          'Attachments',
          'Timeline',
        ],
        tabViews: [
          _verificationOverviewBody(r),
          _verificationCustomerBody(r),
          _verificationTestsBody(r),
          _verificationRemarksBody(r),
          _verificationAttachmentsBody(),
          _verificationTimelineBody(r),
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
