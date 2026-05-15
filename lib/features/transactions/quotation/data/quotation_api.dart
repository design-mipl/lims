import '../../shared/activity_timeline_models.dart';
import '../../enquiry/data/enquiry_api.dart';
import '../../enquiry/data/enquiry_model.dart';
import 'quotation_model.dart';

/// Mock quotations linked to enquiries.
class QuotationApi {
  QuotationApi({required EnquiryApi enquiryApi}) : _enquiryApi = enquiryApi {
    _items = _seed();
  }

  final EnquiryApi _enquiryApi;
  late List<QuotationRecord> _items;

  Future<List<QuotationRecord>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<QuotationRecord>.from(_items);
  }

  Future<QuotationRecord?> fetchById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    try {
      return _items.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  QuotationRecord? getByIdSync(String id) {
    try {
      return _items.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(QuotationRecord record) async {
    await Future<void>.delayed(const Duration(milliseconds: 70));
    final i = _items.indexWhere((q) => q.id == record.id);
    final next = record.copyWith(updatedAt: DateTime.now());
    if (i >= 0) {
      _items[i] = next;
    } else {
      _items.add(next);
    }
  }

  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 70));
    _items.removeWhere((q) => q.id == id);
  }

  Future<void> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return;
    final set = ids.toSet();
    _items.removeWhere((q) => set.contains(q.id));
  }

  String allocateQuoteNo() {
    final next = _items.length + 1;
    return 'QUO-${next.toString().padLeft(5, '0')}';
  }

  Future<QuotationRecord> createDraftFromEnquiry(String enquiryId) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    final EnquiryRecord? e = _enquiryApi.getByIdSync(enquiryId);
    if (e == null) {
      throw StateError('Unknown enquiry $enquiryId');
    }
    final id = 'quo-${DateTime.now().millisecondsSinceEpoch}';
    final quoteNo = allocateQuoteNo();
    final lines = e.requestedTests
        .where((t) => t.selected)
        .map(
          (t) => QuotationPricingLine(
            id: 'ln-${t.id}-$id',
            testCode: t.testCode,
            description: t.testName,
            qty: 1,
            rate: 2500,
          ),
        )
        .toList();
    final pricedLines = lines.isEmpty
        ? [
            QuotationPricingLine(
              id: 'ln-default-$id',
              testCode: 'PKG',
              description: 'Standard analysis package',
              qty: 1,
              rate: 4000,
            ),
          ]
        : lines;

    final quote = QuotationRecord(
      id: id,
      quoteNo: quoteNo,
      enquiryId: e.id,
      enquiryNo: e.enquiryNo,
      customerName: e.customerName,
      siteName: e.siteName,
      typeOfSample: e.typeOfSample,
      status: QuotationStatus.pendingPrep,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      preparedBy: 'Pricing desk',
      lines: pricedLines,
      discountAmount: 0,
      gstPercent: 18,
      terms: 'Net 30 days. Prices ex-works.',
      notes: '',
      internalComments: '',
      attachmentNames: List<String>.from(e.attachmentNames),
      activity: [
        ...e.activity,
        ActivityTimelineEntry(
          id: 'evt-$id-created',
          at: DateTime.now(),
          actorLabel: 'Pricing',
          message: 'Quotation $quoteNo drafted from ${e.enquiryNo}',
        ),
      ],
    );
    _items.add(quote);
    _enquiryApi.linkQuotation(enquiryId, id);
    return quote;
  }

  Future<void> sendToSalesReview(String id) async {
    final q = getByIdSync(id);
    if (q == null) return;
    await upsert(
      q.copyWith(
        status: QuotationStatus.inReview,
        activity: [
          ...q.activity,
          ActivityTimelineEntry(
            id: 'evt-$id-review',
            at: DateTime.now(),
            actorLabel: 'Pricing',
            message: 'Sent to sales review',
          ),
        ],
      ),
    );
  }

  Future<void> approve(String id, {double? discountOverride}) async {
    final q = getByIdSync(id);
    if (q == null) return;
    await upsert(
      q.copyWith(
        status: QuotationStatus.approved,
        discountAmount: discountOverride ?? q.discountAmount,
        approvedDiscountAmount: discountOverride ?? q.discountAmount,
        activity: [
          ...q.activity,
          ActivityTimelineEntry(
            id: 'evt-$id-appr',
            at: DateTime.now(),
            actorLabel: 'Sales',
            message: 'Quotation approved',
          ),
        ],
      ),
    );
  }

  Future<void> requestChanges(String id, String note) async {
    final q = getByIdSync(id);
    if (q == null) return;
    await upsert(
      q.copyWith(
        status: QuotationStatus.changesRequested,
        discussionNotes: note,
        activity: [
          ...q.activity,
          ActivityTimelineEntry(
            id: 'evt-$id-chg',
            at: DateTime.now(),
            actorLabel: 'Sales',
            message: 'Changes requested: $note',
          ),
        ],
      ),
    );
  }

  Future<void> convertToOrder(String id, {String orderRef = 'ORD-MOCK'}) async {
    final q = getByIdSync(id);
    if (q == null) return;
    await upsert(
      q.copyWith(
        orderReference: orderRef,
        activity: [
          ...q.activity,
          ActivityTimelineEntry(
            id: 'evt-$id-ord',
            at: DateTime.now(),
            actorLabel: 'Sales',
            message: 'Converted to order $orderRef → sample intake',
          ),
        ],
      ),
    );
    await _enquiryApi.markConverted(q.enquiryId);
  }

  List<QuotationRecord> _seed() {
    final now = DateTime.now();
    ActivityTimelineEntry ae(String id, int daysAgo, String who, String msg) =>
        ActivityTimelineEntry(
          id: id,
          at: now.subtract(Duration(days: daysAgo)),
          actorLabel: who,
          message: msg,
        );

    return [
      QuotationRecord(
        id: 'quo-1',
        quoteNo: 'QUO-70001',
        enquiryId: 'enq-2',
        enquiryNo: 'ENQ-00002',
        customerName: 'Northern Wind Energy',
        siteName: 'Jaipur Site',
        typeOfSample: 'Grease',
        status: QuotationStatus.pendingPrep,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
        preparedBy: 'You',
        lines: const [
          QuotationPricingLine(
            id: 'ln-a',
            testCode: 'FTIR',
            description: 'FTIR Spectroscopy',
            qty: 1,
            rate: 3200,
          ),
          QuotationPricingLine(
            id: 'ln-b',
            testCode: 'RULER',
            description: 'RULER oxidation',
            qty: 2,
            rate: 1800,
          ),
        ],
        discountAmount: 200,
        gstPercent: 18,
        terms: 'Net 30',
        notes: 'Rush reporting available.',
        internalComments: 'New turbine warranty batch.',
        attachmentNames: const [],
        activity: [
          ae('e1', 2, 'Pricing', 'Draft opened'),
        ],
      ),
      QuotationRecord(
        id: 'quo-2',
        quoteNo: 'QUO-70002',
        enquiryId: 'enq-5',
        enquiryNo: 'ENQ-00005',
        customerName: 'Metro Transit Corp',
        siteName: 'Depot North',
        typeOfSample: 'Gear oil',
        status: QuotationStatus.inReview,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 3)),
        preparedBy: 'Ravi Menon',
        lines: const [
          QuotationPricingLine(
            id: 'ln-c',
            testCode: 'ICP',
            description: 'ICP Metals',
            qty: 3,
            rate: 2100,
          ),
        ],
        discountAmount: 0,
        gstPercent: 18,
        terms: 'Standard Ultra Labs T&Cs',
        notes: '',
        internalComments: '',
        attachmentNames: const ['quote-draft.pdf'],
        activity: [
          ae('e2', 5, 'Pricing', 'Pricing completed'),
          ae('e3', 3, 'Pricing', 'Sent to sales'),
        ],
        discussionNotes: 'Awaiting discount approval',
      ),
      QuotationRecord(
        id: 'quo-3',
        quoteNo: 'QUO-70003',
        enquiryId: 'enq-3',
        enquiryNo: 'ENQ-00003',
        customerName: 'Coastal Chemicals',
        siteName: 'Chennai Dock',
        typeOfSample: 'Coolant',
        status: QuotationStatus.approved,
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 9)),
        preparedBy: 'Anita Rao',
        lines: const [
          QuotationPricingLine(
            id: 'ln-d',
            testCode: 'WATER',
            description: 'Water content',
            qty: 2,
            rate: 900,
          ),
        ],
        discountAmount: 150,
        gstPercent: 18,
        terms: 'Advance 50%',
        notes: 'Approved by customer verbally.',
        internalComments: '',
        attachmentNames: const [],
        activity: [
          ae('e4', 12, 'Pricing', 'Issued'),
          ae('e5', 10, 'Sales', 'Approved'),
        ],
        approvedDiscountAmount: 150,
      ),
    ];
  }
}
