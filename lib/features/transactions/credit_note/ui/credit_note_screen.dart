import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../shared/billing_listing_provider.dart';
import '../../shared/billing_listing_scaffold.dart';
import '../data/credit_note_api.dart';

/// Credit Note — Ultra Labs adjustment listing (mock-backed).
class CreditNoteScreen extends StatelessWidget {
  const CreditNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BillingListingProvider(
        fetchRows: () => sl<CreditNoteApi>().fetchCreditNotes(),
      ),
      child: BillingListingScaffold(
        title: 'Credit Note',
        subtitle:
            'Credit note listing — outstanding reflects remaining balance after adjustments.',
        searchHint: 'Search credit note no., customer...',
        detailPathPrefix: '/transactions/credit-note',
        selectionSingular: 'Credit Note',
        selectionPlural: 'Credit Notes',
        primaryActionLabel: 'Create Credit Note',
        onPrimaryAction: () => context.push('/transactions/credit-note/create'),
      ),
    );
  }
}
