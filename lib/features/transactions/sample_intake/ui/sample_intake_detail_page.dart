import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../state/sample_intake_provider.dart';
import 'widgets/sample_data_entry_table.dart';

/// Sample receipt detail with summary strip and per-sample data entry grid.
class SampleIntakeDetailPage extends StatefulWidget {
  const SampleIntakeDetailPage({super.key, required this.receiptId});

  final String receiptId;

  @override
  State<SampleIntakeDetailPage> createState() => _SampleIntakeDetailPageState();
}

class _SampleIntakeDetailPageState extends State<SampleIntakeDetailPage> {
  SampleIntakeProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<SampleIntakeProvider>();
      _provider!.addListener(_onProviderChanged);
      context.read<SampleIntakeProvider>().fetchById(widget.receiptId);
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

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions/sample-intake');
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _mockAction(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label — coming soon.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.neutral700,
      ),
    );
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
      return AppFormPage(
        title: 'Receipt not found',
        subtitle: 'ID: ${widget.receiptId}',
        onBack: () => _back(context),
        body: Center(
          child: Text(
            'This receipt could not be loaded.',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return AppFormPage(
      title: 'Sample receipt — data entry',
      subtitle: r.lotNo,
      onBack: () => _back(context),
      scrollBody: false,
      fullWidthBody: true,
      actions: [
        AppButton(
          label: 'Export',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.md,
          onPressed: () => _mockAction(context, 'Export'),
        ),
        AppButton(
          label: 'Send mail',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.md,
          onPressed: () => _mockAction(context, 'Send mail'),
        ),
        AppButton(
          label: 'Generate LC',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.md,
          onPressed: () => _mockAction(context, 'Generate LC'),
        ),
        AppButton(
          label: 'Print LC',
          variant: AppButtonVariant.tertiary,
          size: AppButtonSize.md,
          onPressed: () => _mockAction(context, 'Print LC'),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                context.read<SampleIntakeProvider>().clearActiveRow(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTokens.cardBg,
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                border: Border.all(
                  color: AppTokens.borderDefault,
                  width: AppTokens.borderWidthSm,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTokens.space4),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth <
                        AppTokens.layoutBreakpointCompact;
                    final completed = context.select<SampleIntakeProvider, int>(
                      (pr) => pr.getCompletedCount(),
                    );

                    Widget block(String title, Widget child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.tableHeaderSize,
                              fontWeight: AppTokens.weightSemibold,
                              color: AppTokens.textMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          SizedBox(height: AppTokens.space1),
                          DefaultTextStyle(
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.bodySize,
                              color: AppTokens.textPrimary,
                            ),
                            child: child,
                          ),
                        ],
                      );
                    }

                    final customerCompany = '${r.customerName}'
                        '${r.customerCompany.isEmpty ? '' : ' · ${r.customerCompany}'}';

                    final statusRow = Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Status',
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.tableHeaderSize,
                            fontWeight: AppTokens.weightSemibold,
                            color: AppTokens.textMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(width: AppTokens.space3),
                        StatusChip(status: r.status),
                      ],
                    );

                    final cellWidgets = [
                      block(
                        'Lot',
                        Text(
                          r.lotNo.isEmpty ? '—' : r.lotNo,
                          style: GoogleFonts.poppins(
                            fontSize: AppTokens.bodySize,
                            fontWeight: AppTokens.weightSemibold,
                            color: AppTokens.textPrimary,
                          ),
                        ),
                      ),
                      block(
                        'Receipt date',
                        Text(_formatDate(r.receiptDate)),
                      ),
                      block(
                        'Customer',
                        Text(
                          customerCompany.isEmpty ? '—' : customerCompany,
                        ),
                      ),
                      block(
                        'No. of samples',
                        Text('${r.noOfSamples}'),
                      ),
                      block(
                        'Data entry progress',
                        Text('$completed / ${r.noOfSamples} completed'),
                      ),
                    ];

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          statusRow,
                          SizedBox(height: AppTokens.space2),
                          for (var i = 0; i < cellWidgets.length; i++) ...[
                            if (i > 0) SizedBox(height: AppTokens.space3),
                            cellWidgets[i],
                          ],
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Wrap(
                            spacing: AppTokens.space6,
                            runSpacing: AppTokens.space4,
                            children: cellWidgets,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: statusRow,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: AppTokens.space4),
          const SampleDataEntryTable(),
        ],
      ),
    );
  }
}
