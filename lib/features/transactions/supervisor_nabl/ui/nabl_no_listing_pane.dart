import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../nabl_no/data/nabl_no_model.dart';
import '../../nabl_no/state/nabl_no_provider.dart';
import '../../nabl_no/utils/nabl_listing_export.dart';

/// NABL No. listing (embedded in [SupervisorNablWorkspaceScreen] or standalone).
class NablNoListingPane extends StatefulWidget {
  const NablNoListingPane({super.key, this.showPageHeader = false});

  final bool showPageHeader;

  @override
  State<NablNoListingPane> createState() => _NablNoListingPaneState();
}

class _NablNoListingPaneState extends State<NablNoListingPane> {
  NablNoProvider? _provider;

  static const double _kCol = 160;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<NablNoProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<NablNoProvider>().loadItems();
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

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor:
            error ? AppTokens.error500 : AppTokens.primary800,
      ),
    );
  }

  Future<void> _onAuthorize(NablNoProvider p, List<NablNoRow> selected) async {
    if (selected.isEmpty) {
      _snack('Select at least one NABL record to authorize.', error: true);
      return;
    }
    await p.authorizeItems(selected.map((r) => r.id).toList());
    if (!mounted) return;
    if (p.hasError) return;
    _snack('NABL records authorized successfully');
  }

  Future<void> _onExportToExcel(List<NablNoRow> selected) async {
    if (selected.isEmpty) {
      _snack('Select at least one NABL record to export.', error: true);
      return;
    }
    await exportNablListingToExcel(selected);
    if (!mounted) return;
    if (kIsWeb) {
      _snack('Exported ${selected.length} row(s) to Excel');
    } else {
      _snack(
        'Copied ${selected.length} row(s) to clipboard — paste into Excel',
      );
    }
  }

  Future<void> _onBulkDelete(
    BuildContext context,
    NablNoProvider p,
    List<NablNoRow> selected,
  ) async {
    if (selected.isEmpty) return;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Selected',
      message:
          'Delete ${selected.length} selected record(s)? This cannot be undone.',
      confirmLabel: 'Delete All',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed != true || !mounted) return;
    await p.bulkDeleteItems(selected.map((r) => r.id).toList());
  }

  static Widget _textCell(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        color: AppTokens.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NablNoProvider>();

    final columns = <TableColumn<NablNoRow>>[
      TableColumn<NablNoRow>(
        key: 'nablDate',
        label: 'NABL Date',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.nablDate.millisecondsSinceEpoch,
        filter: const AppColumnFilter(type: AppColumnFilterType.dateRange),
        filterDateValue: (r) => r.nablDate,
        cellBuilder: (r) => _textCell(NablNoRow.formatYmd(r.nablDate)),
      ),
      TableColumn<NablNoRow>(
        key: 'nablNo',
        label: 'NABL No.',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.nablNo.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.nablNo,
        cellBuilder: (r) => _textCell(r.nablNo),
      ),
      TableColumn<NablNoRow>(
        key: 'lcDate',
        label: 'LC Date',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.lcDate.millisecondsSinceEpoch,
        cellBuilder: (r) => _textCell(NablNoRow.formatYmd(r.lcDate)),
      ),
      TableColumn<NablNoRow>(
        key: 'lcNo',
        label: 'LC No.',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.lcNo.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.lcNo,
        cellBuilder: (r) => _textCell(r.lcNo),
      ),
      TableColumn<NablNoRow>(
        key: 'typeOfSample',
        label: 'Type Of Sample',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.typeOfSample.toLowerCase(),
        cellBuilder: (r) => _textCell(r.typeOfSample),
      ),
      TableColumn<NablNoRow>(
        key: 'customerName',
        label: 'Customer Name',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.customerName.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.customerName,
        cellBuilder: (r) => _textCell(r.customerName),
      ),
      TableColumn<NablNoRow>(
        key: 'sampleId',
        label: 'Sample',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.sampleId.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.sampleId,
        cellBuilder: (r) => _textCell(r.sampleId),
      ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<NablNoRow>(
        showPageHeader: widget.showPageHeader,
        title: 'NABL No.',
        subtitle:
            'Track NABL registrations and laboratory code linkage for reports.',
        showKpis: false,
        showExport: false,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: true,
        tableScrollableMinWidth: _kCol * columns.length + 480,
        tabs: [
          TabConfig(label: 'Pending', count: p.pendingCount),
          TabConfig(label: 'Authenticated', count: p.authenticatedCount),
          TabConfig(label: 'Duplicate', count: p.duplicateCount),
        ],
        initialTabIndex: p.subTabIndex,
        onTabChanged: p.setSubTabByIndex,
        searchHint: 'Search NABL no., LC no., customer, sample, type…',
        onSearch: p.setSearchQuery,
        toolbarAfterSearch: [
          SizedBox(width: AppTokens.space2),
          LabCodeLabIdDateField(
            hint: 'From Date',
            selectedDate: p.fromDate,
            onDateSelected: p.setFromDate,
          ),
          SizedBox(width: AppTokens.space2),
          LabCodeLabIdDateField(
            hint: 'To Date',
            selectedDate: p.toDate,
            onDateSelected: p.setToDate,
          ),
        ],
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        bulkActions: [
          BulkAction<NablNoRow>(
            key: 'authorize',
            label: 'Authorize',
            icon: Icon(
              LucideIcons.shieldCheck,
              size: AppTokens.iconButtonIconSm,
            ),
            onTap: (rows) => _onAuthorize(p, rows),
          ),
          BulkAction<NablNoRow>(
            key: 'export_excel',
            label: 'Export To Excel',
            icon: Icon(
              LucideIcons.fileSpreadsheet,
              size: AppTokens.iconButtonIconSm,
            ),
            onTap: _onExportToExcel,
          ),
          BulkAction<NablNoRow>(
            key: 'delete',
            label: 'Delete',
            icon: Icon(
              LucideIcons.trash2,
              size: AppTokens.iconButtonIconSm,
            ),
            isDanger: true,
            onTap: (rows) => _onBulkDelete(context, p, rows),
          ),
        ],
        columns: columns,
        rows: p.pagedRows,
        mobileCardBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.nablNo,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightSemibold,
                color: AppTokens.textPrimary,
              ),
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              '${r.lcNo} · ${r.customerName}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        rowActions: [
          RowAction<NablNoRow>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'View — coming soon',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.bodySize,
                      color: AppTokens.white,
                    ),
                  ),
                  backgroundColor: AppTokens.primary800,
                ),
              );
            },
          ),
        ],
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No NABL records found',
      ),
    );
  }
}
