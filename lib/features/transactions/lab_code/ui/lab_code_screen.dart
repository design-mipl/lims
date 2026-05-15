import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/lab_code_model.dart';
import '../state/lab_code_provider.dart';

class LabCodeScreen extends StatefulWidget {
  const LabCodeScreen({super.key});

  @override
  State<LabCodeScreen> createState() => _LabCodeScreenState();
}

class _LabCodeScreenState extends State<LabCodeScreen> {
  LabCodeProvider? _provider;

  /// Uniform width for all Lab Code listing data columns (equal visual rhythm).
  static const double _kListingColWidth = 220;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<LabCodeProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<LabCodeProvider>().loadItems();
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

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Widget _labCodeUpdateColumnCell(LabCodeModel r) {
    final code = r.labCode;
    if (code == null || code.isEmpty) {
      return Text(
        '—',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: AppTokens.tableCellSize,
          color: AppTokens.textMuted,
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTokens.kpiTeal,
          borderRadius: BorderRadius.circular(AppTokens.chipRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space2,
            vertical: 2,
          ),
          child: Text(
            code,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.chipSize,
              fontWeight: AppTokens.chipWeight,
              color: AppTokens.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  void _primaryActionPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Create Lab Code — coming soon',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  void _bulkPrintSnack(BuildContext context, List<LabCodeModel> rows, String kind) {
    final n = rows.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$kind — $n row(s) (coming soon)',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LabCodeProvider>();

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<LabCodeModel>(
        title: 'Lab Code',
        subtitle:
            'Stage after Sample Data Entry → Generate Lab Code; before Lab Manager Assignment.',
        primaryActionLabel: 'Create Lab Code',
        onPrimaryAction: () => _primaryActionPlaceholder(context),
        tableScrollableMinWidth: _kListingColWidth * 5,
        showTableHorizontalScrollbar: true,
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        onBulkDelete: (ids) => p.bulkDeleteItems(ids),
        bulkActions: [
          BulkAction<LabCodeModel>(
            key: 'print',
            label: 'Reprint',
            icon: Icon(LucideIcons.printer, size: AppTokens.iconButtonIconSm),
            showOnlyWhenSelected: true,
            onTap: (rows) => _bulkPrintSnack(context, rows, 'Reprint'),
          ),
          BulkAction<LabCodeModel>(
            key: 'printLabels',
            label: 'Print Label',
            icon: Icon(LucideIcons.tags, size: AppTokens.iconButtonIconSm),
            showOnlyWhenSelected: true,
            onTap: (rows) => _bulkPrintSnack(context, rows, 'Print Label'),
          ),
        ],
        showKpis: false,
        showExport: false,
        tabs: [
          TabConfig(
            label: 'Pending List',
            count: p.countForStatus(LabCodeStatus.pending),
          ),
          TabConfig(
            label: 'Lab Id',
            count: p.countForStatus(LabCodeStatus.completed),
          ),
        ],
        initialTabIndex: p.statusTabIndex,
        onTabChanged: p.setStatusFilterByTab,
        toolbarAfterSearch: p.isLabIdTabSelected
            ? [
                LabCodeLabIdDateField(
                  hint: 'From Date',
                  selectedDate: p.labIdFromDate,
                  onDateSelected: p.setLabIdFromDate,
                ),
                SizedBox(width: AppTokens.space2),
                LabCodeLabIdDateField(
                  hint: 'To Date',
                  selectedDate: p.labIdToDate,
                  onDateSelected: p.setLabIdToDate,
                ),
              ]
            : null,
        searchHint: 'Search Sample Id',
        onSearch: p.setSearchQuery,
        onRowTap: (row) => context.push(
          '/transactions/lab-code/${row.id}/view',
        ),
        columns: [
          TableColumn<LabCodeModel>(
            key: 'recordedAt',
            label: 'Date',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.recordedAt.millisecondsSinceEpoch,
            cellBuilder: (r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDate(r.recordedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.tableCellSize,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.textPrimary,
                  ),
                ),
                Text(
                  _formatTime(r.recordedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.captionSize,
                    color: AppTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TableColumn<LabCodeModel>(
            key: 'sampleId',
            label: 'Sample Id',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.sampleId.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) =>
                '${r.sampleId} ${r.labCode ?? ''}'.trim(),
            cellBuilder: (r) => Text(
              r.sampleId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightMedium,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          TableColumn<LabCodeModel>(
            key: 'update',
            label: 'Lab Code',
            width: _kListingColWidth,
            sortable: false,
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.labCode ?? '',
            cellBuilder: _labCodeUpdateColumnCell,
          ),
          TableColumn<LabCodeModel>(
            key: 'customer',
            label: 'Customer',
            width: _kListingColWidth,
            sortable: true,
            sortValue: (r) => r.customerName.toLowerCase(),
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => '${r.customerName} ${r.customerCompany}',
            cellBuilder: (r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  r.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.tableCellSize,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.textPrimary,
                  ),
                ),
                Text(
                  r.customerCompany,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.captionSize,
                    color: AppTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TableColumn<LabCodeModel>(
            key: 'sampleType',
            label: 'Type Of Sample',
            width: _kListingColWidth,
            sortable: false,
            filter: const AppColumnFilter(type: AppColumnFilterType.text),
            filterTextValue: (r) => r.sampleType,
            cellBuilder: (r) => Text(
              r.sampleType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
        ],
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
            if (r.labCode != null && r.labCode!.isNotEmpty) ...[
              SizedBox(height: AppTokens.space1),
              _labCodeUpdateColumnCell(r),
            ],
            SizedBox(height: AppTokens.space1),
            Text(
              r.customerName,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        rowActions: [
          RowAction<LabCodeModel>(
            key: 'view',
            label: 'View',
            icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
            onTap: (row) => context.push(
              '/transactions/lab-code/${row.id}/view',
            ),
          ),
        ],
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No lab code records found',
      ),
    );
  }
}
