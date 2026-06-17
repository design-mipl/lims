import '../../customer_invoice/data/invoice_item_row_model.dart';
import '../../shared/billing_document_row.dart';
import 'credit_note_invoice_line_model.dart';

/// Passed via GoRouter [GoRouterState.extra] when opening Create Credit Note
/// from Customer Invoice **Generate Credit Note**.
class CreateCreditNotePrefill {
  const CreateCreditNotePrefill({
    required this.invoiceId,
    required this.invoiceNo,
    required this.customerName,
    required this.invoiceDate,
    required this.total,
    required this.amountReceived,
    required this.lines,
    this.gstNo = '—',
    this.state = '—',
    this.country = 'India',
    this.pinCode = '400001',
    this.billToAddress,
    this.shipToSite,
    this.buyerOrder = '',
    this.supplierRef = '',
    this.deliveryNote = '',
    this.dispatchDocNo = '',
    this.remarks = '',
    this.otherReferences = '',
    this.destination = '',
    this.gstType,
    this.creditNoteType = 'credit',
    this.buyerOrderDate,
    this.dispatchDate,
    this.referenceInvoiceDate,
  });

  final String invoiceId;
  final String invoiceNo;
  final String customerName;
  final DateTime invoiceDate;
  final double total;
  final double amountReceived;
  final List<CreditNoteInvoiceLineRow> lines;

  final String gstNo;
  final String state;
  final String country;
  final String pinCode;
  final String? billToAddress;
  final String? shipToSite;
  final String buyerOrder;
  final String supplierRef;
  final String deliveryNote;
  final String dispatchDocNo;
  final String remarks;
  final String otherReferences;
  final String destination;
  final String? gstType;
  final String? creditNoteType;
  final DateTime? buyerOrderDate;
  final DateTime? dispatchDate;

  /// Linked reference invoice date on Create Credit Note form.
  final DateTime? referenceInvoiceDate;

  factory CreateCreditNotePrefill.fromBillingListingRow(
    BillingDocumentListingRow row,
  ) {
    final lines = _mockLinesForInvoice(row);
    final site = lines.isNotEmpty ? lines.first.site : 'Main Site';
    return CreateCreditNotePrefill(
      invoiceId: row.id,
      invoiceNo: row.documentNo,
      customerName: row.customer,
      invoiceDate: row.docDate,
      total: row.total,
      amountReceived: row.amountReceived,
      lines: lines,
      billToAddress: '$site — billing address (mock)',
      shipToSite: site,
      buyerOrder: 'PO-${row.documentNo}',
      supplierRef: row.documentNo,
      deliveryNote: 'DN-${row.documentNo}',
      dispatchDocNo: 'DISP-${row.id}',
      remarks: 'Credit note against ${row.documentNo}',
      otherReferences: row.documentNo,
      destination: site,
      gstType: row.gstVerified ? 'intra' : 'unreg',
      referenceInvoiceDate: row.docDate,
    );
  }

  /// Single invoice line from Create / View Customer Invoice item grid.
  factory CreateCreditNotePrefill.fromInvoiceLine({
    required String invoiceId,
    required String invoiceNo,
    required String customerName,
    required DateTime invoiceDate,
    required double invoiceTotal,
    required InvoiceItemRowModel line,
  }) {
    final cnLine = CreditNoteInvoiceLineRow(
      id: 'cn-from-${line.id}',
      labDate: line.labDate,
      labNo: line.labNo,
      reportId: line.reportId,
      typeOfSample: line.typeOfSample,
      lineItem: line.lineItem,
      rate: line.amount,
      site: line.site,
      invoiceNo: invoiceNo,
      referenceInvoiceNo: invoiceNo,
      customer: customerName,
      contactPerson: line.contactPerson,
    );
    return CreateCreditNotePrefill(
      invoiceId: invoiceId,
      invoiceNo: invoiceNo,
      customerName: customerName,
      invoiceDate: invoiceDate,
      total: invoiceTotal,
      amountReceived: 0,
      lines: [cnLine],
      billToAddress: '${line.site} — billing address (mock)',
      shipToSite: line.site,
      buyerOrder: line.references,
      supplierRef: invoiceNo,
      otherReferences: line.references,
      destination: line.site,
      referenceInvoiceDate: invoiceDate,
    );
  }

  /// Full invoice workspace — all line items selected for credit note.
  factory CreateCreditNotePrefill.fromInvoiceWorkspace({
    required String invoiceId,
    required String invoiceNo,
    required String customerName,
    required DateTime invoiceDate,
    required double invoiceTotal,
    required List<InvoiceItemRowModel> lines,
    String? billTo,
    String? address,
    String? shipTo,
    String? gstNo,
    String? state,
    String? country,
    String? buyerOrder,
    String? supplierRef,
    String? deliveryNote,
    String? dispatchDocNo,
    String? remarks,
    String? gstType,
  }) {
    final cnLines = [
      for (final line in lines)
        CreditNoteInvoiceLineRow(
          id: 'cn-from-${line.id}',
          labDate: line.labDate,
          labNo: line.labNo,
          reportId: line.reportId,
          typeOfSample: line.typeOfSample,
          lineItem: line.lineItem,
          rate: line.amount,
          site: line.site,
          invoiceNo: invoiceNo,
          referenceInvoiceNo: invoiceNo,
          customer: customerName,
          contactPerson: line.contactPerson,
        ),
    ];
    final site = cnLines.isNotEmpty ? cnLines.first.site : 'Main Site';
    return CreateCreditNotePrefill(
      invoiceId: invoiceId,
      invoiceNo: invoiceNo,
      customerName: customerName,
      invoiceDate: invoiceDate,
      total: invoiceTotal,
      amountReceived: 0,
      lines: cnLines,
      billToAddress: address ?? '$site — billing address (mock)',
      shipToSite: shipTo ?? site,
      gstNo: gstNo ?? '—',
      state: state ?? '—',
      country: country ?? 'India',
      buyerOrder: buyerOrder ?? '',
      supplierRef: supplierRef ?? invoiceNo,
      deliveryNote: deliveryNote ?? '',
      dispatchDocNo: dispatchDocNo ?? '',
      remarks: remarks ?? 'Credit note against $invoiceNo',
      otherReferences: invoiceNo,
      destination: site,
      gstType: gstType,
      referenceInvoiceDate: invoiceDate,
    );
  }

  /// Mock lines when navigating from listing row only.
  static List<CreditNoteInvoiceLineRow> _mockLinesForInvoice(
    BillingDocumentListingRow row,
  ) {
  final base = row.docDate;
    return [
      CreditNoteInvoiceLineRow(
        id: 'cn-line-${row.id}-1',
        labDate: base,
        labNo: 'LAB-${row.documentNo}-01',
        reportId: 'RPT-${row.id}-01',
        typeOfSample: 'Lubricant',
        lineItem: 'Routine analysis',
        rate: row.total * 0.55,
        site: 'Plant A',
        invoiceNo: row.documentNo,
        referenceInvoiceNo: row.documentNo,
        customer: row.customer,
        contactPerson: 'Accounts',
      ),
      CreditNoteInvoiceLineRow(
        id: 'cn-line-${row.id}-2',
        labDate: base.add(const Duration(days: 1)),
        labNo: 'LAB-${row.documentNo}-02',
        reportId: 'RPT-${row.id}-02',
        typeOfSample: 'Coolant',
        lineItem: 'Spectro analysis',
        rate: row.total * 0.45,
        site: 'Plant B',
        invoiceNo: row.documentNo,
        referenceInvoiceNo: row.documentNo,
        customer: row.customer,
        contactPerson: 'Site In-charge',
      ),
    ];
  }
}
