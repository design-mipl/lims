import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../shared/billing_document_row.dart';
import '../../shared/form_read_only_field.dart';
import '../data/credit_note_api.dart';

/// Credit note detail — read-only overview with inline **Edit** (mock save).
class CreditNoteDetailScreen extends StatefulWidget {
  const CreditNoteDetailScreen({
    super.key,
    required this.noteId,
    this.startInEditMode = false,
  });

  final String noteId;
  final bool startInEditMode;

  @override
  State<CreditNoteDetailScreen> createState() => _CreditNoteDetailScreenState();
}

class _CreditNoteDetailScreenState extends State<CreditNoteDetailScreen> {
  BillingDocumentListingRow? _row;
  bool _loading = true;
  bool _editing = false;

  final _customerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.startInEditMode) {
      _editing = true;
    }
    _load();
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await sl<CreditNoteApi>().fetchCreditNoteById(widget.noteId);
    if (!mounted) return;
    setState(() {
      _row = r;
      _customerCtrl.text = r?.customer ?? '';
      _loading = false;
    });
  }

  bool get _workflowLocked {
    final r = _row;
    if (r == null) return true;
    return r.statusLabel == 'Shared';
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions/credit-note');
    }
  }

  void _beginEdit() {
    setState(() => _editing = true);
  }

  void _cancelEdit() {
    final r = _row;
    if (r != null) {
      _customerCtrl.text = r.customer;
    }
    setState(() => _editing = false);
  }

  void _saveChanges() {
    final r = _row;
    if (r == null) return;
    setState(() {
      _row = BillingDocumentListingRow(
        id: r.id,
        eInvoiceActive: r.eInvoiceActive,
        docDate: r.docDate,
        documentNo: r.documentNo,
        customer: _customerCtrl.text.trim().isEmpty ? r.customer : _customerCtrl.text.trim(),
        dueDays: r.dueDays,
        total: r.total,
        amountReceived: r.amountReceived,
        statusLabel: r.statusLabel,
      );
      _editing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Credit note updated (UI only)',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final r = _row;
    if (r == null) {
      return Center(
        child: Text(
          'Credit note not found',
          style: GoogleFonts.poppins(fontSize: AppTokens.bodySize),
        ),
      );
    }

    final body = SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: AppFormSection(
            title: 'Credit note',
            children: [
              FormReadOnlyField(label: 'Document no.', value: r.documentNo),
              FormReadOnlyField(label: 'Document date', value: _fmtDate(r.docDate)),
              FormReadOnlyField(label: 'Status', value: r.statusLabel),
              FormReadOnlyField(
                label: 'Outstanding',
                value: r.outstanding.toStringAsFixed(2),
              ),
              if (!_editing)
                FormReadOnlyField(label: 'Customer', value: r.customer)
              else
                AppInput(
                  label: 'Customer',
                  controller: _customerCtrl,
                  hint: 'Customer name',
                ),
            ],
          ),
        ),
      ),
    );

    return DetailTemplate(
      parentLabel: 'Credit Note',
      parentRoute: '/transactions/credit-note',
      currentLabel: r.documentNo,
      headerCard: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.documentNo,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.textXl,
                    fontWeight: AppTokens.weightSemibold,
                  ),
                ),
                SizedBox(height: AppTokens.space1),
                Text(
                  r.customer,
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.bodySize,
                    color: AppTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: AppTokens.space2,
            children: [
              AppButton(
                label: 'Back',
                variant: AppButtonVariant.tertiary,
                size: AppButtonSize.md,
                onPressed: _onBack,
              ),
              if (!_editing) ...[
                if (!_workflowLocked)
                  AppButton(
                    label: 'Edit',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.md,
                    onPressed: _beginEdit,
                  ),
              ] else ...[
                AppButton(
                  label: 'Cancel edit',
                  variant: AppButtonVariant.tertiary,
                  size: AppButtonSize.md,
                  onPressed: _cancelEdit,
                ),
                AppButton(
                  label: 'Save changes',
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.md,
                  onPressed: _saveChanges,
                ),
              ],
            ],
          ),
        ],
      ),
      tabLabels: const ['Overview'],
      tabViews: [body],
    );
  }
}
