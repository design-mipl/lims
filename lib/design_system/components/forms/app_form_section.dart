import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';
import 'app_form_field_row.dart';

/// Card-style section for medium/large forms.
///
/// Provide either [children] (preferred — responsive 2-column Row/Column grid)
/// or the legacy [child] (renders as-is).
class AppFormSection extends StatelessWidget {
  const AppFormSection({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    this.children,
    this.child,
  }) : assert(
          children != null || child != null,
          'Provide either children or child',
        );

  final String title;
  final String? description;
  final Widget? trailing;

  /// Grid children. [AppFormFullWidth] items span both columns.
  final List<Widget>? children;

  /// Legacy single-child passthrough.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.brightness == Brightness.dark
        ? theme.cardColor
        : AppTokens.cardBg;
    final borderColor = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.borderDefault;

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.sectionTitleSize,
                          fontWeight: AppTokens.sectionTitleWeight,
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurface
                              : AppTokens.textPrimary,
                        ),
                      ),
                      if (description != null && description!.isNotEmpty) ...[
                        SizedBox(height: AppTokens.space1),
                        Text(
                          description!,
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.bodySize,
                            fontWeight: AppTokens.bodyWeight,
                            color: theme.brightness == Brightness.dark
                                ? AppTokens.textMuted
                                : AppTokens.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: AppTokens.space3),
                  trailing!,
                ],
              ],
            ),
            SizedBox(height: AppTokens.space3),
            if (children != null)
              _GridBody(children: children!)
            else
              child!,
          ],
        ),
      ),
    );
  }
}

class _GridBody extends StatelessWidget {
  const _GridBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = AppBreakpoints.isMobileWidth(screenWidth);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _buildMobileChildren(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _buildDesktopRows(),
    );
  }

  List<Widget> _buildMobileChildren() {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        result.add(SizedBox(height: AppTokens.space3));
      }
      final child = children[i];
      if (child is AppFormFullWidth) {
        result.add(child.child);
      } else {
        result.add(child);
      }
    }
    return result;
  }

  List<Widget> _buildDesktopRows() {
    final result = <Widget>[];
    var i = 0;

    while (i < children.length) {
      if (result.isNotEmpty) {
        result.add(SizedBox(height: AppTokens.space3));
      }

      final current = children[i];

      if (current is AppFormFullWidth) {
        result.add(current.child);
        i++;
        continue;
      }

      final hasNext = i + 1 < children.length;
      final next = hasNext ? children[i + 1] : null;
      final nextIsFullWidth = next is AppFormFullWidth;

      if (hasNext && !nextIsFullWidth) {
        result.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: current),
              SizedBox(width: AppTokens.space3),
              Expanded(child: next!),
            ],
          ),
        );
        i += 2;
      } else {
        result.add(
          Row(
            children: [
              Expanded(child: current),
              SizedBox(width: AppTokens.space3),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        );
        i++;
      }
    }
    return result;
  }
}
