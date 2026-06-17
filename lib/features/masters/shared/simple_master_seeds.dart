import 'simple_master_model.dart';

abstract final class SimpleMasterSeeds {
  const SimpleMasterSeeds._();

  static const equipment = [
    SimpleMasterSeed(code: 'EXC', name: 'Excavator'),
    SimpleMasterSeed(code: 'DMP', name: 'Dumper'),
    SimpleMasterSeed(code: 'GRD', name: 'Grader'),
  ];

  static const sampleType = [
    SimpleMasterSeed(code: 'UOIL', name: 'Used Oil'),
    SimpleMasterSeed(code: 'GRS', name: 'Grease'),
    SimpleMasterSeed(code: 'CLNT', name: 'Coolant'),
    SimpleMasterSeed(code: 'HYD', name: 'Hydraulic'),
    SimpleMasterSeed(code: 'FLTR', name: 'Filter Flush'),
  ];

  static const grade = [
    SimpleMasterSeed(code: 'ISO68', name: 'ISO VG 68'),
    SimpleMasterSeed(code: 'ISO46', name: 'ISO VG 46'),
    SimpleMasterSeed(code: 'ISO32', name: 'ISO VG 32'),
    SimpleMasterSeed(code: 'EP2', name: 'EP2 Grease'),
    SimpleMasterSeed(code: 'TBN10', name: 'TBN 10 Marine'),
  ];

  static const department = [
    SimpleMasterSeed(code: 'CHEM', name: 'Chemistry'),
    SimpleMasterSeed(code: 'MICRO', name: 'Microbiology'),
    SimpleMasterSeed(code: 'SAMPLE', name: 'Sample Intake'),
    SimpleMasterSeed(code: 'QA', name: 'Quality Assurance'),
  ];

  static const designation = [
    SimpleMasterSeed(code: 'CHEM', name: 'Chemist'),
    SimpleMasterSeed(code: 'TECH', name: 'Lab Technician'),
    SimpleMasterSeed(code: 'MGR', name: 'Lab Manager'),
    SimpleMasterSeed(code: 'QA', name: 'QA Officer'),
  ];

  static const test = [
    SimpleMasterSeed(code: 'VIS', name: 'Viscosity @ 40°C'),
    SimpleMasterSeed(code: 'WTR', name: 'Water Content'),
    SimpleMasterSeed(code: 'TAN', name: 'Total Acid Number'),
    SimpleMasterSeed(code: 'ICP', name: 'Wear Metals (ICP)'),
  ];

  static const method = [
    SimpleMasterSeed(code: 'ASTM445', name: 'ASTM D445'),
    SimpleMasterSeed(code: 'ASTM6304', name: 'ASTM D6304'),
    SimpleMasterSeed(code: 'ASTM664', name: 'ASTM D664'),
    SimpleMasterSeed(code: 'ASTM5185', name: 'ASTM D5185'),
  ];

  static const instrument = [
    SimpleMasterSeed(code: 'ICP01', name: 'ICP-OES'),
    SimpleMasterSeed(code: 'FTIR01', name: 'FTIR Spectrometer'),
    SimpleMasterSeed(code: 'VIS01', name: 'Kinematic Viscometer'),
    SimpleMasterSeed(code: 'TAN01', name: 'TAN/TBN Titrator'),
  ];

  static const parameter = [
    SimpleMasterSeed(code: 'FE', name: 'Iron (Fe)'),
    SimpleMasterSeed(code: 'CU', name: 'Copper (Cu)'),
    SimpleMasterSeed(code: 'SI', name: 'Silicon (Si)'),
    SimpleMasterSeed(code: 'H2O', name: 'Water Content'),
  ];

  static const storage = [
    SimpleMasterSeed(code: 'RACK-A1', name: 'Rack A1 - Ambient'),
    SimpleMasterSeed(code: 'RACK-B2', name: 'Rack B2 - Retain Samples'),
    SimpleMasterSeed(code: 'COLD-01', name: 'Cold Storage 01'),
    SimpleMasterSeed(code: 'HAZ-01', name: 'Hazard Cabinet 01'),
  ];
}
