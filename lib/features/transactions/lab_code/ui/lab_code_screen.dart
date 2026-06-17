import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/print/lab_sample_label_data.dart';
import '../../shared/print/lab_sample_label_print.dart';
import '../data/lab_code_model.dart';
import '../state/lab_code_provider.dart';
class LabCodeScreen extends StatefulWidget {
  const LabCodeScreen({super.key});

  @override
  State<LabCodeScreen> createState() => _LabCodeScreenState();
}

class _LabCodeScreenState extends State<LabCodeScreen> {
  LabCodeProvider? _provider;
  final Set<String> _selectedLabIdRowIds = <String>{};

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

  void _onLabIdSelectionChanged(LabCodeProvider p, Set<int> indices) {
    final rows = p.pagedRows;
    setState(() {
      _selectedLabIdRowIds
        ..clear()
        ..addAll(
          indices
              .where((i) => i >= 0 && i < rows.length)
              .map((i) => rows[i].id),
        );
    });
  }

  List<LabCodeModel> _selectedLabIdRows(LabCodeProvider p) {
    final ids = _selectedLabIdRowIds;
    if (ids.isEmpty) return const [];
    return p.filteredItems.where((r) => ids.contains(r.id)).toList();
  }

  bool _canPrintLabels(LabCodeProvider p) {
    if (_selectedLabIdRowIds.isEmpty) return false;
    return _selectedLabIdRows(p).every(
      (r) => r.labCode != null && r.labCode!.trim().isNotEmpty,
    );
  }

  Future<void> _printLabels(BuildContext context, LabCodeProvider p) async {
    final rows = _selectedLabIdRows(p);
    if (rows.isEmpty) return;

    final missingCode = rows.any(
      (r) => r.labCode == null || r.labCode!.trim().isEmpty,
    );
    if (missingCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selected rows must have a lab code before printing labels.',
            style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      return;
    }

    final labels =
        rows.map(LabSampleLabelData.fromLabCode).toList(growable: false);
    final ok = await printLabSampleLabels(context, labels);
    if (!ok || !context.mounted) return;

    await p.printLabelsForRows(rows);
    if (!context.mounted) return;

    setState(_selectedLabIdRowIds.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${rows.length} label(s) sent to print. Records moved out of Lab ID queue.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  List<Widget>? _labIdToolbarTrailing(
    BuildContext context,
    LabCodeProvider p,
  ) {
    if (!p.isLabIdTabSelected) return null;
    return [
      AppButton(
        label: 'Print labels',
        variant: AppButtonVariant.primary,
        size: AppButtonSize.sm,
        leadingIcon: Icon(
          LucideIcons.tags,
          size: AppTokens.iconButtonIconSm,
          color: AppTokens.white,
        ),
        onPressed:
            !_canPrintLabels(p) ? null : () => _printLabels(context, p),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LabCodeProvider>();

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<LabCodeModel>(
        key: ValueKey('lab-code-${p.listingResetKey}-${p.statusTabIndex}'),
        title: 'Lab Code',
        subtitle:
            'Stage after Sample Data Entry → Generate Lab Code; before Lab Manager Assignment.',
        tableScrollableMinWidth: _kListingColWidth * 5,
        showTableHorizontalScrollbar: true,
        showCheckboxes: true,
        bulkRowId: (r) => r.id,
        onBulkDelete: p.isLabIdTabSelected ? null : (ids) => p.bulkDeleteItems(ids),
        showBulkBar: !p.isLabIdTabSelected,
        onRowSelectionChanged: p.isLabIdTabSelected
            ? (indices) => _onLabIdSelectionChanged(p, indices)
            : null,
        toolbarTrailingActions: _labIdToolbarTrailing(context, p),
        showKpis: false,
        exportModuleName: 'Lab_Code',
        exportSourceRows: p.filteredItems,
        tabs: [
          TabConfig(
            label: 'Pending',
            count: p.countForStatus(LabCodeStatus.pending),
          ),
          TabConfig(
            label: 'Lab ID',
            count: p.countForStatus(LabCodeStatus.completed),
          ),
        ],
        initialTabIndex: p.statusTabIndex,
        onTabChanged: (index) {
          setState(_selectedLabIdRowIds.clear);
          p.setStatusFilterByTab(index);
        },
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
                SizedBox(width: AppTokens.space2),
                Tooltip(
                  message: 'Refresh',
                  child: IconButton(
                    onPressed: p.isLoading ? null : () => p.refresh(),
                    icon: Icon(
                      LucideIcons.refreshCw,
                      size: AppTokens.iconButtonIconMd,
                    ),
                  ),
                ),
              ]
            : [
                Tooltip(
                  message: 'Refresh',
                  child: IconButton(
                    onPressed: p.isLoading ? null : () => p.refresh(),
                    icon: Icon(
                      LucideIcons.refreshCw,
                      size: AppTokens.iconButtonIconMd,
                    ),
                  ),
                ),
              ],
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
