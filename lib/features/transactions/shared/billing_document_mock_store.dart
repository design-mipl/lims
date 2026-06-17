import 'billing_document_row.dart';

/// In-memory row mutations shared by Customer Invoice and Credit Note mock APIs.
class BillingDocumentMockStore {
  BillingDocumentMockStore(List<BillingDocumentListingRow> seed)
      : _items = List<BillingDocumentListingRow>.from(seed);

  final List<BillingDocumentListingRow> _items;

  List<BillingDocumentListingRow> snapshot() =>
      List<BillingDocumentListingRow>.unmodifiable(_items);

  void replaceRow(BillingDocumentListingRow row) {
    final idx = _items.indexWhere((e) => e.id == row.id);
    if (idx >= 0) {
      _items[idx] = row;
    }
  }

  void attachDigitalSignature(String id, String fileName) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    _items[idx] = _items[idx].copyWith(
      digitalSignatureAttached: true,
      digitalSignatureFileName: fileName,
    );
  }
}
