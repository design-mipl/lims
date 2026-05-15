import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../supervisor_comments/data/supervisor_comments_model.dart';
import '../../supervisor_comments/state/supervisor_comments_provider.dart';
import '../../supervisor_comments/ui/supervisor_review_workspace_grouped_table.dart';

/// Supervisor Comments listing (embedded in [SupervisorNablWorkspaceScreen] or standalone).
class SupervisorCommentsListingPane extends StatefulWidget {
  const SupervisorCommentsListingPane({
    super.key,
    this.showPageHeader = false,
  });

  final bool showPageHeader;

  @override
  State<SupervisorCommentsListingPane> createState() =>
      _SupervisorCommentsListingPaneState();
}

class _SupervisorCommentsListingPaneState
    extends State<SupervisorCommentsListingPane> {
  SupervisorCommentsProvider? _provider;

  static const double _kCol = 160;

  /// Slightly below [AppTokens.tableRowHeight] — more rows per viewport.
  static const double _kListingRowHeight = 48.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<SupervisorCommentsProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<SupervisorCommentsProvider>().loadItems();
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

  static Widget _textCell(String text, {Color? color}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        color: color ?? AppTokens.textPrimary,
      ),
    );
  }

  String _numStr(double n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }

  void _openDetail(BuildContext context, SupervisorCommentsRow r) {
    context.push('/transactions/supervisor-review/${r.id}/view');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SupervisorCommentsProvider>();

    final zoneLabels = p.items.map((e) => e.zone).toSet().toList()
      ..sort();
    final zoneItems = zoneLabels
        .map((z) => AppSelectItem<String>(value: z, label: z))
        .toList();

    final columns = <TableColumn<SupervisorCommentsRow>>[
      TableColumn<SupervisorCommentsRow>(
        key: 'companyName',
        label: 'Company Name',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.companyName.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.companyName,
        cellBuilder: (r) => _textCell(r.companyName),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'siteName',
        label: 'Site Name',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.siteName.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.siteName,
        cellBuilder: (r) => _textCell(r.siteName),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'typeOfSample',
        label: 'Type of Sample',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.typeOfSample.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.typeOfSample,
        cellBuilder: (r) => _textCell(r.typeOfSample),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'samplingDate',
        label: 'Sampling Date',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.samplingDate.millisecondsSinceEpoch,
        cellBuilder: (r) =>
            _textCell(SupervisorCommentsRow.formatYmd(r.samplingDate)),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'lotNo',
        label: 'Lot No.',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.lotNo.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.lotNo,
        cellBuilder: (r) => _textCell(r.lotNo),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'labId',
        label: 'Lab Id',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.labId.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => '${r.labId} HMR: ${_numStr(r.hmr)}',
        headerMaxLines: 2,
        cellBuilder: (r) => supervisorReviewLabIdCell(
          labId: r.labId,
          hmr: r.hmr,
        ),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'labDate',
        label: 'Lab Date',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.labDate.millisecondsSinceEpoch,
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => SupervisorCommentsRow.formatYmd(r.labDate),
        cellBuilder: (r) =>
            _textCell(SupervisorCommentsRow.formatYmd(r.labDate)),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'zone',
        label: 'Zone',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.zone.toLowerCase(),
        filter: AppColumnFilter(
          type: AppColumnFilterType.select,
          options: zoneItems,
        ),
        filterSelectValue: (r) => r.zone,
        cellBuilder: (r) => _textCell(r.zone),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'fluid',
        label: 'Fluid',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.fluid.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.fluid,
        cellBuilder: (r) => _textCell(r.fluid),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'lubeHrs',
        label: 'Lube Hrs',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.lubeHrs,
        cellBuilder: (r) => _textCell(_numStr(r.lubeHrs)),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'topUpVolume',
        label: 'Top Up Volume',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.topUpVolume,
        cellBuilder: (r) => _textCell(_numStr(r.topUpVolume)),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'dtOfReceipt',
        label: 'Dt of Receipt',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.dtOfReceipt.millisecondsSinceEpoch,
        cellBuilder: (r) =>
            _textCell(SupervisorCommentsRow.formatYmd(r.dtOfReceipt)),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'sampleId',
        label: 'Sample Id',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.sampleId.toLowerCase(),
        cellBuilder: (r) => _textCell(r.sampleId),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'make',
        label: 'Make',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.make.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.make,
        cellBuilder: (r) => _textCell(r.make),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'model',
        label: 'Model',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.model.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.model,
        cellBuilder: (r) => _textCell(r.model),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'serialNo',
        label: 'Serial No.',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.serialNo.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.serialNo,
        cellBuilder: (r) => _textCell(r.serialNo),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'oilBrand',
        label: 'Oil Brand',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.oilBrand.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.oilBrand,
        cellBuilder: (r) => _textCell(r.oilBrand),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'oilGrade',
        label: 'Oil Grade',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.oilGrade.toLowerCase(),
        cellBuilder: (r) => _textCell(r.oilGrade),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'samplingPoint',
        label: 'Sampling Point',
        width: _kCol,
        sortable: true,
        sortValue: (r) => r.samplingPoint.toLowerCase(),
        cellBuilder: (r) => _textCell(r.samplingPoint),
      ),
      TableColumn<SupervisorCommentsRow>(
        key: 'customerNote',
        label: 'Customer Note',
        width: _kCol,
        sortable: false,
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.customerNote,
        cellBuilder: (r) => _textCell(r.customerNote),
      ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<SupervisorCommentsRow>(
        showPageHeader: widget.showPageHeader,
        title: 'Supervisor Comments',
        subtitle:
            'Review and complete supervisor comments on sample rows post-verification.',
        showKpis: false,
        showExport: false,
        showTableHorizontalScrollbar: true,
        tableBodyFillsViewport: true,
        tableRowHeight: _kListingRowHeight,
        tableHeaderHeight: 40,
        tableScrollableMinWidth: _kCol * columns.length + 480,
        tabs: [
          TabConfig(label: 'Pending', count: p.pendingCount),
          TabConfig(label: 'Completed', count: p.completedCount),
        ],
        initialTabIndex: p.tabIndex,
        onTabChanged: p.setTabByIndex,
        searchHint:
            'Search company, site, lot, lab id, sample id, make, model…',
        onSearch: p.setSearchQuery,
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        onBulkDelete: p.bulkDeleteItems,
        columns: columns,
        rows: p.pagedRows,
        onRowTap: (r) => _openDetail(context, r),
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
          RowAction<SupervisorCommentsRow>(
            key: 'review',
            label: 'Review',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (r) => _openDetail(context, r),
          ),
        ],
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No supervisor comment records found',
      ),
    );
  }
}
