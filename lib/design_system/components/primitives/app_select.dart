import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';
import 'app_input.dart' show AppInputSize;

class AppSelectItem<T> {
  const AppSelectItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
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

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;

  double get _inputHeight => switch (widget.size) {
        AppInputSize.sm => 30.0,
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

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  void _selectItem(T value) {
    widget.onChanged?.call(value);
    _closeOverlay();
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => _SelectOverlay<T>(
        layerLink: _layerLink,
        triggerWidth: size.width,
        items: widget.items,
        selectedValue: widget.value,
        onSelect: _selectItem,
        onDismiss: _closeOverlay,
        fontSize: _fontSize,
      ),
    );
  }

  @override
  void dispose() {
    _closeOverlay();
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
    final borderWidth = _isOpen ? AppTokens.focusRingWidth : AppTokens.borderWidthSm;

    return Material(
      type: MaterialType.transparency,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
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
              height: _inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: widget.enabled ? AppTokens.cardBg : AppTokens.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppTokens.inputRadius),
                border: Border.all(color: borderColor, width: borderWidth),
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
    ),
    );
  }
}

class _SelectOverlay<T> extends StatefulWidget {
  const _SelectOverlay({
    required this.layerLink,
    required this.triggerWidth,
    required this.items,
    required this.selectedValue,
    required this.onSelect,
    required this.onDismiss,
    required this.fontSize,
  });

  final LayerLink layerLink;
  final double triggerWidth;
  final List<AppSelectItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelect;
  final VoidCallback onDismiss;
  final double fontSize;

  @override
  State<_SelectOverlay<T>> createState() => _SelectOverlayState<T>();
}

class _SelectOverlayState<T> extends State<_SelectOverlay<T>> {
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppSelectItem<T>> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    final q = _searchQuery.toLowerCase();
    return widget.items
        .where((item) => item.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final showSearch = widget.items.length > 5;
    final filtered = _filteredItems;

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
          offset: const Offset(0, 2),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              type: MaterialType.transparency,
              color: AppTokens.cardBg,
              borderRadius: BorderRadius.circular(AppTokens.cardRadius),
              child: Container(
                width: widget.triggerWidth,
                constraints: const BoxConstraints(maxHeight: 240),
                decoration: BoxDecoration(
                  color: AppTokens.cardBg,
                  borderRadius: BorderRadius.circular(AppTokens.cardRadius),
                  border: Border.all(color: AppTokens.borderDefault),
                  boxShadow: AppTokens.shadowMd,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSearch)
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.poppins(
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w400,
                              color: AppTokens.textPrimary,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: AppTokens.surfaceSubtle,
                              hintText: 'Search...',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: widget.fontSize,
                                color: AppTokens.hintColor,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                borderSide: BorderSide(color: AppTokens.borderDefault),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                borderSide: BorderSide(color: AppTokens.borderDefault),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                borderSide: BorderSide(
                                  color: AppTokens.borderFocus,
                                  width: AppTokens.focusRingWidth,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Flexible(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = item.value == widget.selectedValue;
                          return _SelectMenuItem<T>(
                            item: item,
                            isSelected: isSelected,
                            onTap: () => widget.onSelect(item.value),
                            fontSize: widget.fontSize,
                          );
                        },
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

class _SelectMenuItem<T> extends StatefulWidget {
  const _SelectMenuItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.fontSize,
  });

  final AppSelectItem<T> item;
  final bool isSelected;
  final VoidCallback onTap;
  final double fontSize;

  @override
  State<_SelectMenuItem<T>> createState() => _SelectMenuItemState<T>();
}

class _SelectMenuItemState<T> extends State<_SelectMenuItem<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    if (widget.isSelected) bgColor = AppTokens.primary50;
    if (_hovered && !widget.isSelected) bgColor = AppTokens.surfaceSubtle;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 32,
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  size: 14,
                  color: widget.isSelected
                      ? AppTokens.primary800
                      : AppTokens.textMuted,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: GoogleFonts.poppins(
                    fontSize: widget.fontSize,
                    fontWeight:
                        widget.isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: widget.isSelected
                        ? AppTokens.primary800
                        : AppTokens.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
