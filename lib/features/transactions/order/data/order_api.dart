import '../../quotation/data/quotation_api.dart';
import '../../quotation/data/quotation_model.dart';
import 'order_model.dart';

/// Mock orders — pending rows are quotations in review without an order ref.
class OrderApi {
  OrderApi({required QuotationApi quotationApi}) : _quotationApi = quotationApi {
    _seed();
  }

  final QuotationApi _quotationApi;
  final List<OrderRecord> _orders = [];

  void _seed() {
    final now = DateTime.now();
    _orders.add(
      OrderRecord(
        id: 'ord-1',
        orderNo: 'ORD-00001',
        quotationId: 'quo-3',
        quoteNo: 'QUO-70003',
        enquiryNo: 'ENQ-00003',
        customerName: 'Coastal Chemicals',
        siteName: 'Chennai Dock',
        sampleType: 'Coolant',
        status: OrderStatus.confirmed,
        versionNo: 2,
        originalAmount: 1950,
        discountPercent: 7.7,
        revisedAmount: 1800,
        updatedAt: now.subtract(const Duration(days: 8)),
        updatedBy: 'Anita Rao',
        salesPerson: 'Anita Rao',
        emailSent: true,
        convertedOrderRef: 'ORD-00001',
        convertedAt: now.subtract(const Duration(days: 10)),
        customerApproval: 'Approved',
        versions: [
          OrderVersionEntry(
            versionNo: 1,
            revisedAt: now.subtract(const Duration(days: 12)),
            updatedBy: 'Pricing desk',
            originalAmount: 1950,
            discountPercent: 0,
            revisedAmount: 1950,
            status: OrderStatus.draft,
            remarks: 'Original quotation',
          ),
          OrderVersionEntry(
            versionNo: 2,
            revisedAt: now.subtract(const Duration(days: 9)),
            updatedBy: 'Anita Rao',
            originalAmount: 1950,
            discountPercent: 7.7,
            revisedAmount: 1800,
            status: OrderStatus.confirmed,
            remarks: 'Customer discount approved',
          ),
        ],
      ),
    );
  }

  List<QuotationRecord> pendingQuotationsSync() {
    return _quotationApi
        .fetchAllSync()
        .where(
          (q) =>
              q.status == QuotationStatus.inReview &&
              (q.orderReference == null || q.orderReference!.isEmpty),
        )
        .toList();
  }

  Future<List<QuotationRecord>> fetchPendingQuotations() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return pendingQuotationsSync();
  }

  Future<List<OrderRecord>> fetchConfirmedOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return List<OrderRecord>.from(_orders);
  }

  Future<OrderRecord?> fetchById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  String _allocateOrderNo() {
    final next = _orders.length + 1;
    return 'ORD-${next.toString().padLeft(5, '0')}';
  }

  Future<List<OrderRecord>> createOrdersFromQuotations(
    List<String> quotationIds, {
    String actor = 'Sales',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final created = <OrderRecord>[];
    for (final quoteId in quotationIds) {
      final q = _quotationApi.getByIdSync(quoteId);
      if (q == null) continue;
      if (q.orderReference != null && q.orderReference!.isNotEmpty) continue;

      final orderNo = _allocateOrderNo();
      final original = q.subtotal;
      final discountPct =
          original > 0 ? (q.discountAmount / original * 100) : 0.0;
      final revised = q.grandTotal;
      final now = DateTime.now();
      final v1 = OrderVersionEntry(
        versionNo: 1,
        revisedAt: now,
        updatedBy: actor,
        originalAmount: original,
        discountPercent: discountPct,
        revisedAmount: revised,
        status: OrderStatus.convertedOrder,
        remarks: 'Order created from ${q.quoteNo}',
        readOnly: true,
      );

      final salesPerson =
          q.salesPerson.isNotEmpty ? q.salesPerson : q.preparedBy;

      final record = OrderRecord(
        id: 'ord-${DateTime.now().millisecondsSinceEpoch}-$quoteId',
        orderNo: orderNo,
        quotationId: q.id,
        quoteNo: q.quoteNo,
        enquiryNo: q.enquiryNo,
        customerName: q.customerName,
        siteName: q.siteName,
        sampleType: q.typeOfSample,
        status: OrderStatus.confirmed,
        versionNo: 1,
        originalAmount: original,
        discountPercent: discountPct,
        revisedAmount: revised,
        updatedAt: now,
        updatedBy: actor,
        salesPerson: salesPerson,
        emailSent: false,
        convertedOrderRef: orderNo,
        convertedAt: now,
        customerApproval: 'Pending',
        versions: [v1],
      );
      _orders.add(record);
      created.add(record);

      await _quotationApi.convertToOrder(quoteId, orderRef: orderNo);
    }
    return created;
  }

  Future<OrderRecord?> addRevision(
    String orderId, {
    required double discountPercent,
    required String remarks,
    String actor = 'Sales',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    final i = _orders.indexWhere((o) => o.id == orderId);
    if (i < 0) return null;
    final o = _orders[i];
    final nextVersion = o.versionNo + 1;
    final revised =
        o.originalAmount * (1 - discountPercent / 100).clamp(0, double.infinity);
    final entry = OrderVersionEntry(
      versionNo: nextVersion,
      revisedAt: DateTime.now(),
      updatedBy: actor,
      originalAmount: o.originalAmount,
      discountPercent: discountPercent,
      revisedAmount: revised,
      status: OrderStatus.discountRevised,
      remarks: remarks,
    );
    final next = o.copyWith(
      versionNo: nextVersion,
      discountPercent: discountPercent,
      revisedAmount: revised,
      status: OrderStatus.discountRevised,
      updatedAt: DateTime.now(),
      updatedBy: actor,
      versions: [...o.versions, entry],
    );
    _orders[i] = next;
    return next;
  }
}
