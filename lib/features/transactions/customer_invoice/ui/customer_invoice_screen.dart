import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../shared/billing_listing_provider.dart';
import '../../shared/billing_listing_scaffold.dart';
import '../data/customer_invoice_api.dart';

/// Customer Invoice — Ultra Labs billing listing (mock-backed).
class CustomerInvoiceScreen extends StatelessWidget {
  const CustomerInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BillingListingProvider(
        fetchRows: () => sl<CustomerInvoiceApi>().fetchInvoices(),
      ),
      child: BillingListingScaffold(
        title: 'Customer Invoice',
        subtitle:
            'Operational invoice listing — balances derive from total vs amount received.',
        searchHint: 'Search invoice no., customer...',
        detailPathPrefix: '/transactions/customer-invoice',
        selectionSingular: 'Invoice',
        selectionPlural: 'Invoices',
        showEditRowAction: true,
        enableGstEinvoiceWorkflow: true,
        primaryActionLabel: 'Create Customer Invoice',
        onPrimaryAction: () =>
            context.push('/transactions/customer-invoice/create'),
      ),
    );
  }
}
