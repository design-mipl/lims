import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';
import 'app_button.dart';
import 'app_input.dart';

class AppSelectItem<T> {
  const AppSelectItem({
    required this.value,
    required this.label,
    this.code,
    this.icon,
  });

  final T value;
  final String label;

  /// When non-null/non-empty, overlay uses CODE | NAME columns and header row.
  final String? code;
  final IconData? icon;
}

class AppSelect<T> extends StatefulWidget {
  const AppSelect({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
    this.size = AppInputSize.md,
    this.isSearchable = true,
    this.countLabel,
  });

  final String? label;
  final String? hint;
  final T? value;
  final List<AppSelectItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final String? errorText;
  final bool enabled;
  final AppInputSize size;

  /// When true, overlay includes search (default true).
  final bool isSearchable;

  /// Noun after count, e.g. `'tests'` → `"5 tests"`. Defaults to `'items'`.
  final String? countLabel;

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  bool _isOpen = false;

  double get _inputHeight => switch (widget.size) {
        AppInputSize.sm => AppTokens.buttonHeightMd,
        AppInputSize.md => AppTokens.inputHeight,
        AppInputSize.lg => 38.0,
      };

  double get _fontSize => switch (widget.size) {
        AppInputSize.sm => 11.0,
        AppInputSize.md => 12.0,
        AppInputSize.lg => 13.0,
      };

  void _openOverlay() {
    if (!widget.enabled || _isOpen) return;
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _detachOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _closeOverlay() {
    _detachOverlay();
    if (mounted) setState(() => _isOpen = false);
  }

  void _selectItem(T value) {
    widget.onChanged?.call(value);
    _closeOverlay();
  }

  OverlayEntry _buildOverlay() {
    final fieldRo =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final fallbackRo = context.findRenderObject() as RenderBox;
    final triggerW = fieldRo?.size.width ?? fallbackRo.size.width;
    final triggerH = fieldRo?.size.height ?? _inputHeight;

    return OverlayEntry(
      builder: (context) => _SelectOverlay<T>(
        layerLink: _layerLink,
        triggerWidth: triggerW,
        triggerHeight: triggerH,
        items: widget.items,
        selectedValue: widget.value,
        onSelect: _selectItem,
        onDismiss: _closeOverlay,
        showSearch: widget.isSearchable,
        countLabel: widget.countLabel ?? 'items',
      ),
    );
  }

  @override
  void dispose() {
    _detachOverlay();
    _isOpen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final selectedItem = widget.items.cast<AppSelectItem<T>?>().firstWhere(
          (item) => item?.value == widget.value,
          orElse: () => null,
        );

    final borderColor = hasError
        ? AppTokens.error500
        : _isOpen
            ? AppTokens.borderFocus
            : AppTokens.borderDefault;
    final borderWidth =
        _isOpen ? AppTokens.focusRingWidth : AppTokens.borderWidthSm;

    final hasLabel = widget.label != null && widget.label!.isNotEmpty;
    final compactField = !hasLabel && !hasError;

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          final triggerHeight = compactField &&
                  maxH.isFinite &&
                  maxH > 0 &&
                  maxH < _inputHeight
              ? maxH
              : _inputHeight;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasLabel) ...[
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.fieldLabelSize,
                      fontWeight: AppTokens.fieldLabelWeight,
                      color: AppTokens.labelColor,
                    ),
                    children: [
                      TextSpan(text: widget.label),
                      if (widget.isRequired)
                        TextSpan(
                          text: ' *',
                          style: GoogleFonts.poppins(
                            color: AppTokens.error500,
                            fontSize: AppTokens.fieldLabelSize,
                            fontWeight: AppTokens.fieldLabelWeight,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
              CompositedTransformTarget(
                link: _layerLink,
                child: GestureDetector(
                  onTap: _isOpen ? _closeOverlay : _openOverlay,
                  child: Container(
                    key: _fieldKey,
                    height: triggerHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: widget.enabled
                          ? AppTokens.cardBg
                          : AppTokens.surfaceSubtle,
                      borderRadius:
                          BorderRadius.circular(AppTokens.inputRadius),
                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedItem?.label ?? widget.hint ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: _fontSize,
                              fontWeight: FontWeight.w400,
                              color: selectedItem != null
                                  ? AppTokens.textPrimary
                                  : AppTokens.hintColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronDown,
                          size: 14,
                          color: AppTokens.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    widget.errorText!,
                    style: GoogleFonts.poppins(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w400,
                      color: AppTokens.error500,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

const double _kCodeColumnWidth = 80;
const double _kOverlayMaxHeight = 320;
const double _kOverlayMinWidth = 320;

class _SelectOverlay<T> extends StatefulWidget {
  const _SelectOverlay({
    required this.layerLink,
    required this.triggerWidth,
    required this.triggerHeight,
    required this.items,
    required this.selectedValue,
    required this.onSelect,
    required this.onDismiss,
    required this.showSearch,
    required this.countLabel,
  });

  final LayerLink layerLink;
  final double triggerWidth;
  final double triggerHeight;
  final List<AppSelectItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelect;
  final VoidCallback onDismiss;
  final bool showSearch;
  final String countLabel;

  @override
  State<_SelectOverlay<T>> createState() => _SelectOverlayState<T>();
}

class _SelectOverlayState<T> extends State<_SelectOverlay<T>> {
  String _searchQuery = '';
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  bool get _hasCode => widget.items.any(
        (e) => e.code != null && e.code!.trim().isNotEmpty,
      );

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    if (widget.showSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<AppSelectItem<T>> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    final q = _searchQuery.toLowerCase().trim();
    return widget.items.where((item) {
      final labelHit = item.label.toLowerCase().contains(q);
      final code = item.code?.toLowerCase() ?? '';
      final codeHit = code.isNotEmpty && code.contains(q);
      return labelHit || codeHit;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final overlayWidth =
        math.max(widget.triggerWidth, _kOverlayMinWidth);

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onDismiss,
          child: const SizedBox.expand(),
        ),
        CompositedTransformFollower(
          link: widget.layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, widget.triggerHeight + 2),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: overlayWidth,
                height: _kOverlayMaxHeight,
                decoration: BoxDecoration(
                  color: AppTokens.white,
                  borderRadius:
                      BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: AppTokens.border),
                  boxShadow: AppTokens.shadowMd,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.showSearch)
                      Padding(
                        padding: EdgeInsets.all(AppTokens.space2),
                        child: AppInput(
                          hint: 'Search by code or name...',
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          size: AppInputSize.sm,
                          prefixIcon: Icon(
                            LucideIcons.search,
                            size: AppTokens.iconSizeMd,
                            color: AppTokens.textMuted,
                          ),
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                        ),
                      ),
                    if (_hasCode)
                      Container(
                        color: AppTokens.primary800,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTokens.space3,
                          vertical: AppTokens.space2,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: _kCodeColumnWidth,
                              child: Text(
                                'CODE',
                                style: GoogleFonts.poppins(
                                  color: AppTokens.white,
                                  fontSize: AppTokens.textXs,
                                  fontWeight: AppTokens.weightSemibold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'NAME',
                                style: GoogleFonts.poppins(
                                  color: AppTokens.white,
                                  fontSize: AppTokens.textXs,
                                  fontWeight: AppTokens.weightSemibold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected =
                              item.value == widget.selectedValue;
                          return _SelectOverlayRow<T>(
                            item: item,
                            hasCode: _hasCode,
                            isSelected: isSelected,
                            onTap: () => widget.onSelect(item.value),
                          );
                        },
                      ),
                    ),
                    Divider(
                      height: AppTokens.borderWidthSm,
                      thickness: AppTokens.borderWidthSm,
                      color: AppTokens.border,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTokens.space3,
                        vertical: AppTokens.space2,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${filtered.length} ${widget.countLabel}',
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.textXs,
                              color: AppTokens.textMuted,
                              fontWeight: AppTokens.weightRegular,
                            ),
                          ),
                          const Spacer(),
                          AppButton(
                            label: 'Close',
                            variant: AppButtonVariant.tertiary,
                            size: AppButtonSize.sm,
                            onPressed: widget.onDismiss,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectOverlayRow<T> extends StatefulWidget {
  const _SelectOverlayRow({
    required this.item,
    required this.hasCode,
    required this.isSelected,
    required this.onTap,
  });

  final AppSelectItem<T> item;
  final bool hasCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SelectOverlayRow<T>> createState() => _SelectOverlayRowState<T>();
}

class _SelectOverlayRowState<T> extends State<_SelectOverlayRow<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final showCodeCol = widget.hasCode;
    final code = item.code?.trim();

    Color background;
    if (widget.isSelected) {
      background = AppTokens.primary50;
    } else if (_hovered) {
      background = AppTokens.pageBg;
    } else {
      background = Colors.transparent;
    }

    final nameColor = widget.isSelected
        ? AppTokens.accent500
        : AppTokens.textPrimary;

    final codeColor = AppTokens.primary800;

    Widget nameCell = Row(
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: AppTokens.iconSizeMd,
            color:
                widget.isSelected ? AppTokens.accent500 : AppTokens.textMuted,
          ),
          SizedBox(width: AppTokens.space1),
        ],
        Expanded(
          child: Text(
            item.label,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.textSm,
              fontWeight: FontWeight.w400,
              color: nameColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: background,
        child: InkWell(
          onTap: widget.onTap,
          hoverColor: widget.isSelected
              ? Colors.transparent
              : AppTokens.pageBg,
          child: SizedBox(
            height: AppTokens.tableRowHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space3,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showCodeCol) ...[
                    SizedBox(
                      width: _kCodeColumnWidth,
                      child: Text(
                        code ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.textSm,
                          fontWeight: FontWeight.w500,
                          color: codeColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(child: nameCell),
                  ] else
                    Expanded(child: nameCell),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
