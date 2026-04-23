import 'package:flutter/material.dart';

import '../../tokens.dart';
import '../cards/app_card.dart';
import 'template_pulse.dart';

/// Card with uppercase section header and optional action.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    required this.child,
    this.contentPadding,
    this.noPadding = false,
    this.headerRight,
    this.isLoading = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;
  final EdgeInsetsGeometry? contentPadding;
  final bool noPadding;
  final Widget? headerRight;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.neutral100;

    final Widget body = isLoading
        ? TemplatePulse(
            child: Padding(
              padding: EdgeInsets.all(AppTokens.space4),
              child: _SectionSkeletonLines(theme: theme),
            ),
          )
        : noPadding
            ? child
            : Padding(
                padding: contentPadding ?? EdgeInsets.all(AppTokens.space4),
                child: child,
              );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppTokens.space4,
              AppTokens.space4,
              AppTokens.space4,
              AppTokens.space2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppTokens.neutral400
                          : AppTokens.neutral600,
                      fontWeight: AppTokens.weightSemibold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                if (headerRight != null)
                  headerRight!
                else if (actionLabel != null && onAction != null)
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTokens.accent500,
                      padding: EdgeInsets.symmetric(horizontal: AppTokens.space2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      actionLabel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTokens.accent500,
                        fontWeight: AppTokens.weightMedium,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            height: AppTokens.borderWidthHairline,
            thickness: AppTokens.borderWidthHairline,
            color: dividerColor,
          ),
          body,
        ],
      ),
    );
  }
}

class _SectionSkeletonLines extends StatelessWidget {
  const _SectionSkeletonLines({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final bg = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.neutral200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: AppTokens.space2),
          child: Container(
            height: AppTokens.space3,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
          ),
        ),
      ),
    );
  }
}
