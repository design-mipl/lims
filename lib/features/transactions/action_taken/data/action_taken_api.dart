import 'action_taken_model.dart';
import 'action_taken_workspace_model.dart';

/// Mock API for Action Taken — local seed data only.
class ActionTakenApi {
  ActionTakenApi() : _items = _seedRows();

  final List<ActionTakenRow> _items;
  final Map<String, ActionTakenWorkspaceDraft> _workspaceDrafts = {};

  Future<List<ActionTakenRow>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<ActionTakenRow>.from(_items);
  }

  ActionTakenRow? rowById(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ActionTakenWorkspaceDraft?> fetchWorkspaceDraft(String rowId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final row = rowById(rowId);
    if (row == null) return null;
    return _workspaceDrafts.putIfAbsent(
      rowId,
      () => _seedDraft(row),
    );
  }

  Future<void> saveWorkspaceDraft(ActionTakenWorkspaceDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    _workspaceDrafts[draft.rowId] = draft;
  }
}

const List<String> _chemists = [
  'Dr. Ananya Sharma',
  'P. Mehta, Sr. Chemist',
  'Dr. K. Iyer',
  'S. Bose',
  'R. Gupta',
  'Dr. N. Kapoor',
  'V. Nambiar',
  'L. Thomas',
];

ActionTakenWorkspaceDraft _seedDraft(ActionTakenRow row) {
  return ActionTakenWorkspaceDraft(
    rowId: row.id,
    comments:
        'Lab review flagged abnormal wear metals vs. baseline for ${row.labId}. '
        'Equipment ${row.equipmentIdNo} trend elevated iron and chromium.',
    recommendation:
        'Drain and flush circuit; replace filters; top-up with OEM-spec fluid '
        'and resubmit sample after 250 operating hours or 30 calendar days.',
    actionTaken: '',
    actionDate: null,
  );
}

List<ActionTakenRow> _seedRows() {
  final now = DateTime.now();
  DateTime d(int daysAgo) =>
      DateTime(now.year, now.month, now.day).subtract(Duration(days: daysAgo));

  String chem(int i) => _chemists[i % _chemists.length];

  return [
    ActionTakenRow(
      id: 'at-001',
      companyName: 'Ultra PetroChem Ltd',
      siteContactPerson: 'R. Menon',
      siteName: 'Vadodara Refinery',
      labId: 'LC-240891',
      typeOfSample: 'Lubricating Oil',
      samplingDate: d(2),
      equipmentIdNo: 'EQ-HYD-4412',
      sampleId: 'SMP-98231',
      make: 'Shell Tellus',
      chemist: chem(0),
      severity: ActionTakenRowSeverity.critical,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-002',
      companyName: 'RiverStone Mining',
      siteContactPerson: 'A. Kulkarni',
      siteName: 'Pit Conveyor B',
      labId: 'LC-240892',
      typeOfSample: 'Hydraulic Fluid',
      samplingDate: d(5),
      equipmentIdNo: 'EQ-CVH-2291',
      sampleId: 'SMP-98244',
      make: 'Mobil DTE',
      chemist: chem(1),
      severity: ActionTakenRowSeverity.cautions,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-003',
      companyName: 'Northwind Foods',
      siteContactPerson: 'S. Pereira',
      siteName: 'Cold Storage Unit 3',
      labId: 'LC-240893',
      typeOfSample: 'Compressor Oil',
      samplingDate: d(8),
      equipmentIdNo: 'EQ-REF-8830',
      sampleId: 'SMP-98251',
      make: 'Castrol Hyspin',
      chemist: chem(2),
      severity: ActionTakenRowSeverity.normal,
      status: ActionTakenStatus.completed,
    ),
    ActionTakenRow(
      id: 'at-004',
      companyName: 'Atlas Wind Energy',
      siteContactPerson: 'N. Shah',
      siteName: 'Turbine Farm Block A',
      labId: 'LC-240894',
      typeOfSample: 'Gear Oil',
      samplingDate: d(12),
      equipmentIdNo: 'EQ-WTG-1104',
      sampleId: 'SMP-98260',
      make: 'Klüber Synth',
      chemist: chem(3),
      severity: ActionTakenRowSeverity.critical,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-005',
      companyName: 'BluePeak Pharma',
      siteContactPerson: 'P. Desai',
      siteName: 'Sterile Plant Line 2',
      labId: 'LC-240895',
      typeOfSample: 'USP Mineral Oil',
      samplingDate: d(15),
      equipmentIdNo: 'EQ-MIX-7742',
      sampleId: 'SMP-98271',
      make: 'Sonnest',
      chemist: chem(4),
      severity: ActionTakenRowSeverity.normal,
      status: ActionTakenStatus.completed,
    ),
    ActionTakenRow(
      id: 'at-006',
      companyName: 'MetroRail Industries',
      siteContactPerson: 'K. Iyer',
      siteName: 'Depot Workshop North',
      labId: 'LC-240896',
      typeOfSample: 'Traction Oil',
      samplingDate: d(18),
      equipmentIdNo: 'EQ-TRN-5510',
      sampleId: 'SMP-98282',
      make: 'Petronas Tutela',
      chemist: chem(5),
      severity: ActionTakenRowSeverity.cautions,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-007',
      companyName: 'Coastal Shipyards',
      siteContactPerson: 'V. Nambiar',
      siteName: 'Dry Dock Bay 2',
      labId: 'LC-240897',
      typeOfSample: 'Marine Diesel',
      samplingDate: d(22),
      equipmentIdNo: 'EQ-DKY-3398',
      sampleId: 'SMP-98290',
      make: 'BP Marine',
      chemist: chem(6),
      severity: ActionTakenRowSeverity.normal,
      status: ActionTakenStatus.completed,
    ),
    ActionTakenRow(
      id: 'at-008',
      companyName: 'Summit Cement',
      siteContactPerson: 'J. Rawat',
      siteName: 'Kiln Gear Drive',
      labId: 'LC-240898',
      typeOfSample: 'Industrial Gear Oil',
      samplingDate: d(25),
      equipmentIdNo: 'EQ-KLN-6612',
      sampleId: 'SMP-98301',
      make: 'Shell Omala',
      chemist: chem(7),
      severity: ActionTakenRowSeverity.critical,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-009',
      companyName: 'Evergreen Paper Mills',
      siteContactPerson: 'T. Bose',
      siteName: 'Steam Turbine Hall',
      labId: 'LC-240899',
      typeOfSample: 'Turbine Oil',
      samplingDate: d(28),
      equipmentIdNo: 'EQ-STB-4401',
      sampleId: 'SMP-98312',
      make: 'Chevron GST',
      chemist: chem(0),
      severity: ActionTakenRowSeverity.cautions,
      status: ActionTakenStatus.completed,
    ),
    ActionTakenRow(
      id: 'at-010',
      companyName: 'Horizon Auto Components',
      siteContactPerson: 'M. Sinha',
      siteName: 'Press Shop Line 4',
      labId: 'LC-240900',
      typeOfSample: 'Hydraulic Oil',
      samplingDate: d(31),
      equipmentIdNo: 'EQ-PRS-2288',
      sampleId: 'SMP-98320',
      make: 'Total Equivis',
      chemist: chem(1),
      severity: ActionTakenRowSeverity.normal,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-011',
      companyName: 'SilverLake Dairy',
      siteContactPerson: 'L. Thomas',
      siteName: 'Pasteurizer Skid',
      labId: 'LC-240901',
      typeOfSample: 'Food-grade Oil',
      samplingDate: d(34),
      equipmentIdNo: 'EQ-PAS-1199',
      sampleId: 'SMP-98331',
      make: 'Klüber FM',
      chemist: chem(2),
      severity: ActionTakenRowSeverity.normal,
      status: ActionTakenStatus.completed,
    ),
    ActionTakenRow(
      id: 'at-012',
      companyName: 'Vertex Steel',
      siteContactPerson: 'H. Patil',
      siteName: 'Rolling Mill Lubrication',
      labId: 'LC-240902',
      typeOfSample: 'Circulating Oil',
      samplingDate: d(40),
      equipmentIdNo: 'EQ-ROL-9934',
      sampleId: 'SMP-98345',
      make: 'Quaker Houghton',
      chemist: chem(3),
      severity: ActionTakenRowSeverity.critical,
      status: ActionTakenStatus.completed,
    ),
    ActionTakenRow(
      id: 'at-013',
      companyName: 'ClearStream Water',
      siteContactPerson: 'D. Fernandes',
      siteName: 'Pump Station 7',
      labId: 'LC-240903',
      typeOfSample: 'Synthetic ISO VG 68',
      samplingDate: d(45),
      equipmentIdNo: 'EQ-PMP-7721',
      sampleId: 'SMP-98352',
      make: 'Amoco Sync',
      chemist: chem(4),
      severity: ActionTakenRowSeverity.cautions,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-014',
      companyName: 'Zenith Packaging',
      siteContactPerson: 'R. Gupta',
      siteName: 'Extruder Hydraulic Pack',
      labId: 'LC-240904',
      typeOfSample: 'Hydraulic Oil',
      samplingDate: d(48),
      equipmentIdNo: 'EQ-EXT-5519',
      sampleId: 'SMP-98360',
      make: 'Shell Tellus',
      chemist: chem(5),
      severity: ActionTakenRowSeverity.normal,
      status: ActionTakenStatus.completed,
    ),
    ActionTakenRow(
      id: 'at-015',
      companyName: 'Polar Logistics',
      siteContactPerson: 'C. D\'Souza',
      siteName: 'Cold Chain Hub',
      labId: 'LC-240905',
      typeOfSample: 'Compressor Lubricant',
      samplingDate: d(52),
      equipmentIdNo: 'EQ-CMP-3381',
      sampleId: 'SMP-98371',
      make: 'Mobil Rarus',
      chemist: chem(6),
      severity: ActionTakenRowSeverity.critical,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-016',
      companyName: 'Granite Power Gen',
      siteContactPerson: 'S. Krishnan',
      siteName: 'GT Package B',
      labId: 'LC-240906',
      typeOfSample: 'Synthetic Turbine Oil',
      samplingDate: d(55),
      equipmentIdNo: 'EQ-GTG-9022',
      sampleId: 'SMP-98380',
      make: 'BP Energol',
      chemist: chem(7),
      severity: ActionTakenRowSeverity.cautions,
      status: ActionTakenStatus.completed,
    ),
    ActionTakenRow(
      id: 'at-017',
      companyName: 'Oakridge Hospitals',
      siteContactPerson: 'N. Kapoor',
      siteName: 'Backup Generator Farm',
      labId: 'LC-240907',
      typeOfSample: 'Engine Oil',
      samplingDate: d(58),
      equipmentIdNo: 'EQ-GEN-6644',
      sampleId: 'SMP-98391',
      make: 'Castrol CRB',
      chemist: chem(0),
      severity: ActionTakenRowSeverity.normal,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-018',
      companyName: 'SkyForge Aerospace',
      siteContactPerson: 'A. Verma',
      siteName: 'Test Cell ISO 7',
      labId: 'LC-240908',
      typeOfSample: 'Synthetic Fluid',
      samplingDate: d(62),
      equipmentIdNo: 'EQ-TST-7710',
      sampleId: 'SMP-98402',
      make: 'Eastman Skydrol',
      chemist: chem(1),
      severity: ActionTakenRowSeverity.critical,
      status: ActionTakenStatus.completed,
    ),
    ActionTakenRow(
      id: 'at-019',
      companyName: 'Willow Textiles',
      siteContactPerson: 'P. Reddy',
      siteName: 'Stenter lubrication loop',
      labId: 'LC-240909',
      typeOfSample: 'High-temp Chain Oil',
      samplingDate: d(66),
      equipmentIdNo: 'EQ-STN-2218',
      sampleId: 'SMP-98410',
      make: 'Klüber Hotemp',
      chemist: chem(2),
      severity: ActionTakenRowSeverity.cautions,
      status: ActionTakenStatus.pending,
    ),
    ActionTakenRow(
      id: 'at-020',
      companyName: 'BrightFuture Solar',
      siteContactPerson: 'K. Mishra',
      siteName: 'Inverter Cooling Skid',
      labId: 'LC-240910',
      typeOfSample: 'Heat Transfer Fluid',
      samplingDate: d(70),
      equipmentIdNo: 'EQ-HTF-4477',
      sampleId: 'SMP-98421',
      make: 'Dow Syltherm',
      chemist: chem(3),
      severity: ActionTakenRowSeverity.normal,
      status: ActionTakenStatus.completed,
    ),
  ];
}
