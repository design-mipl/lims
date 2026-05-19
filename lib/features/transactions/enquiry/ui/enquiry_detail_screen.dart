import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../quotation/data/quotation_api.dart';
import '../../quotation/ui/widgets/quotation_activity_timeline.dart';
import '../../shared/form_read_only_dropdown_field.dart';
import '../../shared/form_read_only_field.dart';
import '../data/enquiry_model.dart';
import '../state/enquiry_provider.dart';
import 'enquiry_form_page.dart';
import 'widgets/enquiry_requested_tests_table.dart';

/// Enquiry view with inline edit — layout aligned with Sample Intake view.
class EnquiryDetailScreen extends StatefulWidget {
  const EnquiryDetailScreen({super.key, required this.enquiryId});

  final String enquiryId;

  @override
  State<EnquiryDetailScreen> createState() => _EnquiryDetailScreenState();
}

class _EnquiryDetailScreenState extends State<EnquiryDetailScreen> {
  EnquiryProvider? _provider;
  bool _editingFromView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<EnquiryProvider>();
      _provider!.addListener(_onErr);
      context.read<EnquiryProvider>().loadDetail(widget.enquiryId);
    });
  }

  void _onErr() {
    final pr = _provider;
    if (pr == null || !pr.hasError || !mounted) return;
    final m = pr.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || m == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: AppTokens.error500),
      );
      pr.clearError();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onErr);
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dashIfEmpty(String? s) {
    final t = s?.trim() ?? '';
    return t.isEmpty ? '—' : t;
  }

  Future<void> _createQuote(BuildContext context, EnquiryRecord e) async {
    try {
      final q = await sl<QuotationApi>().createDraftFromEnquiry(e.id);
      if (!context.mounted) return;
      context.push('/transactions/quotation/${q.id}/workspace');
    } catch (err) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$err'),
          backgroundColor: AppTokens.error500,
        ),
      );
    }
  }

  Future<void> _exitInlineEdit({required bool reload}) async {
    if (reload) {
      await context.read<EnquiryProvider>().loadDetail(widget.enquiryId);
    }
    if (!mounted) return;
    setState(() => _editingFromView = false);
  }

  Widget _status(EnquiryRecord r) {
    final label = switch (r.status) {
      EnquiryStatus.pending => 'Pending',
      EnquiryStatus.submitted => 'Submitted',
      EnquiryStatus.converted => 'Converted',
      _ => r.status,
    };
    final key = switch (r.status) {
      EnquiryStatus.pending => 'pending',
      EnquiryStatus.submitted => 'inReview',
      EnquiryStatus.converted => 'completed',
      _ => r.status,
    };
    return StatusChip(status: key, customLabel: label);
  }

  Widget _attachmentChips(EnquiryRecord e) {
    if (e.attachmentNames.isEmpty) {
      return Text(
        '—',
        style: GoogleFonts.poppins(
          fontSize: AppTokens.bodySize,
          color: AppTokens.textMuted,
        ),
      );
    }
    return Wrap(
      spacing: AppTokens.space2,
      runSpacing: AppTokens.space2,
      children: e.attachmentNames.map((name) {
        return Material(
          color: AppTokens.primary50,
          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Open attachment: $name')),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space3,
                vertical: AppTokens.space1,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.paperclip,
                    size: AppTokens.iconButtonIconSm,
                    color: AppTokens.primary700,
                  ),
                  SizedBox(width: AppTokens.space1),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.captionSize,
                      color: AppTokens.primary700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReadOnlyOverview(EnquiryRecord e) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormPageLayout(
        left: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Enquiry Details',
            children: [
              FormReadOnlyField(
                label: 'Enquiry No.',
                value: e.enquiryNo,
              ),
              FormReadOnlyField(
                label: 'Enquiry Date',
                value: _formatDate(e.enquiryDate),
              ),
              FormReadOnlyField(
                label: 'Enquiry Source',
                value: e.enquirySource,
              ),
              FormReadOnlyField(
                label: 'Created By',
                value: e.createdBy,
              ),
            ],
          ),
          AppFormSection(
            title: 'Sample Requirement Information',
            children: [
              FormReadOnlyField(
                label: 'Type of Sample',
                value: e.typeOfSample,
              ),
              FormReadOnlyField(
                label: 'Sample Count',
                value: '${e.sampleCount}',
              ),
              FormReadOnlyField(
                label: 'Expected Timeline',
                value: e.expectedTimeline.isEmpty ? null : e.expectedTimeline,
              ),
              FormReadOnlyField(
                label: 'Priority',
                value: e.samplePriority,
              ),
              AppFormFullWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested Tests',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.fieldLabelSize,
                        fontWeight: AppTokens.fieldLabelWeight,
                        color: AppTokens.labelColor,
                      ),
                    ),
                    SizedBox(height: AppTokens.space2),
                    EnquiryRequestedTestsTable(tests: e.requestedTests),
                  ],
                ),
              ),
            ],
          ),
          AppFormSection(
            title: 'Notes & Attachments',
            children: [
              AppFormFullWidth(
                child: FormReadOnlyField(
                  label: 'Internal Notes',
                  value: e.internalNotes,
                ),
              ),
              AppFormFullWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attachments',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.fieldLabelSize,
                        fontWeight: AppTokens.fieldLabelWeight,
                        color: AppTokens.labelColor,
                      ),
                    ),
                    SizedBox(height: AppTokens.space2),
                    _attachmentChips(e),
                  ],
                ),
              ),
            ],
          ),
        ]),
        right: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Customer Details',
            children: [
              FormReadOnlyDropdownField(
                label: 'Customer Name',
                value: e.customerName,
              ),
              FormReadOnlyField(
                label: 'Customer Company',
                value: e.customerCompany,
              ),
              FormReadOnlyField(
                label: 'Contact Person',
                value: e.contactPerson,
              ),
              FormReadOnlyField(
                label: 'Contact Email',
                value: e.contactEmail,
              ),
              FormReadOnlyField(
                label: 'Contact Phone',
                value: e.contactPhone,
              ),
            ],
          ),
          AppFormSection(
            title: 'Site Details',
            children: [
              FormReadOnlyDropdownField(
                label: 'Site Name',
                value: e.siteName,
              ),
              FormReadOnlyField(
                label: 'Site Company',
                value: e.siteCompany,
              ),
              FormReadOnlyField(
                label: 'Site Contact',
                value: e.siteContactPerson,
              ),
            ],
          ),
          AppFormSection(
            title: 'Activity Timeline',
            child: QuotationActivityTimeline(entries: e.activity),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EnquiryProvider>();
    final e = p.detail;

    if (p.isLoading && e == null) {
      return const Material(
        type: MaterialType.transparency,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (e == null) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Text(
            'Enquiry not found',
            style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
          ),
        ),
      );
    }

    final overviewBody = _editingFromView
        ? EnquiryFormPage(
            enquiryId: widget.enquiryId,
            inlineEdit: true,
            onInlineCancel: () => _exitInlineEdit(reload: true),
            onInlineSaved: () => _exitInlineEdit(reload: true),
          )
        : _buildReadOnlyOverview(e);

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Enquiry',
        parentRoute: '/transactions/enquiry',
        currentLabel: e.enquiryNo,
        headerCard: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(
              name: 'EN',
              size: AppAvatarSize.lg,
            ),
            SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.enquiryNo,
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
                      _status(e),
                    ],
                  ),
                  SizedBox(height: AppTokens.space2),
                  Wrap(
                    spacing: AppTokens.space4,
                    runSpacing: AppTokens.space1,
                    children: [
                      _EnquiryViewInfoItem(
                        icon: LucideIcons.calendar,
                        label: _formatDate(e.enquiryDate),
                      ),
                      _EnquiryViewInfoItem(
                        icon: LucideIcons.user,
                        label: _dashIfEmpty(e.customerName),
                      ),
                      _EnquiryViewInfoItem(
                        icon: LucideIcons.mapPin,
                        label: _dashIfEmpty(e.siteName),
                      ),
                      if (e.quotationId != null)
                        _EnquiryViewInfoItem(
                          icon: LucideIcons.fileText,
                          label: 'Quote: ${e.quotationId}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (!_editingFromView)
              Wrap(
                spacing: AppTokens.space2,
                children: [
                  AppButton(
                    label: 'Edit',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.md,
                    onPressed: () => setState(() => _editingFromView = true),
                  ),
                  AppButton(
                    label: 'Create quotation',
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.md,
                    onPressed: e.status == EnquiryStatus.converted
                        ? null
                        : () => _createQuote(context, e),
                  ),
                  AppButton(
                    label: 'Convert to order',
                    variant: AppButtonVariant.tertiary,
                    size: AppButtonSize.md,
                    onPressed: () => context.push(
                      '/transactions/sample-intake/create?enquiryId=${e.id}',
                    ),
                  ),
                ],
              )
            else
              AppButton(
                label: 'Back to view',
                variant: AppButtonVariant.tertiary,
                size: AppButtonSize.md,
                onPressed: () => _exitInlineEdit(reload: true),
              ),
          ],
        ),
        tabController: null,
        tabLabels: const ['Overview'],
        tabViews: [overviewBody],
      ),
    );
  }
}

class _EnquiryViewInfoItem extends StatelessWidget {
  const _EnquiryViewInfoItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppTokens.iconButtonIconSm, color: AppTokens.textMuted),
        SizedBox(width: AppTokens.space1),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.captionSize,
            color: AppTokens.textMuted,
          ),
        ),
      ],
    );
  }
}
