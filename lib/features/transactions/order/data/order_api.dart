import '../../enquiry/data/enquiry_api.dart';
import '../../enquiry/data/enquiry_model.dart';
import '../../quotation/data/quotation_api.dart';
import '../../quotation/data/quotation_model.dart';
import 'order_form_model.dart';
import 'order_model.dart';

/// Mock orders — pending rows are quotations in review without an order ref.
class OrderApi {
  OrderApi({
    required QuotationApi quotationApi,
    required EnquiryApi enquiryApi,
  })  : _quotationApi = quotationApi,
        _enquiryApi = enquiryApi {
    _seed();
  }

  final QuotationApi _quotationApi;
  final EnquiryApi _enquiryApi;
  final List<OrderRecord> _orders = [];
  final Map<String, OrderFormRecord> _forms = {};

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

  Future<List<QuotationRecord>> fetchQuotationsForOrderPicker() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return _quotationApi.fetchAllSync().where((q) {
      if (q.orderReference != null && q.orderReference!.trim().isNotEmpty) {
        return false;
      }
      return q.status == QuotationStatus.approved ||
          q.status == QuotationStatus.inReview;
    }).toList();
  }

  Future<OrderFormRecord?> fetchFormById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    return _forms[id];
  }

  OrderFormRecord newDraftForm() {
    final now = DateTime.now();
    return OrderFormRecord(
      id: 'ord-form-${now.millisecondsSinceEpoch}',
      orderNo: _allocateOrderNo(),
      orderDate: now,
      quotationId: '',
      quoteNo: '',
      enquiryNo: '',
      status: OrderFormStatus.draft,
      customerName: '',
      siteName: '',
      contactPerson: '',
      mobile: '',
      email: '',
      sampleLines: const [],
      total: 0,
      discount: 0,
      gstAmount: 0,
      freight: 0,
      grandTotal: 0,
    );
  }

  Future<OrderFormRecord?> prefillFormFromQuotation(
    String quotationId, {
    OrderFormRecord? base,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final q = _quotationApi.getByIdSync(quotationId);
    if (q == null) return null;

    final enquiry = _enquiryApi.getByIdSync(q.enquiryId);
    final lines = _sampleLinesFromQuotation(q, enquiry);
    const freight = 0.0;

    final contactPerson = enquiry != null
        ? (enquiry.contactPerson.trim().isNotEmpty
            ? enquiry.contactPerson
            : enquiry.siteContactPerson)
        : '';
    final mobile = enquiry?.contactPhone ?? '';
    final email = enquiry?.contactEmail ?? '';

    final draft = base ?? newDraftForm();
    return draft.copyWith(
      quotationId: q.id,
      quoteNo: q.quoteNo,
      enquiryNo: q.enquiryNo,
      customerName: q.customerName,
      siteName: q.siteName,
      contactPerson: contactPerson,
      mobile: mobile,
      email: email,
      sampleLines: lines,
      total: q.subtotal,
      discount: q.discountAmount,
      gstAmount: q.gstAmount,
      freight: freight,
      grandTotal: q.grandTotal + freight,
      remarks: q.notes.isNotEmpty ? q.notes : q.terms,
    );
  }

  List<OrderSampleLine> _sampleLinesFromQuotation(
    QuotationRecord q,
    EnquiryRecord? enquiry,
  ) {
    final selectedTests =
        enquiry?.requestedTests.where((t) => t.selected).toList() ??
            const <EnquiryRequestedTestRow>[];

    if (enquiry != null && enquiry.sampleRequirements.isNotEmpty) {
      final lines = <OrderSampleLine>[];
      var idx = 0;
      for (final req in enquiry.sampleRequirements) {
        final testName = idx < selectedTests.length
            ? selectedTests[idx].testName
            : (idx < q.lines.length
                ? q.lines[idx].description
                : 'Analysis package');
        final rate = idx < q.lines.length ? q.lines[idx].rate : 0.0;
        lines.add(
          OrderSampleLine(
            id: 'osl-${req.id}-$idx',
            typeOfSample: req.typeOfSample,
            sampleCount: req.sampleCount,
            testName: testName,
            priority: req.priority,
            expectedTimeline: req.expectedTimeline,
            rate: rate,
          ),
        );
        idx++;
      }
      if (lines.isNotEmpty) return lines;
    }

    if (q.lines.isEmpty) {
      return [
        OrderSampleLine(
          id: 'osl-default',
          typeOfSample: q.typeOfSample,
          sampleCount: 1,
          testName: 'Standard analysis package',
          priority: enquiry?.samplePriority ?? 'Normal',
          expectedTimeline: enquiry?.expectedTimeline ?? '',
          rate: 0,
        ),
      ];
    }

    return q.lines
        .map(
          (l) => OrderSampleLine(
            id: l.id,
            typeOfSample: q.typeOfSample,
            sampleCount: l.qty,
            testName: l.description,
            priority: enquiry?.samplePriority ?? 'Normal',
            expectedTimeline: enquiry?.expectedTimeline ?? '',
            rate: l.rate,
          ),
        )
        .toList();
  }

  Future<OrderFormRecord> saveForm(OrderFormRecord form) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _forms[form.id] = form;
    if (form.status == OrderFormStatus.confirmed) {
      await _upsertConfirmedFromForm(form);
    }
    return form;
  }

  Future<void> _upsertConfirmedFromForm(OrderFormRecord form) async {
    final existingIdx =
        _orders.indexWhere((o) => o.id == form.id || o.orderNo == form.orderNo);
    final original = form.total;
    final discountPct =
        original > 0 ? (form.discount / original * 100) : 0.0;
    final now = DateTime.now();
    final record = OrderRecord(
      id: form.id,
      orderNo: form.orderNo,
      quotationId: form.quotationId,
      quoteNo: form.quoteNo,
      enquiryNo: form.enquiryNo,
      customerName: form.customerName,
      siteName: form.siteName,
      sampleType: form.sampleLines.isNotEmpty
          ? form.sampleLines.first.typeOfSample
          : '',
      status: OrderStatus.confirmed,
      versionNo: 1,
      originalAmount: form.total,
      discountPercent: discountPct,
      revisedAmount: form.grandTotal,
      updatedAt: now,
      updatedBy: 'Order desk',
      salesPerson: '',
      emailSent: false,
      convertedOrderRef: form.orderNo,
      convertedAt: now,
      customerApproval: 'Pending',
      versions: [
        OrderVersionEntry(
          versionNo: 1,
          revisedAt: now,
          updatedBy: 'Order desk',
          originalAmount: form.total,
          discountPercent: discountPct,
          revisedAmount: form.grandTotal,
          status: OrderStatus.confirmed,
          remarks: 'Order confirmed from quotation ${form.quoteNo}',
        ),
      ],
    );
    if (existingIdx >= 0) {
      _orders[existingIdx] = record;
    } else {
      _orders.add(record);
    }
    if (form.quotationId.isNotEmpty) {
      await _quotationApi.convertToOrder(
        form.quotationId,
        orderRef: form.orderNo,
      );
    }
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
