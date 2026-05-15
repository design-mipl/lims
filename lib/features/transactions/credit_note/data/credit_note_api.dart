import '../../shared/billing_document_row.dart';

class CreditNoteApi {
  Future<BillingDocumentListingRow?> fetchCreditNoteById(String id) async {
    final rows = await fetchCreditNotes();
    try {
      return rows.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<BillingDocumentListingRow>> fetchCreditNotes() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final now = DateTime.now();
    return [
      BillingDocumentListingRow(
        id: 'cn-001',
        eInvoiceActive: true,
        docDate: DateTime(now.year, now.month, 2),
        documentNo: 'CN-2026-00301',
        customer: 'Acme Petrochemicals Ltd',
        dueDays: 30,
        total: 12450.00,
        amountReceived: 8000,
        statusLabel: 'Pending',
      ),
      BillingDocumentListingRow(
        id: 'cn-002',
        eInvoiceActive: false,
        docDate: DateTime(now.year, now.month - 1, 19),
        documentNo: 'CN-2026-00274',
        customer: 'Southern Lubricants Pvt Ltd',
        dueDays: 5,
        total: 5600.50,
        amountReceived: 5600.50,
        statusLabel: 'Adjusted',
      ),
      BillingDocumentListingRow(
        id: 'cn-003',
        eInvoiceActive: true,
        docDate: DateTime(now.year, now.month - 1, 8),
        documentNo: 'CN-2026-00218',
        customer: 'Harbour Marine Services',
        dueDays: -1,
        total: 22100.00,
        amountReceived: 10000,
        statusLabel: 'Shared',
      ),
      BillingDocumentListingRow(
        id: 'cn-004',
        eInvoiceActive: true,
        docDate: DateTime(now.year, now.month - 2, 24),
        documentNo: 'CN-2026-00165',
        customer: 'Ultra Labs Chennai',
        dueDays: 14,
        total: 3375.25,
        amountReceived: 0,
        statusLabel: 'Pending',
      ),
      BillingDocumentListingRow(
        id: 'cn-005',
        eInvoiceActive: false,
        docDate: DateTime(now.year, now.month - 2, 11),
        documentNo: 'CN-2026-00102',
        customer: 'Northwind Power Gen',
        dueDays: 20,
        total: 189999.00,
        amountReceived: 150000,
        statusLabel: 'Adjusted',
      ),
      BillingDocumentListingRow(
        id: 'cn-006',
        eInvoiceActive: true,
        docDate: DateTime(now.year, now.month - 3, 29),
        documentNo: 'CN-2025-00991',
        customer: 'Precision Gears India',
        dueDays: 7,
        total: 9420.80,
        amountReceived: 9420.80,
        statusLabel: 'Shared',
      ),
      BillingDocumentListingRow(
        id: 'cn-007',
        eInvoiceActive: false,
        docDate: DateTime(now.year, now.month - 3, 15),
        documentNo: 'CN-2025-00944',
        customer: 'Greenfield Sugar Mills',
        dueDays: 60,
        total: 45000.00,
        amountReceived: 20000,
        statusLabel: 'Pending',
      ),
    ];
  }
}
