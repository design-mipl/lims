import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/indian_states.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../masters/customer_master/data/customer_model.dart';
import '../../../masters/customer_master/state/customer_provider.dart';
import '../../sample_intake/data/sample_master_options.dart';

/// Create Quotation — fields aligned with Ultra Labs Customer Quotation portal.
class CreateQuotationPage extends StatefulWidget {
  const CreateQuotationPage({super.key});

  @override
  State<CreateQuotationPage> createState() => _CreateQuotationPageState();
}

class _QuoteLine {
  _QuoteLine({
    required this.sampleKey,
    required this.testKey,
    required String qtyText,
    required String rateText,
  })  : qty = TextEditingController(
          text: qtyText.trim().isEmpty ? '1' : qtyText.trim(),
        ),
        rate = TextEditingController(
          text: rateText.trim().isEmpty ? '0' : rateText.trim(),
        );

  final String sampleKey;
  final String testKey;
  final TextEditingController qty;
  final TextEditingController rate;

  void dispose() {
    qty.dispose();
    rate.dispose();
  }
}

class _CreateQuotationPageState extends State<CreateQuotationPage> {
  final _docDateCtrl = TextEditingController();
  final _docNoCtrl = TextEditingController();
  final _quotationSeriesCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();

  final _addressCtrl = TextEditingController();
  final _addressLine2Ctrl = TextEditingController();
  String? _stateKey;
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _entrySampleKey = ValueNotifier<String?>(
    SampleMasterOptions.typeOfSample.isEmpty
        ? null
        : SampleMasterOptions.typeOfSample.first.value,
  );
  final _entryTestKey = ValueNotifier<String?>(
    QuotationFormOptions.tests.isEmpty
        ? null
        : QuotationFormOptions.tests.first.value,
  );
  final _entryQtyCtrl = TextEditingController(text: '1');
  final _entryRateCtrl = TextEditingController(text: '0');

  final _discountRateCtrl = TextEditingController(text: '0');
  final _freightCtrl = TextEditingController(text: '0');

  final _totalCtrl = TextEditingController(text: '0.00');
  final _discountAmountCtrl = TextEditingController(text: '0.00');
  final _gstAmountCtrl = TextEditingController(text: '0.00');
  final _grandTotalCtrl = TextEditingController(text: '0.00');

  String? _customerId;
  String _gstRateKey = '18';

  final List<_QuoteLine> _lines = [];

  final ScrollController _quotationTestsHScrollController = ScrollController();

  static const double _twPlus = 40;
  static const double _twSr = 44;
  static const double _twSampleMin = 168;
  static const double _twTestMin = 212;
  static const double _twQty = 72;
  static const double _twRate = 84;
  static const double _twValue = 96;
  static const double _twDel = 44;

  static const double _tableHeaderHeight = 44;
  static const double _tableRowHeight = 44;

  /// Matches [AppTextarea] inner field font size (private there).
  static const double _textareaFieldFontSize = 12.0;

  static double get _minTableTotalWidth =>
      _twPlus +
      _twSr +
      _twSampleMin +
      _twTestMin +
      _twQty +
      _twRate +
      _twValue +
      _twDel;

  static final Map<String, String> _gstPresets = {
    '0': '0%',
    '5': '5%',
    '12': '12%',
    '18': '18%',
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _docDateCtrl.text = _formatYmd(now);
    _docNoCtrl.text =
        'DOC-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${math.Random().nextInt(900) + 100}';
    _quotationSeriesCtrl.text =
        'QT/${now.year}/${(math.Random().nextInt(900) + 100).toString().padLeft(3, '0')}';

    _discountRateCtrl.addListener(_onDiscountOrFreightChanged);
    _freightCtrl.addListener(_onDiscountOrFreightChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CustomerProvider>().fetchAll();
    });
    _updatePricing();
  }

  @override
  void dispose() {
    _discountRateCtrl.removeListener(_onDiscountOrFreightChanged);
    _freightCtrl.removeListener(_onDiscountOrFreightChanged);
    _docDateCtrl.dispose();
    _docNoCtrl.dispose();
    _quotationSeriesCtrl.dispose();
    _narrationCtrl.dispose();
    _addressCtrl.dispose();
    _addressLine2Ctrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _entrySampleKey.dispose();
    _entryTestKey.dispose();
    _entryQtyCtrl.dispose();
    _entryRateCtrl.dispose();
    _discountRateCtrl.dispose();
    _freightCtrl.dispose();
    _totalCtrl.dispose();
    _discountAmountCtrl.dispose();
    _gstAmountCtrl.dispose();
    _grandTotalCtrl.dispose();
    _quotationTestsHScrollController.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  static String _formatYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double _parseMoney(String s) => double.tryParse(s.trim()) ?? 0;

  double _lineValue(_QuoteLine line) =>
      _parseMoney(line.qty.text) * _parseMoney(line.rate.text);

  double _linesSum() {
    var s = 0.0;
    for (final line in _lines) {
      s += _lineValue(line);
    }
    return s;
  }

  void _onDiscountOrFreightChanged() {
    if (!mounted) return;
    _updatePricing();
    setState(() {});
  }

  void _updatePricing() {
    final linesTotal = _linesSum();
    final discRatePct = _parseMoney(_discountRateCtrl.text);
    final freight = _parseMoney(_freightCtrl.text);
    final gstRatePct = double.tryParse(_gstRateKey) ?? 0;

    final discountAmt = linesTotal * (discRatePct / 100);
    final afterDisc = linesTotal - discountAmt;
    final taxable = afterDisc + freight;
    final gstAmt = taxable * (gstRatePct / 100);
    final grand = taxable + gstAmt;

    _totalCtrl.text = linesTotal.toStringAsFixed(2);
    _discountAmountCtrl.text = discountAmt.toStringAsFixed(2);
    _gstAmountCtrl.text = gstAmt.toStringAsFixed(2);
    _grandTotalCtrl.text = grand.toStringAsFixed(2);
  }

  void _addTableRow() {
    final sk = _entrySampleKey.value;
    final tk = _entryTestKey.value;
    if (sk == null || sk.isEmpty || tk == null || tk.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Choose Sample and Test in Quotation Test Entry before adding a row.',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.primary800,
        ),
      );
      return;
    }
    setState(() {
      _lines.add(
        _QuoteLine(
          sampleKey: sk,
          testKey: tk,
          qtyText: _entryQtyCtrl.text,
          rateText: _entryRateCtrl.text,
        ),
      );
      _updatePricing();
    });
  }

  Future<void> _pickDate(TextEditingController c) async {
    final parsed = DateTime.tryParse(c.text.trim());
    final initial = parsed ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => c.text = _formatYmd(picked));
    }
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
  }) {
    return AppInput(
      label: label,
      hint: 'YYYY-MM-DD',
      controller: controller,
      readOnly: true,
      size: AppInputSize.md,
      onTap: () => _pickDate(controller),
      suffixIcon: Icon(LucideIcons.calendar, size: AppTokens.iconButtonIconSm),
    );
  }

  List<AppSelectItem<String>> _itemsFrom(Map<String, String> map) =>
      map.entries
          .map((e) => AppSelectItem<String>(value: e.key, label: e.value))
          .toList(growable: false);

  String _sampleLabel(String key) {
    for (final e in SampleMasterOptions.typeOfSample) {
      if (e.value == key) return e.label;
    }
    return key;
  }

  String _testLabel(String key) =>
      QuotationFormOptions.tests
          .firstWhere(
            (e) => e.value == key,
            orElse: () => AppSelectItem<String>(value: key, label: key),
          )
          .label;

  List<AppSelectItem<String>> _stateItemsFor(String? current) {
    final base = List<AppSelectItem<String>>.from(IndianStates.list);
    if (current != null &&
        current.isNotEmpty &&
        !base.any((e) => e.value == current)) {
      base.insert(
        0,
        AppSelectItem<String>(value: current, label: current),
      );
    }
    return base;
  }

  CustomerModel? _customerById(List<CustomerModel> customers, String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return customers.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void _applyCustomer(CustomerModel? c) {
    if (c == null) {
      _addressCtrl.clear();
      _addressLine2Ctrl.clear();
      _stateKey = null;
      _mobileCtrl.clear();
      _emailCtrl.clear();
      return;
    }
    _addressCtrl.text = (c.addressLine1 ?? '').trim();
    final line2Parts = <String>[
      if ((c.city ?? '').trim().isNotEmpty) c.city!.trim(),
      if ((c.pincode ?? '').trim().isNotEmpty) c.pincode!.trim(),
      if ((c.country ?? '').trim().isNotEmpty) c.country!.trim(),
    ];
    _addressLine2Ctrl.text = line2Parts.join(', ');
    final st = (c.state ?? '').trim();
    _stateKey = st.isEmpty ? null : st;
    ContactPersonModel? contact;
    if (c.contacts.isNotEmpty) {
      contact = c.contacts.first;
      for (final p in c.contacts) {
        if ((p.mobile ?? '').trim().isNotEmpty) {
          contact = p;
          break;
        }
      }
    }
    _emailCtrl.text = contact?.email ?? '';
    _mobileCtrl.text = contact?.mobile ?? '';
  }

  void _removeLine(int index) {
    setState(() {
      _lines[index].dispose();
      _lines.removeAt(index);
      _updatePricing();
    });
  }

  BorderSide get _gridLine => BorderSide(
        color: AppTokens.borderLight,
        width: AppTokens.borderWidthMd,
      );

  TextStyle get _hdrStyle => GoogleFonts.poppins(
        fontSize: AppTokens.textXs,
        fontWeight: AppTokens.weightSemibold,
        color: AppTokens.textSecondary,
        letterSpacing: 0.3,
      );

  TextStyle get _cellStyle => GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        color: AppTokens.textPrimary,
      );

  Widget _plusHeaderCell(double width) {
    return SizedBox(
      width: width,
      height: _tableHeaderHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTokens.surfaceSubtle,
          border: Border(right: _gridLine, bottom: _gridLine),
        ),
        child: Center(
          child: IconButton(
            tooltip: 'Add row',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            icon: Icon(
              LucideIcons.plus,
              size: AppTokens.iconButtonIconSm,
              color: AppTokens.primary800,
            ),
            onPressed: _addTableRow,
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String label, double width, {bool last = false}) {
    return SizedBox(
      width: width,
      height: _tableHeaderHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTokens.surfaceSubtle,
          border: Border(
            right: last ? BorderSide.none : _gridLine,
            bottom: _gridLine,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _hdrStyle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableRowCell(
    Widget child,
    double width, {
    bool last = false,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return SizedBox(
      width: width,
      height: _tableRowHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: last ? BorderSide.none : _gridLine,
            bottom: _gridLine,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space2,
            vertical: AppTokens.space1,
          ),
          child: Align(
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }

  InputDecoration _inlineFieldDecoration(String hint) {
    return InputDecoration(
      isDense: true,
      border: InputBorder.none,
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        color: AppTokens.textMuted,
      ),
      contentPadding: EdgeInsets.zero,
      isCollapsed: true,
    );
  }

  Widget _buildTestsTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vw = constraints.maxWidth;
        final tw = math.max(vw, _minTableTotalWidth);
        final bonus = tw - _minTableTotalWidth;
        final sampleW = _twSampleMin + bonus / 2;
        final testW = _twTestMin + bonus / 2;

        final scrollNeeded = tw > vw + 0.5;

        Widget tableCore() {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                border: Border(
                  left: BorderSide(
                    color: AppTokens.borderLight,
                    width: AppTokens.borderWidthMd,
                  ),
                  top: BorderSide(
                    color: AppTokens.borderLight,
                    width: AppTokens.borderWidthMd,
                  ),
                  right: BorderSide(
                    color: AppTokens.borderLight,
                    width: AppTokens.borderWidthMd,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _plusHeaderCell(_twPlus),
                      _headerCell('Sr. No.', _twSr),
                      _headerCell('Sample', sampleW),
                      _headerCell('Test', testW),
                      _headerCell('Qty', _twQty),
                      _headerCell('Rate', _twRate),
                      _headerCell('Value', _twValue),
                      _headerCell('Delete', _twDel, last: true),
                    ],
                  ),
                  if (_lines.isEmpty)
                    DecoratedBox(
                      decoration: BoxDecoration(border: Border(bottom: _gridLine)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTokens.space3,
                          vertical: AppTokens.space2,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No lines yet. Set Sample and Test above, then use + in the header.',
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.captionSize,
                              color: AppTokens.textMuted,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_lines.length, (index) {
                      final line = _lines[index];
                      final n = index + 1;
                      final valueStr = _lineValue(line).toStringAsFixed(2);
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _tableRowCell(const SizedBox.shrink(), _twPlus),
                          _tableRowCell(
                            Text('$n', style: _cellStyle),
                            _twSr,
                          ),
                          _tableRowCell(
                            Text(
                              _sampleLabel(line.sampleKey),
                              style: _cellStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            sampleW,
                          ),
                          _tableRowCell(
                            Text(
                              _testLabel(line.testKey),
                              style: _cellStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            testW,
                          ),
                          _tableRowCell(
                            TextField(
                              controller: line.qty,
                              keyboardType: TextInputType.number,
                              style: _cellStyle,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: _inlineFieldDecoration('Qty'),
                              onChanged: (_) =>
                                  setState(() => _updatePricing()),
                            ),
                            _twQty,
                            alignment: Alignment.center,
                          ),
                          _tableRowCell(
                            TextField(
                              controller: line.rate,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: _cellStyle,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: _inlineFieldDecoration('Rate'),
                              onChanged: (_) =>
                                  setState(() => _updatePricing()),
                            ),
                            _twRate,
                            alignment: Alignment.center,
                          ),
                          _tableRowCell(
                            Text(
                              valueStr,
                              style: _cellStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            _twValue,
                          ),
                          _tableRowCell(
                            IconButton(
                              tooltip: 'Remove row',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: Icon(
                                LucideIcons.trash2,
                                size: AppTokens.iconButtonIconSm,
                                color: AppTokens.error500,
                              ),
                              onPressed: () => _removeLine(index),
                            ),
                            _twDel,
                            last: true,
                            alignment: Alignment.center,
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
          );
        }

        final sizedTable = SizedBox(width: tw, child: tableCore());

        if (!scrollNeeded) return sizedTable;

        return ClipRect(
          child: AppScrollbar(
            controller: _quotationTestsHScrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _quotationTestsHScrollController,
              scrollDirection: Axis.horizontal,
              primary: false,
              physics: const ClampingScrollPhysics(),
              child: sizedTable,
            ),
          ),
        );
      },
    );
  }

  Widget _tightStack(List<Widget> children) {
    final out = <Widget>[children.first];
    for (var i = 1; i < children.length; i++) {
      out
        ..add(SizedBox(height: AppTokens.space2))
        ..add(children[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: out,
    );
  }

  /// Narration fills remaining vertical space beside Customer Details (wide layout).
  Widget _narrationStretchCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? theme.cardColor : AppTokens.cardBg;
    final borderColor =
        isDark ? AppTokens.neutral700 : AppTokens.borderDefault;
    final titleColor =
        isDark ? theme.colorScheme.onSurface : AppTokens.textPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: borderColor,
          width: AppTokens.borderWidthSm,
        ),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Narration',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.sectionTitleSize,
                fontWeight: AppTokens.sectionTitleWeight,
                color: titleColor,
              ),
            ),
            SizedBox(height: AppTokens.space3),
            Expanded(
              child: TextFormField(
                controller: _narrationCtrl,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: appFormFieldValueTextStyle(
                  fontSize: _textareaFieldFontSize,
                  color: AppTokens.textPrimary,
                ),
                cursorColor: AppTokens.borderFocus,
                decoration: buildAppFormFieldDecoration(
                  enabled: true,
                  hasError: false,
                  hintText: 'Narration…',
                  hintStyle: appFormFieldValueTextStyle(
                    fontSize: _textareaFieldFontSize,
                    color: AppTokens.hintColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCancel() => context.go('/transactions/quotation/pending');

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Draft saved (UI only)',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Quotation submitted (UI only)',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
    context.go('/transactions/quotation/pending');
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    final active =
        customers.where((e) => e.status == 'active').toList(growable: false);
    final customerItems = <AppSelectItem<String>>[
      for (final c in active)
        AppSelectItem<String>(value: c.id, label: c.companyName),
    ];

    final sampleMasterItems =
        List<AppSelectItem<String>>.from(SampleMasterOptions.typeOfSample);

    final basicLeft = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _dateField(label: 'Doc. Date', controller: _docDateCtrl),
        SizedBox(height: AppTokens.space3),
        AppInput(
          label: 'Quotation No. / Series No.',
          hint: 'Series',
          controller: _quotationSeriesCtrl,
          size: AppInputSize.md,
        ),
      ],
    );

    final basicRight = AppInput(
      label: 'Doc. No.',
      controller: _docNoCtrl,
      size: AppInputSize.md,
    );

    final sectionBasic = AppFormSection(
      title: 'Quotation Basic Details',
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 640) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                basicLeft,
                SizedBox(height: AppTokens.space3),
                basicRight,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: basicLeft),
              SizedBox(width: AppTokens.space4),
              Expanded(child: basicRight),
            ],
          );
        },
      ),
    );

    final sectionCustomer = AppFormSection(
      title: 'Customer Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnchoredSearchableDropdownField<String>(
            label: 'Customer',
            hint: 'Select customer',
            value: _customerId,
            items: customerItems,
            size: AppInputSize.md,
            overlayMinimalShadow: true,
            onChanged: (id) => setState(() {
              _customerId = id;
              _applyCustomer(_customerById(active, id));
            }),
          ),
          SizedBox(height: AppTokens.space3),
          AppTextarea(
            label: 'Address',
            hint: 'Street, building…',
            controller: _addressCtrl,
            minLines: 4,
            maxLines: 6,
          ),
          SizedBox(height: AppTokens.space3),
          AppInput(
            label: 'Address Line 2 (optional)',
            hint: 'City, PIN, etc.',
            controller: _addressLine2Ctrl,
            size: AppInputSize.md,
          ),
          SizedBox(height: AppTokens.space3),
          AnchoredSearchableDropdownField<String>(
            label: 'State',
            hint: 'Select state',
            value: _stateKey,
            items: _stateItemsFor(_stateKey),
            size: AppInputSize.md,
            overlayMinimalShadow: true,
            onChanged: (v) => setState(() => _stateKey = v),
          ),
          SizedBox(height: AppTokens.space3),
          AppInput(
            label: 'Mobile',
            controller: _mobileCtrl,
            keyboardType: TextInputType.phone,
            size: AppInputSize.md,
          ),
          SizedBox(height: AppTokens.space3),
          AppInput(
            label: 'Email',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            size: AppInputSize.md,
          ),
        ],
      ),
    );

    final pricingChild = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          label: 'Total',
          controller: _totalCtrl,
          readOnly: true,
          size: AppInputSize.md,
        ),
        SizedBox(height: AppTokens.space3),
        AppInput(
          label: 'Discount Rate',
          hint: '%',
          controller: _discountRateCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          size: AppInputSize.md,
        ),
        SizedBox(height: AppTokens.space3),
        AppInput(
          label: 'Discount Amount',
          controller: _discountAmountCtrl,
          readOnly: true,
          size: AppInputSize.md,
        ),
        SizedBox(height: AppTokens.space3),
        AppInput(
          label: 'Freight',
          controller: _freightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          size: AppInputSize.md,
        ),
        SizedBox(height: AppTokens.space3),
        AnchoredSearchableDropdownField<String>(
          label: 'GST Rate',
          hint: 'GST %',
          value: _gstRateKey,
          items: _itemsFrom(_gstPresets),
          size: AppInputSize.md,
          overlayMinimalShadow: true,
          onChanged: (v) => setState(() {
            _gstRateKey = v ?? _gstRateKey;
            _updatePricing();
          }),
        ),
        SizedBox(height: AppTokens.space3),
        AppInput(
          label: 'GST Amount',
          controller: _gstAmountCtrl,
          readOnly: true,
          size: AppInputSize.md,
        ),
        SizedBox(height: AppTokens.space3),
        AppInput(
          label: 'Grand Total',
          controller: _grandTotalCtrl,
          readOnly: true,
          size: AppInputSize.md,
        ),
      ],
    );

    final sectionPricing = AppFormSection(
      title: 'Pricing Summary',
      child: pricingChild,
    );

    final sectionNarrationMobile = AppFormSection(
      title: 'Narration',
      child: AppTextarea(
        hint: 'Narration…',
        controller: _narrationCtrl,
        minLines: 8,
        maxLines: 14,
      ),
    );

    final sectionTestEntry = AppFormSection(
      title: 'Quotation Test Entry',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 760;
          final gap = SizedBox(width: AppTokens.space3);
          Widget rowBody(bool expanded) {
            Widget sampleField({required double? width}) {
              final dd = AnchoredSearchableDropdownField<String>(
                label: 'Sample',
                hint: 'Select sample',
                value: _entrySampleKey.value,
                items: sampleMasterItems,
                size: AppInputSize.md,
                overlayMinimalShadow: true,
                onChanged: (v) => setState(() => _entrySampleKey.value = v),
              );
              return width != null ? SizedBox(width: width, child: dd) : dd;
            }

            Widget testField({required double? width}) {
              final dd = AnchoredSearchableDropdownField<String>(
                label: 'Test',
                hint: 'Select test',
                value: _entryTestKey.value,
                items: QuotationFormOptions.tests,
                size: AppInputSize.md,
                overlayMinimalShadow: true,
                onChanged: (v) => setState(() => _entryTestKey.value = v),
              );
              return width != null ? SizedBox(width: width, child: dd) : dd;
            }

            Widget qtyField({required double? width}) {
              final ip = AppInput(
                label: 'Qty',
                controller: _entryQtyCtrl,
                keyboardType: TextInputType.number,
                size: AppInputSize.md,
              );
              return width != null ? SizedBox(width: width, child: ip) : ip;
            }

            Widget rateField({required double? width}) {
              final ip = AppInput(
                label: 'Rate',
                controller: _entryRateCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                size: AppInputSize.md,
              );
              return width != null ? SizedBox(width: width, child: ip) : ip;
            }

            if (expanded) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 28, child: sampleField(width: null)),
                  gap,
                  Expanded(flex: 42, child: testField(width: null)),
                  gap,
                  SizedBox(width: 108, child: qtyField(width: null)),
                  gap,
                  SizedBox(width: 108, child: rateField(width: null)),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                sampleField(width: 200),
                gap,
                testField(width: 280),
                gap,
                qtyField(width: 104),
                gap,
                rateField(width: 104),
              ],
            );
          }

          return AnimatedBuilder(
            animation: Listenable.merge([_entrySampleKey, _entryTestKey]),
            builder: (context, _) {
              if (narrow) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(constraints.maxWidth, 740),
                    child: rowBody(false),
                  ),
                );
              }
              return rowBody(true);
            },
          );
        },
      ),
    );

    final sectionTestsTable = AppFormSection(
      title: 'Quotation Tests',
      child: _buildTestsTable(),
    );

    Widget quotationTopRow(BoxConstraints constraints) {
      final wide = constraints.maxWidth >= 880;
      if (!wide) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _tightStack([sectionBasic, sectionCustomer]),
            SizedBox(height: AppTokens.space3),
            _tightStack([sectionPricing, sectionNarrationMobile]),
          ],
        );
      }
      return Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: Padding(
                  padding: EdgeInsets.only(right: AppTokens.space4),
                  child: _tightStack([sectionBasic, sectionCustomer]),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.fill,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    sectionPricing,
                    SizedBox(height: AppTokens.space2),
                    Expanded(child: _narrationStretchCard(context)),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    final scrollBody = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              quotationTopRow(constraints),
              SizedBox(height: AppTokens.space3),
              sectionTestEntry,
              SizedBox(height: AppTokens.space3),
              sectionTestsTable,
              SizedBox(height: AppTokens.space4),
            ],
          );
        },
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DetailTemplate(
              parentLabel: 'Quotation',
              parentRoute: '/transactions/quotation/pending',
              currentLabel: 'Create Quotation',
              tabController: null,
              headerCard: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(
                    name: 'QT',
                    size: AppAvatarSize.lg,
                  ),
                  SizedBox(width: AppTokens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Quotation',
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.textXl,
                            fontWeight: AppTokens.weightBold,
                            color: AppTokens.textPrimary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: AppTokens.space1),
                        Text(
                          'Customer quotation — Doc., customer, line tests, and pricing summary.',
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.textSm,
                            fontWeight: AppTokens.weightRegular,
                            color: AppTokens.textMuted,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: AppTokens.space2),
                        Text(
                          '${_docNoCtrl.text} · ${_quotationSeriesCtrl.text}',
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.textSm,
                            color: AppTokens.textSecondary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: AppTokens.space2,
                    runSpacing: AppTokens.space2,
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppButton(
                        label: 'Cancel',
                        variant: AppButtonVariant.tertiary,
                        size: AppButtonSize.md,
                        onPressed: _onCancel,
                      ),
                      AppButton(
                        label: 'Save draft',
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.md,
                        onPressed: _saveDraft,
                      ),
                      AppButton(
                        label: 'Submit',
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.md,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ],
              ),
              tabLabels: const ['Overview'],
              tabViews: [scrollBody],
            ),
          ),
        ],
      ),
    );
  }
}

/// Portal-aligned quotation test catalogue (replace with API later).
abstract final class QuotationFormOptions {
  const QuotationFormOptions._();

  static List<AppSelectItem<String>> get tests => [
        const AppSelectItem(value: 'wearMetals', label: 'Wear Metals (ICP)'),
        const AppSelectItem(value: 'viscosity', label: 'Viscosity @ 40°C'),
        const AppSelectItem(value: 'tnb', label: 'TBN / TAN'),
        const AppSelectItem(value: 'particleCount', label: 'Particle Count ISO'),
        const AppSelectItem(value: 'water', label: 'Water / Karl Fischer'),
        const AppSelectItem(value: 'flashPoint', label: 'Flash Point'),
        const AppSelectItem(value: 'ferrography', label: 'Ferrography'),
        const AppSelectItem(value: 'ftir', label: 'FTIR Screening'),
      ];
}
