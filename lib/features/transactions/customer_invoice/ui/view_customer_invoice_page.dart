import 'package:flutter/material.dart';

import 'create_customer_invoice_page.dart';

/// Full-page **View Customer Invoice** — same layout as create; read-only with inline edit.
class ViewCustomerInvoicePage extends StatelessWidget {
  const ViewCustomerInvoicePage({
    super.key,
    required this.invoiceId,
    this.startInEditMode = false,
  });

  final String invoiceId;
  final bool startInEditMode;

  @override
  Widget build(BuildContext context) {
    return CreateCustomerInvoicePage(
      viewInvoiceId: invoiceId,
      startInEditMode: startInEditMode,
    );
  }
}
