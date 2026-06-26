import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/form_read_only_field.dart';
import '../state/sample_intake_provider.dart';
import 'widgets/sample_data_entry_table.dart';

/// Sample receipt datasheet workspace — summary strip + full operational grid.
class SampleIntakeDetailPage extends StatefulWidget {
  const SampleIntakeDetailPage({super.key, required this.receiptId});

  final String receiptId;

  @override
  State<SampleIntakeDetailPage> createState() => _SampleIntakeDetailPageState();
}

class _SampleIntakeDetailPageState extends State<SampleIntakeDetailPage> {
  SampleIntakeProvider? _provider;
  bool _footerBusy = false;

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

  Future<void> _onSaveSelected(Set<int> _) async {
    if (_footerBusy) return;
    setState(() => _footerBusy = true);
    final p = context.read<SampleIntakeProvider>();
    await p.persistDatasheetGrid(widget.receiptId);
    if (!mounted) return;
    setState(() => _footerBusy = false);
    if (p.hasError) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Datasheet saved.',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.neutral700,
      ),
    );
  }

  Future<void> _onSaveAndGenerateLabCode(Set<int> indexes) async {
    if (_footerBusy) return;
    setState(() => _footerBusy = true);
    final p = context.read<SampleIntakeProvider>();
    await p.persistDatasheetGrid(widget.receiptId);
    if (!mounted) return;
    setState(() => _footerBusy = false);
    if (p.hasError) return;
    final sorted = indexes.toList()..sort();
    context.go(
      '/transactions/sample-intake/${widget.receiptId}/generate-lab-code?rows=${sorted.join(',')}',
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

    final completed = context.select<SampleIntakeProvider, int>(
      (pr) => pr.getCompletedCount(),
    );
    final customerCompany =
        '${r.customerName}${r.customerCompany.isEmpty ? '' : ' · ${r.customerCompany}'}';

    return AppFormPage(
      title: 'Sample datasheet',
      subtitle: r.lotNo,
      onBack: () => _back(context),
      scrollBody: false,
      fullWidthBody: true,
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
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space4,
                  vertical: AppTokens.space3,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FormReadOnlyField(
                        label: 'Receipt No.',
                        value: r.lotNo,
                      ),
                    ),
                    SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: FormReadOnlyField(
                        label: 'Date',
                        value: _formatDate(r.receiptDate),
                      ),
                    ),
                    SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: FormReadOnlyField(
                        label: 'Customer',
                        value: customerCompany,
                      ),
                    ),
                    SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: FormReadOnlyField(
                        label: 'Samples',
                        value: '${r.noOfSamples}',
                      ),
                    ),
                    SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: FormReadOnlyField(
                        label: 'Datasheet',
                        value: '$completed / ${r.noOfSamples}',
                      ),
                    ),
                    SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: FormReadOnlyField(
                        label: 'Datasheet Status',
                        value: r.datasheetStatusDisplay,
                      ),
                    ),
                    SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: FormReadOnlyField(
                        label: 'Lab Code Status',
                        value: r.labCodeStatusDisplay,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Expanded(
            child: Shortcuts(
              shortcuts: <ShortcutActivator, Intent>{
                const SingleActivator(LogicalKeyboardKey.arrowDown):
                    DirectionalFocusIntent(TraversalDirection.down),
                const SingleActivator(LogicalKeyboardKey.arrowUp):
                    DirectionalFocusIntent(TraversalDirection.up),
                const SingleActivator(LogicalKeyboardKey.arrowRight):
                    DirectionalFocusIntent(TraversalDirection.right),
                const SingleActivator(LogicalKeyboardKey.arrowLeft):
                    DirectionalFocusIntent(TraversalDirection.left),
              },
              child: Actions(
                actions: <Type, Action<Intent>>{
                  DirectionalFocusIntent: DirectionalFocusAction(),
                },
                child: SampleDataEntryTable(
                  isActionBusy: _footerBusy,
                  onSaveSelected: _onSaveSelected,
                  onSaveAndGenerateLabCode: _onSaveAndGenerateLabCode,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
