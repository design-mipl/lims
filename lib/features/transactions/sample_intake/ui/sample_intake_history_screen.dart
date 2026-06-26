import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../quotation/ui/widgets/quotation_activity_timeline.dart';
import '../sample_intake_synthetic_activity.dart';
import '../state/sample_intake_provider.dart';

/// Read-only activity timeline for a sample intake receipt (from listing actions).
class SampleIntakeHistoryScreen extends StatefulWidget {
  const SampleIntakeHistoryScreen({super.key, required this.receiptId});

  final String receiptId;

  @override
  State<SampleIntakeHistoryScreen> createState() =>
      _SampleIntakeHistoryScreenState();
}

class _SampleIntakeHistoryScreenState extends State<SampleIntakeHistoryScreen> {
  SampleIntakeProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<SampleIntakeProvider>();
      _provider!.addListener(_onProviderChanged);
      await _provider!.fetchById(widget.receiptId);
    });
  }

  void _onProviderChanged() {
    final pr = _provider;
    if (pr == null || !pr.hasError || !mounted) return;
    final message = pr.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      pr.clearError();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onCancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions/sample-intake');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();
    final r = p.selected;

    if (p.isLoading && r == null) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: SizedBox(
            width: AppTokens.inlineProgressIndicatorSize + AppTokens.space3,
            height: AppTokens.inlineProgressIndicatorSize + AppTokens.space3,
            child: CircularProgressIndicator(
              strokeWidth: AppTokens.inlineProgressIndicatorStrokeWidth,
              color: AppTokens.primary800,
            ),
          ),
        ),
      );
    }

    if (r == null || r.id != widget.receiptId) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Receipt not found',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space3),
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.primary,
                onPressed: _onCancel,
              ),
            ],
          ),
        ),
      );
    }

    final body = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormSection(
        title: 'Activity',
        children: [
          QuotationActivityTimeline(
            entries: syntheticSampleIntakeActivity(r),
          ),
        ],
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Sample Intake',
        parentRoute: '/transactions/sample-intake',
        currentLabel: r.lotNo,
        tabController: null,
        headerCard: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(
              name: r.lotNo,
              size: AppAvatarSize.lg,
            ),
            SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${r.lotNo} · Activity',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textXl,
                      fontWeight: AppTokens.weightBold,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTokens.space1),
                  Wrap(
                    spacing: AppTokens.space4,
                    runSpacing: AppTokens.space1,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.history,
                            size: AppTokens.textSm,
                            color: AppTokens.textMuted,
                          ),
                          SizedBox(width: AppTokens.space1),
                          Text(
                            'History for this receipt',
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.textSm,
                              color: AppTokens.textMuted,
                              fontWeight: AppTokens.weightRegular,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.primary,
              onPressed: _onCancel,
            ),
          ],
        ),
        tabLabels: const ['History'],
        tabViews: [
          body,
        ],
      ),
    );
  }
}
