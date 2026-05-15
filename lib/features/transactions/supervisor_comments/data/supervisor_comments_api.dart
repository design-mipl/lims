import 'supervisor_comments_model.dart';
import 'supervisor_review_workspace_model.dart';

/// In-memory mock API for Supervisor Comments listing.
class SupervisorCommentsApi {
  SupervisorCommentsApi() {
    final now = DateTime.now();
    _items = [
      SupervisorCommentsRow(
        id: 'sc-1',
        companyName: 'IDEMITSU LUBE INDIA PVT LTD',
        siteName: 'IDEMITSU Mumbai Plant',
        typeOfSample: 'LUBE OIL',
        samplingDate: now.subtract(const Duration(days: 2)),
        lotNo: 'LOT-24091',
        labId: 'LCN-2026/05-639',
        lubeHrs: 4200,
        hmr: 11800,
        topUpVolume: 2.5,
        dtOfReceipt: now.subtract(const Duration(days: 1)),
        sampleId: 'ES150',
        make: 'Atlas Copco',
        model: 'GA-55',
        serialNo: 'SN-77821',
        oilBrand: 'IDEMITSU',
        oilGrade: 'DAPHNE SUPER 68',
        samplingPoint: 'Main sump',
        customerNote: 'Routine annual',
        labDate: now.subtract(const Duration(days: 1)),
        zone: 'North',
        fluid: 'Mineral',
        status: SupervisorCommentsStatus.pending,
        supervisorComment: '',
      ),
      SupervisorCommentsRow(
        id: 'sc-2',
        companyName: 'Coastal Petro',
        siteName: 'Coastal Jamnagar',
        typeOfSample: 'Coolant',
        samplingDate: now.subtract(const Duration(days: 5)),
        lotNo: 'LOT-24092',
        labId: 'LCN-2026/05-640',
        lubeHrs: 2100,
        hmr: 6400,
        topUpVolume: 0,
        dtOfReceipt: now.subtract(const Duration(days: 4)),
        sampleId: 'USN585462',
        make: 'SKF',
        model: 'Lincoln',
        serialNo: 'SN-44102',
        oilBrand: 'Castrol',
        oilGrade: 'Syntilo 9918',
        samplingPoint: 'Coolant tank',
        customerNote: 'Foaming observed',
        labDate: now.subtract(const Duration(days: 3)),
        zone: 'West',
        fluid: 'Synthetic blend',
        status: SupervisorCommentsStatus.completed,
        supervisorComment: 'Reviewed — coolant acceptable.',
      ),
      SupervisorCommentsRow(
        id: 'sc-3',
        companyName: 'Northwind Traders',
        siteName: 'Northwind Pune',
        typeOfSample: 'Hydraulic fluid',
        samplingDate: now.subtract(const Duration(days: 7)),
        lotNo: 'LOT-24093',
        labId: 'LCN-2026/05-641',
        lubeHrs: 8800,
        hmr: 15200,
        topUpVolume: 5.2,
        dtOfReceipt: now.subtract(const Duration(days: 6)),
        sampleId: 'USN585463',
        make: 'Parker',
        model: 'HPU-200',
        serialNo: 'SN-22901',
        oilBrand: 'Shell',
        oilGrade: 'Tellus S2 V 46',
        samplingPoint: 'Hydraulic power unit',
        customerNote: '',
        labDate: now.subtract(const Duration(days: 5)),
        zone: 'South',
        fluid: 'Mineral',
        status: SupervisorCommentsStatus.pending,
      ),
      SupervisorCommentsRow(
        id: 'sc-4',
        companyName: 'Steelworks Ltd',
        siteName: 'Steelworks Bokaro',
        typeOfSample: 'Metal swarf',
        samplingDate: now.subtract(const Duration(days: 10)),
        lotNo: 'LOT-24094',
        labId: 'LCN-2026/05-642',
        lubeHrs: 1200,
        hmr: 3200,
        topUpVolume: 0.5,
        dtOfReceipt: now.subtract(const Duration(days: 9)),
        sampleId: 'USN585464',
        make: 'Siemens',
        model: 'Line-Mill-1',
        serialNo: 'SN-99120',
        oilBrand: 'Mobil',
        oilGrade: 'SHC 630',
        samplingPoint: 'Gearbox',
        customerNote: 'Particle count requested',
        labDate: now.subtract(const Duration(days: 8)),
        zone: 'East',
        fluid: 'PAO',
        status: SupervisorCommentsStatus.completed,
        supervisorComment: '',
      ),
      SupervisorCommentsRow(
        id: 'sc-5',
        companyName: 'BioPharm Co',
        siteName: 'BioPharm Hyderabad',
        typeOfSample: 'Process water',
        samplingDate: now.subtract(const Duration(days: 12)),
        lotNo: 'LOT-24095',
        labId: 'LCN-2026/05-643',
        lubeHrs: 0,
        hmr: 0,
        topUpVolume: 0,
        dtOfReceipt: now.subtract(const Duration(days: 11)),
        sampleId: 'USN585465',
        make: 'GE',
        model: 'Water-IX',
        serialNo: 'SN-10293',
        oilBrand: 'N/A',
        oilGrade: 'N/A',
        samplingPoint: 'RO outlet',
        customerNote: 'TOC trending up',
        labDate: now.subtract(const Duration(days: 10)),
        zone: 'North',
        fluid: 'Water',
        status: SupervisorCommentsStatus.pending,
      ),
      SupervisorCommentsRow(
        id: 'sc-6',
        companyName: 'IDEMITSU LUBE INDIA PVT LTD',
        siteName: 'IDEMITSU Chennai DC',
        typeOfSample: 'USED ENGINE OIL',
        samplingDate: now.subtract(const Duration(days: 1)),
        lotNo: 'LOT-24096',
        labId: 'LCN-2026/05-644',
        lubeHrs: 5100,
        hmr: 14200,
        topUpVolume: 1.1,
        dtOfReceipt: now,
        sampleId: 'ES151',
        make: 'Caterpillar',
        model: 'C18',
        serialNo: 'SN-55201',
        oilBrand: 'IDEMITSU',
        oilGrade: 'AP-S 15W40',
        samplingPoint: 'Engine sump',
        customerNote: 'Post service',
        labDate: now,
        zone: 'South',
        fluid: 'Mineral',
        status: SupervisorCommentsStatus.pending,
      ),
    ];
  }

  late List<SupervisorCommentsRow> _items;

  /// Draft / saved workspace payloads keyed by supervisor comment row id.
  final Map<String, SupervisorReviewWorkspace> _workspaceById = {};

  Future<List<SupervisorCommentsRow>> fetchAll() async {
    return List<SupervisorCommentsRow>.unmodifiable(_items);
  }

  Future<SupervisorCommentsRow?> fetchById(String id) async {
    for (final e in _items) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> updateSupervisorComment(String id, String comment) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(supervisorComment: comment);
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    final remove = ids.toSet();
    _items = _items.where((e) => !remove.contains(e.id)).toList();
    for (final id in remove) {
      _workspaceById.remove(id);
    }
  }

  /// Loads workspace for review UI (creates seed data once per id until replaced).
  Future<SupervisorReviewWorkspace?> fetchWorkspace(String supervisorCommentsId) async {
    final row = await fetchById(supervisorCommentsId);
    if (row == null) return null;
    final existing = _workspaceById[supervisorCommentsId];
    if (existing != null) {
      return _normalizeHistoricalColumns(existing);
    }
    final seeded = _seedWorkspace(row);
    _workspaceById[supervisorCommentsId] = seeded;
    return seeded;
  }

  Future<void> saveWorkspaceDraft(SupervisorReviewWorkspace workspace) async {
    _workspaceById[workspace.supervisorCommentsId] = workspace;
    final i = _items.indexWhere((e) => e.id == workspace.supervisorCommentsId);
    if (i >= 0) {
      final merged = [
        workspace.problem,
        workspace.comments,
        workspace.recommendation,
      ].where((s) => s.trim().isNotEmpty).join('\n');
      if (merged.isNotEmpty) {
        _items[i] = _items[i].copyWith(supervisorComment: merged);
      }
    }
  }

  Future<void> approveWorkspace(String supervisorCommentsId) async {
    final i = _items.indexWhere((e) => e.id == supervisorCommentsId);
    if (i >= 0) {
      _items[i] = _items[i].copyWith(status: SupervisorCommentsStatus.completed);
    }
  }

  Future<void> sendBackWorkspace(String supervisorCommentsId) async {
    final i = _items.indexWhere((e) => e.id == supervisorCommentsId);
    if (i >= 0) {
      _items[i] = _items[i].copyWith(status: SupervisorCommentsStatus.pending);
    }
  }

  SupervisorReviewWorkspace _seedWorkspace(SupervisorCommentsRow row) {
    final chemist = _chemistFor(row.id);
    final lines = _seedLines(row, chemist);
    final withSeverity = lines.map(_recomputeLineSeverity).toList();
    final status = _sampleSeverityStatus(withSeverity);
    return SupervisorReviewWorkspace(
      supervisorCommentsId: row.id,
      severityStatus: status,
      assignedChemist: chemist,
      historicalComparisonHeaders: List<String>.from(_kSupervisorHistoricalHeaders),
      lines: withSeverity,
      problem: '',
      comments: row.supervisorComment,
      recommendation: '',
    );
  }

  /// Historical comparison headers after Chemist — Lab Id + HMR merged per column.
  static const List<String> _kSupervisorHistoricalHeaders = [
    'LCN-2026/02-251\nHMR: 26077',
    'LCN-2025/12-1182\nHMR: 25080',
    'LCN-2025/10-544\nHMR: 24161',
    'LCN-2025/08-391\nHMR: 23204',
  ];

  /// Upgrades in-memory workspaces created before LCN/HMR header merge.
  static SupervisorReviewWorkspace _normalizeHistoricalColumns(
    SupervisorReviewWorkspace ws,
  ) {
    final headers = ws.historicalComparisonHeaders;
    if (headers.isEmpty) return ws;
    if (headers.first.contains('\n')) return ws;
    if (headers.length < 2 || !headers[1].trim().toUpperCase().startsWith('HMR')) {
      return ws;
    }
    final mergedHeaders = <String>[];
    for (var i = 0; i < headers.length; i += 2) {
      if (i + 1 < headers.length) {
        mergedHeaders.add('${headers[i]}\n${headers[i + 1]}');
      } else {
        mergedHeaders.add(headers[i]);
      }
    }
    final lines = [
      for (final line in ws.lines)
        line.copyWith(
          historicalComparisonValues: line.historicalComparisonValues.length >
                  mergedHeaders.length
              ? historicalParameterValues(line.historicalComparisonValues)
              : line.historicalComparisonValues,
        ),
    ];
    return ws.copyWith(
      historicalComparisonHeaders: mergedHeaders,
      lines: lines,
    );
  }

  /// Parameter values only (drops alternating HMR slots from legacy flat lists).
  static List<String> historicalParameterValues(List<String> alternating) {
    if (alternating.isEmpty) return const [];
    final out = <String>[];
    for (var i = 0; i < alternating.length; i += 2) {
      out.add(alternating[i]);
    }
    return out;
  }

  static String _chemistFor(String rowId) {
    const names = [
      'Priya Nair',
      'Rahul Menon',
      'Ananya Kulkarni',
      'Vikram Shah',
    ];
    var h = 0;
    for (final c in rowId.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return names[h % names.length];
  }

  List<SupervisorReviewTestLine> _seedLines(
    SupervisorCommentsRow row,
    String chemist,
  ) {
    final rowId = row.id;
    final suffix = rowId.hashCode.abs() % 7;

    const physico = 'Physico Chemical Analysis';
    const ftir = 'FTIR - ASTM E2412';
    const astm = 'ASTM D5185';

    return [
      SupervisorReviewTestLine(
        id: '$rowId-t1',
        methodGroup: physico,
        parameterName: 'Viscosity @ 40°C (cSt)',
        currentValue: '${62.4 + suffix * 0.1}',
        minLimit: '58.0',
        maxLimit: '68.0',
        customerMin: '56.0',
        customerMax: '70.0',
        fluidMin: '58.0',
        fluidMax: '68.0',
        freshFluidValue: '61.2',
        typical: '62–64',
        highlightFlag: false,
        previousValue: '${61.9 + suffix * 0.1}',
        trendDisplay: '',
        historicalComparisonValues: const [
          '61.8',
          '61.2',
          '60.9',
          '60.4',
        ],
        severity: SupervisorReviewSeverity.normal,
        flagCritical: false,
        includeInReport: true,
        chemist: chemist,
        recordedOn: row.samplingDate,
      ),
      SupervisorReviewTestLine(
        id: '$rowId-t2',
        methodGroup: physico,
        parameterName: 'TBN (mg KOH/g)',
        currentValue: suffix.isEven ? '4.8' : '3.1',
        minLimit: '5.0',
        maxLimit: '—',
        customerMin: '5.0',
        customerMax: '—',
        fluidMin: '5.2',
        fluidMax: '—',
        freshFluidValue: '6.1',
        typical: '≥ 5.0',
        highlightFlag: false,
        previousValue: suffix.isEven ? '5.2' : '4.9',
        trendDisplay: '',
        historicalComparisonValues: const [
          '5.6',
          '5.4',
          '5.5',
          '5.3',
        ],
        severity: SupervisorReviewSeverity.normal,
        flagCritical: false,
        includeInReport: true,
        chemist: chemist,
        recordedOn: row.samplingDate.add(const Duration(days: 1)),
      ),
      SupervisorReviewTestLine(
        id: '$rowId-t3',
        methodGroup: physico,
        parameterName: 'Water content %',
        currentValue: '420',
        minLimit: '—',
        maxLimit: '300',
        customerMin: '—',
        customerMax: '250',
        fluidMin: '—',
        fluidMax: '280',
        freshFluidValue: '120',
        typical: '< 200',
        highlightFlag: true,
        previousValue: '280',
        trendDisplay: '',
        historicalComparisonValues: const [
          '240',
          '210',
          '195',
          '188',
        ],
        severity: SupervisorReviewSeverity.normal,
        flagCritical: true,
        includeInReport: true,
        chemist: chemist,
        recordedOn: row.samplingDate.add(const Duration(days: 2)),
      ),
      SupervisorReviewTestLine(
        id: '$rowId-t4',
        methodGroup: ftir,
        parameterName: 'Iron (Fe)',
        currentValue: '14.2',
        minLimit: '—',
        maxLimit: '15.0',
        customerMin: '—',
        customerMax: '18.0',
        fluidMin: '—',
        fluidMax: '16.0',
        freshFluidValue: '6.2',
        typical: '< 10',
        highlightFlag: false,
        previousValue: '11.0',
        trendDisplay: '',
        historicalComparisonValues: const [
          '12.1',
          '11.8',
          '10.4',
          '9.9',
        ],
        severity: SupervisorReviewSeverity.normal,
        flagCritical: false,
        includeInReport: false,
        chemist: chemist,
        recordedOn: row.samplingDate.add(const Duration(days: 3)),
      ),
      SupervisorReviewTestLine(
        id: '$rowId-t5',
        methodGroup: ftir,
        parameterName: 'Chromium (Cr)',
        currentValue: '2.1',
        minLimit: '—',
        maxLimit: '3.0',
        customerMin: '—',
        customerMax: '4.0',
        fluidMin: '—',
        fluidMax: '3.5',
        freshFluidValue: '0.8',
        typical: '< 2',
        highlightFlag: true,
        previousValue: '1.6',
        trendDisplay: '',
        historicalComparisonValues: const [
          '1.8',
          '1.7',
          '1.6',
          '1.5',
        ],
        severity: SupervisorReviewSeverity.normal,
        flagCritical: false,
        includeInReport: true,
        chemist: chemist,
        recordedOn: row.samplingDate.add(const Duration(days: 4)),
      ),
      SupervisorReviewTestLine(
        id: '$rowId-t6',
        methodGroup: astm,
        parameterName: 'Copper (Cu)',
        currentValue: suffix.isEven ? '11.5' : '8.2',
        minLimit: '—',
        maxLimit: '12.0',
        customerMin: '—',
        customerMax: '14.0',
        fluidMin: '—',
        fluidMax: '13.0',
        freshFluidValue: '4.0',
        typical: '< 8',
        highlightFlag: false,
        previousValue: '7.9',
        trendDisplay: '',
        historicalComparisonValues: const [
          '9.2',
          '8.8',
          '8.1',
          '7.6',
        ],
        severity: SupervisorReviewSeverity.normal,
        flagCritical: false,
        includeInReport: true,
        chemist: chemist,
        recordedOn: row.samplingDate.add(const Duration(days: 5)),
      ),
    ];
  }

  /// Recomputes severity/trend from limits after a row edit (mock parity with backend).
  SupervisorReviewTestLine recomputeReviewLine(SupervisorReviewTestLine line) =>
      _recomputeLineSeverity(line);

  SupervisorReviewTestLine _recomputeLineSeverity(SupervisorReviewTestLine line) {
    final sev = _computeSeverity(line.currentValue, line.minLimit, line.maxLimit);
    final trend = _trend(line.currentValue, line.previousValue);
    return line.copyWith(
      severity: sev,
      trendDisplay: trend,
      flagCritical: line.flagCritical || sev == SupervisorReviewSeverity.critical,
    );
  }

  static SupervisorReviewSeverity _computeSeverity(
    String current,
    String min,
    String max,
  ) {
    final c = _parseNum(current);
    final lo = _parseNum(min);
    final hi = _parseNum(max);
    if (c == null) return SupervisorReviewSeverity.normal;

    var breached = false;
    if (lo != null && c < lo) breached = true;
    if (hi != null && c > hi) breached = true;
    if (breached) return SupervisorReviewSeverity.critical;

    if (lo != null && hi != null && hi > lo) {
      final span = hi - lo;
      if (span > 0) {
        final distLo = (c - lo) / span;
        final distHi = (hi - c) / span;
        if (distLo <= 0.12 || distHi <= 0.12) {
          return SupervisorReviewSeverity.warning;
        }
      }
    } else if (lo != null && hi == null) {
      final margin = lo.abs() * 0.08;
      if (c >= lo && c <= lo + margin) {
        return SupervisorReviewSeverity.warning;
      }
    } else if (hi != null && lo == null) {
      final margin = hi.abs() * 0.08;
      if (c <= hi && c >= hi - margin) {
        return SupervisorReviewSeverity.warning;
      }
    }

    return SupervisorReviewSeverity.normal;
  }

  static double? _parseNum(String raw) {
    final t = raw.trim();
    if (t.isEmpty || t == '—' || t == '-') return null;
    return double.tryParse(t.replaceAll(',', ''));
  }

  static String _trend(String current, String previous) {
    final c = _parseNum(current);
    final p = _parseNum(previous);
    if (c == null || p == null) return '→ Stable';
    if (c > p * 1.03) return '↑ Increased';
    if (c < p * 0.97) return '↓ Decreased';
    return '→ Stable';
  }

  static String _sampleSeverityStatus(List<SupervisorReviewTestLine> lines) {
    var worst = SupervisorReviewSeverity.normal;
    for (final e in lines) {
      if (e.severity == SupervisorReviewSeverity.critical) {
        worst = SupervisorReviewSeverity.critical;
        break;
      }
      if (e.severity == SupervisorReviewSeverity.warning) {
        worst = SupervisorReviewSeverity.warning;
      }
    }
    return worst.label;
  }
}

