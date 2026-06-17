import '../../../masters/customer_master/data/customer_model.dart';
import '../../shared/billing_document_row.dart';
import 'customer_invoice_api.dart';
import 'invoice_item_row_model.dart';

/// Mock detail payload for View Customer Invoice (until API provides full shape).
class CustomerInvoiceViewPayload {
  const CustomerInvoiceViewPayload({
    required this.listingRow,
    required this.customer,
    required this.lines,
    required this.invoiceType,
    required this.gstType,
    required this.typeOfService,
    required this.paymentTerms,
    required this.hsnCode,
    required this.dispatchThrough,
    required this.modeOfDelivery,
    required this.deliveryNote,
    required this.supplierRef,
    required this.dispatchDocNo,
    required this.dispatchDate,
    required this.remarks,
    required this.buyerOrderDate,
  });

  final BillingDocumentListingRow listingRow;
  final CustomerModel? customer;
  final List<InvoiceItemRowModel> lines;
  final String invoiceType;
  final String gstType;
  final String typeOfService;
  final String paymentTerms;
  final String hsnCode;
  final String dispatchThrough;
  final String modeOfDelivery;
  final String deliveryNote;
  final String supplierRef;
  final String dispatchDocNo;
  final DateTime? dispatchDate;
  final String remarks;
  final DateTime? buyerOrderDate;
}

Future<CustomerInvoiceViewPayload?> loadCustomerInvoiceViewPayload(
  String invoiceId,
  List<CustomerModel> customers,
) async {
  final api = CustomerInvoiceApi();
  final rows = await api.fetchInvoices();
  BillingDocumentListingRow? row;
  for (final r in rows) {
    if (r.id == invoiceId) {
      row = r;
      break;
    }
  }
  if (row == null) return null;

  CustomerModel? customer;
  for (final c in customers) {
    if (c.companyName.trim() == row.customer.trim()) {
      customer = c;
      break;
    }
  }
  customer ??= customers.isNotEmpty ? customers.first : null;

  final doc = row.docDate;
  final total = row.total;
  final r1 = (total / 3).clamp(100.0, total);
  final r2 = ((total - r1) / 2).clamp(100.0, total - r1);
  final r3 = (total - r1 - r2).clamp(0.0, total);

  final lines = <InvoiceItemRowModel>[
    InvoiceItemRowModel(
      srNo: 1,
      id: '$invoiceId-l1',
      labDate: doc,
      labNo: '${row.documentNo}-L1',
      reportId: 'RPT-$invoiceId-A',
      typeOfSample: 'Composite',
      lineItem: 'Testing package A',
      rate: r1,
      quantity: 1,
      site: customer?.city ?? '—',
      status: row.statusLabel,
      references: 'REF-$invoiceId-01',
      contactPerson: customer != null && customer.contacts.isNotEmpty
          ? customer.contacts.first.name
          : '—',
    ),
    InvoiceItemRowModel(
      srNo: 2,
      id: '$invoiceId-l2',
      labDate: doc.add(const Duration(days: 1)),
      labNo: '${row.documentNo}-L2',
      reportId: 'RPT-$invoiceId-B',
      typeOfSample: 'Lubricant',
      lineItem: 'Testing package B',
      rate: r2,
      quantity: 1,
      site: customer?.city ?? '—',
      status: row.statusLabel,
      references: 'REF-$invoiceId-02',
      contactPerson: customer != null && customer.contacts.isNotEmpty
          ? customer.contacts.first.name
          : '—',
    ),
    InvoiceItemRowModel(
      srNo: 3,
      id: '$invoiceId-l3',
      labDate: doc.add(const Duration(days: 2)),
      labNo: '${row.documentNo}-L3',
      reportId: 'RPT-$invoiceId-C',
      typeOfSample: 'Greases',
      lineItem: 'Testing package C',
      rate: r3,
      quantity: 1,
      site: customer?.city ?? '—',
      status: row.statusLabel,
      references: 'REF-$invoiceId-03',
      contactPerson: customer != null && customer.contacts.isNotEmpty
          ? customer.contacts.first.name
          : '—',
    ),
  ];

  final short = invoiceId.length >= 6 ? invoiceId.substring(invoiceId.length - 6) : invoiceId;

  return CustomerInvoiceViewPayload(
    listingRow: row,
    customer: customer,
    lines: lines,
    invoiceType: 'tax',
    gstType: row.total > 200000 ? 'inter' : 'intra',
    typeOfService: 'lab',
    paymentTerms: (customer?.paymentTerms ?? '').trim().isNotEmpty ? 'cust' : 'net30',
    hsnCode: '998346',
    dispatchThrough: 'road',
    modeOfDelivery: 'courier',
    deliveryNote: 'DN-${doc.year}-$short',
    supplierRef: 'SR-${row.documentNo}',
    dispatchDocNo: 'DD-${doc.year}-$short',
    dispatchDate: doc.add(const Duration(days: 3)),
    remarks:
        'View-only mock — ${row.customer}. Outstanding ${row.outstanding.toStringAsFixed(2)}.',
    buyerOrderDate: doc.subtract(const Duration(days: 5)),
  );
}
