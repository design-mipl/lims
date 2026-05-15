import 'lab_workflow_test_line.dart';

/// Shared section titles for lab workflow nested tables (verification / chemist seeds).
const String kLabWorkflowSectionPhysico = 'Physico Chemical Analysis';
const String kLabWorkflowSectionFtir = 'FTIR - ASTM E2412';

/// Elemental wear metals block title for Lab Manager Verification seeds.
const String kLabMethodD5185 = 'ASTM D5185';

class _MvTpl {
  const _MvTpl(
    this.testName,
    this.value,
    this.minValue,
    this.maxValue,
    this.typical,
    this.retestRemarks,
  );

  final String testName;
  final String value;
  final String minValue;
  final String maxValue;
  final String typical;
  final String retestRemarks;
}

typedef _MvBlock = ({String method, String chemist, List<_MvTpl> rows});

/// Synthetic merged timeline for Lab Manager Verification — grouped by method codes.
/// Verified counts are **per assigned test line** (`lineVerified`), not listing rows.
List<LabWorkflowTestLine> labWorkflowManagerVerificationDetailLines({
  required String rowId,
  required bool parentVerified,
}) {
  final profile = rowId.hashCode.abs() % 5;

  /// When [parentVerified] is false, first [n] lines (global order) show as verified.
  const verifiedWhenPartial = [0, 0, 3, 8, 12];

  final raw = <_MvBlock>[
    switch (profile) {
      0 => (
          method: kLabWorkflowSectionPhysico,
          chemist: 'A. Mehta',
          rows: const [
            _MvTpl(
              'Viscosity @ 40°C',
              '36.2',
              '34.0',
              '38.0',
              '36.5',
              '—',
            ),
            _MvTpl(
              'Viscosity @ 100°C',
              '6.9',
              '6.0',
              '8.5',
              '7.1',
              '—',
            ),
            _MvTpl('Pour point °C', '-41', '-45', '-35', '-40', '—'),
            _MvTpl(
              'Flash point °C',
              '218',
              '200',
              '—',
              '215',
              '—',
            ),
          ],
        ),
      1 => (
          method: kLabWorkflowSectionPhysico,
          chemist: 'A. Mehta',
          rows: const [
            _MvTpl(
              'Viscosity @ 40°C',
              '35.9',
              '34.0',
              '38.0',
              '36.5',
              'Repeat if out of spec',
            ),
            _MvTpl(
              'Viscosity @ 100°C',
              '7.0',
              '6.0',
              '8.5',
              '7.1',
              '—',
            ),
            _MvTpl('Pour point °C', '-39', '-45', '-35', '-40', '—'),
          ],
        ),
      2 => (
          method: kLabWorkflowSectionPhysico,
          chemist: 'A. Mehta',
          rows: const [
            _MvTpl(
              'Viscosity @ 40°C',
              '36.4',
              '34.0',
              '38.0',
              '36.5',
              '—',
            ),
            _MvTpl(
              'Viscosity @ 100°C',
              '6.8',
              '6.0',
              '8.5',
              '7.1',
              '—',
            ),
            _MvTpl('Pour point °C', '-43', '-45', '-35', '-40', '—'),
            _MvTpl(
              'Flash point °C',
              '212',
              '200',
              '—',
              '215',
              '—',
            ),
            _MvTpl('TBN', '6.2', '5.0', '8.0', '6.5', '—'),
            _MvTpl(
              'Water content %',
              '0.03',
              '0.00',
              '0.08',
              '0.03',
              'Dilution suspected',
            ),
          ],
        ),
      3 => (
          method: kLabWorkflowSectionPhysico,
          chemist: 'A. Mehta',
          rows: const [
            _MvTpl(
              'Viscosity @ 40°C',
              '37.1',
              '34.0',
              '38.0',
              '36.5',
              '—',
            ),
            _MvTpl(
              'Viscosity @ 100°C',
              '7.2',
              '6.0',
              '8.5',
              '7.1',
              '—',
            ),
            _MvTpl('Pour point °C', '-44', '-45', '-35', '-40', '—'),
            _MvTpl(
              'Flash point °C',
              '221',
              '200',
              '—',
              '215',
              '—',
            ),
            _MvTpl('TBN', '6.4', '5.0', '8.0', '6.5', '—'),
            _MvTpl(
              'Water content %',
              '0.02',
              '0.00',
              '0.08',
              '0.03',
              '—',
            ),
            _MvTpl(
              'Foam (seq I)',
              '10 / nil',
              '—',
              '—',
              '—',
              '—',
            ),
            _MvTpl(
              'Rust prevention',
              'Pass',
              '—',
              '—',
              'Pass',
              '—',
            ),
          ],
        ),
      _ => (
          method: kLabWorkflowSectionPhysico,
          chemist: 'A. Mehta',
          rows: const [
            _MvTpl(
              'Viscosity @ 40°C',
              '36.1',
              '34.0',
              '38.0',
              '36.5',
              '—',
            ),
            _MvTpl(
              'Viscosity @ 100°C',
              '6.9',
              '6.0',
              '8.5',
              '7.1',
              '—',
            ),
            _MvTpl('Pour point °C', '-40', '-45', '-35', '-40', '—'),
            _MvTpl(
              'Flash point °C',
              '216',
              '200',
              '—',
              '215',
              '—',
            ),
            _MvTpl('TBN', '6.0', '5.0', '8.0', '6.5', '—'),
            _MvTpl(
              'Water content %',
              '0.04',
              '0.00',
              '0.08',
              '0.03',
              '—',
            ),
            _MvTpl(
              'Foam (seq I)',
              '12 / nil',
              '—',
              '—',
              '—',
              '—',
            ),
            _MvTpl(
              'Rust prevention',
              'Pass',
              '—',
              '—',
              'Pass',
              '—',
            ),
            _MvTpl(
              'Colour ASTM',
              '3.0',
              '—',
              '—',
              '2.5',
              '—',
            ),
            _MvTpl(
              'Density @ 15°C',
              '0.865',
              '0.850',
              '0.880',
              '0.870',
              '—',
            ),
          ],
        ),
    },
    switch (profile) {
      0 => (
          method: kLabMethodD5185,
          chemist: 'S. Rao',
          rows: const [
            _MvTpl('Iron', '42', '—', '150', '45', '—'),
            _MvTpl('Copper', '18', '—', '50', '15', '—'),
            _MvTpl('Lead', '6', '—', '30', '5', '—'),
            _MvTpl('Chromium', '4', '—', '25', '3', '—'),
            _MvTpl('Tin', '11', '—', '40', '10', '—'),
            _MvTpl('Aluminum', '9', '—', '35', '8', '—'),
            _MvTpl('Nickel', '5', '—', '20', '4', '—'),
            _MvTpl('Molybdenum', '78', '—', '200', '80', '—'),
          ],
        ),
      1 => (
          method: kLabMethodD5185,
          chemist: 'S. Rao',
          rows: const [
            _MvTpl('Iron', '55', '—', '150', '45', 'Elevated wear'),
            _MvTpl('Copper', '22', '—', '50', '15', '—'),
            _MvTpl('Lead', '8', '—', '30', '5', '—'),
            _MvTpl('Chromium', '6', '—', '25', '3', '—'),
            _MvTpl('Tin', '14', '—', '40', '10', '—'),
            _MvTpl('Aluminum', '12', '—', '35', '8', '—'),
          ],
        ),
      2 || 3 || 4 => (
          method: kLabMethodD5185,
          chemist: 'S. Rao',
          rows: [
            const _MvTpl('Iron', '48', '—', '150', '45', '—'),
            const _MvTpl('Copper', '19', '—', '50', '15', '—'),
            const _MvTpl('Lead', '7', '—', '30', '5', '—'),
            const _MvTpl('Chromium', '5', '—', '25', '3', '—'),
            const _MvTpl('Tin', '12', '—', '40', '10', '—'),
            const _MvTpl('Aluminum', '10', '—', '35', '8', '—'),
            const _MvTpl('Nickel', '6', '—', '20', '4', '—'),
            const _MvTpl('Molybdenum', '82', '—', '200', '80', '—'),
            if (profile >= 3)
              const _MvTpl('Silver', '2', '—', '10', '1', '—'),
            if (profile >= 3)
              const _MvTpl('Titanium', '3', '—', '15', '2', '—'),
            if (profile >= 4) ...const [
              _MvTpl('Vanadium', '4', '—', '18', '3', '—'),
              _MvTpl('Boron', '15', '—', '60', '12', '—'),
            ],
          ],
        ),
      _ => (
          method: kLabMethodD5185,
          chemist: 'S. Rao',
          rows: const [
            _MvTpl('Iron', '48', '—', '150', '45', '—'),
            _MvTpl('Copper', '19', '—', '50', '15', '—'),
            _MvTpl('Lead', '7', '—', '30', '5', '—'),
            _MvTpl('Chromium', '5', '—', '25', '3', '—'),
            _MvTpl('Tin', '12', '—', '40', '10', '—'),
            _MvTpl('Aluminum', '10', '—', '35', '8', '—'),
            _MvTpl('Nickel', '6', '—', '20', '4', '—'),
            _MvTpl('Molybdenum', '82', '—', '200', '80', '—'),
            _MvTpl('Silver', '2', '—', '10', '1', '—'),
            _MvTpl('Titanium', '3', '—', '15', '2', '—'),
            _MvTpl('Vanadium', '4', '—', '18', '3', '—'),
            _MvTpl('Boron', '15', '—', '60', '12', '—'),
          ],
        ),
    },
    switch (profile) {
      0 => (
          method: kLabWorkflowSectionFtir,
          chemist: 'K. Iyer',
          rows: const [
            _MvTpl(
              'Particle count @ 4µm(c)',
              '6800',
              '—',
              '—',
              '6000',
              '—',
            ),
            _MvTpl(
              'Particle count @ 6µm(c)',
              '920',
              '—',
              '1200',
              '850',
              '—',
            ),
          ],
        ),
      1 => (
          method: kLabWorkflowSectionFtir,
          chemist: 'K. Iyer',
          rows: const [
            _MvTpl(
              'Particle count @ 4µm(c)',
              '7100',
              '—',
              '—',
              '6000',
              '—',
            ),
            _MvTpl(
              'Particle count @ 6µm(c)',
              '980',
              '—',
              '1200',
              '850',
              '—',
            ),
            _MvTpl(
              'Particle count @ 14µm(c)',
              '112',
              '—',
              '250',
              '120',
              '—',
            ),
          ],
        ),
      2 => (
          method: kLabWorkflowSectionFtir,
          chemist: 'K. Iyer',
          rows: const [
            _MvTpl(
              'Particle count @ 4µm(c)',
              '6950',
              '—',
              '—',
              '6000',
              '—',
            ),
            _MvTpl(
              'Particle count @ 6µm(c)',
              '905',
              '—',
              '1200',
              '850',
              '—',
            ),
            _MvTpl(
              'Particle count @ 14µm(c)',
              '118',
              '—',
              '250',
              '120',
              '—',
            ),
            _MvTpl(
              'ISO cleanliness code',
              '19/17/14',
              '—',
              '—',
              '18/16/13',
              'Borderline fine',
            ),
          ],
        ),
      3 => (
          method: kLabWorkflowSectionFtir,
          chemist: 'K. Iyer',
          rows: const [
            _MvTpl(
              'Particle count @ 4µm(c)',
              '7230',
              '—',
              '—',
              '6000',
              '—',
            ),
            _MvTpl(
              'Particle count @ 6µm(c)',
              '990',
              '—',
              '1200',
              '850',
              '—',
            ),
            _MvTpl(
              'Particle count @ 14µm(c)',
              '125',
              '—',
              '250',
              '120',
              '—',
            ),
            _MvTpl(
              'ISO cleanliness code',
              '19/17/15',
              '—',
              '—',
              '18/16/13',
              '—',
            ),
            _MvTpl(
              'NAS 1638',
              '6',
              '—',
              '8',
              '5',
              '—',
            ),
            _MvTpl(
              'Moisture (KF)',
              '120',
              '—',
              '300',
              '150',
              '—',
            ),
          ],
        ),
      _ => (
          method: kLabWorkflowSectionFtir,
          chemist: 'K. Iyer',
          rows: const [
            _MvTpl(
              'Particle count @ 4µm(c)',
              '7340',
              '—',
              '—',
              '6000',
              '—',
            ),
            _MvTpl(
              'Particle count @ 6µm(c)',
              '1010',
              '—',
              '1200',
              '850',
              '—',
            ),
            _MvTpl(
              'Particle count @ 14µm(c)',
              '131',
              '—',
              '250',
              '120',
              '—',
            ),
            _MvTpl(
              'ISO cleanliness code',
              '20/18/15',
              '—',
              '—',
              '18/16/13',
              '—',
            ),
            _MvTpl(
              'NAS 1638',
              '7',
              '—',
              '8',
              '5',
              '—',
            ),
            _MvTpl(
              'Moisture (KF)',
              '135',
              '—',
              '300',
              '150',
              '—',
            ),
            _MvTpl(
              'PQ Index',
              '18',
              '—',
              '35',
              '12',
              'Review ferrous debris',
            ),
          ],
        ),
    },
  ];
  // Popup reads Physico → FTIR → elemental (matches operational worksheet flow).
  final blocks = <_MvBlock>[raw[0], raw[2], raw[1]];

  var lineNo = 1;
  var globalIdx = 0;
  final thresh = verifiedWhenPartial[profile];
  final out = <LabWorkflowTestLine>[];

  for (final b in blocks) {
    for (final t in b.rows) {
      final verified = parentVerified || globalIdx < thresh;
      out.add(
    LabWorkflowTestLine(
          lineNo: lineNo++,
          testName: t.testName,
          value: t.value,
          minValue: t.minValue,
          maxValue: t.maxValue,
      customerMin: '—',
          customerMax: '—',
      fluidMin: '—',
          fluidMax: '—',
          typical: t.typical,
          retestRemarks: t.retestRemarks,
          chemistName: b.chemist,
          lineVerified: verified,
          sectionTitle: b.method,
        ),
      );
      globalIdx++;
    }
  }

  return out;
}

List<LabWorkflowTestLine> labWorkflowChemistVerificationDetailLines({
  required String rowId,
  required bool parentVerified,
}) {
  final pfx = rowId.hashCode.abs() % 5;
  return [
    LabWorkflowTestLine(
      lineNo: 1,
      testName: 'Viscosity @ 40°C',
      value: '${35.8 + pfx * 0.15}',
      minValue: '34.0',
      maxValue: '38.0',
      customerMin: '33.5',
      customerMax: '38.5',
      fluidMin: '34.2',
      fluidMax: '37.8',
      typical: '36.5',
      retestRemarks: '—',
      chemistName: 'A. Mehta',
      lineVerified: parentVerified || pfx == 0,
      sectionTitle: kLabWorkflowSectionPhysico,
    ),
    LabWorkflowTestLine(
      lineNo: 2,
      testName: 'TBN',
      value: '${5.8 + (pfx % 3)}',
      minValue: '5.0',
      maxValue: '8.0',
      customerMin: '4.5',
      customerMax: '8.5',
      fluidMin: '5.2',
      fluidMax: '7.6',
      typical: '6.5',
      retestRemarks: '—',
      chemistName: 'S. Rao',
      lineVerified: parentVerified,
      sectionTitle: kLabWorkflowSectionPhysico,
    ),
    LabWorkflowTestLine(
      lineNo: 3,
      testName: 'Flash point °C',
      value: '${210 + pfx}',
      minValue: '200',
      maxValue: '—',
      customerMin: '195',
      customerMax: '—',
      fluidMin: '200',
      fluidMax: '—',
      typical: '215',
      retestRemarks: '—',
      chemistName: 'K. Iyer',
      lineVerified: parentVerified && pfx != 1,
      sectionTitle: kLabWorkflowSectionFtir,
    ),
    LabWorkflowTestLine(
      lineNo: 4,
      testName: 'Particle count ISO',
      value: '${17 + pfx}',
      minValue: '—',
      maxValue: '21',
      customerMin: '—',
      customerMax: '23',
      fluidMin: '—',
      fluidMax: '22',
      typical: '18',
      retestRemarks: '—',
      chemistName: 'N. Shah',
      lineVerified: parentVerified,
      sectionTitle: kLabWorkflowSectionFtir,
    ),
    LabWorkflowTestLine(
      lineNo: 5,
      testName: 'Iron',
      value: '${42 + pfx % 5}',
      minValue: '—',
      maxValue: '150',
      customerMin: '—',
      customerMax: '—',
      fluidMin: '—',
      fluidMax: '—',
      typical: '45',
      retestRemarks: '—',
      chemistName: 'S. Rao',
      lineVerified: parentVerified,
      sectionTitle: kLabMethodD5185,
    ),
    LabWorkflowTestLine(
      lineNo: 6,
      testName: 'Copper',
      value: '${18 + pfx % 4}',
      minValue: '—',
      maxValue: '50',
      customerMin: '—',
      customerMax: '—',
      fluidMin: '—',
      fluidMax: '—',
      typical: '15',
      retestRemarks: '—',
      chemistName: 'S. Rao',
      lineVerified: parentVerified,
      sectionTitle: kLabMethodD5185,
    ),
    LabWorkflowTestLine(
      lineNo: 7,
      testName: 'Lead',
      value: '${6 + pfx % 3}',
      minValue: '—',
      maxValue: '30',
      customerMin: '—',
      customerMax: '—',
      fluidMin: '—',
      fluidMax: '—',
      typical: '5',
      retestRemarks: '—',
      chemistName: 'S. Rao',
      lineVerified: parentVerified && pfx != 2,
      sectionTitle: kLabMethodD5185,
    ),
  ];
}
