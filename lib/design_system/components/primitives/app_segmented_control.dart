import 'package:flutter/material.dart';

import '../../tokens.dart';

/// One segment in [AppSegmentedControl].
class AppSegment<T> {
  const AppSegment({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Compact segmented control for binary or small enums (Active/Inactive, etc.).
class AppSegmentedControl<T extends Object> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppTokens.borderDefault),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: SizedBox(
          height: 32,
          child: Row(
            children: [
              for (var i = 0; i < segments.length; i++) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    color: AppTokens.borderDefault,
                  ),
                Expanded(
                  child: _SegmentCell<T>(
                    segment: segments[i],
                    selected: segments[i].value == selected,
                    onTap: () => onChanged(segments[i].value),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentCell<T> extends StatelessWidget {
  const _SegmentCell({
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  final AppSegment<T> segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppTokens.primary800 : AppTokens.white;
    final fg = selected ? AppTokens.white : AppTokens.textSecondary;
    final weight = selected ? AppTokens.weightMedium : AppTokens.weightRegular;

    return Material(
      color: bg,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (segment.icon != null) ...[
                  Icon(
                    segment.icon,
                    size: 14,
                    color: fg,
                  ),
                  const SizedBox(width: AppTokens.space1),
                ],
                Flexible(
                  child: Text(
                    segment.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily:
                          Theme.of(context).textTheme.bodyMedium?.fontFamily ??
                              AppTokens.fontFamily,
                      fontSize: 12,
                      fontWeight: weight,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
