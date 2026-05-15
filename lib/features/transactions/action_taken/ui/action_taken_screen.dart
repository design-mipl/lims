import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/action_taken_model.dart';
import '../state/action_taken_provider.dart';

/// Action Taken — transaction listing with toolbar filters and Pending/Completed tabs.
class ActionTakenScreen extends StatefulWidget {
  const ActionTakenScreen({super.key});

  @override
  State<ActionTakenScreen> createState() => _ActionTakenScreenState();
}

class _ActionTakenScreenState extends State<ActionTakenScreen> {
  ActionTakenProvider? _provider;

  static const double _kColW = 220;
  static const int _kCols = 11;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<ActionTakenProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<ActionTakenProvider>().loadItems();
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

  static String _formatYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _severityLabel(ActionTakenRowSeverity s) {
    return switch (s) {
      ActionTakenRowSeverity.critical => 'Critical',
      ActionTakenRowSeverity.cautions => 'Cautions',
      ActionTakenRowSeverity.normal => 'Normal',
    };
  }

  static String _statusLabel(ActionTakenStatus s) {
    return switch (s) {
      ActionTakenStatus.pending => 'Pending',
      ActionTakenStatus.completed => 'Completed',
    };
  }

  Color? _rowTint(ActionTakenRow r) {
    return switch (r.severity) {
      ActionTakenRowSeverity.normal => null,
      ActionTakenRowSeverity.critical => AppTokens.error50,
      ActionTakenRowSeverity.cautions => AppTokens.warning50,
    };
  }

  Widget _cell(String text, {FontWeight weight = AppTokens.weightRegular}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        fontWeight: weight,
        color: AppTokens.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ActionTakenProvider>();
    final rows = p.pagedRows;

    final severityItems = <AppSelectItem<ActionTakenSeverityFilter>>[
      const AppSelectItem<ActionTakenSeverityFilter>(
        value: ActionTakenSeverityFilter.all,
        label: 'All severities',
      ),
      const AppSelectItem<ActionTakenSeverityFilter>(
        value: ActionTakenSeverityFilter.critical,
        label: 'Critical',
      ),
      const AppSelectItem<ActionTakenSeverityFilter>(
        value: ActionTakenSeverityFilter.cautions,
        label: 'Cautions',
      ),
      const AppSelectItem<ActionTakenSeverityFilter>(
        value: ActionTakenSeverityFilter.normal,
        label: 'Normal',
      ),
    ];

    final columns = <TableColumn<ActionTakenRow>>[
      TableColumn<ActionTakenRow>(
        key: 'companyName',
        label: 'Company Name',
        width: _kColW,
        sortable: true,
        sortValue: (r) => r.companyName.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.companyName,
        cellBuilder: (r) => _cell(r.companyName),
      ),
      TableColumn<ActionTakenRow>(
        key: 'siteContactPerson',
        label: 'Site Contact Person',
        width: _kColW,
        sortable: true,
        sortValue: (r) => r.siteContactPerson.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.siteContactPerson,
        cellBuilder: (r) => _cell(r.siteContactPerson),
      ),
      TableColumn<ActionTakenRow>(
        key: 'siteName',
        label: 'Site Name',
        width: _kColW,
        sortable: true,
        sortValue: (r) => r.siteName.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.siteName,
        cellBuilder: (r) => _cell(r.siteName),
      ),
      TableColumn<ActionTakenRow>(
        key: 'labId',
        label: 'Lab Id',
        width: _kColW,
        sortable: true,
        sortValue: (r) => r.labId.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.labId,
        cellBuilder: (r) =>
            _cell(r.labId, weight: AppTokens.weightMedium),
      ),
      TableColumn<ActionTakenRow>(
        key: 'typeOfSample',
        label: 'Type of Sample',
        width: _kColW,
        sortable: true,
        sortValue: (r) => r.typeOfSample.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.typeOfSample,
        cellBuilder: (r) => _cell(r.typeOfSample),
      ),
      TableColumn<ActionTakenRow>(
        key: 'samplingDate',
        label: 'Sampling Date',
        width: _kColW,
        sortable: true,
        sortValue: (r) => r.samplingDate.millisecondsSinceEpoch,
        cellBuilder: (r) => _cell(_formatYmd(r.samplingDate)),
      ),
      TableColumn<ActionTakenRow>(
        key: 'equipmentIdNo',
        label: 'Equipment Id No',
        width: _kColW,
        sortable: true,
        sortValue: (r) => r.equipmentIdNo.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.equipmentIdNo,
        cellBuilder: (r) => _cell(r.equipmentIdNo),
      ),
      TableColumn<ActionTakenRow>(
        key: 'sampleId',
        label: 'Sample Id',
        width: _kColW,
        sortable: true,
        sortValue: (r) => r.sampleId.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.sampleId,
        cellBuilder: (r) =>
            _cell(r.sampleId, weight: AppTokens.weightMedium),
      ),
      TableColumn<ActionTakenRow>(
        key: 'make',
        label: 'Make',
        width: _kColW,
        sortable: true,
        sortValue: (r) => r.make.toLowerCase(),
        filter: const AppColumnFilter(type: AppColumnFilterType.text),
        filterTextValue: (r) => r.make,
        cellBuilder: (r) => _cell(r.make),
      ),
      TableColumn<ActionTakenRow>(
        key: 'severity',
        label: 'Severity',
        width: _kColW,
        sortable: true,
        sortValue: (r) => _severityLabel(r.severity).toLowerCase(),
        cellBuilder: (r) => _cell(_severityLabel(r.severity)),
      ),
      TableColumn<ActionTakenRow>(
        key: 'status',
        label: 'Status',
        width: _kColW,
        sortable: true,
        sortValue: (r) => _statusLabel(r.status).toLowerCase(),
        cellBuilder: (r) => _cell(_statusLabel(r.status)),
      ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: AppListingScreen<ActionTakenRow>(
        title: 'Action Taken',
        subtitle:
            'Post-report actions and corrective follow-ups after laboratory release.',
        showKpis: false,
        showExport: false,
        showBulkBar: false,
        showCheckboxes: false,
        showTableHorizontalScrollbar: true,
        showActionsColumnLeadingBorder: false,
        tableBodyFillsViewport: true,
        tableScrollableMinWidth: _kColW * _kCols + AppTokens.space4,
        rowBackgroundColor: _rowTint,
        onRowTap: (r) =>
            context.push('/transactions/action-taken/${r.id}/workspace'),
        tabs: [
          TabConfig(
            label: 'Pending',
            count: p.countForStatus(ActionTakenStatus.pending),
          ),
          TabConfig(
            label: 'Completed',
            count: p.countForStatus(ActionTakenStatus.completed),
          ),
        ],
        initialTabIndex: p.statusTabIndex,
        onTabChanged: p.setTabByIndex,
        searchHint: 'Search / Lab Id…',
        onSearch: p.setSearchQuery,
        toolbarAfterSearch: [
          SizedBox(width: AppTokens.space2),
          SizedBox(
            width: 152,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnchoredSearchableDropdownField<ActionTakenSeverityFilter>(
                hint: 'Severity',
                value: p.severityFilter,
                items: severityItems,
                onChanged: (v) {
                  if (v != null) p.setSeverityFilter(v);
                },
                size: AppInputSize.sm,
                overlayMinimalShadow: true,
              ),
            ),
          ),
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
        columns: columns,
        rows: rows,
        mobileCardBuilder: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.labId,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                fontWeight: AppTokens.weightSemibold,
                color: AppTokens.textPrimary,
              ),
            ),
            SizedBox(height: AppTokens.space1),
            Text(
              '${r.sampleId} · ${_severityLabel(r.severity)}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
        isLoading: p.isLoading,
        totalCount: p.filteredItems.length,
        currentPage: p.effectiveCurrentPage,
        pageSize: p.pageSize,
        onPageChanged: p.setPage,
        onPageSizeChanged: p.setPageSize,
        emptyMessage: 'No action records match the current filters',
      ),
    );
  }
}
