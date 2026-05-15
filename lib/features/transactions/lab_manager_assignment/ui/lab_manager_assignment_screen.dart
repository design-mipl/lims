import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/form_read_only_field.dart';
import '../data/lab_manager_assignment_model.dart';
import '../data/lab_manager_assignment_test_columns.dart';
import '../state/lab_manager_assignment_provider.dart';

class LabManagerAssignmentScreen extends StatefulWidget {
  const LabManagerAssignmentScreen({super.key});

  @override
  State<LabManagerAssignmentScreen> createState() =>
      _LabManagerAssignmentScreenState();
}

class _LabManagerAssignmentScreenState extends State<LabManagerAssignmentScreen> {
  final _labNoCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  LabManagerAssignmentProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = context.read<LabManagerAssignmentProvider>();
      _provider = p;
      p.addListener(_onProvider);
    });
  }

  void _onProvider() {
    final p = _provider;
    if (p == null || !mounted) return;
    final fd = _formatDate(p.fromDate);
    final td = _formatDate(p.toDate);
    if (_fromCtrl.text != fd) {
      _fromCtrl.text = fd;
    }
    if (_toCtrl.text != td) {
      _toCtrl.text = td;
    }
    if (p.labNoQuery != _labNoCtrl.text) {
      _labNoCtrl.text = p.labNoQuery;
      _labNoCtrl.selection = TextSelection.collapsed(offset: _labNoCtrl.text.length);
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProvider);
    _labNoCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  Future<void> _pickDate(
    BuildContext context, {
    required bool isFrom,
  }) async {
    final p = context.read<LabManagerAssignmentProvider>();
    final initial = isFrom ? p.fromDate : p.toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !context.mounted) return;
    if (isFrom) {
      p.setFromDate(picked);
      _fromCtrl.text = _formatDate(picked);
    } else {
      p.setToDate(picked);
      _toCtrl.text = _formatDate(picked);
    }
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  Future<void> _saveAssignmentForRows(
    BuildContext context,
    List<LabManagerAssignmentRow> rows,
  ) async {
    final p = context.read<LabManagerAssignmentProvider>();
    p.saveAssignmentForRowIds(rows.map((r) => r.id).toList());
    if (!context.mounted) return;
    if (p.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            p.error ?? 'Error',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      p.clearError();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Assignment saved',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.primary800,
        ),
      );
    }
  }

  void _bulkPrintSnack(
    BuildContext context,
    List<LabManagerAssignmentRow> rows,
    String kind,
  ) {
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

  void _bulkReset(
    BuildContext context,
    LabManagerAssignmentProvider p,
    List<LabManagerAssignmentRow> rows,
  ) {
    if (rows.isEmpty) return;
    if (p.isAssignedTab) {
      _stubSnack(context, 'Reset tests on Pending rows only');
      return;
    }
    p.clearTestSelectionsForRows(rows.map((r) => r.id).toList());
  }

  void _bulkDelete(
    BuildContext context,
    LabManagerAssignmentProvider p,
    List<LabManagerAssignmentRow> rows,
  ) {
    if (rows.isEmpty) return;
    if (!p.isAssignedTab) {
      _stubSnack(context, 'Delete assignment on Assigned tab only');
      return;
    }
    _confirmDeleteAssignments(context, p, rows);
  }

  double _tableMinWidth() {
    const idx = 48.0;
    const date = 104.0;
    const lab = 108.0;
    const assigned = 128.0;
    const status = 112.0;
    final n = kLabManagerAssignmentTestColumns.length;
    return idx +
        date +
        lab +
        kLabManagerAssignmentTestColumnWidth * n +
        assigned +
        status;
  }

  List<TableColumn<LabManagerAssignmentRow>> _buildColumns(
    LabManagerAssignmentProvider p,
    List<LabManagerAssignmentRow> paged,
  ) {
    final readOnly = p.isAssignedTab || p.isLoading;
    final base = (p.effectiveCurrentPage - 1) * p.pageSize;

    TextStyle cellStyle() => GoogleFonts.poppins(
          fontSize: AppTokens.tableCellSize,
          fontWeight: AppTokens.weightMedium,
          color: AppTokens.textPrimary,
          decoration: TextDecoration.none,
        );

    Widget cellText(String t, {TextAlign align = TextAlign.start}) => Text(
          t,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: cellStyle(),
        );

    final cols = <TableColumn<LabManagerAssignmentRow>>[
      TableColumn<LabManagerAssignmentRow>(
        key: 'row_num',
        label: '#',
        width: 48,
        sortable: false,
        numeric: true,
        cellBuilder: (r) {
          final i = paged.indexWhere((x) => x.id == r.id);
          final n = i >= 0 ? base + i + 1 : 0;
          return cellText('$n', align: TextAlign.end);
        },
      ),
      TableColumn<LabManagerAssignmentRow>(
        key: 'date',
        label: 'Date',
        width: 104,
        sortValue: (r) => r.sampleDate.millisecondsSinceEpoch,
        cellBuilder: (r) => cellText(_formatDate(r.sampleDate)),
      ),
      TableColumn<LabManagerAssignmentRow>(
        key: 'lab',
        label: 'Lab Id',
        width: 108,
        sortValue: (r) => r.labId.toLowerCase(),
        cellBuilder: (r) => cellText(r.labId),
      ),
    ];

    for (final colDef in kLabManagerAssignmentTestColumns) {
      final tkey = colDef.key;
      cols.add(
        TableColumn<LabManagerAssignmentRow>(
          key: 'test_$tkey',
          label: colDef.label,
          width: kLabManagerAssignmentTestColumnWidth,
          sortable: false,
          headerMaxLines: kLabManagerAssignmentTestHeaderMaxLines,
          cellBuilder: (r) {
            final v = r.testSelections[tkey] ?? false;
            return Center(
              child: SizedBox(
                height: AppTokens.inputHeight,
                child: Center(
                  child: Checkbox(
                    value: v,
                    onChanged: readOnly || r.isAssigned
                        ? null
                        : (_) => p.toggleTestForRow(r.id, tkey),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    cols.add(
      TableColumn<LabManagerAssignmentRow>(
        key: 'assigned',
        label: 'Assigned to',
        width: 128,
        sortable: false,
        cellBuilder: (r) {
          if (r.assignedToName == null || r.assignedToName!.isEmpty) {
            return Text(
              '—',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.tableCellSize,
                color: AppTokens.textMuted,
              ),
            );
          }
          return cellText(r.assignedToName!);
        },
      ),
    );

    cols.add(
      TableColumn<LabManagerAssignmentRow>(
        key: 'status',
        label: 'Status',
        width: 112,
        sortable: false,
        cellBuilder: (r) => Align(
          alignment: Alignment.centerLeft,
          child: StatusChip(
            status: r.isAssigned ? 'completed' : 'pending',
            customLabel: r.isAssigned ? 'Assigned' : 'Pending',
          ),
        ),
      ),
    );

    return cols;
  }

  Widget _filtersCard(BuildContext context, LabManagerAssignmentProvider p) {
    final methodSelect = AppSelect<String?>(
      label: 'Method',
      hint: 'Select method',
      isRequired: true,
      isSearchable: false,
      value: p.selectedMethodId,
      items: [
        const AppSelectItem<String?>(value: null, label: 'Select method'),
        ...LabManagerAssignmentProvider.kMethods.map(
          (m) => AppSelectItem<String?>(value: m.id, label: m.label),
        ),
      ],
      onChanged: (v) => p.setSelectedMethod(v),
    );
    final userSelect = AppSelect<String?>(
      label: 'Assign user',
      hint: 'Select chemist',
      value: p.assignUserId,
      items: [
        const AppSelectItem<String?>(value: null, label: 'Select chemist'),
        ...LabManagerAssignmentProvider.kChemists.map(
          (c) => AppSelectItem<String?>(value: c.id, label: c.name),
        ),
      ],
      onChanged: p.setAssignUserId,
    );
    final fromField = AppInput(
      label: 'From date',
      hint: 'DD/MM/YYYY',
      controller: _fromCtrl,
      readOnly: true,
      onTap: () => _pickDate(context, isFrom: true),
      suffixIcon: const Icon(LucideIcons.calendar),
    );
    final toField = AppInput(
      label: 'To date',
      hint: 'DD/MM/YYYY',
      controller: _toCtrl,
      readOnly: true,
      onTap: () => _pickDate(context, isFrom: false),
      suffixIcon: const Icon(LucideIcons.calendar),
    );
    final labField = AppInput(
      label: 'Lab No.',
      hint: 'Filter by lab id',
      controller: _labNoCtrl,
      onChanged: p.setLabNoQuery,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
        border: Border.all(
          color: AppTokens.borderDefault,
          width: AppTokens.borderWidthSm,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, c) {
                const minField = 152.0;
                const count = 5;
                final rowMin = minField * count;
                final w = math.max(c.maxWidth, rowMin);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: methodSelect),
                        SizedBox(width: AppTokens.space2),
                        Expanded(child: userSelect),
                        SizedBox(width: AppTokens.space2),
                        Expanded(child: fromField),
                        SizedBox(width: AppTokens.space2),
                        Expanded(child: toField),
                        SizedBox(width: AppTokens.space2),
                        Expanded(child: labField),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LabManagerAssignmentProvider>();

    final rows = p.selectedMethodId == null
        ? const <LabManagerAssignmentRow>[]
        : p.pagedRows;
    final emptyWidget = p.selectedMethodId == null
        ? Center(
            child: Padding(
              padding: EdgeInsets.all(AppTokens.space8),
              child: Text(
                'Select a method to load tests',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textSecondary,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          )
        : null;

    return Material(
      type: MaterialType.transparency,
      child: AppFormPage(
        title: 'Lab Manager Assignment',
        subtitle: 'Assign tests to chemists based on selected methods',
        scrollBody: false,
        fullWidthBody: true,
        onBack: () => _back(context),
        actions: null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: double.infinity, child: _filtersCard(context, p)),
            SizedBox(height: AppTokens.space3),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: AppListingScreen<LabManagerAssignmentRow>(
                key: ValueKey<int>(p.tableRevision),
                title: 'Tests',
                subtitle: 'Assignment listing',
                showPageHeader: false,
                showKpis: false,
                showToolbar: false,
                showBulkBar: true,
                showSearch: false,
                showColumnToggle: false,
                showTableHorizontalScrollbar: true,
                tableBodyFillsViewport: true,
                tableHeaderHeight: kLabManagerAssignmentTableHeaderHeight,
                listingShellPadding:
                    const EdgeInsets.only(bottom: AppTokens.space4),
                tableScrollableMinWidth: _tableMinWidth(),
                columns: _buildColumns(p, rows),
                rows: rows,
                mobileCardBuilder: (r) => _MobileAssignmentCard(
                  row: r,
                  testColumns: kLabManagerAssignmentTestColumns,
                  readOnly: p.isAssignedTab || p.isLoading,
                  onToggleTest: p.toggleTestForRow,
                ),
                isLoading: p.isLoading,
                emptyMessage: 'No records for current filters',
                emptyWidget: emptyWidget,
                tabs: [
                  TabConfig(label: 'Pending', count: p.pendingCount),
                  TabConfig(label: 'Assigned', count: p.assignedCount),
                ],
                initialTabIndex: p.assignmentTabIndex,
                onTabChanged: p.setAssignmentTabIndex,
                showCheckboxes: true,
                bulkRowId: (r) => r.id,
                bulkActions: [
                  BulkAction<LabManagerAssignmentRow>(
                    key: 'reset',
                    label: 'Reset',
                    icon: Icon(
                      LucideIcons.rotateCw,
                      size: AppTokens.iconButtonIconSm,
                    ),
                    onTap: (sel) => _bulkReset(context, p, sel),
                  ),
                  BulkAction<LabManagerAssignmentRow>(
                    key: 'save',
                    label: 'Save',
                    icon: Icon(
                      LucideIcons.save,
                      size: AppTokens.iconButtonIconSm,
                    ),
                    onTap: (sel) => _saveAssignmentForRows(context, sel),
                  ),
                  BulkAction<LabManagerAssignmentRow>(
                    key: 'delete',
                    label: 'Delete',
                    icon: Icon(
                      LucideIcons.trash2,
                      size: AppTokens.iconButtonIconSm,
                    ),
                    isDanger: true,
                    onTap: (sel) => _bulkDelete(context, p, sel),
                  ),
                  BulkAction<LabManagerAssignmentRow>(
                    key: 'print',
                    label: 'Print',
                    icon: Icon(
                      LucideIcons.printer,
                      size: AppTokens.iconButtonIconSm,
                    ),
                    onTap: (sel) => _bulkPrintSnack(context, sel, 'Print'),
                  ),
                ],
                rowActions: [
                  RowAction<LabManagerAssignmentRow>(
                    key: 'view',
                    label: 'View',
                    icon: Icon(LucideIcons.eye, size: AppTokens.iconButtonIconMd),
                    onTap: (r) => _showAssignmentRowDetails(context, r),
                  ),
                  RowAction<LabManagerAssignmentRow>(
                    key: 'edit',
                    label: 'Edit',
                    icon:
                        Icon(LucideIcons.pencil, size: AppTokens.iconButtonIconMd),
                    onTap: (r) {
                      context
                          .read<LabManagerAssignmentProvider>()
                          .focusRowInWorkspace(r);
                      if (!context.mounted) return;
                      _stubSnack(
                        context,
                        r.isAssigned
                            ? 'Review ${r.labId} on Assigned tab. Delete assignment to return to Pending before changing tests.'
                            : 'Filters set to ${r.labId}. Select tests, choose chemist, then bulk **Save**.',
                      );
                    },
                  ),
                  RowAction<LabManagerAssignmentRow>(
                    key: 'print',
                    label: 'Print',
                    icon:
                        Icon(LucideIcons.printer, size: AppTokens.iconButtonIconMd),
                    onTap: (r) =>
                        _stubSnack(context, 'Print ${r.labId} — coming soon'),
                  ),
                ],
                totalCount:
                    p.selectedMethodId == null ? 0 : p.filteredRows.length,
                currentPage: p.effectiveCurrentPage,
                pageSize: p.pageSize,
                onPageChanged: p.setPage,
                onPageSizeChanged: p.setPageSize,
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignmentRowDetails(
    BuildContext context,
    LabManagerAssignmentRow row,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppTokens.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppTokens.space4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    row.labId,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textLg,
                      fontWeight: AppTokens.weightSemibold,
                      color: AppTokens.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: AppTokens.space3),
                  FormReadOnlyField(
                    label: 'Sample date',
                    value: _formatDate(row.sampleDate),
                  ),
                  FormReadOnlyField(label: 'Sample ID', value: row.sampleId),
                  FormReadOnlyField(label: 'Customer', value: row.customer),
                  FormReadOnlyField(label: 'Equipment', value: row.equipment),
                  FormReadOnlyField(label: 'Method', value: row.methodLabel),
                  FormReadOnlyField(
                    label: 'Assigned to',
                    value: row.assignedToName ?? '—',
                  ),
                  FormReadOnlyField(
                    label: 'Status',
                    value: row.isAssigned ? 'Assigned' : 'Pending',
                  ),
                  SizedBox(height: AppTokens.space3),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: 'Close',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.md,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAssignments(
    BuildContext context,
    LabManagerAssignmentProvider p,
    List<LabManagerAssignmentRow> rows,
  ) async {
    final ok = await AppConfirmDialog.show(
      context: context,
      title: 'Delete assignment',
      message:
          'Remove assignment for ${rows.length} row(s) and return them to Pending?',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (ok == true && context.mounted) {
      p.deleteAssignmentsForRows(rows);
    }
  }

  void _stubSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }
}

class _MobileAssignmentCard extends StatelessWidget {
  const _MobileAssignmentCard({
    required this.row,
    required this.testColumns,
    required this.readOnly,
    required this.onToggleTest,
  });

  final LabManagerAssignmentRow row;
  final List<LabAssignmentTestColumn> testColumns;
  final bool readOnly;
  final void Function(String rowId, String testKey) onToggleTest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.labId,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              fontWeight: AppTokens.weightSemibold,
              color: AppTokens.textPrimary,
            ),
          ),
          SizedBox(height: AppTokens.space1),
          Text(
            row.sampleId,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.captionSize,
              color: AppTokens.textSecondary,
            ),
          ),
          SizedBox(height: AppTokens.space2),
          StatusChip(
            status: row.isAssigned ? 'completed' : 'pending',
            customLabel: row.isAssigned ? 'Assigned' : 'Pending',
          ),
          if (row.assignedToName != null) ...[
            SizedBox(height: AppTokens.space2),
            Text(
              'Assigned to: ${row.assignedToName}',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textPrimary,
              ),
            ),
          ],
          SizedBox(height: AppTokens.space2),
          Wrap(
            spacing: AppTokens.space2,
            runSpacing: AppTokens.space2,
            children: [
              for (final col in testColumns)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: row.testSelections[col.key] ?? false,
                      onChanged: readOnly || row.isAssigned
                          ? null
                          : (_) => onToggleTest(row.id, col.key),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      col.label,
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.captionSize,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
