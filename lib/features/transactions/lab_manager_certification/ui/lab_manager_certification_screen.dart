import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/lab_manager_listing_columns.dart';
import '../../shared/lab_manager_listing_row.dart';
import '../state/lab_manager_certification_provider.dart';

class LabManagerCertificationScreen extends StatefulWidget {
  const LabManagerCertificationScreen({super.key});

  @override
  State<LabManagerCertificationScreen> createState() =>
      _LabManagerCertificationScreenState();
}

class _LabManagerCertificationScreenState
    extends State<LabManagerCertificationScreen> {
  LabManagerCertificationProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<LabManagerCertificationProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<LabManagerCertificationProvider>().loadItems();
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LabManagerCertificationProvider>();

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<LabManagerListingRow>(
        title: 'Lab Manager Certification',
        subtitle:
            'Certify lab reports and release workflow after verification.',
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        showKpis: false,
        showExport: false,
        showTableHorizontalScrollbar: true,
        tableScrollableMinWidth: labManagerListingDataColumnsWidth + 480,
        searchHint:
            'Search company, site, lot, lab id, sample id, make, model...',
        onSearch: p.setSearchQuery,
        onBulkDelete: (ids) => p.bulkDeleteRows(ids),
        onBulkActivate: (ids) => p.bulkSetVerified(ids, true),
        onBulkDeactivate: (ids) => p.bulkSetVerified(ids, false),
        columns: buildLabManagerListingColumns(
          mode: LabManagerListingColumnsMode.certification,
        ),
        rows: p.pagedRows,
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
            label: 'View Details',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (row) => context.push(
                  '/transactions/lab-manager-certification/${row.id}/view',
                ),
          ),
        ],
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No certification records found',
      ),
    );
  }
}
