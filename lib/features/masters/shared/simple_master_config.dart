import 'simple_master_model.dart';

class SimpleMasterConfig {
  const SimpleMasterConfig({
    required this.title,
    required this.subtitle,
    required this.entityLabel,
    required this.addFormTitle,
    required this.editFormTitle,
    required this.primaryActionLabel,
    required this.codeHint,
    required this.nameHint,
    required this.emptyMessage,
    required this.searchHint,
    required this.createdSuccessMessage,
    required this.updatedSuccessMessage,
    required this.deleteTitle,
    required this.deleteMessage,
  });

  final String title;
  final String subtitle;
  final String entityLabel;
  final String addFormTitle;
  final String editFormTitle;
  final String primaryActionLabel;
  final String codeHint;
  final String nameHint;
  final String emptyMessage;
  final String searchHint;
  final String createdSuccessMessage;
  final String updatedSuccessMessage;
  final String deleteTitle;
  final String Function(SimpleMasterModel row) deleteMessage;
}

abstract final class SimpleMasterConfigs {
  const SimpleMasterConfigs._();

  static const equipment = SimpleMasterConfig(
    title: 'Equipment Master',
    subtitle: 'Equipment types and categories',
    entityLabel: 'Equipment',
    addFormTitle: 'Add Equipment Master',
    editFormTitle: 'Edit Equipment Master',
    primaryActionLabel: '+ Add Equipment',
    codeHint: 'e.g. EXC',
    nameHint: 'Excavator',
    emptyMessage: 'No equipment records found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Equipment created',
    updatedSuccessMessage: 'Equipment updated',
    deleteTitle: 'Delete equipment',
    deleteMessage: _equipmentDeleteMessage,
  );

  static const sampleType = SimpleMasterConfig(
    title: 'Type of Sample Master',
    subtitle: 'Sample types for lab intake',
    entityLabel: 'Sample type',
    addFormTitle: 'Add Type of Sample',
    editFormTitle: 'Edit Type of Sample',
    primaryActionLabel: '+ Add Sample Type',
    codeHint: 'e.g. UOIL',
    nameHint: 'Used Oil',
    emptyMessage: 'No sample types found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Sample type created',
    updatedSuccessMessage: 'Sample type updated',
    deleteTitle: 'Delete sample type',
    deleteMessage: _sampleTypeDeleteMessage,
  );

  static const grade = SimpleMasterConfig(
    title: 'Grade Master',
    subtitle: 'Oil and lubricant grades',
    entityLabel: 'Grade',
    addFormTitle: 'Add Grade Master',
    editFormTitle: 'Edit Grade Master',
    primaryActionLabel: '+ Add Grade',
    codeHint: 'e.g. ISO68',
    nameHint: 'ISO VG 68',
    emptyMessage: 'No grades found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Grade created',
    updatedSuccessMessage: 'Grade updated',
    deleteTitle: 'Delete grade',
    deleteMessage: _gradeDeleteMessage,
  );

  static const department = SimpleMasterConfig(
    title: 'Department Master',
    subtitle: 'Lab and operational departments',
    entityLabel: 'Department',
    addFormTitle: 'Add Department Master',
    editFormTitle: 'Edit Department Master',
    primaryActionLabel: '+ Add Department',
    codeHint: 'e.g. CHEM',
    nameHint: 'Chemistry',
    emptyMessage: 'No departments found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Department created',
    updatedSuccessMessage: 'Department updated',
    deleteTitle: 'Delete department',
    deleteMessage: _departmentDeleteMessage,
  );

  static const designation = SimpleMasterConfig(
    title: 'Designation Master',
    subtitle: 'Job titles and roles',
    entityLabel: 'Designation',
    addFormTitle: 'Add Designation Master',
    editFormTitle: 'Edit Designation Master',
    primaryActionLabel: '+ Add Designation',
    codeHint: 'e.g. CHEM',
    nameHint: 'Chemist',
    emptyMessage: 'No designations found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Designation created',
    updatedSuccessMessage: 'Designation updated',
    deleteTitle: 'Delete designation',
    deleteMessage: _designationDeleteMessage,
  );

  static const test = SimpleMasterConfig(
    title: 'Test Master',
    subtitle: 'Laboratory test definitions',
    entityLabel: 'Test',
    addFormTitle: 'Add Test Master',
    editFormTitle: 'Edit Test Master',
    primaryActionLabel: '+ Add Test',
    codeHint: 'e.g. VIS',
    nameHint: 'Viscosity @ 40°C',
    emptyMessage: 'No tests found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Test created',
    updatedSuccessMessage: 'Test updated',
    deleteTitle: 'Delete test',
    deleteMessage: _testDeleteMessage,
  );

  static const method = SimpleMasterConfig(
    title: 'Method Master',
    subtitle: 'Test methods and standards',
    entityLabel: 'Method',
    addFormTitle: 'Add Method Master',
    editFormTitle: 'Edit Method Master',
    primaryActionLabel: '+ Add Method',
    codeHint: 'e.g. ASTM445',
    nameHint: 'ASTM D445',
    emptyMessage: 'No methods found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Method created',
    updatedSuccessMessage: 'Method updated',
    deleteTitle: 'Delete method',
    deleteMessage: _methodDeleteMessage,
  );

  static const instrument = SimpleMasterConfig(
    title: 'Instrument Master',
    subtitle: 'Laboratory instruments and equipment',
    entityLabel: 'Instrument',
    addFormTitle: 'Add Instrument Master',
    editFormTitle: 'Edit Instrument Master',
    primaryActionLabel: '+ Add Instrument',
    codeHint: 'e.g. ICP01',
    nameHint: 'ICP-OES',
    emptyMessage: 'No instruments found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Instrument created',
    updatedSuccessMessage: 'Instrument updated',
    deleteTitle: 'Delete instrument',
    deleteMessage: _instrumentDeleteMessage,
  );

  static const parameter = SimpleMasterConfig(
    title: 'Parameter Master',
    subtitle: 'Test parameters and analytes',
    entityLabel: 'Parameter',
    addFormTitle: 'Add Parameter Master',
    editFormTitle: 'Edit Parameter Master',
    primaryActionLabel: '+ Add Parameter',
    codeHint: 'e.g. FE',
    nameHint: 'Iron (Fe)',
    emptyMessage: 'No parameters found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Parameter created',
    updatedSuccessMessage: 'Parameter updated',
    deleteTitle: 'Delete parameter',
    deleteMessage: _parameterDeleteMessage,
  );

  static const storage = SimpleMasterConfig(
    title: 'Storage Master',
    subtitle: 'Sample storage locations and conditions',
    entityLabel: 'Storage',
    addFormTitle: 'Add Storage Master',
    editFormTitle: 'Edit Storage Master',
    primaryActionLabel: '+ Add Storage',
    codeHint: 'e.g. RACK-A1',
    nameHint: 'Rack A1 - Ambient',
    emptyMessage: 'No storage locations found',
    searchHint: 'Search by code or name…',
    createdSuccessMessage: 'Storage created',
    updatedSuccessMessage: 'Storage updated',
    deleteTitle: 'Delete storage',
    deleteMessage: _storageDeleteMessage,
  );

  static String _equipmentDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';

  static String _sampleTypeDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';

  static String _gradeDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';

  static String _departmentDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';

  static String _designationDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';

  static String _testDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';

  static String _methodDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';

  static String _instrumentDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';

  static String _parameterDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';

  static String _storageDeleteMessage(SimpleMasterModel row) =>
      'Delete "${row.code}" — ${row.name}?';
}
