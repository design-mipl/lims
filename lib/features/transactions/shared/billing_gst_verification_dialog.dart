import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../design_system/components/components.dart';
import '../../../design_system/tokens.dart';
/// Payment-app style GST verification success / failure modal (Customer Invoice &
/// Credit Note).
class BillingGstVerificationDialog extends StatefulWidget {
  const BillingGstVerificationDialog._({
    required this.success,
    required this.title,
    required this.subtitle,
    this.errorMessage,
    this.successMessage,
    this.onViewStatus,
    this.onRetry,
    this.autoDismissSuccess = false,
  });

  final bool success;
  final String title;
  final String subtitle;
  final String? errorMessage;
  final String? successMessage;
  final VoidCallback? onViewStatus;
  final VoidCallback? onRetry;
  final bool autoDismissSuccess;

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String successMessage,
    VoidCallback? onViewStatus,
    bool autoDismiss = false,
  }) {
    return _show(
      context,
      BillingGstVerificationDialog._(
        success: true,
        title: title,
        subtitle: subtitle,
        successMessage: successMessage,
        onViewStatus: onViewStatus,
        autoDismissSuccess: autoDismiss,
      ),
    );
  }

  static Future<void> showFailure(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String errorMessage,
    VoidCallback? onRetry,
  }) {
    return _show(
      context,
      BillingGstVerificationDialog._(
        success: false,
        title: title,
        subtitle: subtitle,
        errorMessage: errorMessage,
        onRetry: onRetry,
      ),
    );
  }

  static Future<void> _show(
    BuildContext context,
    BillingGstVerificationDialog dialog,
  ) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: AppTokens.modalBarrierScrim,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () {
              Navigator.of(ctx).maybePop();
            },
          },
          child: Focus(
            autofocus: true,
            child: Center(
              child: Material(
                type: MaterialType.transparency,
                child: dialog,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<BillingGstVerificationDialog> createState() =>
      _BillingGstVerificationDialogState();
}

class _BillingGstVerificationDialogState
    extends State<BillingGstVerificationDialog>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconScale;
  late Animation<double> _checkFade;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _iconScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );
    _checkFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.45, 1, curve: Curves.easeOut),
      ),
    );
    _iconController.forward();

    if (widget.success && widget.autoDismissSuccess) {
      _autoCloseTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _iconController.dispose();
    super.dispose();
  }

  void _close() {
    _autoCloseTimer?.cancel();
    Navigator.of(context).pop();
  }

  void _onViewStatus() {
    _autoCloseTimer?.cancel();
    Navigator.of(context).pop();
    widget.onViewStatus?.call();
  }

  void _onRetry() {
    _autoCloseTimer?.cancel();
    Navigator.of(context).pop();
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    final success = widget.success;
    final iconBg = success ? AppTokens.success100 : AppTokens.error100;
    final iconColor = success ? AppTokens.success500 : AppTokens.error500;
    final icon = success ? LucideIcons.check : LucideIcons.x;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppTokens.space4),
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
          padding: EdgeInsets.fromLTRB(
            AppTokens.space5,
            AppTokens.space5,
            AppTokens.space5,
            AppTokens.space4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _iconScale,
                child: Container(
                  width: AppTokens.space12,
                  height: AppTokens.space12,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: FadeTransition(
                    opacity: _checkFade,
                    child: Icon(
                      icon,
                      size: AppTokens.space6,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppTokens.space4),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.textMd,
                  fontWeight: AppTokens.weightSemibold,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space2),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textSecondary,
                ),
              ),
              if (success &&
                  widget.successMessage != null &&
                  widget.successMessage!.trim().isNotEmpty) ...[
                SizedBox(height: AppTokens.space3),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppTokens.space3),
                  decoration: BoxDecoration(
                    color: AppTokens.success100,
                    borderRadius: BorderRadius.circular(AppTokens.inputRadius),
                    border: Border.all(
                      color: AppTokens.success500.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.circleCheck,
                        size: AppTokens.iconButtonIconSm,
                        color: AppTokens.success500,
                      ),
                      SizedBox(width: AppTokens.space2),
                      Expanded(
                        child: Text(
                          widget.successMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.captionSize,
                            fontWeight: AppTokens.weightMedium,
                            color: AppTokens.success500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!success &&
                  widget.errorMessage != null &&
                  widget.errorMessage!.trim().isNotEmpty) ...[
                SizedBox(height: AppTokens.space3),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppTokens.space3),
                  decoration: BoxDecoration(
                    color: AppTokens.error100,
                    borderRadius: BorderRadius.circular(AppTokens.inputRadius),
                    border: Border.all(
                      color: AppTokens.error500.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    widget.errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.captionSize,
                      color: AppTokens.error500,
                    ),
                  ),
                ),
              ],
              SizedBox(height: AppTokens.space5),
              Row(
                children: success
                    ? [
                        Expanded(
                          child: AppButton(
                            label: 'Done',
                            variant: AppButtonVariant.outlined,
                            size: AppButtonSize.md,
                            onPressed: _close,
                          ),
                        ),
                        SizedBox(width: AppTokens.space2),
                        Expanded(
                          child: AppButton(
                            label: 'View Status',
                            variant: AppButtonVariant.primary,
                            size: AppButtonSize.md,
                            onPressed: _onViewStatus,
                          ),
                        ),
                      ]
                    : [
                        if (widget.onRetry != null)
                          Expanded(
                            child: AppButton(
                              label: 'Retry',
                              variant: AppButtonVariant.primary,
                              size: AppButtonSize.md,
                              onPressed: _onRetry,
                            ),
                          ),
                        if (widget.onRetry != null)
                          SizedBox(width: AppTokens.space2),
                        Expanded(
                          child: AppButton(
                            label: 'Close',
                            variant: AppButtonVariant.outlined,
                            size: AppButtonSize.md,
                            onPressed: _close,
                          ),
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
