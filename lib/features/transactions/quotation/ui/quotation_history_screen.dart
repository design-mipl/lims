import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/quotation_model.dart';
import '../state/quotation_provider.dart';
import '../../shared/module_history_builder.dart';
import '../../shared/module_history_models.dart';
import '../../shared/module_history_timeline.dart';
import 'widgets/quotation_history_header_card.dart';

/// Full-page read-only activity history for a quotation.
class QuotationHistoryScreen extends StatefulWidget {
  const QuotationHistoryScreen({super.key, required this.quoteId});

  final String quoteId;

  @override
  State<QuotationHistoryScreen> createState() =>
      _QuotationHistoryScreenState();
}

class _QuotationHistoryScreenState extends State<QuotationHistoryScreen> {
  QuotationProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<QuotationProvider>();
      _provider!.addListener(_onErr);
      context.read<QuotationProvider>().loadQuote(widget.quoteId);
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

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions/quotation/pending');
    }
  }

  Widget _statusChip(QuotationRecord r) {
    final label = switch (r.status) {
      QuotationStatus.pendingPrep => 'Pending prep',
      QuotationStatus.changesRequested => 'Changes',
      QuotationStatus.inReview => 'In review',
      QuotationStatus.approved => 'Approved',
      _ => r.status,
    };
    final key = switch (r.status) {
      QuotationStatus.pendingPrep => 'pending',
      QuotationStatus.changesRequested => 'pending',
      QuotationStatus.inReview => 'inReview',
      QuotationStatus.approved => 'completed',
      _ => r.status,
    };
    return StatusChip(status: key, customLabel: label);
  }

  String _stageLabel(QuotationRecord r) {
    return switch (r.status) {
      QuotationStatus.pendingPrep => 'Pending prep',
      QuotationStatus.changesRequested => 'Changes requested',
      QuotationStatus.inReview => 'In review',
      QuotationStatus.approved => 'Approved',
      _ => r.status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuotationProvider>();
    final q = p.active;

    if (p.isLoading && q == null) {
      return const Material(
        type: MaterialType.transparency,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (q == null) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Text(
            'Quotation not found',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.textMuted,
            ),
          ),
        ),
      );
    }

    final entries = buildQuotationHistoryEntries(q);

    return DetailTemplate(
      parentLabel: 'Quotation',
      parentRoute: '/transactions/quotation/pending',
      currentLabel: q.quoteNo,
      onBreadcrumbBack: () => _back(context),
      headerCard: QuotationHistoryHeaderCard(
        quoteNo: q.quoteNo,
        moduleBreadcrumbLine: 'Quotation · History',
        summaryStatusChip: _statusChip(q),
        createdByLabel: q.preparedBy,
        createdDateLabel: ModuleHistoryFormat.dateOnly(q.createdAt),
        stageLabel: _stageLabel(q),
        workflowStatusLabel: quotationWorkflowStatusLabel(q),
      ),
      tabLabels: const ['Activity'],
      tabViews: [
        AppScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.fromLTRB(
            AppTokens.space4,
            AppTokens.space3,
            AppTokens.space4,
            AppTokens.space4,
          ),
          child: ModuleHistoryTimeline(entries: entries),
        ),
      ],
    );
  }
}
