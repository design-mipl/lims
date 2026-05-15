import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/lab_manager_listing_columns.dart';
import '../../shared/lab_manager_listing_row.dart';
import '../../shared/lab_workflow_verification_detail_popup.dart';
import '../state/lab_manager_verification_provider.dart';

class LabManagerVerificationScreen extends StatefulWidget {
  const LabManagerVerificationScreen({super.key});

  @override
  State<LabManagerVerificationScreen> createState() =>
      _LabManagerVerificationScreenState();
}

class _LabManagerVerificationScreenState
    extends State<LabManagerVerificationScreen> {
  LabManagerVerificationProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<LabManagerVerificationProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<LabManagerVerificationProvider>().loadItems();
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

  void _showTestDetailsDialog(LabManagerListingRow row) {
    LabWorkflowVerificationDetailPopup.show(
      context,
      companyName: row.companyName,
      siteName: row.siteName,
      labId: row.labId,
      typeOfSample: row.typeOfSample,
      testLines: row.testLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LabManagerVerificationProvider>();
    final paged = p.pagedRows;

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<LabManagerListingRow>(
        title: 'Lab Manager Verification',
        subtitle:
            'Verify sample and lab data before certification and reporting.',
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        showKpis: false,
        showExport: false,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: true,
        tableScrollableMinWidth: labManagerListingDataColumnsWidth + 480,
        tabs: [
          TabConfig(label: 'Pending', count: p.pendingVerificationCount),
          TabConfig(label: 'Completed', count: p.completedVerificationCount),
        ],
        initialTabIndex: p.tabIndex,
        onTabChanged: (i) => p.setTabByIndex(i),
        searchHint:
            'Search company, site, lot, lab id, sample id, make, model...',
        onSearch: (q) => p.setSearchQuery(q),
        onBulkDelete: (ids) => p.bulkDeleteRows(ids),
        onBulkActivate: (ids) => p.bulkSetVerified(ids, true),
        onBulkDeactivate: (ids) => p.bulkSetVerified(ids, false),
        columns: buildLabManagerListingColumns(
          mode: LabManagerListingColumnsMode.verification,
        ),
        rows: paged,
        showExpandColumn: false,
        onRowTap: (row) => _showTestDetailsDialog(row),
        mobileCardBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.sampleId,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightSemibold,
                color: AppTokens.textPrimary,
              ),
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              '${r.lotNo} · ${r.labId}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        rowActions: [
          RowAction<LabManagerListingRow>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (row) => context.push(
                  '/transactions/verification/${row.id}/view',
                ),
          ),
        ],
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: (page) => p.setPage(page),
        onPageSizeChanged: (size) => p.setPageSize(size),
        emptyMessage: 'No verification records found',
      ),
    );
  }
}
