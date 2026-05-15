import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../state/quotation_provider.dart';
import 'widgets/quotation_activity_timeline.dart';

/// Sales review — approvals, discount tweaks, convert to order.
class QuotationSalesReviewScreen extends StatefulWidget {
  const QuotationSalesReviewScreen({super.key, required this.quoteId});

  final String quoteId;

  @override
  State<QuotationSalesReviewScreen> createState() =>
      _QuotationSalesReviewScreenState();
}

class _QuotationSalesReviewScreenState extends State<QuotationSalesReviewScreen> {
  QuotationProvider? _provider;
  final _discountCtrl = TextEditingController();
  final _discussionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<QuotationProvider>();
      _provider!.addListener(_onErr);
      await _provider!.loadQuote(widget.quoteId);
      final q = _provider!.active;
      if (!mounted || q == null) return;
      _discountCtrl.text =
          (q.approvedDiscountAmount ?? q.discountAmount).toStringAsFixed(2);
      _discussionCtrl.text = q.discussionNotes;
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
    _discountCtrl.dispose();
    _discussionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuotationProvider>();
    final q = p.active;

    if (p.isLoading && q == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (q == null) {
      return Center(child: Text('Quotation not found'));
    }

    return AppFormPage(
      title: 'Sales review',
      subtitle: '${q.quoteNo} · ${q.customerName}',
      scrollBody: true,
      onBack: () => context.go('/transactions/quotation/pending'),
      cancelLabel: 'Back',
      onCancel: () => context.go('/transactions/quotation/pending'),
      saveAndContinueLabel: 'Request changes',
      onSaveAndContinue: () async {
        await p.requestChangesQuote(q.id, _discussionCtrl.text.trim());
        if (!context.mounted) return;
        context.go('/transactions/quotation/pending');
      },
      primaryLabel: 'Approve',
      onPrimary: () async {
        final d = double.tryParse(_discountCtrl.text.trim());
        await p.approveQuote(q.id, discountOverride: d);
        if (!context.mounted) return;
        context.go('/transactions/quotation/approved');
      },
      isPrimaryLoading: p.isLoading,
      actions: [
        AppButton(
          label: 'Update discount',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.md,
          onPressed: p.isLoading
              ? null
              : () async {
                  final d = double.tryParse(_discountCtrl.text.trim());
                  final next = q.copyWith(discountAmount: d ?? q.discountAmount);
                  p.setActiveLocal(next);
                  await p.persistActive();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Discount updated')),
                  );
                },
        ),
        SizedBox(width: AppTokens.space2),
        AppButton(
          label: 'Convert to order',
          variant: AppButtonVariant.primary,
          size: AppButtonSize.md,
          onPressed: p.isLoading
              ? null
              : () async {
                  await p.convertToOrder(q.id);
                  if (!context.mounted) return;
                  await context.push(
                    '/transactions/sample-intake/create?enquiryId=${q.enquiryId}&quotationId=${q.id}',
                  );
                },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppTokens.space4,
            runSpacing: AppTokens.space3,
            children: [
              _kv('Customer', q.customerName),
              _kv('Site', q.siteName),
              _kv('Sample type', q.typeOfSample),
              _kv('Status', q.status),
            ],
          ),
          SizedBox(height: AppTokens.space5),
          Text(
            'Pricing lines',
            style: GoogleFonts.poppins(
              fontWeight: AppTokens.weightSemibold,
              fontSize: AppTokens.textBase,
            ),
          ),
          SizedBox(height: AppTokens.space3),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Code')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Rate')),
                DataColumn(label: Text('Amount')),
              ],
              rows: q.lines
                  .map(
                    (l) => DataRow(
                      cells: [
                        DataCell(Text(l.testCode)),
                        DataCell(Text(l.description)),
                        DataCell(Text('${l.qty}')),
                        DataCell(Text(l.rate.toStringAsFixed(2))),
                        DataCell(Text(l.amount.toStringAsFixed(2))),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _rowAmt('Subtotal', q.subtotal),
                  _rowAmt('Discount', q.discountAmount),
                  _rowAmt('GST', q.gstAmount),
                  Divider(),
                  _rowAmt('Grand total', q.grandTotal, bold: true),
                ],
              ),
            ),
          ),
          SizedBox(height: AppTokens.space5),
          AppInput(
            label: 'Approved discount (flat)',
            controller: _discountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: AppTokens.space4),
          AppInput(
            label: 'Discussion / notes',
            controller: _discussionCtrl,
            maxLines: 4,
            onChanged: (tx) => p.setDiscussionNotes(q.id, tx),
          ),
          SizedBox(height: AppTokens.space5),
          Text(
            'Timeline (recent)',
            style: GoogleFonts.poppins(
              fontWeight: AppTokens.weightSemibold,
              fontSize: AppTokens.textBase,
            ),
          ),
          SizedBox(height: AppTokens.space3),
          QuotationActivityTimeline(
            entries: q.activity.length > 6
                ? q.activity.sublist(q.activity.length - 6)
                : q.activity,
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.captionSize,
              color: AppTokens.textMuted,
            ),
          ),
          Text(
            v,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.tableCellSize,
              fontWeight: AppTokens.weightMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowAmt(String label, double v, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: bold ? AppTokens.weightSemibold : AppTokens.weightRegular,
            ),
          ),
          Text(
            v.toStringAsFixed(2),
            style: GoogleFonts.poppins(
              fontWeight: bold ? AppTokens.weightSemibold : AppTokens.weightRegular,
            ),
          ),
        ],
      ),
    );
  }
}
