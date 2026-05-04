import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/customer_model.dart';
import '../../state/customer_provider.dart';

class SampleTypesTab extends StatefulWidget {
  const SampleTypesTab({super.key, required this.customerId});

  final String customerId;

  @override
  State<SampleTypesTab> createState() => _SampleTypesTabState();
}

class _SampleTypesTabState extends State<SampleTypesTab> {
  // Column widths — header and data cells use identical fixed widths (horizontal scroll).
  static const double _colIndex = 48;
  static const double _colSampleType = 180;
  static const double _colTest = 220;
  static const double _colLimit = 120;
  static const double _colHmrLower = 120;
  static const double _colHmrUpper = 120;
  static const double _colLowerMin = 120;
  static const double _colLowerMax = 120;
  static const double _colUpperMin = 120;
  static const double _colUpperMax = 120;
  static const double _colModel = 150;
  static const double _colBrand = 150;
  static const double _colFluid = 150;
  static const double _colRate = 100;

  static double get _tableMinWidth =>
      _colIndex +
      _colSampleType +
      _colTest +
      _colLimit +
      _colHmrLower +
      _colHmrUpper +
      _colLowerMin +
      _colLowerMax +
      _colUpperMin +
      _colUpperMax +
      _colModel +
      _colBrand +
      _colFluid +
      _colRate;

  final ScrollController _horizontalScrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  String? _editingRowId;
  SampleTypeRowModel? _editingDraft;
  int _currentPage = 1;
  final int _pageSize = 10;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _columnFilters = {};

  String? _sortColumn;
  bool _sortAsc = true;

  OverlayEntry? _columnFilterOverlay;
  TextEditingController? _columnFilterEditController;

  String _columnText(SampleTypeRowModel e, String key) {
    switch (key) {
      case 'sampleTypeName':
        return e.sampleTypeName;
      case 'testName':
        return e.testName;
      case 'limit':
        return e.limit ?? '';
      case 'hmrLower':
        return e.hmrLower ?? '';
      case 'hmrUpper':
        return e.hmrUpper ?? '';
      case 'lowerMinVal':
        return e.lowerMinVal ?? '';
      case 'lowerMaxVal':
        return e.lowerMaxVal ?? '';
      case 'upperMinVal':
        return e.upperMinVal ?? '';
      case 'upperMaxVal':
        return e.upperMaxVal ?? '';
      case 'modelName':
        return e.modelName ?? '';
      case 'brandName':
        return e.brandName ?? '';
      case 'fluidName':
        return e.fluidName ?? '';
      case 'rate':
        return e.rate?.toString() ?? '';
      default:
        return '';
    }
  }

  List<SampleTypeRowModel> _filteredFrom(List<SampleTypeRowModel> source) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return source.where((e) {
      if (q.isNotEmpty) {
        final hitsGlobal =
            e.sampleTypeName.toLowerCase().contains(q) ||
            e.testName.toLowerCase().contains(q) ||
            (e.modelName ?? '').toLowerCase().contains(q) ||
            (e.brandName ?? '').toLowerCase().contains(q) ||
            (e.fluidName ?? '').toLowerCase().contains(q);
        if (!hitsGlobal) return false;
      }
      for (final entry in _columnFilters.entries) {
        final fq = entry.value.trim().toLowerCase();
        if (fq.isEmpty) continue;
        if (!_columnText(e, entry.key).toLowerCase().contains(fq)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int _compareSort(SampleTypeRowModel a, SampleTypeRowModel b, String column) {
    if (column == '#') {
      return a.id.compareTo(b.id);
    }
    if (column == 'rate') {
      final da = double.tryParse(_columnText(a, 'rate'));
      final db = double.tryParse(_columnText(b, 'rate'));
      if (da == null && db == null) return 0;
      if (da == null) return -1;
      if (db == null) return 1;
      return da.compareTo(db);
    }
    final sa = _columnText(a, column).toLowerCase();
    final sb = _columnText(b, column).toLowerCase();
    return sa.compareTo(sb);
  }

  List<SampleTypeRowModel> _sortedFrom(List<SampleTypeRowModel> filtered) {
    if (_sortColumn == null) return filtered;
    final list = List<SampleTypeRowModel>.from(filtered);
    final col = _sortColumn!;
    list.sort((a, b) {
      final c = _compareSort(a, b, col);
      return _sortAsc ? c : -c;
    });
    return list;
  }

  void _onSortTap(String columnKey) {
    setState(() {
      if (_sortColumn == columnKey) {
        if (_sortAsc) {
          _sortAsc = false;
        } else {
          _sortColumn = null;
          _sortAsc = true;
        }
      } else {
        _sortColumn = columnKey;
        _sortAsc = true;
      }
      _currentPage = 1;
    });
  }

  List<SampleTypeRowModel> _pagedSlice(List<SampleTypeRowModel> display) {
    final all = display;
    if (all.isEmpty) return const [];
    final last = ((all.length - 1) ~/ _pageSize) + 1;
    final page = _currentPage.clamp(1, last);
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  void _removeColumnFilterOverlay() {
    _columnFilterOverlay?.remove();
    _columnFilterOverlay = null;
    _columnFilterEditController?.dispose();
    _columnFilterEditController = null;
  }

  void _openColumnFilter(String columnKey, LayerLink link) {
    _removeColumnFilterOverlay();
    _columnFilterEditController = TextEditingController(
      text: _columnFilters[columnKey] ?? '',
    );
    final controller = _columnFilterEditController!;

    _columnFilterOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeColumnFilterOverlay,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: Offset(0, AppTokens.space4),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: AppTokens.elevationPopupMenu,
                  color: AppTokens.cardBg,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppTokens.columnFilterPopoverWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppTokens.space2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppInput(
                            hint: 'Filter…',
                            size: AppInputSize.sm,
                            controller: controller,
                          ),
                          SizedBox(height: AppTokens.space2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppIconButton(
                                icon: Icon(LucideIcons.x),
                                tooltip: 'Clear',
                                variant: AppIconButtonVariant.ghost,
                                onPressed: () {
                                  setState(() {
                                    _columnFilters.remove(columnKey);
                                    _currentPage = 1;
                                  });
                                  _removeColumnFilterOverlay();
                                },
                              ),
                              SizedBox(width: AppTokens.space2),
                              AppButton(
                                label: 'Apply',
                                size: AppButtonSize.sm,
                                variant: AppButtonVariant.primary,
                                onPressed: () {
                                  final text = controller.text.trim();
                                  setState(() {
                                    if (text.isEmpty) {
                                      _columnFilters.remove(columnKey);
                                    } else {
                                      _columnFilters[columnKey] = text;
                                    }
                                    _currentPage = 1;
                                  });
                                  _removeColumnFilterOverlay();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_columnFilterOverlay!);
  }

  @override
  void dispose() {
    _removeColumnFilterOverlay();
    _horizontalScrollCtrl.dispose();
    _searchCtrl.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String key, String value) {
    final existing = _controllers[key];
    if (existing != null) return existing;
    final c = TextEditingController(text: value);
    _controllers[key] = c;
    return c;
  }

  _CodeNameOption? _optionByCode(List<_CodeNameOption> options, String? code) {
    if (code == null || code.isEmpty) return null;
    for (final o in options) {
      if (o.code == code) return o;
    }
    return null;
  }

  Future<void> _saveAndClearEditing() async {
    final rowId = _editingRowId;
    if (rowId == null) return;
    await _saveRow(rowId);
    if (mounted) {
      setState(() {
        _editingRowId = null;
        _editingDraft = null;
      });
    }
  }

  Future<void> _saveRow(String rowId) async {
    final p = context.read<CustomerProvider>();
    final prefix = '$rowId:';
    final draft = (_editingRowId == rowId) ? _editingDraft : null;

    String? fieldText(String key) {
      final t = _controllers['$prefix$key']?.text.trim();
      if (t == null || t.isEmpty) return null;
      return t;
    }

    double? parseRate() {
      final val = _controllers['${prefix}rate']?.text.trim() ?? '';
      return val.isEmpty ? null : double.tryParse(val);
    }

    await p.updateSampleRow(widget.customerId, rowId, {
      'sampleTypeId': draft?.sampleTypeId,
      'sampleTypeName': draft?.sampleTypeName,
      'testId': draft?.testId,
      'testName': draft?.testName,
      'limit': fieldText('limit'),
      'hmrLower': fieldText('hmrLower'),
      'hmrUpper': fieldText('hmrUpper'),
      'lowerMinVal': fieldText('lowerMinVal'),
      'lowerMaxVal': fieldText('lowerMaxVal'),
      'upperMinVal': fieldText('upperMinVal'),
      'upperMaxVal': fieldText('upperMaxVal'),
      'modelId': draft?.modelId,
      'modelName': draft?.modelName,
      'brandId': draft?.brandId,
      'brandName': draft?.brandName,
      'fluidId': draft?.fluidId,
      'fluidName': draft?.fluidName,
      'rate': parseRate(),
    });
  }

  Future<void> _onRowTap(SampleTypeRowModel row) async {
    final previous = _editingRowId;
    if (previous != null && previous != row.id) {
      await _saveRow(previous);
    }
    if (!mounted) return;
    setState(() {
      _editingRowId = row.id;
      _editingDraft = row;
    });
  }

  Future<void> _showAddModal() async {
    final limitCtrl = TextEditingController();
    final hmrLowerCtrl = TextEditingController();
    final hmrUpperCtrl = TextEditingController();
    final lowerMinCtrl = TextEditingController();
    final lowerMaxCtrl = TextEditingController();
    final upperMinCtrl = TextEditingController();
    final upperMaxCtrl = TextEditingController();
    final rateCtrl = TextEditingController();

    final provider = context.read<CustomerProvider>();
    String? selectedSampleTypeCode;
    String? selectedTestCode;
    String? selectedModelCode;
    String? selectedBrandCode;
    String? selectedFluidCode;
    await AppFormModal.show(
      context: context,
      title: 'Sample Details',
      body: StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          children: [
            AppFormSection(
              title: 'Details',
              children: [
                AppSelect<String>(
                  label: 'Type of Sample',
                  hint: 'Search and select',
                  size: AppInputSize.sm,
                  isRequired: true,
                  countLabel: 'sample types',
                  value: selectedSampleTypeCode,
                  items: _sampleTypeOptions
                      .map(
                        (item) => AppSelectItem<String>(
                          value: item.code,
                          code: item.code,
                          label: item.name,
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setModalState(() {
                    selectedSampleTypeCode = value;
                  }),
                ),
                AppSelect<String>(
                  label: 'Test',
                  hint: 'Search and select',
                  size: AppInputSize.sm,
                  isRequired: true,
                  countLabel: 'tests',
                  value: selectedTestCode,
                  items: _testOptions
                      .map(
                        (item) => AppSelectItem<String>(
                          value: item.code,
                          code: item.code,
                          label: item.name,
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setModalState(() {
                    selectedTestCode = value;
                  }),
                ),
                AppInput(
                  label: 'Limit',
                  hint: 'Enter limit',
                  controller: limitCtrl,
                ),
                AppInput(
                  label: 'HMR Lower',
                  hint: 'Enter lower',
                  controller: hmrLowerCtrl,
                ),
                AppInput(
                  label: 'HMR Upper',
                  hint: 'Enter upper',
                  controller: hmrUpperCtrl,
                ),
                AppInput(
                  label: 'Lower Min',
                  hint: 'Enter value',
                  controller: lowerMinCtrl,
                ),
                AppInput(
                  label: 'Lower Max',
                  hint: 'Enter value',
                  controller: lowerMaxCtrl,
                ),
                AppInput(
                  label: 'Upper Min',
                  hint: 'Enter value',
                  controller: upperMinCtrl,
                ),
                AppInput(
                  label: 'Upper Max',
                  hint: 'Enter value',
                  controller: upperMaxCtrl,
                ),
                AppSelect<String>(
                  label: 'Model',
                  hint: 'Search and select',
                  size: AppInputSize.sm,
                  countLabel: 'models',
                  value: selectedModelCode,
                  items: _modelOptions
                      .map(
                        (item) => AppSelectItem<String>(
                          value: item.code,
                          code: item.code,
                          label: item.name,
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setModalState(() {
                    selectedModelCode = value;
                  }),
                ),
                AppSelect<String>(
                  label: 'Brand',
                  hint: 'Search and select',
                  size: AppInputSize.sm,
                  countLabel: 'brands',
                  value: selectedBrandCode,
                  items: _brandOptions
                      .map(
                        (item) => AppSelectItem<String>(
                          value: item.code,
                          code: item.code,
                          label: item.name,
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setModalState(() {
                    selectedBrandCode = value;
                  }),
                ),
                AppSelect<String>(
                  label: 'Fluid',
                  hint: 'Search and select',
                  size: AppInputSize.sm,
                  countLabel: 'fluids',
                  value: selectedFluidCode,
                  items: _fluidOptions
                      .map(
                        (item) => AppSelectItem<String>(
                          value: item.code,
                          code: item.code,
                          label: item.name,
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setModalState(() {
                    selectedFluidCode = value;
                  }),
                ),
                AppInput(
                  label: 'Rate',
                  hint: 'Enter rate',
                  controller: rateCtrl,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ],
        ),
      ),
      onCancel: () => Navigator.of(context).pop(),
      onPrimary: () async {
        final navigator = Navigator.of(context);
        _CodeNameOption? findByCode(
          List<_CodeNameOption> options,
          String? selectedCode,
        ) {
          if (selectedCode == null || selectedCode.isEmpty) return null;
          for (final item in options) {
            if (item.code == selectedCode) return item;
          }
          return null;
        }

        final selectedSampleType = findByCode(
          _sampleTypeOptions,
          selectedSampleTypeCode,
        );
        final selectedTest = findByCode(_testOptions, selectedTestCode);
        final selectedModel = findByCode(_modelOptions, selectedModelCode);
        final selectedBrand = findByCode(_brandOptions, selectedBrandCode);
        final selectedFluid = findByCode(_fluidOptions, selectedFluidCode);

        await provider.addSampleRow(widget.customerId, {
          'sampleTypeId': selectedSampleType?.code ?? '',
          'sampleTypeName': selectedSampleType?.name ?? '',
          'testId': selectedTest?.code ?? '',
          'testName': selectedTest?.name ?? '',
          'limit': limitCtrl.text.trim(),
          'hmrLower': hmrLowerCtrl.text.trim(),
          'hmrUpper': hmrUpperCtrl.text.trim(),
          'lowerMinVal': lowerMinCtrl.text.trim(),
          'lowerMaxVal': lowerMaxCtrl.text.trim(),
          'upperMinVal': upperMinCtrl.text.trim(),
          'upperMaxVal': upperMaxCtrl.text.trim(),
          'modelId': selectedModel?.code,
          'modelName': selectedModel?.name ?? '',
          'brandId': selectedBrand?.code,
          'brandName': selectedBrand?.name ?? '',
          'fluidId': selectedFluid?.code,
          'fluidName': selectedFluid?.name ?? '',
          'rate': double.tryParse(rateCtrl.text.trim()),
        });
        if (mounted) navigator.pop();
      },
      isPrimaryLoading: provider.isLoading,
    );

    limitCtrl.dispose();
    hmrLowerCtrl.dispose();
    hmrUpperCtrl.dispose();
    lowerMinCtrl.dispose();
    lowerMaxCtrl.dispose();
    upperMinCtrl.dispose();
    upperMaxCtrl.dispose();
    rateCtrl.dispose();
  }

  Future<void> _clearAll() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Clear All Sample Types',
      message: 'This will remove all sample type rows for this customer.',
      confirmLabel: 'Clear All',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirmed == true && mounted) {
      await context.read<CustomerProvider>().clearAllSamples(widget.customerId);
      if (mounted) {
        setState(() {
          _editingRowId = null;
          _editingDraft = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceRows = context
        .select<CustomerProvider, List<SampleTypeRowModel>>((p) {
          if (p.selected?.id != widget.customerId) return const [];
          return p.selected!.sampleTypes;
        });
    final filtered = _filteredFrom(sourceRows);
    final display = _sortedFrom(filtered);
    final rows = _pagedSlice(display);
    final total = display.length;
    final start = total == 0 ? 0 : ((_currentPage - 1) * _pageSize) + 1;
    final end = total == 0 ? 0 : (start + rows.length - 1);
    final pages = total == 0 ? 1 : ((total - 1) ~/ _pageSize) + 1;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _saveAndClearEditing,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppTokens.space4),
            child: Row(
              children: [
                SizedBox(
                  width: AppTokens.space12 * 6,
                  child: AppInput(
                    hint: 'Search...',
                    controller: _searchCtrl,
                    prefixIcon: const Icon(LucideIcons.search),
                    onChanged: (_) => setState(() => _currentPage = 1),
                  ),
                ),
                const Spacer(),
                AppButton(
                  label: 'Import Tests',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                SizedBox(width: AppTokens.space2),
                AppButton(
                  label: 'Export Tests',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                SizedBox(width: AppTokens.space2),
                AppButton(
                  label: 'Clear All',
                  variant: AppButtonVariant.danger,
                  onPressed: _clearAll,
                ),
                SizedBox(width: AppTokens.space2),
                AppButton(
                  label: '+ Add Row',
                  variant: AppButtonVariant.primary,
                  onPressed: _showAddModal,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
              child: Scrollbar(
                controller: _horizontalScrollCtrl,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: _tableMinWidth,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _headerRow(),
                        ...rows.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final row = entry.value;
                          final editing = _editingRowId == row.id;
                          return InkWell(
                            onTap: () => _onRowTap(row),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppTokens.borderDefault,
                                  ),
                                ),
                              ),
                              constraints: BoxConstraints(
                                minHeight: AppTokens.tableRowHeight,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _cell(
                                    '${((_currentPage - 1) * _pageSize) + idx + 1}',
                                    width: _colIndex,
                                    isPlaceholder: false,
                                  ),
                                  _sampleTypeCell(row, editing),
                                  _testCell(row, editing),
                                  _editableCell(
                                    row,
                                    'limit',
                                    row.limit ?? '',
                                    editing,
                                    _colLimit,
                                  ),
                                  _editableCell(
                                    row,
                                    'hmrLower',
                                    row.hmrLower ?? '',
                                    editing,
                                    _colHmrLower,
                                  ),
                                  _editableCell(
                                    row,
                                    'hmrUpper',
                                    row.hmrUpper ?? '',
                                    editing,
                                    _colHmrUpper,
                                  ),
                                  _editableCell(
                                    row,
                                    'lowerMinVal',
                                    row.lowerMinVal ?? '',
                                    editing,
                                    _colLowerMin,
                                  ),
                                  _editableCell(
                                    row,
                                    'lowerMaxVal',
                                    row.lowerMaxVal ?? '',
                                    editing,
                                    _colLowerMax,
                                  ),
                                  _editableCell(
                                    row,
                                    'upperMinVal',
                                    row.upperMinVal ?? '',
                                    editing,
                                    _colUpperMin,
                                  ),
                                  _editableCell(
                                    row,
                                    'upperMaxVal',
                                    row.upperMaxVal ?? '',
                                    editing,
                                    _colUpperMax,
                                  ),
                                  _modelCell(row, editing),
                                  _brandCell(row, editing),
                                  _fluidCell(row, editing),
                                  _editableCell(
                                    row,
                                    'rate',
                                    row.rate?.toString() ?? '',
                                    editing,
                                    _colRate,
                                    isNumber: true,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: AppTokens.listingPaginationHeight,
            decoration: const BoxDecoration(
              color: AppTokens.cardBg,
              border: Border(top: BorderSide(color: AppTokens.borderDefault)),
            ),
            padding: EdgeInsets.symmetric(horizontal: AppTokens.space4),
            child: Row(
              children: [
                Text(
                  '$start-$end of $total',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.captionSize,
                    color: AppTokens.textSecondary,
                  ),
                ),
                const Spacer(),
                AppButton(
                  label: '<',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.secondary,
                  onPressed: _currentPage <= 1
                      ? null
                      : () => setState(() => _currentPage -= 1),
                ),
                SizedBox(width: AppTokens.space2),
                AppButton(
                  label: '>',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.secondary,
                  onPressed: _currentPage >= pages
                      ? null
                      : () => setState(() => _currentPage += 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    final labels = [
      ('#', _colIndex),
      ('Type of Sample', _colSampleType),
      ('Test', _colTest),
      ('Limit', _colLimit),
      ('HMR Lower', _colHmrLower),
      ('HMR Upper', _colHmrUpper),
      ('Lower Min', _colLowerMin),
      ('Lower Max', _colLowerMax),
      ('Upper Min', _colUpperMin),
      ('Upper Max', _colUpperMax),
      ('Model', _colModel),
      ('Brand', _colBrand),
      ('Fluid', _colFluid),
      ('Rate', _colRate),
    ];
    const filterKeys = <String?>[
      null,
      'sampleTypeName',
      'testName',
      'limit',
      'hmrLower',
      'hmrUpper',
      'lowerMinVal',
      'lowerMaxVal',
      'upperMinVal',
      'upperMaxVal',
      'modelName',
      'brandName',
      'fluidName',
      'rate',
    ];
    const sortKeys = <String>[
      '#',
      'sampleTypeName',
      'testName',
      'limit',
      'hmrLower',
      'hmrUpper',
      'lowerMinVal',
      'lowerMaxVal',
      'upperMinVal',
      'upperMaxVal',
      'modelName',
      'brandName',
      'fluidName',
      'rate',
    ];
    final headerLabelStyle = GoogleFonts.poppins(
      fontSize: AppTokens.textXs,
      fontWeight: AppTokens.weightSemibold,
      color: AppTokens.textMuted,
      letterSpacing: 0.5,
    );
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTokens.borderDefault)),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final (label, w) = labels[i];
          final filterKey = filterKeys[i];
          final sortKey = sortKeys[i];
          return _SortableFilterColumnHeader(
            label: label,
            width: w,
            filterKey: filterKey,
            sortKey: sortKey,
            filterActive:
                filterKey != null &&
                (_columnFilters[filterKey]?.trim().isNotEmpty ?? false),
            sortColumn: _sortColumn,
            sortAsc: _sortAsc,
            labelStyle: headerLabelStyle,
            onOpenFilter: _openColumnFilter,
            onSortTap: _onSortTap,
          );
        }),
      ),
    );
  }

  Widget _sampleTypeCell(SampleTypeRowModel row, bool editing) {
    if (!editing || _editingDraft == null || _editingRowId != row.id) {
      final v = row.sampleTypeName.trim();
      return _cell(
        v.isEmpty ? '—' : v,
        width: _colSampleType,
        isPlaceholder: v.isEmpty,
      );
    }
    return SizedBox(
      width: _colSampleType,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppTokens.space2,
          horizontal: AppTokens.space2,
        ),
        child: AppSelect<String>(
          hint: 'Select',
          size: AppInputSize.sm,
          countLabel: 'sample types',
          value: _editingDraft!.sampleTypeId,
          items: _sampleTypeOptions
              .map(
                (e) => AppSelectItem<String>(
                  value: e.code,
                  code: e.code,
                  label: e.name,
                ),
              )
              .toList(),
          onChanged: (v) {
            final opt = _optionByCode(_sampleTypeOptions, v);
            setState(() {
              _editingDraft = _editingDraft!.copyWith(
                sampleTypeId: opt?.code ?? '',
                sampleTypeName: opt?.name ?? '',
              );
            });
          },
        ),
      ),
    );
  }

  Widget _testCell(SampleTypeRowModel row, bool editing) {
    if (!editing || _editingDraft == null || _editingRowId != row.id) {
      final v = row.testName.trim();
      return _cell(
        v.isEmpty ? '—' : v,
        width: _colTest,
        isPlaceholder: v.isEmpty,
      );
    }
    return SizedBox(
      width: _colTest,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppTokens.space2,
          horizontal: AppTokens.space2,
        ),
        child: AppSelect<String>(
          hint: 'Select',
          size: AppInputSize.sm,
          countLabel: 'tests',
          value: _editingDraft!.testId,
          items: _testOptions
              .map(
                (e) => AppSelectItem<String>(
                  value: e.code,
                  code: e.code,
                  label: e.name,
                ),
              )
              .toList(),
          onChanged: (v) {
            final opt = _optionByCode(_testOptions, v);
            setState(() {
              _editingDraft = _editingDraft!.copyWith(
                testId: opt?.code ?? '',
                testName: opt?.name ?? '',
              );
            });
          },
        ),
      ),
    );
  }

  Widget _modelCell(SampleTypeRowModel row, bool editing) {
    if (!editing || _editingDraft == null || _editingRowId != row.id) {
      final v = (row.modelName ?? '').trim();
      return _cell(
        v.isEmpty ? '—' : v,
        width: _colModel,
        isPlaceholder: v.isEmpty,
      );
    }
    return SizedBox(
      width: _colModel,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppTokens.space2,
          horizontal: AppTokens.space2,
        ),
        child: AppSelect<String>(
          hint: 'Select',
          size: AppInputSize.sm,
          countLabel: 'models',
          value: _editingDraft!.modelId,
          items: _modelOptions
              .map(
                (e) => AppSelectItem<String>(
                  value: e.code,
                  code: e.code,
                  label: e.name,
                ),
              )
              .toList(),
          onChanged: (v) {
            final opt = _optionByCode(_modelOptions, v);
            setState(() {
              if (opt == null) {
                _editingDraft = _editingDraft!.copyWith(
                  modelId: null,
                  modelName: null,
                );
              } else {
                _editingDraft = _editingDraft!.copyWith(
                  modelId: opt.code,
                  modelName: opt.name,
                );
              }
            });
          },
        ),
      ),
    );
  }

  Widget _brandCell(SampleTypeRowModel row, bool editing) {
    if (!editing || _editingDraft == null || _editingRowId != row.id) {
      final v = (row.brandName ?? '').trim();
      return _cell(
        v.isEmpty ? '—' : v,
        width: _colBrand,
        isPlaceholder: v.isEmpty,
      );
    }
    return SizedBox(
      width: _colBrand,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppTokens.space2,
          horizontal: AppTokens.space2,
        ),
        child: AppSelect<String>(
          hint: 'Select',
          size: AppInputSize.sm,
          countLabel: 'brands',
          value: _editingDraft!.brandId,
          items: _brandOptions
              .map(
                (e) => AppSelectItem<String>(
                  value: e.code,
                  code: e.code,
                  label: e.name,
                ),
              )
              .toList(),
          onChanged: (v) {
            final opt = _optionByCode(_brandOptions, v);
            setState(() {
              if (opt == null) {
                _editingDraft = _editingDraft!.copyWith(
                  brandId: null,
                  brandName: null,
                );
              } else {
                _editingDraft = _editingDraft!.copyWith(
                  brandId: opt.code,
                  brandName: opt.name,
                );
              }
            });
          },
        ),
      ),
    );
  }

  Widget _fluidCell(SampleTypeRowModel row, bool editing) {
    if (!editing || _editingDraft == null || _editingRowId != row.id) {
      final v = (row.fluidName ?? '').trim();
      return _cell(
        v.isEmpty ? '—' : v,
        width: _colFluid,
        isPlaceholder: v.isEmpty,
      );
    }
    return SizedBox(
      width: _colFluid,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppTokens.space2,
          horizontal: AppTokens.space2,
        ),
        child: AppSelect<String>(
          hint: 'Select',
          size: AppInputSize.sm,
          countLabel: 'fluids',
          value: _editingDraft!.fluidId,
          items: _fluidOptions
              .map(
                (e) => AppSelectItem<String>(
                  value: e.code,
                  code: e.code,
                  label: e.name,
                ),
              )
              .toList(),
          onChanged: (v) {
            final opt = _optionByCode(_fluidOptions, v);
            setState(() {
              if (opt == null) {
                _editingDraft = _editingDraft!.copyWith(
                  fluidId: null,
                  fluidName: null,
                );
              } else {
                _editingDraft = _editingDraft!.copyWith(
                  fluidId: opt.code,
                  fluidName: opt.name,
                );
              }
            });
          },
        ),
      ),
    );
  }

  Widget _editableCell(
    SampleTypeRowModel row,
    String field,
    String value,
    bool editing,
    double width, {
    bool isNumber = false,
  }) {
    if (!editing) {
      final v = value.trim();
      final showDash = v.isEmpty;
      return _cell(showDash ? '—' : v, width: width, isPlaceholder: showDash);
    }
    final key = '${row.id}:$field';
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppTokens.space2,
          horizontal: AppTokens.space2,
        ),
        child: AppInput(
          hint: '',
          controller: _ctrl(key, value),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          size: AppInputSize.sm,
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    required double width,
    required bool isPlaceholder,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppTokens.space2,
          horizontal: AppTokens.space2,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textSm,
              fontWeight: FontWeight.w400,
              color: isPlaceholder
                  ? AppTokens.textMuted
                  : AppTokens.textPrimary,
              decoration: TextDecoration.none,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class _SortableFilterColumnHeader extends StatefulWidget {
  const _SortableFilterColumnHeader({
    required this.label,
    required this.width,
    this.filterKey,
    required this.sortKey,
    required this.filterActive,
    required this.sortColumn,
    required this.sortAsc,
    required this.labelStyle,
    required this.onOpenFilter,
    required this.onSortTap,
  });

  final String label;
  final double width;
  final String? filterKey;
  final String sortKey;
  final bool filterActive;
  final String? sortColumn;
  final bool sortAsc;
  final TextStyle labelStyle;
  final void Function(String columnKey, LayerLink link) onOpenFilter;
  final void Function(String sortKey) onSortTap;

  @override
  State<_SortableFilterColumnHeader> createState() =>
      _SortableFilterColumnHeaderState();
}

class _SortableFilterColumnHeaderState
    extends State<_SortableFilterColumnHeader> {
  final LayerLink _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final sortActive = widget.sortColumn == widget.sortKey;
    return SizedBox(
      width: widget.width,
      child: CompositedTransformTarget(
        link: _link,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: widget.labelStyle,
                ),
              ),
              if (widget.filterKey != null) ...[
                SizedBox(width: AppTokens.space1),
                InkWell(
                  onTap: () => widget.onOpenFilter(widget.filterKey!, _link),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  child: Padding(
                    padding: EdgeInsets.all(AppTokens.spaceHalf),
                    child: Icon(
                      LucideIcons.listFilter,
                      size: AppTokens.textSm,
                      color: widget.filterActive
                          ? AppTokens.accent500
                          : AppTokens.textMuted,
                    ),
                  ),
                ),
              ],
              SizedBox(width: AppTokens.space1),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onSortTap(widget.sortKey),
                child: Padding(
                  padding: EdgeInsets.all(AppTokens.spaceHalf),
                  child: Icon(
                    sortActive
                        ? (widget.sortAsc
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown)
                        : LucideIcons.chevronsUpDown,
                    size: AppTokens.textSm,
                    color: sortActive
                        ? AppTokens.accent500
                        : AppTokens.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeNameOption {
  const _CodeNameOption({required this.code, required this.name});

  final String code;
  final String name;
}

const List<_CodeNameOption> _sampleTypeOptions = [
  _CodeNameOption(code: 'ST01', name: 'Oil'),
  _CodeNameOption(code: 'ST02', name: 'Coolant'),
  _CodeNameOption(code: 'ST03', name: 'Grease'),
];

const List<_CodeNameOption> _testOptions = [
  _CodeNameOption(code: 'T01', name: 'Viscosity'),
  _CodeNameOption(code: 'T02', name: 'Water Content'),
  _CodeNameOption(code: 'T03', name: 'TAN'),
];

const List<_CodeNameOption> _modelOptions = [
  _CodeNameOption(code: 'M01', name: 'Model A'),
  _CodeNameOption(code: 'M02', name: 'Model B'),
];

const List<_CodeNameOption> _brandOptions = [
  _CodeNameOption(code: 'B01', name: 'Brand X'),
  _CodeNameOption(code: 'B02', name: 'Brand Y'),
];

const List<_CodeNameOption> _fluidOptions = [
  _CodeNameOption(code: 'F01', name: 'Fluid 1'),
  _CodeNameOption(code: 'F02', name: 'Fluid 2'),
];
