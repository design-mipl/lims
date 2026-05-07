/// Static test matrix for Lab Manager Assignment listing checkboxes.
///
/// [LabAssignmentTestColumn.key] is an ASCII slug used in [LabManagerAssignmentRow.testSelections].
/// [LabAssignmentTestColumn.label] is the table header (may include symbols such as µ, °C).
class LabAssignmentTestColumn {
  const LabAssignmentTestColumn({required this.key, required this.label});

  final String key;
  final String label;
}

/// Full column set shown for every method once rows are loaded (method only gates loading).
const List<LabAssignmentTestColumn> kLabManagerAssignmentTestColumns = [
  LabAssignmentTestColumn(key: 'zr', label: 'Zirconium (Zr)'),
  LabAssignmentTestColumn(key: 'al', label: 'Aluminium (Al)'),
  LabAssignmentTestColumn(key: 'sb', label: 'Antimony (Sb)'),
  LabAssignmentTestColumn(key: 'as_', label: 'Arsenic (As)'),
  LabAssignmentTestColumn(key: 'ba', label: 'Barium (Ba)'),
  LabAssignmentTestColumn(key: 'b', label: 'Boron (B)'),
  LabAssignmentTestColumn(key: 'ca', label: 'Calcium (Ca)'),
  LabAssignmentTestColumn(key: 'cd', label: 'Cadmium (Cd)'),
  LabAssignmentTestColumn(key: 'cr', label: 'Chromium (Cr)'),
  LabAssignmentTestColumn(key: 'cu', label: 'Copper (Cu)'),
  LabAssignmentTestColumn(key: 'fe', label: 'Iron (Fe)'),
  LabAssignmentTestColumn(key: 'pb', label: 'Lead (Pb)'),
  LabAssignmentTestColumn(key: 'mg', label: 'Magnesium (Mg)'),
  LabAssignmentTestColumn(key: 'mn', label: 'Manganese (Mn)'),
  LabAssignmentTestColumn(key: 'mo', label: 'Molybdenum (Mo)'),
  LabAssignmentTestColumn(key: 'ni', label: 'Nickel (Ni)'),
  LabAssignmentTestColumn(key: 'p', label: 'Phosphorus (P)'),
  LabAssignmentTestColumn(key: 'k', label: 'Potassium (K)'),
  LabAssignmentTestColumn(key: 'na', label: 'Sodium (Na)'),
  LabAssignmentTestColumn(key: 'si', label: 'Silicon (Si)'),
  LabAssignmentTestColumn(key: 'ag', label: 'Silver (Ag)'),
  LabAssignmentTestColumn(key: 'sn', label: 'Tin (Sn)'),
  LabAssignmentTestColumn(key: 'ti', label: 'Titanium (Ti)'),
  LabAssignmentTestColumn(key: 'v', label: 'Vanadium (V)'),
  LabAssignmentTestColumn(key: 'zn', label: 'Zinc (Zn)'),
  LabAssignmentTestColumn(key: 'tan', label: 'TAN (mg KOH/g)'),
  LabAssignmentTestColumn(key: 'tbn', label: 'TBN (mg KOH/g)'),
  LabAssignmentTestColumn(
    key: 'kin_visc_40',
    label: 'Kinematic Viscosity @ 40°C (cSt)',
  ),
  LabAssignmentTestColumn(
    key: 'kin_visc_100',
    label: 'Kinematic Viscosity @ 100°C (cSt)',
  ),
  LabAssignmentTestColumn(key: 'vi', label: 'Viscosity Index'),
  LabAssignmentTestColumn(key: 'pq', label: 'PQ Index'),
  LabAssignmentTestColumn(key: 'flash', label: 'Flash Point (°C)'),
  LabAssignmentTestColumn(key: 'water_kf', label: 'Water (ppm, Karl Fischer)'),
  LabAssignmentTestColumn(
    key: 'water_distill',
    label: 'Water (%, distillation)',
  ),
  LabAssignmentTestColumn(key: 'fuel', label: 'Fuel Dilution (%)'),
  LabAssignmentTestColumn(key: 'glycol', label: 'Glycol (%)'),
  LabAssignmentTestColumn(key: 'soot', label: 'Soot (%)'),
  LabAssignmentTestColumn(key: 'oxidation', label: 'Oxidation (abs/cm)'),
  LabAssignmentTestColumn(key: 'nitration', label: 'Nitration (abs/cm)'),
  LabAssignmentTestColumn(key: 'sulfation', label: 'Sulfation (abs/cm)'),
  LabAssignmentTestColumn(key: 'particle_iso', label: 'Particle Count ISO'),
  LabAssignmentTestColumn(key: 'cnt_4um', label: 'Particles ≥4 µm/ml'),
  LabAssignmentTestColumn(key: 'cnt_6um', label: 'Particles ≥6 µm/ml'),
  LabAssignmentTestColumn(key: 'cnt_14um', label: 'Particles ≥14 µm/ml'),
  LabAssignmentTestColumn(key: 'patch', label: 'Patch Membrane'),
  LabAssignmentTestColumn(key: 'ferro', label: 'Ferrography'),
  LabAssignmentTestColumn(key: 'demuls', label: 'Demulsibility (54°C)'),
  LabAssignmentTestColumn(key: 'rust', label: 'Rust Test (ASTM D665)'),
  LabAssignmentTestColumn(key: 'cu_strip', label: 'Copper Strip Corrosion'),
  LabAssignmentTestColumn(key: 'pour', label: 'Pour Point (°C)'),
  LabAssignmentTestColumn(key: 'hths', label: 'HTHS Viscosity (cP)'),
  LabAssignmentTestColumn(key: 'insol_hex', label: 'Insolubles (Hexane)'),
  LabAssignmentTestColumn(key: 'tbn_reserve', label: 'TBN Reserve'),
  LabAssignmentTestColumn(key: 'base_num', label: 'Strong Base Number'),
  LabAssignmentTestColumn(key: 'chlorine', label: 'Chlorine (ppm)'),
  LabAssignmentTestColumn(key: 'fft', label: 'FFT (Foam)'),
  LabAssignmentTestColumn(key: 'air_release', label: 'Air Release (min)'),
  LabAssignmentTestColumn(
    key: 'filterability',
    label: 'Filterability (ΔP)',
  ),
];
