import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../tokens.dart';
import '../primitives/app_button.dart';

/// Category for [ErrorTemplate] defaults and iconography.
enum ErrorTemplateType {
  notFound,
  unauthorized,
  serverError,
  noInternet,
  empty,
}

/// Centered error / empty state page.
class ErrorTemplate extends StatelessWidget {
  const ErrorTemplate({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.onBack,
  });

  final ErrorTemplateType type;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onBack;

  static String _defaultTitle(ErrorTemplateType t) {
    switch (t) {
      case ErrorTemplateType.notFound:
        return 'Page Not Found';
      case ErrorTemplateType.unauthorized:
        return 'Access Denied';
      case ErrorTemplateType.serverError:
        return 'Something Went Wrong';
      case ErrorTemplateType.noInternet:
        return 'No Connection';
      case ErrorTemplateType.empty:
        return 'Nothing Here Yet';
    }
  }

  static String _defaultMessage(ErrorTemplateType t) {
    switch (t) {
      case ErrorTemplateType.notFound:
        return "The page you're looking for doesn't exist.";
      case ErrorTemplateType.unauthorized:
        return "You don't have permission to view this.";
      case ErrorTemplateType.serverError:
        return 'An unexpected error occurred.';
      case ErrorTemplateType.noInternet:
        return 'Check your internet connection.';
      case ErrorTemplateType.empty:
        return 'No records have been added yet.';
    }
  }

  IconData _iconForType() {
    switch (type) {
      case ErrorTemplateType.notFound:
        return LucideIcons.mapPinOff;
      case ErrorTemplateType.unauthorized:
        return LucideIcons.lock;
      case ErrorTemplateType.serverError:
        return LucideIcons.triangleAlert;
      case ErrorTemplateType.noInternet:
        return LucideIcons.wifiOff;
      case ErrorTemplateType.empty:
        return LucideIcons.inbox;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedTitle = title ?? _defaultTitle(type);
    final resolvedMessage = message ?? _defaultMessage(type);
    final iconSize = AppTokens.space8 * 2;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconForType(),
              size: iconSize,
              color: AppTokens.neutral300,
            ),
            SizedBox(height: AppTokens.space4),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTokens.listingFilterPanelWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    resolvedTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppTokens.neutral300
                          : AppTokens.neutral700,
                    ),
                  ),
                  SizedBox(height: AppTokens.space2),
                  Text(
                    resolvedMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppTokens.neutral400
                          : AppTokens.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppTokens.space6),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.md,
              ),
            ],
            if (onBack != null) ...[
              SizedBox(height: AppTokens.space2),
              AppButton(
                label: 'Go Back',
                onPressed: onBack,
                variant: AppButtonVariant.tertiary,
                size: AppButtonSize.md,
                leadingIcon: const Icon(LucideIcons.chevronLeft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
