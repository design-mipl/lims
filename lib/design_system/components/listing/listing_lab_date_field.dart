import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';
import '../primitives/app_button.dart';

String labIdFormatToolbarDate(DateTime d) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day.toString().padLeft(2, '0')}-${months[d.month - 1]}-${d.year}';
}

const List<String> _kPickerMonthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Horizontal size for the Lab Id toolbar date popover (compact but readable).
const double _kLabIdDatePopoverWidth = 246.0;

/// Flatter than 1:1 so the grid uses less vertical space without shrinking type.
const double _kLabIdDayCellAspect = 1.28;

/// Layout for [LabCodeLabIdDateField]: compact listing toolbar vs form row (full width,
/// [AppTokens.inputHeight], [AppTokens.cardBg] — same popover/calendar as toolbar).
enum LabCodeLabIdDateFieldLayout {
  /// Listing toolbar: fixed width, [AppTokens.listingToolbarSearchHeight].
  toolbar,

  /// Form rows (e.g. Create Customer Invoice): expands horizontally, matches [AppInput] height/padding.
  formRow,
}

/// Lab Code–style date trigger + anchored calendar popover.
/// Use [LabCodeLabIdDateFieldLayout.toolbar] in listing toolbars; [formRow] in full-width form grids.
/// Popover uses [RenderBox.localToGlobal] (web-safe; avoid [CompositedTransformFollower]).
class LabCodeLabIdDateField extends StatefulWidget {
  const LabCodeLabIdDateField({
    super.key,
    required this.hint,
    required this.selectedDate,
    required this.onDateSelected,
    this.layout = LabCodeLabIdDateFieldLayout.toolbar,
    this.enabled = true,
  });

  final String hint;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  /// [toolbar] keeps Lab Code listing metrics; [formRow] fills the row like [AppInput]/dropdowns.
  final LabCodeLabIdDateFieldLayout layout;

  /// When false, the trigger is non-interactive (read-only view).
  final bool enabled;

  @override
  State<LabCodeLabIdDateField> createState() => _LabCodeLabIdDateFieldState();
}

class _LabCodeLabIdDateFieldState extends State<LabCodeLabIdDateField> {
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _entry;

  static const double _toolbarFieldWidth = 132.0;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  void _openPopover() {
    if (!widget.enabled) return;
    _removeOverlay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) return;

      // Same overlay as [Navigator] + anchor in **overlay** coordinates (not global).
      // Raw [localToGlobal] without [ancestor] misaligns [Positioned] on web / nested routes.
      final overlayState =
          Navigator.maybeOf(context)?.overlay ??
          Overlay.maybeOf(context, rootOverlay: true);
      if (overlayState == null) return;
      final overlayBox = overlayState.context.findRenderObject() as RenderBox?;
      if (overlayBox == null || !overlayBox.hasSize) return;

      final size = box.size;
      final verticalGap = AppTokens.spaceHalf;

      final popoverTopLeft = box.localToGlobal(
        Offset(0, size.height + verticalGap),
        ancestor: overlayBox,
      );

      final margin = AppTokens.space2;
      var left = popoverTopLeft.dx;
      final overlayW = overlayBox.size.width;
      if (left + _kLabIdDatePopoverWidth > overlayW - margin) {
        left = overlayW - margin - _kLabIdDatePopoverWidth;
      }
      if (left < margin) {
        left = margin;
      }

      _entry = OverlayEntry(
        builder: (ctx) {
          return _LabIdDatePickerPopover(
            panelWidth: _kLabIdDatePopoverWidth,
            topLeft: Offset(left, popoverTopLeft.dy),
            selectedDate: widget.selectedDate,
            onCancel: _removeOverlay,
            onCommit: (d) {
              widget.onDateSelected(d);
              _removeOverlay();
            },
          );
        },
      );
      overlayState.insert(_entry!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isForm = widget.layout == LabCodeLabIdDateFieldLayout.formRow;
    final fieldHeight = isForm
        ? AppTokens.inputHeight
        : AppTokens.listingToolbarSearchHeight;
    final fontSize = AppTokens.textSm;
    final fillColor = isForm ? AppTokens.cardBg : AppTokens.surfaceSubtle;
    final radius = BorderRadius.circular(AppTokens.inputRadius);
    final display = widget.selectedDate != null
        ? labIdFormatToolbarDate(widget.selectedDate!)
        : null;
    final horizontalPadding = isForm ? AppTokens.space3 : AppTokens.space2;
    final verticalPadding = isForm ? AppTokens.space2 : 0.0;
    final enabled = widget.enabled;

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        key: _fieldKey,
        width: isForm ? double.infinity : _toolbarFieldWidth,
        height: fieldHeight,
        child: InkWell(
          onTap: enabled ? _openPopover : null,
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: radius,
              border: Border.all(
                color: AppTokens.borderDefault,
                width: AppTokens.borderWidthSm,
              ),
            ),
            child: Opacity(
              opacity: enabled ? 1 : 0.55,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        display ?? widget.hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                          color: display != null
                              ? AppTokens.textPrimary
                              : AppTokens.hintColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.calendar,
                      size: AppTokens.iconButtonIconSm,
                      color: AppTokens.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabIdDatePickerPopover extends StatefulWidget {
  const _LabIdDatePickerPopover({
    required this.panelWidth,
    required this.topLeft,
    required this.selectedDate,
    required this.onCancel,
    required this.onCommit,
  });

  final double panelWidth;
  final Offset topLeft;
  final DateTime? selectedDate;
  final VoidCallback onCancel;
  final ValueChanged<DateTime> onCommit;

  @override
  State<_LabIdDatePickerPopover> createState() =>
      _LabIdDatePickerPopoverState();
}

class _LabIdDatePickerPopoverState extends State<_LabIdDatePickerPopover> {
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static final DateTime _rangeFirst = DateTime(2000, 1, 1);
  static final DateTime _rangeLast = DateTime(2100, 12, 31);

  late DateTime _pickedDay;
  late DateTime _displayMonth;
  bool _showMonthYearSelector = false;
  late int _selectorYear;

  @override
  void initState() {
    super.initState();
    final base = widget.selectedDate ?? DateTime.now();
    _pickedDay = _dateOnly(base);
    _displayMonth = DateTime(_pickedDay.year, _pickedDay.month, 1);
    _selectorYear = _displayMonth.year;
  }

  void _setDisplayYearMonth(int year, int month) {
    final lastDay = DateUtils.getDaysInMonth(year, month);
    final day = math.min(_pickedDay.day, lastDay);
    setState(() {
      _displayMonth = DateTime(year, month, 1);
      _pickedDay = DateTime(year, month, day);
      _selectorYear = year;
    });
  }

  void _shiftMonth(int delta) {
    final y = _displayMonth.year;
    final m = _displayMonth.month;
    final next = DateTime(y, m + delta, 1);
    if (next.isBefore(DateTime(_rangeFirst.year, _rangeFirst.month, 1)) ||
        next.isAfter(DateTime(_rangeLast.year, _rangeLast.month, 1))) {
      return;
    }
    _setDisplayYearMonth(next.year, next.month);
  }

  bool get _canPrevMonth {
    final prev = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    return !prev.isBefore(DateTime(_rangeFirst.year, _rangeFirst.month, 1));
  }

  bool get _canNextMonth {
    final nxt = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    return !nxt.isAfter(DateTime(_rangeLast.year, _rangeLast.month, 1));
  }

  String get _headerMonthYearLabel =>
      '${_kPickerMonthShort[_displayMonth.month - 1]} ${_displayMonth.year}';

  void _onHeaderLeft() {
    if (_showMonthYearSelector) {
      setState(() => _showMonthYearSelector = false);
      return;
    }
    if (_canPrevMonth) _shiftMonth(-1);
  }

  void _onHeaderRight() {
    if (_showMonthYearSelector) return;
    if (_canNextMonth) _shiftMonth(1);
  }

  void _toggleMonthYearSelector() {
    setState(() {
      _showMonthYearSelector = !_showMonthYearSelector;
      if (_showMonthYearSelector) {
        _selectorYear = _displayMonth.year;
      }
    });
  }

  bool _isSelectableDay(DateTime d) {
    final x = _dateOnly(d);
    return !x.isBefore(_rangeFirst) && !x.isAfter(_rangeLast);
  }

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => widget.onCancel(),
          ),
        ),
        Positioned(
          left: widget.topLeft.dx,
          top: widget.topLeft.dy,
          width: widget.panelWidth,
          child: Material(
            color: AppTokens.transparent,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.deferToChild,
              child: Container(
                width: widget.panelWidth,
                decoration: BoxDecoration(
                  color: AppTokens.cardBg,
                  borderRadius: BorderRadius.circular(AppTokens.cardRadius),
                  border: Border.all(
                    color: AppTokens.borderDefault,
                    width: AppTokens.borderWidthSm,
                  ),
                  boxShadow: AppTokens.shadowMd,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space2,
                    vertical: AppTokens.space1,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: AppTokens.space6 + AppTokens.space1,
                          child: Row(
                            children: [
                              _HeaderArrow(
                                icon: LucideIcons.chevronLeft,
                                enabled:
                                    _showMonthYearSelector || _canPrevMonth,
                                onTap: _onHeaderLeft,
                              ),
                              Expanded(
                                child: Center(
                                  child: Material(
                                    color: AppTokens.transparent,
                                    child: InkWell(
                                      onTap: _toggleMonthYearSelector,
                                      borderRadius: BorderRadius.circular(
                                        AppTokens.inputRadius,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTokens.space1,
                                          vertical: AppTokens.spaceHalf,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _headerMonthYearLabel,
                                              style: GoogleFonts.poppins(
                                                fontSize: AppTokens.bodySmSize,
                                                fontWeight:
                                                    AppTokens.weightSemibold,
                                                color: AppTokens.textPrimary,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            SizedBox(width: AppTokens.space1),
                                            Icon(
                                              LucideIcons.chevronDown,
                                              size: AppTokens.textXs,
                                              color: AppTokens.textSecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _HeaderArrow(
                                icon: LucideIcons.chevronRight,
                                enabled:
                                    !_showMonthYearSelector && _canNextMonth,
                                onTap: _onHeaderRight,
                              ),
                            ],
                          ),
                        ),
                        if (_showMonthYearSelector) ...[
                          SizedBox(height: AppTokens.spaceHalf),
                          _MonthYearSelectorBody(
                            panelWidth: widget.panelWidth,
                            selectorYear: _selectorYear,
                            highlightMonth: _displayMonth.month,
                            highlightYear: _displayMonth.year,
                            onYearChanged: (y) =>
                                setState(() => _selectorYear = y),
                            onMonthPicked: (m) {
                              _setDisplayYearMonth(_selectorYear, m);
                              setState(() => _showMonthYearSelector = false);
                            },
                          ),
                        ] else ...[
                          SizedBox(height: AppTokens.spaceHalf),
                          _LabIdDayGrid(
                            displayMonth: _displayMonth,
                            pickedDay: _pickedDay,
                            localizations: loc,
                            isSelectable: _isSelectableDay,
                            onDayTap: (d) {
                              if (!_isSelectableDay(d)) return;
                              setState(() => _pickedDay = _dateOnly(d));
                              widget.onCommit(_dateOnly(d));
                            },
                          ),
                        ],
                        SizedBox(height: AppTokens.spaceHalf),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppButton(
                            label: 'Cancel',
                            variant: AppButtonVariant.tertiary,
                            size: AppButtonSize.sm,
                            onPressed: widget.onCancel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderArrow extends StatelessWidget {
  const _HeaderArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hit = AppTokens.space6 + AppTokens.space1;
    return SizedBox(
      width: hit,
      height: hit,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppTokens.inputRadius),
        child: Icon(
          icon,
          size: AppTokens.iconButtonIconSm,
          color: enabled ? AppTokens.textPrimary : AppTokens.textDisabled,
        ),
      ),
    );
  }
}

class _MonthYearSelectorBody extends StatelessWidget {
  const _MonthYearSelectorBody({
    required this.panelWidth,
    required this.selectorYear,
    required this.highlightMonth,
    required this.highlightYear,
    required this.onYearChanged,
    required this.onMonthPicked,
  });

  final double panelWidth;
  final int selectorYear;
  final int highlightMonth;
  final int highlightYear;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthPicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: AppTokens.space8,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 2100 - 2000 + 1,
            itemBuilder: (context, index) {
              final y = 2000 + index;
              final selected = y == selectorYear;
              return Padding(
                padding: const EdgeInsets.only(right: AppTokens.space1),
                child: Material(
                  color: AppTokens.transparent,
                  child: InkWell(
                    onTap: () => onYearChanged(y),
                    borderRadius: BorderRadius.circular(AppTokens.inputRadius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space2,
                        vertical: AppTokens.spaceHalf,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTokens.primary50
                            : AppTokens.transparent,
                        borderRadius: BorderRadius.circular(
                          AppTokens.inputRadius,
                        ),
                        border: Border.all(
                          color: selected
                              ? AppTokens.primary800
                              : AppTokens.borderDefault,
                          width: AppTokens.borderWidthSm,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$y',
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.tableCellSize,
                          fontWeight: selected
                              ? AppTokens.weightSemibold
                              : FontWeight.w400,
                          color: selected
                              ? AppTokens.primary800
                              : AppTokens.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: AppTokens.spaceHalf),
        SizedBox(
          width: panelWidth - AppTokens.space2 * 2,
          child: Wrap(
            spacing: AppTokens.space1,
            runSpacing: AppTokens.spaceHalf,
            alignment: WrapAlignment.center,
            children: [
              for (var m = 1; m <= 12; m++)
                Material(
                  color: AppTokens.transparent,
                  child: InkWell(
                    onTap: () => onMonthPicked(m),
                    borderRadius: BorderRadius.circular(AppTokens.inputRadius),
                    child: Container(
                      width:
                          (panelWidth -
                              AppTokens.space2 * 2 -
                              AppTokens.space6) /
                          4,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTokens.spaceHalf,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            m == highlightMonth && selectorYear == highlightYear
                            ? AppTokens.primary50
                            : AppTokens.surfaceSubtle,
                        borderRadius: BorderRadius.circular(
                          AppTokens.inputRadius,
                        ),
                        border: Border.all(
                          color: AppTokens.borderDefault,
                          width: AppTokens.borderWidthSm,
                        ),
                      ),
                      child: Text(
                        _kPickerMonthShort[m - 1],
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.captionSize,
                          fontWeight: AppTokens.weightMedium,
                          color: AppTokens.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabIdDayGrid extends StatelessWidget {
  const _LabIdDayGrid({
    required this.displayMonth,
    required this.pickedDay,
    required this.localizations,
    required this.isSelectable,
    required this.onDayTap,
  });

  final DateTime displayMonth;
  final DateTime pickedDay;
  final MaterialLocalizations localizations;
  final bool Function(DateTime d) isSelectable;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final year = displayMonth.year;
    final month = displayMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstOffset = DateUtils.firstDayOffset(year, month, localizations);
    final prevMonthDays = DateTime(year, month, 0).day;
    final weekdays = localizations.narrowWeekdays;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    weekdays[i],
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textXs,
                      fontWeight: AppTokens.weightMedium,
                      color: AppTokens.textMuted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppTokens.spaceHalf),
        for (var row = 0; row < 6; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: _LabIdDayGrid._dayCell(
                    row: row,
                    col: col,
                    firstOffset: firstOffset,
                    daysInMonth: daysInMonth,
                    prevMonthDays: prevMonthDays,
                    year: year,
                    month: month,
                    pickedDay: pickedDay,
                    isSelectable: isSelectable,
                    onDayTap: onDayTap,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  static Widget _dayCell({
    required int row,
    required int col,
    required int firstOffset,
    required int daysInMonth,
    required int prevMonthDays,
    required int year,
    required int month,
    required DateTime pickedDay,
    required bool Function(DateTime d) isSelectable,
    required ValueChanged<DateTime> onDayTap,
  }) {
    final index = row * 7 + col;
    final int dayNumber = index - firstOffset + 1;
    int cellYear = year;
    int cellMonth = month;
    int cellDay;

    if (dayNumber < 1) {
      cellMonth = month - 1;
      if (cellMonth < 1) {
        cellMonth = 12;
        cellYear -= 1;
      }
      cellDay = prevMonthDays + dayNumber;
    } else if (dayNumber > daysInMonth) {
      cellDay = dayNumber - daysInMonth;
      cellMonth = month + 1;
      if (cellMonth > 12) {
        cellMonth = 1;
        cellYear += 1;
      }
    } else {
      cellDay = dayNumber;
    }

    final d = DateTime(cellYear, cellMonth, cellDay);
    final inMonth = dayNumber >= 1 && dayNumber <= daysInMonth;
    final selectable = isSelectable(d);
    final isPicked =
        pickedDay.year == d.year &&
        pickedDay.month == d.month &&
        pickedDay.day == d.day;

    final fg = !inMonth
        ? AppTokens.textMuted
        : (!selectable ? AppTokens.textDisabled : AppTokens.textPrimary);

    return AspectRatio(
      aspectRatio: _kLabIdDayCellAspect,
      child: Material(
        color: AppTokens.transparent,
        child: InkWell(
          onTap: inMonth && selectable ? () => onDayTap(d) : null,
          borderRadius: BorderRadius.circular(AppTokens.chipRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isPicked && inMonth && selectable
                  ? AppTokens.primary800
                  : AppTokens.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${d.day}',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.captionSize,
                  fontWeight: isPicked && inMonth
                      ? AppTokens.weightSemibold
                      : FontWeight.w400,
                  color: isPicked && inMonth && selectable
                      ? AppTokens.white
                      : fg,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
