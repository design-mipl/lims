import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../masters/customer_master/data/customer_model.dart';
import '../data/pending_invoice_lab_row_model.dart';

/// Builds mock pending uninvoiced labs tagged with real [CustomerModel.id] values.
List<PendingInvoiceLabRow> pendingLabsTemplateForCustomers(
  List<CustomerModel> customers,
) {
  if (customers.isEmpty) return [];
  String cid(int i) => customers[i % customers.length].id;

  return [
    PendingInvoiceLabRow(
      serialNo: 1,
      id: 'pl-1',
      customerId: cid(0),
      labDate: DateTime(2026, 5, 2),
      labNo: 'LAB-2026-01482',
      reportId: 'RPT-8821',
      typeOfSample: 'Used oil',
      site: 'Main Plant',
      referenceNo: 'REF-22001',
      contactPerson: 'A. Verma',
      lineItem: 'Wear Metals (ICP)',
      suggestedRate: 4200,
    ),
    PendingInvoiceLabRow(
      serialNo: 2,
      id: 'pl-2',
      customerId: cid(0),
      labDate: DateTime(2026, 5, 3),
      labNo: 'LAB-2026-01483',
      reportId: 'RPT-8822',
      typeOfSample: 'Grease',
      site: 'Lab Facility',
      referenceNo: 'REF-22002',
      contactPerson: 'A. Verma',
      lineItem: 'FTIR fingerprint',
      suggestedRate: 2800,
    ),
    PendingInvoiceLabRow(
      serialNo: 3,
      id: 'pl-3',
      customerId: cid(1),
      labDate: DateTime(2026, 5, 4),
      labNo: 'LAB-2026-01490',
      reportId: 'RPT-8830',
      typeOfSample: 'Coolant',
      site: 'Main Plant',
      referenceNo: 'REF-33001',
      contactPerson: 'R. Iyer',
      lineItem: 'ICP metals + TBN',
      suggestedRate: 5600,
    ),
    PendingInvoiceLabRow(
      serialNo: 4,
      id: 'pl-4',
      customerId: cid(1),
      labDate: DateTime(2026, 5, 5),
      labNo: 'LAB-2026-01491',
      reportId: 'RPT-8831',
      typeOfSample: 'Hydraulic fluid',
      site: 'Warehouse',
      referenceNo: 'REF-33002',
      contactPerson: 'R. Iyer',
      lineItem: 'Particle count ISO',
      suggestedRate: 1900,
    ),
    PendingInvoiceLabRow(
      serialNo: 5,
      id: 'pl-5',
      customerId: cid(2),
      labDate: DateTime(2026, 5, 6),
      labNo: 'LAB-2026-01495',
      reportId: 'RPT-8838',
      typeOfSample: 'Fuel',
      site: 'Main Plant',
      referenceNo: 'REF-44001',
      contactPerson: 'S. Khan',
      lineItem: 'Sulphur / distillation',
      suggestedRate: 3400,
    ),
    PendingInvoiceLabRow(
      serialNo: 6,
      id: 'pl-6',
      customerId: cid(2),
      labDate: DateTime(2026, 5, 7),
      labNo: 'LAB-2026-01502',
      reportId: 'RPT-8840',
      typeOfSample: 'Transformer oil',
      site: 'Lab Facility',
      referenceNo: 'REF-44002',
      contactPerson: 'S. Khan',
      lineItem: 'DGA + moisture',
      suggestedRate: 4100,
    ),
  ];
}

/// Pending lab multi-select for invoice lines.
Future<List<PendingInvoiceLabRow>?> showPendingInvoiceLabSelectionDialog(
  BuildContext context, {
  required List<PendingInvoiceLabRow> availableRows,
}) {
  return showDialog<List<PendingInvoiceLabRow>>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    builder: (ctx) =>
        _PendingLabPickerBody(availableRows: List.of(availableRows)),
  );
}

class _PendingLabPickerBody extends StatefulWidget {
  const _PendingLabPickerBody({required this.availableRows});

  final List<PendingInvoiceLabRow> availableRows;

  @override
  State<_PendingLabPickerBody> createState() => _PendingLabPickerBodyState();
}

class _PendingLabPickerBodyState extends State<_PendingLabPickerBody> {
  String _search = '';
  Set<int> _selected = {};
  bool _listingReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _listingReady = true);
    });
  }

  List<PendingInvoiceLabRow> get _filtered {
    var list = widget.availableRows;
    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) {
        final blob =
            '${e.labNo} ${e.reportId} ${e.typeOfSample} ${e.referenceNo} '
                    '${e.contactPerson} ${e.serialNo}'
                .toLowerCase();
        return blob.contains(q);
      }).toList();
    }
    return list;
  }

  static String _formatYmd(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    const col = 112.0;

    return Dialog(
      insetPadding: EdgeInsets.all(AppTokens.space4),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1180,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppTokens.space4,
                AppTokens.space4,
                AppTokens.space2,
                AppTokens.space2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Pending Lab Items',
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.textLg,
                            fontWeight: AppTokens.weightSemibold,
                            color: AppTokens.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppTokens.space1),
                        Text(
                          'Select rows to add to this invoice.',
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.captionSize,
                            color: AppTokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppIconButton(
                    tooltip: 'Close',
                    icon: Icon(LucideIcons.x, size: AppTokens.iconButtonIconMd),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppTokens.borderLight),
            Expanded(
              child: _listingReady
                  ? RepaintBoundary(
                      child: AppListingScreen<PendingInvoiceLabRow>(
                        showPageHeader: false,
                        title: '',
                        subtitle: '',
                        showKpis: false,
                        showExport: false,
                        showImport: false,
                        showPrint: false,
                        showColumnToggle: false,
                        showToolbar: true,
                        showSearch: true,
                        searchHint: 'Search lab no., report, sample…',
                        onSearch: (v) => setState(() {
                          _search = v;
                          _selected.clear();
                        }),
                        showBulkBar: false,
                        showCheckboxes: true,
                        showPaginationFooter: false,
                        tableScrollableMinWidth: col * 8,
                        showTableHorizontalScrollbar: true,
                        tableBodyFillsViewport: false,
                        disableOuterVerticalScroll: true,
                        listingShellPadding: EdgeInsets.zero,
                        scaleDataColumnsToFillViewport: true,
                        columns: [
                          TableColumn<PendingInvoiceLabRow>(
                            key: 'labDate',
                            label: 'Lab Date',
                            width: col,
                            sortable: true,
                            sortValue: (r) => r.labDate.millisecondsSinceEpoch,
                            cellBuilder: (r) => Text(
                              _formatYmd(r.labDate),
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableCellSize,
                              ),
                            ),
                          ),
                          TableColumn<PendingInvoiceLabRow>(
                            key: 'labNo',
                            label: 'Lab No.',
                            width: col + 28,
                            sortable: true,
                            sortValue: (r) => r.labNo.toLowerCase(),
                            cellBuilder: (r) => Text(
                              r.labNo,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableCellSize,
                              ),
                            ),
                          ),
                          TableColumn<PendingInvoiceLabRow>(
                            key: 'reportId',
                            label: 'Report Id',
                            width: col,
                            sortable: true,
                            sortValue: (r) => r.reportId.toLowerCase(),
                            cellBuilder: (r) => Text(
                              r.reportId,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableCellSize,
                              ),
                            ),
                          ),
                          TableColumn<PendingInvoiceLabRow>(
                            key: 'sample',
                            label: 'Type Of Sample',
                            width: col + 20,
                            sortable: true,
                            sortValue: (r) => r.typeOfSample.toLowerCase(),
                            cellBuilder: (r) => Text(
                              r.typeOfSample,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableCellSize,
                              ),
                            ),
                          ),
                          TableColumn<PendingInvoiceLabRow>(
                            key: 'rate',
                            label: 'Rate',
                            width: col - 16,
                            sortable: true,
                            sortValue: (r) => r.suggestedRate,
                            cellBuilder: (r) => Text(
                              r.suggestedRate.toStringAsFixed(2),
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableCellSize,
                              ),
                            ),
                          ),
                          TableColumn<PendingInvoiceLabRow>(
                            key: 'srNo',
                            label: 'Sr No.',
                            width: col - 24,
                            sortable: true,
                            sortValue: (r) => r.serialNo,
                            cellBuilder: (r) => Text(
                              '${r.serialNo}',
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableCellSize,
                              ),
                            ),
                          ),
                          TableColumn<PendingInvoiceLabRow>(
                            key: 'ref',
                            label: 'References',
                            width: col,
                            sortable: true,
                            sortValue: (r) => r.referenceNo.toLowerCase(),
                            cellBuilder: (r) => Text(
                              r.referenceNo,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableCellSize,
                              ),
                            ),
                          ),
                          TableColumn<PendingInvoiceLabRow>(
                            key: 'contact',
                            label: 'Contact Person',
                            width: col + 12,
                            sortable: true,
                            sortValue: (r) => r.contactPerson.toLowerCase(),
                            cellBuilder: (r) => Text(
                              r.contactPerson,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.tableCellSize,
                              ),
                            ),
                          ),
                        ],
                        rows: rows,
                        onRowSelectionChanged: (indices) =>
                            setState(() => _selected = indices),
                        mobileCardBuilder: (r) => ListTile(
                          title: Text(r.labNo),
                          subtitle: Text(
                            '${r.typeOfSample} · ${r.suggestedRate.toStringAsFixed(2)}',
                          ),
                        ),
                        totalCount: rows.length,
                        currentPage: 1,
                        pageSize: rows.isEmpty ? 1 : rows.length,
                        onPageChanged: (_) {},
                        onPageSizeChanged: (_) {},
                      ),
                    )
                  : Center(
                      child: SizedBox(
                        width: AppTokens.space5,
                        height: AppTokens.space5,
                        child: CircularProgressIndicator(
                          strokeWidth: AppTokens.borderWidthMd,
                          color: AppTokens.primary800,
                        ),
                      ),
                    ),
            ),
            Divider(height: 1, color: AppTokens.borderLight),
            Padding(
              padding: EdgeInsets.all(AppTokens.space3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.tertiary,
                    size: AppButtonSize.md,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: AppTokens.space2),
                  AppButton(
                    label: _selected.isEmpty
                        ? 'Add Selected'
                        : 'Add Selected (${_selected.length})',
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.md,
                    onPressed: _selected.isEmpty
                        ? null
                        : () {
                            final picked = _selected
                                .map((i) => rows[i])
                                .toList(growable: false);
                            Navigator.of(context).pop(picked);
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
