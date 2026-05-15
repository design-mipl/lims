import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../quotation/data/quotation_api.dart';
import '../../quotation/ui/widgets/quotation_activity_timeline.dart';
import '../../shared/form_read_only_field.dart';
import '../data/enquiry_model.dart';
import '../state/enquiry_provider.dart';

class EnquiryDetailScreen extends StatefulWidget {
  const EnquiryDetailScreen({super.key, required this.enquiryId});

  final String enquiryId;

  @override
  State<EnquiryDetailScreen> createState() => _EnquiryDetailScreenState();
}

class _EnquiryDetailScreenState extends State<EnquiryDetailScreen> {
  EnquiryProvider? _provider;

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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EnquiryProvider>();
    final e = p.detail;

    if (p.isLoading && e == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (e == null) {
      return Center(
        child: Text(
          'Enquiry not found',
          style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
        ),
      );
    }

    return DetailTemplate(
      parentLabel: 'Enquiry',
      parentRoute: '/transactions/enquiry',
      currentLabel: e.enquiryNo,
      headerCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.enquiryNo,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.textXl,
                        fontWeight: AppTokens.weightSemibold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space2),
                    Wrap(
                      spacing: AppTokens.space3,
                      runSpacing: AppTokens.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _status(e),
                        Text(
                          _formatDate(e.enquiryDate),
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.bodySize,
                            color: AppTokens.textMuted,
                          ),
                        ),
                        if (e.quotationId != null)
                          Text(
                            'Linked quote: ${e.quotationId}',
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.captionSize,
                              color: AppTokens.primary700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: AppTokens.space2,
                children: [
                  AppButton(
                    label: 'Edit',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.md,
                    onPressed: () => context.push(
                      '/transactions/enquiry/${e.id}/edit',
                    ),
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
              ),
            ],
          ),
        ],
      ),
      tabLabels: const ['Overview'],
      tabViews: [
        SingleChildScrollView(
          padding: EdgeInsets.all(AppTokens.space4),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enquiry summary',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textBase,
                      fontWeight: AppTokens.weightSemibold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space3),
                  Wrap(
                    spacing: AppTokens.space4,
                    runSpacing: AppTokens.space4,
                    children: [
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Enquiry source',
                          value: e.enquirySource,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Created by',
                          value: e.createdBy,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTokens.space5),
                  Text(
                    'Customer & site',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textBase,
                      fontWeight: AppTokens.weightSemibold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space3),
                  Wrap(
                    spacing: AppTokens.space4,
                    runSpacing: AppTokens.space4,
                    children: [
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Customer',
                          value: e.customerName,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Company',
                          value: e.customerCompany,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Site',
                          value: e.siteName,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Site contact',
                          value: e.siteContactPerson,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Site company',
                          value: e.siteCompany,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Contact person',
                          value: e.contactPerson,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Email',
                          value: e.contactEmail,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Phone',
                          value: e.contactPhone,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Equipment make / model',
                          value: e.equipmentMakeModel,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTokens.space5),
                  Text(
                    'Sample requirements',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textBase,
                      fontWeight: AppTokens.weightSemibold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space3),
                  Wrap(
                    spacing: AppTokens.space4,
                    runSpacing: AppTokens.space4,
                    children: [
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Type of sample',
                          value: e.typeOfSample,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Sample count',
                          value: '${e.sampleCount}',
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Operating conditions',
                          value: e.operatingConditions,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Expected timeline',
                          value: e.expectedTimeline.isEmpty
                              ? null
                              : e.expectedTimeline,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: FormReadOnlyField(
                          label: 'Priority',
                          value: e.samplePriority,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTokens.space5),
                  Text(
                    'Requested tests',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textBase,
                      fontWeight: AppTokens.weightSemibold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space3),
                  // Horizontal [SingleChildScrollView] inside a vertically unbounded
                  // [Column] needs a bounded height on the cross-axis or layout blows up.
                  SizedBox(
                    height: ((e.requestedTests.length + 1) *
                                kMinInteractiveDimension +
                            24)
                        .clamp(120.0, 520.0)
                        .toDouble(),
                    child: AppScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AppScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Sel')),
                              DataColumn(label: Text('Code')),
                              DataColumn(label: Text('Test')),
                              DataColumn(label: Text('Priority')),
                              DataColumn(label: Text('Remarks')),
                            ],
                            rows: e.requestedTests
                                .map(
                                  (t) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(t.selected ? 'Yes' : '—'),
                                      ),
                                      DataCell(Text(t.testCode)),
                                      DataCell(Text(t.testName)),
                                      DataCell(Text(t.priority)),
                                      DataCell(Text(t.remarks)),
                                    ],
                                  ),
                                )
                                .toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppTokens.space5),
                  Text(
                    'Notes & attachments',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textBase,
                      fontWeight: AppTokens.weightSemibold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space3),
                  SizedBox(
                    width: 520,
                    child: FormReadOnlyField(
                      label: 'Internal notes',
                      value: e.internalNotes,
                    ),
                  ),
                  SizedBox(height: AppTokens.space3),
                  Text(
                    'Attachments',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.captionSize,
                      fontWeight: AppTokens.weightMedium,
                      color: AppTokens.textMuted,
                    ),
                  ),
                  SizedBox(height: AppTokens.space2),
                  if (e.attachmentNames.isEmpty)
                    Text(
                      '—',
                      style: GoogleFonts.poppins(color: AppTokens.textMuted),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: e.attachmentNames
                          .map(
                            (n) => Padding(
                              padding: EdgeInsets.only(bottom: AppTokens.space1),
                              child: Text(
                                n,
                                style: GoogleFonts.poppins(
                                  color: AppTokens.primary700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  SizedBox(height: AppTokens.space5),
                  Text(
                    'Activity timeline',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textBase,
                      fontWeight: AppTokens.weightSemibold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space3),
                  QuotationActivityTimeline(entries: e.activity),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
