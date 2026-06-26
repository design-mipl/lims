import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/sample_intake_model.dart';
import '../data/sample_row_model.dart';
import '../state/sample_intake_provider.dart';

/// Operational LC generation for a receipt's samples.
class GenerateLabCodeWorkspaceScreen extends StatefulWidget {
  const GenerateLabCodeWorkspaceScreen({
    super.key,
    required this.receiptId,
    this.presetRowIndexes,
  });

  final String receiptId;

  /// When non-empty, pre-selects these 0-based datasheet row indexes (from `?rows=`).
  final Set<int>? presetRowIndexes;

  @override
  State<GenerateLabCodeWorkspaceScreen> createState() =>
      _GenerateLabCodeWorkspaceScreenState();
}

class _GenerateLabCodeWorkspaceScreenState
    extends State<GenerateLabCodeWorkspaceScreen> {
  SampleIntakeProvider? _provider;
  final Set<int> _selected = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<SampleIntakeProvider>();
      _provider!.addListener(_onErr);
      await _provider!.fetchById(widget.receiptId);
      if (mounted) {
        setState(() {
          _selected.clear();
          final preset = widget.presetRowIndexes;
          if (preset != null && preset.isNotEmpty) {
            for (final i in preset) {
              if (i >= 0 && i < _provider!.sampleRows.length) {
                _selected.add(i);
              }
            }
          }
          if (_selected.isEmpty) {
            for (var i = 0; i < _provider!.sampleRows.length; i++) {
              _selected.add(i);
            }
          }
        });
      }
    });
  }

  void _onErr() {
    final pr = _provider;
    if (pr == null || !pr.hasError || !mounted) return;
    final m = pr.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || m == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: AppTokens.error500),
      );
      pr.clearError();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onErr);
    super.dispose();
  }

  void _toggle(int i, bool v) {
    setState(() {
      if (v) {
        _selected.add(i);
      } else {
        _selected.remove(i);
      }
    });
  }

  Future<void> _generate(bool regenerate) async {
    final p = context.read<SampleIntakeProvider>();
    if (_selected.isEmpty) return;
    await p.generateLabCodesForSamples(
      receiptId: widget.receiptId,
      rowIndexes: _selected,
      regenerate: regenerate,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          regenerate
              ? 'Regenerated LC for ${_selected.length} row(s)'
              : 'Generated LC for ${_selected.length} row(s)',
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SampleIntakeProvider>();
    final r = p.selected;

    if (p.isLoading && r == null) {
      return const Material(
        type: MaterialType.transparency,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (r == null || r.id != widget.receiptId) {
      return AppFormPage(
        title: 'Receipt not found',
        subtitle: widget.receiptId,
        onBack: () => context.go('/transactions/sample-intake'),
        body: Center(
          child: Text(
            'Unable to load receipt.',
            style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
          ),
        ),
      );
    }

    final rows = p.sampleRows;

    return AppFormPage(
      title: 'Generate lab code',
      subtitle: '${r.lotNo} · ${_selected.length} selected',
      scrollBody: false,
      fullWidthBody: true,
      onBack: () => context.go('/transactions/sample-intake'),
      cancelLabel: 'Cancel',
      onCancel: () => context.go('/transactions/sample-intake'),
      actions: [
        AppButton(
          label: 'Regenerate LC',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.md,
          onPressed:
              p.isLoading || _selected.isEmpty ? null : () => _generate(true),
        ),
        AppButton(
          label: 'Generate LC',
          variant: AppButtonVariant.primary,
          size: AppButtonSize.md,
          onPressed:
              p.isLoading || _selected.isEmpty ? null : () => _generate(false),
          isLoading: p.isLoading,
        ),
      ],
      primaryLabel: 'Move to Lab Code',
      onPrimary: () async {
        final router = GoRouter.of(context);
        await p.forwardReceiptToLabModule(widget.receiptId);
        if (!mounted) return;
        router.go('/transactions/lab-code');
      },
      isPrimaryLoading: p.isLoading,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryStrip(receipt: r),
          SizedBox(height: AppTokens.space3),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppTokens.borderDefault),
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              child: AppScrollView(
                scrollDirection: Axis.horizontal,
                child: AppScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      columnWidths: const {
                        0: FixedColumnWidth(48),
                        1: FixedColumnWidth(140),
                        2: FixedColumnWidth(160),
                        3: FixedColumnWidth(160),
                        4: FixedColumnWidth(140),
                        5: FixedColumnWidth(120),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: AppTokens.surfaceSubtle,
                          ),
                          children: [
                            const SizedBox(
                              height: AppTokens.tableHeaderHeight,
                            ),
                            _th('Sample ID'),
                            _th('Type of sample'),
                            _th('Generated LC'),
                            _th('Barcode preview'),
                            _th('Label status'),
                          ],
                        ),
                        for (var i = 0; i < rows.length; i++)
                          _dataRow(rows[i], i),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: AppTokens.space3),
          Wrap(
            spacing: AppTokens.space2,
            children: [
              AppButton(
                label: 'Print labels',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.md,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Print labels — mock')),
                ),
              ),
              AppButton(
                label: 'Print selected',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.md,
                onPressed: _selected.isEmpty
                    ? null
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Print ${_selected.length} label(s) — mock',
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _th(String s) {
    return Padding(
      padding: EdgeInsets.all(AppTokens.space2),
      child: Text(
        s,
        style: GoogleFonts.poppins(
          fontSize: AppTokens.captionSize,
          fontWeight: AppTokens.weightSemibold,
          color: AppTokens.textMuted,
        ),
      ),
    );
  }

  TableRow _dataRow(SampleRowModel row, int index) {
    final code = row.generatedLabCode ?? '';
    return TableRow(
      children: [
        Checkbox(
          value: _selected.contains(index),
          onChanged: (v) => _toggle(index, v ?? false),
        ),
        Padding(
          padding: EdgeInsets.all(AppTokens.space2),
          child: Text(
            row.sampleId,
            style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppTokens.space2),
          child: Text(
            row.typeOfSample ?? '—',
            style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppTokens.space2),
          child: Text(
            code.isEmpty ? '—' : code,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: AppTokens.weightMedium,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppTokens.space2),
          child: Text(
            code.isEmpty ? 'Preview unavailable' : code,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.captionSize,
              color: AppTokens.textMuted,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppTokens.space2),
          child: Text(
            row.labelStatus ?? '—',
            style: GoogleFonts.poppins(fontSize: AppTokens.tableCellSize),
          ),
        ),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.receipt});

  final SampleIntakeModel receipt;

  @override
  Widget build(BuildContext context) {
    Widget pair(String k, String v) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              k,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.captionSize,
                color: AppTokens.textMuted,
              ),
            ),
            SizedBox(width: AppTokens.space2),
            Expanded(
              child: Text(
                v,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.tableCellSize,
                  fontWeight: AppTokens.weightMedium,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppTokens.space2,
        horizontal: AppTokens.space3,
      ),
      child: Wrap(
        spacing: AppTokens.space4,
        runSpacing: AppTokens.space2,
        children: [
          pair('Customer', receipt.customerName),
          pair('Site', receipt.siteCompany),
          pair(
            'Sample type',
            receipt.typeOfSample.isEmpty ? '—' : receipt.typeOfSample,
          ),
          pair('Receipt No.', receipt.lotNo),
          pair('Sample count', '${receipt.noOfSamples}'),
        ],
      ),
    );
  }
}
