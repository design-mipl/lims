import '../../shared/activity_timeline_models.dart';
import 'enquiry_model.dart';

/// Mock persistence for enquiries.
class EnquiryApi {
  EnquiryApi() {
    _items = _seed();
  }

  late List<EnquiryRecord> _items;

  Future<List<EnquiryRecord>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return List<EnquiryRecord>.from(_items);
  }

  Future<EnquiryRecord?> fetchById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  EnquiryRecord? getByIdSync(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(EnquiryRecord record) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final i = _items.indexWhere((e) => e.id == record.id);
    if (i >= 0) {
      _items[i] = record;
    } else {
      _items.add(record);
    }
  }

  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _items.removeWhere((e) => e.id == id);
  }

  Future<void> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final set = ids.toSet();
    _items.removeWhere((e) => set.contains(e.id));
  }

  void linkQuotation(String enquiryId, String quotationId) {
    final i = _items.indexWhere((e) => e.id == enquiryId);
    if (i < 0) return;
    final e = _items[i];
    final next = e.copyWith(
      quotationId: quotationId,
      activity: [
        ...e.activity,
        ActivityTimelineEntry(
          id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
          at: DateTime.now(),
          actorLabel: 'Sales',
          message: 'Quotation $quotationId linked',
        ),
      ],
    );
    _items[i] = next;
  }

  Future<void> markConverted(String enquiryId) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final i = _items.indexWhere((e) => e.id == enquiryId);
    if (i < 0) return;
    final e = _items[i];
    _items[i] = e.copyWith(
      status: EnquiryStatus.converted,
      activity: [
        ...e.activity,
        ActivityTimelineEntry(
          id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
          at: DateTime.now(),
          actorLabel: 'System',
          message: 'Converted to order (sample intake)',
        ),
      ],
    );
  }

  String allocateEnquiryNo() {
    final next = _items.length + 1;
    return 'ENQ-${next.toString().padLeft(5, '0')}';
  }

  List<EnquiryRecord> _seed() {
    final now = DateTime.now();
    EnquiryRequestedTestRow t(
      String id,
      String code,
      String name, {
      bool sel = true,
    }) =>
        EnquiryRequestedTestRow(
          id: id,
          testCode: code,
          testName: name,
          selected: sel,
          priority: 'Normal',
          remarks: '',
        );

    ActivityTimelineEntry a(String id, int daysAgo, String who, String msg) =>
        ActivityTimelineEntry(
          id: id,
          at: now.subtract(Duration(days: daysAgo)),
          actorLabel: who,
          message: msg,
        );

    EnquiryRecord row({
      required String id,
      required String no,
      required int daysAgo,
      required String status,
      required String cust,
      required String site,
      required String source,
      required String sampleType,
      required int samples,
      required String createdBy,
      String? quotationId,
      List<EnquiryRequestedTestRow>? tests,
      List<ActivityTimelineEntry>? act,
    }) {
      final eta = now.add(const Duration(days: 21));
      final etaStr =
          '${eta.year}-${eta.month.toString().padLeft(2, '0')}-${eta.day.toString().padLeft(2, '0')}';
      return EnquiryRecord(
        id: id,
        enquiryNo: no,
        enquiryDate: now.subtract(Duration(days: daysAgo)),
        customerName: cust,
        siteName: site,
        enquirySource: source,
        typeOfSample: sampleType,
        sampleCount: samples,
        status: status,
        createdBy: createdBy,
        customerCompany: '$cust Pvt Ltd',
        siteContactPerson: 'Site Manager',
        siteCompany: site,
        contactPerson: 'Priya Nair',
        contactEmail: 'priya@example.com',
        contactPhone: '+91 90000 10001',
        equipmentMakeModel: 'Pump unit P-220',
        operatingConditions: 'Continuous duty',
        urgency: 'Normal',
        expectedTimeline: etaStr,
        samplePriority:
            status == EnquiryStatus.submitted ? 'High' : 'Normal',
        internalNotes: 'Standard lubricant suite.',
        attachmentNames: const ['site-photo-1.jpg'],
        requestedTests: tests ??
            [
              t('rt-1', 'FTIR', 'FTIR Spectroscopy'),
              t('rt-2', 'ICP', 'ICP Metals'),
            ],
        activity: act ??
            [
              a('a1', 3, createdBy, 'Enquiry captured'),
              a('a2', 2, 'Sales', 'Customer clarification requested'),
            ],
        quotationId: quotationId,
      );
    }

    return [
      row(
        id: 'enq-1',
        no: 'ENQ-00001',
        daysAgo: 4,
        status: EnquiryStatus.pending,
        cust: 'Acme Industries',
        site: 'Mumbai Plant',
        source: 'Email',
        sampleType: 'Lubricating oil',
        samples: 3,
        createdBy: 'Neha Sharma',
      ),
      row(
        id: 'enq-2',
        no: 'ENQ-00002',
        daysAgo: 6,
        status: EnquiryStatus.submitted,
        cust: 'Northern Wind Energy',
        site: 'Jaipur Site',
        source: 'Portal',
        sampleType: 'Grease',
        samples: 5,
        createdBy: 'Ravi Menon',
      ),
      row(
        id: 'enq-3',
        no: 'ENQ-00003',
        daysAgo: 10,
        status: EnquiryStatus.converted,
        cust: 'Coastal Chemicals',
        site: 'Chennai Dock',
        source: 'Phone',
        sampleType: 'Coolant',
        samples: 2,
        createdBy: 'Anita Rao',
        quotationId: 'quo-3',
      ),
      row(
        id: 'enq-4',
        no: 'ENQ-00004',
        daysAgo: 1,
        status: EnquiryStatus.pending,
        cust: 'Ultra Labs Demo',
        site: 'Pilot Lab',
        source: 'Walk-in',
        sampleType: 'Hydraulic fluid',
        samples: 4,
        createdBy: 'Demo User',
        tests: [
          t('rt-4', 'PQ', 'Particle Quantifier'),
          t('rt-5', 'Water', 'Water content'),
          t('rt-6', 'Viscosity', 'KV40', sel: false),
        ],
      ),
      row(
        id: 'enq-5',
        no: 'ENQ-00005',
        daysAgo: 8,
        status: EnquiryStatus.submitted,
        cust: 'Metro Transit Corp',
        site: 'Depot North',
        source: 'Email',
        sampleType: 'Gear oil',
        samples: 6,
        createdBy: 'Karthik Iyer',
      ),
    ];
  }
}
