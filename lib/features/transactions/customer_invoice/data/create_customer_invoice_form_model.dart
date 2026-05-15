import 'invoice_item_row_model.dart';

/// Draft snapshot for Create Customer Invoice (UI-first; no persistence yet).
class CreateCustomerInvoiceDraft {
  CreateCustomerInvoiceDraft({
    required this.provisionalInvoiceNo,
    this.customerId,
    this.siteId,
    this.invoiceType,
    this.gstType,
  });

  String provisionalInvoiceNo;
  String? customerId;
  String? siteId;
  String? invoiceType;
  String? gstType;

  /// Tax/summary display values derived from [lines] and charge inputs.
  static ({
    double lineValue,
    double otherCharges,
    double discount,
    double cgst,
    double sgst,
    double igst,
    double grandTotal,
  })
  computeSummary({
    required List<InvoiceItemRowModel> lines,
    double otherCharges = 0,
    double discount = 0,
    bool useIgst = false,
  }) {
    final lineValue = lines.fold<double>(0, (a, e) => a + e.amount);
    final taxable = (lineValue + otherCharges - discount).clamp(
      0,
      double.infinity,
    );
    double cgst = 0;
    double sgst = 0;
    double igst = 0;
    if (taxable > 0) {
      if (useIgst) {
        igst = double.parse((taxable * 0.18).toStringAsFixed(2));
      } else {
        final half = double.parse((taxable * 0.09).toStringAsFixed(2));
        cgst = half;
        sgst = half;
      }
    }
    final grandTotal = double.parse(
      (taxable + cgst + sgst + igst).toStringAsFixed(2),
    );
    return (
      lineValue: double.parse(lineValue.toStringAsFixed(2)),
      otherCharges: otherCharges,
      discount: discount,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      grandTotal: grandTotal,
    );
  }
}
