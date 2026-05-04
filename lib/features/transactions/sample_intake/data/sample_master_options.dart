import '../../../../design_system/components/components.dart';

/// Mock master data for sample data entry dropdowns (replace with API later).
abstract final class SampleMasterOptions {
  const SampleMasterOptions._();

  /// Make → dependent models (normalized keys: display value as both value/label).
  static const Map<String, List<String>> makeToModels = {
    'LIEBHERR': ['L566-1797', 'L586', 'R9400'],
    'CAT': ['320D', '336D', '777D'],
    'KOMATSU': ['PC200-8', 'D65EX', 'HD785'],
  };

  static List<String> modelsForMake(String? make) {
    if (make == null || make.isEmpty) return const [];
    return makeToModels[make] ?? const [];
  }

  static List<AppSelectItem<String>> get makes => [
        item('LIEBHERR'),
        item('CAT'),
        item('KOMATSU'),
        item('HITACHI'),
        item('VOLVO CE'),
      ];

  static List<AppSelectItem<String>> modelsForMakeItems(String? make) =>
      modelsForMake(make).map(item).toList();

  static List<AppSelectItem<String>> get typeOfSample => [
        const AppSelectItem(value: 'usedOil', label: 'Used Oil'),
        const AppSelectItem(value: 'grease', label: 'Grease'),
        const AppSelectItem(value: 'coolant', label: 'Coolant'),
        const AppSelectItem(value: 'hydraulic', label: 'Hydraulic'),
        const AppSelectItem(value: 'filter', label: 'Filter Flush'),
      ];

  static List<AppSelectItem<String>> get natureOfSample => [
        const AppSelectItem(value: 'routine', label: 'Routine'),
        const AppSelectItem(value: 'investigation', label: 'Investigation'),
        const AppSelectItem(value: 'breakdown', label: 'Breakdown'),
        const AppSelectItem(value: 'warranty', label: 'Warranty'),
      ];

  static List<AppSelectItem<String>> get typeOfBottle => [
        const AppSelectItem(value: 'amberPet', label: 'Amber PET'),
        const AppSelectItem(value: 'steelCan', label: 'Steel Can'),
        const AppSelectItem(value: 'hdpe', label: 'HDPE Bottle'),
        const AppSelectItem(value: 'glass', label: 'Glass Vial'),
      ];

  static List<AppSelectItem<String>> get grade => [
        const AppSelectItem(value: 'iso68', label: 'ISO VG 68'),
        const AppSelectItem(value: 'iso46', label: 'ISO VG 46'),
        const AppSelectItem(value: 'iso32', label: 'ISO VG 32'),
        const AppSelectItem(value: 'ep2', label: 'EP2 Grease'),
        const AppSelectItem(value: 'tbn10', label: 'TBN 10 Marine'),
      ];

  static List<AppSelectItem<String>> get brandOfOil => [
        const AppSelectItem(value: 'shell', label: 'Shell'),
        const AppSelectItem(value: 'mobil', label: 'Mobil'),
        const AppSelectItem(value: 'castrol', label: 'Castrol'),
        const AppSelectItem(value: 'hp', label: 'HP Lubricants'),
        const AppSelectItem(value: 'gulf', label: 'Gulf'),
      ];

  static List<AppSelectItem<String>> get subAssembly => [
        const AppSelectItem(value: 'eng', label: 'Engine'),
        const AppSelectItem(value: 'trans', label: 'Transmission'),
        const AppSelectItem(value: 'hyd', label: 'Hydraulic'),
        const AppSelectItem(value: 'final', label: 'Final Drive'),
        const AppSelectItem(value: 'swing', label: 'Swing Motor'),
      ];

  static List<AppSelectItem<String>> get problem => [
        const AppSelectItem(value: 'wearMetals', label: 'High wear metals'),
        const AppSelectItem(value: 'viscDrop', label: 'Viscosity drop'),
        const AppSelectItem(value: 'water', label: 'Water contamination'),
        const AppSelectItem(value: 'fuelDil', label: 'Fuel dilution'),
        const AppSelectItem(value: 'tbnLow', label: 'Low TBN'),
      ];

  static List<AppSelectItem<String>> get comments => [
        const AppSelectItem(value: 'resample', label: 'Resample recommended'),
        const AppSelectItem(value: 'changeOil', label: 'Change oil'),
        const AppSelectItem(value: 'offline', label: 'Take offline for repair'),
        const AppSelectItem(value: 'monitor', label: 'Continue monitoring'),
        const AppSelectItem(value: 'na', label: 'None'),
      ];

  static List<AppSelectItem<String>> get samplingFrom => [
        const AppSelectItem(value: 'dipstick', label: 'Dipstick'),
        const AppSelectItem(value: 'drainPort', label: 'Drain Port'),
        const AppSelectItem(value: 'inlineSampler', label: 'Inline Sampler'),
        const AppSelectItem(value: 'sumpTap', label: 'Sump Tap'),
      ];

  static List<AppSelectItem<String>> get severity => [
        const AppSelectItem(value: 'na', label: 'NA'),
        const AppSelectItem(value: 'normal', label: 'Normal'),
        const AppSelectItem(value: 'caution', label: 'Caution'),
        const AppSelectItem(value: 'critical', label: 'Critical'),
      ];

  static List<AppSelectItem<String>> get oilDrained => [
        const AppSelectItem(value: 'yes', label: 'Yes'),
        const AppSelectItem(value: 'no', label: 'No'),
      ];

  static List<AppSelectItem<String>> get invoiceStatus => [
        const AppSelectItem(value: 'not_required', label: 'Not Required'),
        const AppSelectItem(value: 'pending', label: 'Pending'),
        const AppSelectItem(value: 'generated', label: 'Generated'),
      ];

  static AppSelectItem<String> item(String value) =>
      AppSelectItem<String>(value: value, label: value);
}
