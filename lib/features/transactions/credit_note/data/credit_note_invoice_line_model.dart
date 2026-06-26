/// One billable / selectable invoice line in the Create Credit Note workspace.
class CreditNoteInvoiceLineRow {
  const CreditNoteInvoiceLineRow({
    required this.id,
    required this.labDate,
    required this.labNo,
    required this.reportId,
    required this.typeOfSample,
    required this.lineItem,
    required this.rate,
    required this.site,
    required this.invoiceNo,
    required this.referenceInvoiceNo,
    required this.customer,
    required this.contactPerson,
  });

  final String id;
  final DateTime labDate;
  final String labNo;
  final String reportId;
  final String typeOfSample;
  final String lineItem;
  final double rate;
  final String site;
  final String invoiceNo;
  final String referenceInvoiceNo;
  final String customer;
  final String contactPerson;

  CreditNoteInvoiceLineRow copyWith({
    double? rate,
  }) {
    return CreditNoteInvoiceLineRow(
      id: id,
      labDate: labDate,
      labNo: labNo,
      reportId: reportId,
      typeOfSample: typeOfSample,
      lineItem: lineItem,
      rate: rate ?? this.rate,
      site: site,
      invoiceNo: invoiceNo,
      referenceInvoiceNo: referenceInvoiceNo,
      customer: customer,
      contactPerson: contactPerson,
    );
  }
}
