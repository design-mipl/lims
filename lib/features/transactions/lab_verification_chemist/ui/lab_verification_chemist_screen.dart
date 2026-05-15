import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/lab_verification_progress.dart';
import '../../shared/lab_workflow_verification_detail_popup.dart';
import '../data/lab_verification_chemist_model.dart';
import '../state/lab_verification_chemist_provider.dart';

class LabVerificationChemistScreen extends StatefulWidget {
  const LabVerificationChemistScreen({super.key});

  @override
  State<LabVerificationChemistScreen> createState() =>
      _LabVerificationChemistScreenState();
}

class _LabVerificationChemistScreenState
    extends State<LabVerificationChemistScreen> {
  LabVerificationChemistProvider? _provider;

  static const double _kChemColWidth = 160;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<LabVerificationChemistProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<LabVerificationChemistProvider>().loadItems();
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

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<AppSelectItem<String>> _distinctTypeOptions(
    List<LabVerificationChemistModel> all,
  ) {
    final set = all.map((e) => e.typeOfSample).toSet().toList()..sort();
    return set
        .map((v) => AppSelectItem<String>(value: v, label: v))
        .toList();
  }

  List<AppSelectItem<String>> _distinctLabIdOptions(
    List<LabVerificationChemistModel> all,
  ) {
    final set = all.map((e) => e.labId).toSet().toList()..sort();
    return set
        .map((v) => AppSelectItem<String>(value: v, label: v))
        .toList();
  }

  Future<void> _verifyRow(LabVerificationChemistModel row) async {
    if (row.verified) return;
    await context.read<LabVerificationChemistProvider>().verifyRows([row.id]);
  }

  void _showTestDetailsDialog(LabVerificationChemistModel row) {
    LabWorkflowVerificationDetailPopup.show(
      context,
      companyName: row.customerCompany,
      siteName: row.customerName,
      labId: row.labId,
      typeOfSample: row.typeOfSample,
      testLines: row.testLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LabVerificationChemistProvider>();
    final typeOptions = _distinctTypeOptions(p.items);
    final labOptions = _distinctLabIdOptions(p.items);
    final paged = p.pagedRows;

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<LabVerificationChemistModel>(
        title: 'Lab Verification Chemist',
        subtitle:
            'Review samples pending verification and confirm completed verifications.',
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        bulkPrimaryLabel: 'Verify',
        onBulkPrimary: (ids) => p.verifyRows(ids),
        showKpis: false,
        showExport: false,
        showColumnToggle: false,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: true,
        tableScrollableMinWidth: _kChemColWidth * 4,
        tabs: [
          TabConfig(label: 'Pending', count: p.pendingCount),
          TabConfig(label: 'Completed', count: p.completeCount),
        ],
        initialTabIndex: p.tabIndex,
        onTabChanged: (i) {
          p.setTabByIndex(i);
        },
        searchHint: 'Search by sample, lab, customer, lot, report...',
        onSearch: (q) {
          p.setSearchQuery(q);
        },
        columns: [
          TableColumn<LabVerificationChemistModel>(
            key: 'verified',
            label: 'Verified?',
            width: _kChemColWidth,
            sortable: false,
            cellBuilder: (r) => Text(
              labWorkflowVerifiedProgressText(r.testLines),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightMedium,
                color: AppTokens.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          TableColumn<LabVerificationChemistModel>(
            key: 'typeOfSample',
            label: 'Type Of Sample',
            width: _kChemColWidth,
            sortable: true,
            sortValue: (r) => r.typeOfSample.toLowerCase(),
            filter: AppColumnFilter(
              type: AppColumnFilterType.select,
              options: typeOptions,
            ),
            filterSelectValue: (r) => r.typeOfSample,
            cellBuilder: (r) => Text(
              r.typeOfSample,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightRegular,
                color: AppTokens.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          TableColumn<LabVerificationChemistModel>(
            key: 'labId',
            label: 'Lab Id',
            width: _kChemColWidth,
            sortable: true,
            sortValue: (r) => r.labId.toLowerCase(),
            filter: AppColumnFilter(
              type: AppColumnFilterType.select,
              options: labOptions,
            ),
            filterSelectValue: (r) => r.labId,
            cellBuilder: (r) => Text(
              r.labId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightMedium,
                color: AppTokens.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          TableColumn<LabVerificationChemistModel>(
            key: 'dateOfReceipt',
            label: 'Date Of Receipt',
            width: _kChemColWidth,
            sortable: true,
            sortValue: (r) => r.dateOfReceipt.millisecondsSinceEpoch,
            cellBuilder: (r) => Text(
              _formatDate(r.dateOfReceipt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightRegular,
                color: AppTokens.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
        rows: paged,
        showExpandColumn: false,
        onRowTap: _showTestDetailsDialog,
        mobileCardBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.labId,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.tableCellSize,
                      fontWeight: AppTokens.weightSemibold,
                      color: AppTokens.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Text(
                  labWorkflowVerifiedProgressText(r.testLines),
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.captionSize,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.textMuted,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              '${r.typeOfSample} · ${_formatDate(r.dateOfReceipt)}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        rowActions: [
          RowAction<LabVerificationChemistModel>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (row) => context.push(
              '/transactions/lab-verification-chemist/${row.id}/view',
            ),
          ),
          RowAction<LabVerificationChemistModel>(
            key: 'verify',
            label: 'Verify',
            icon: Icon(LucideIcons.checkCircle, size: AppTokens.iconButtonIconMd),
            isEnabled: (row) => !row.verified,
            onTap: (row) => _verifyRow(row),
          ),
        ],
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: (page) {
          p.setPage(page);
        },
        onPageSizeChanged: (size) {
          p.setPageSize(size);
        },
        emptyMessage: 'No records found',
      ),
    );
  }
}
