import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../breakpoints.dart';
import '../../tokens.dart';
import '../cards/app_card.dart';

/// Authentication shell: split marketing panel + form on desktop; stacked on mobile.
class AuthTemplate extends StatelessWidget {
  const AuthTemplate({
    super.key,
    required this.logoWidget,
    required this.appName,
    this.appSubtitle,
    required this.formTitle,
    this.formSubtitle,
    required this.formContent,
    this.footerText,
    this.footerAction,
  });

  final Widget logoWidget;
  final String appName;
  final String? appSubtitle;
  final String formTitle;
  final String? formSubtitle;
  final Widget formContent;
  final String? footerText;
  final Widget? footerAction;

  static double get _formCardMaxWidth =>
      AppTokens.sidebarExpanded * 2; // 420

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = AppBreakpoints.isDesktopWidth(MediaQuery.sizeOf(context).width);

    final footer = _AuthFooter(
      theme: theme,
      footerText: footerText,
      footerAction: footerAction,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: _AuthBrandPanel(
                    theme: theme,
                    logoWidget: logoWidget,
                    appName: appName,
                    appSubtitle: appSubtitle,
                    logoSize: AppTokens.space8 * 2,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _AuthFormColumn(
                    theme: theme,
                    formTitle: formTitle,
                    formSubtitle: formSubtitle,
                    formContent: formContent,
                    footer: footer,
                    cardMaxWidth: _formCardMaxWidth,
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppTokens.space6,
                  horizontal: AppTokens.space4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MobileBrandHeader(
                      theme: theme,
                      logoWidget: logoWidget,
                      logoSize: AppTokens.space8 + AppTokens.space4,
                      appName: appName,
                      appSubtitle: appSubtitle,
                    ),
                    SizedBox(height: AppTokens.space6),
                    AppCard(
                      padding: EdgeInsets.all(AppTokens.space8),
                      child: _AuthFormFields(
                        theme: theme,
                        formTitle: formTitle,
                        formSubtitle: formSubtitle,
                        formContent: formContent,
                      ),
                    ),
                    footer,
                  ],
                ),
              ),
            ),
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel({
    required this.theme,
    required this.logoWidget,
    required this.appName,
    this.appSubtitle,
    required this.logoSize,
  });

  final ThemeData theme;
  final Widget logoWidget;
  final String appName;
  final String? appSubtitle;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTokens.primary800,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: _AuthBrandDecorationPainter(),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppTokens.space8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: IconTheme(
                      data: const IconThemeData(color: AppTokens.white),
                      child: logoWidget,
                    ),
                  ),
                  SizedBox(height: AppTokens.space6),
                  Text(
                    appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppTokens.white,
                      fontWeight: AppTokens.weightSemibold,
                    ),
                  ),
                  if (appSubtitle != null && appSubtitle!.isNotEmpty) ...[
                    SizedBox(height: AppTokens.space2),
                    Text(
                      appSubtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTokens.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBrandDecorationPainter extends CustomPainter {
  const _AuthBrandDecorationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(0);
    for (var i = 0; i < 14; i++) {
      final paint = Paint()
        ..color = (i.isEven ? AppTokens.primary700 : AppTokens.primary600)
            .withValues(
          alpha: AppTokens.overlayPrimaryAlpha +
              rnd.nextDouble() * AppTokens.overlayPrimaryAlpha,
        );
      final w = size.width * (0.08 + rnd.nextDouble() * 0.12);
      final h = size.height * (0.06 + rnd.nextDouble() * 0.1);
      final left = rnd.nextDouble() * size.width * 0.85;
      final top = rnd.nextDouble() * size.height * 0.85;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, w, h),
        Radius.circular(AppTokens.radiusLg),
      );
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthFormColumn extends StatelessWidget {
  const _AuthFormColumn({
    required this.theme,
    required this.formTitle,
    this.formSubtitle,
    required this.formContent,
    required this.footer,
    required this.cardMaxWidth,
  });

  final ThemeData theme;
  final String formTitle;
  final String? formSubtitle;
  final Widget formContent;
  final Widget footer;
  final double cardMaxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardMaxWidth),
              child: AppCard(
                padding: EdgeInsets.all(AppTokens.space8),
                child: _AuthFormFields(
                  theme: theme,
                  formTitle: formTitle,
                  formSubtitle: formSubtitle,
                  formContent: formContent,
                ),
              ),
            ),
            footer,
          ],
        ),
      ),
    );
  }
}

class _AuthFormFields extends StatelessWidget {
  const _AuthFormFields({
    required this.theme,
    required this.formTitle,
    this.formSubtitle,
    required this.formContent,
  });

  final ThemeData theme;
  final String formTitle;
  final String? formSubtitle;
  final Widget formContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.onSurface
                : AppTokens.neutral900,
          ),
        ),
        if (formSubtitle != null && formSubtitle!.isNotEmpty) ...[
          SizedBox(height: AppTokens.space2),
          Text(
            formSubtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? AppTokens.neutral400
                  : AppTokens.neutral500,
            ),
          ),
        ],
        SizedBox(height: AppTokens.space6),
        formContent,
      ],
    );
  }
}

class _MobileBrandHeader extends StatelessWidget {
  const _MobileBrandHeader({
    required this.theme,
    required this.logoWidget,
    required this.logoSize,
    required this.appName,
    this.appSubtitle,
  });

  final ThemeData theme;
  final Widget logoWidget;
  final double logoSize;
  final String appName;
  final String? appSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: logoSize,
          height: logoSize,
          child: IconTheme(
            data: const IconThemeData(color: AppTokens.primary800),
            child: logoWidget,
          ),
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          appName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTokens.primary800,
            fontWeight: AppTokens.weightSemibold,
          ),
        ),
        if (appSubtitle != null && appSubtitle!.isNotEmpty) ...[
          SizedBox(height: AppTokens.space2),
          Text(
            appSubtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTokens.primary800.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({
    required this.theme,
    this.footerText,
    this.footerAction,
  });

  final ThemeData theme;
  final String? footerText;
  final Widget? footerAction;

  @override
  Widget build(BuildContext context) {
    if ((footerText == null || footerText!.isEmpty) && footerAction == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: AppTokens.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (footerText != null && footerText!.isNotEmpty)
            Text(
              footerText!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppTokens.neutral400
                    : AppTokens.neutral500,
              ),
            ),
          if (footerAction != null) ...[
            SizedBox(height: AppTokens.space2),
            footerAction!,
          ],
        ],
      ),
    );
  }
}
