import '../../shared/activity_timeline_models.dart';

abstract final class EnquiryStatus {
  static const String pending = 'pending';
  static const String submitted = 'submitted';
  static const String converted = 'converted';
}

class EnquiryRequestedTestRow {
  const EnquiryRequestedTestRow({
    required this.id,
    required this.testCode,
    required this.testName,
    this.selected = false,
    this.priority = 'Normal',
    this.remarks = '',
  });

  final String id;
  final String testCode;
  final String testName;
  final bool selected;
  final String priority;
  final String remarks;

  EnquiryRequestedTestRow copyWith({
    String? id,
    String? testCode,
    String? testName,
    bool? selected,
    String? priority,
    String? remarks,
  }) {
    return EnquiryRequestedTestRow(
      id: id ?? this.id,
      testCode: testCode ?? this.testCode,
      testName: testName ?? this.testName,
      selected: selected ?? this.selected,
      priority: priority ?? this.priority,
      remarks: remarks ?? this.remarks,
    );
  }
}

class EnquiryRecord {
  const EnquiryRecord({
    required this.id,
    required this.enquiryNo,
    required this.enquiryDate,
    required this.customerName,
    required this.siteName,
    required this.enquirySource,
    required this.typeOfSample,
    required this.sampleCount,
    required this.status,
    required this.createdBy,
    this.customerCompany = '',
    this.siteContactPerson = '',
    this.siteCompany = '',
    this.contactPerson = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.equipmentMakeModel = '',
    this.operatingConditions = '',
    this.urgency = 'Normal',
    this.expectedTimeline = '',
    this.samplePriority = 'Normal',
    this.internalNotes = '',
    this.attachmentNames = const [],
    this.requestedTests = const [],
    this.activity = const [],
    this.quotationId,
  });

  final String id;
  final String enquiryNo;
  final DateTime enquiryDate;
  final String customerName;
  final String siteName;
  final String enquirySource;
  final String typeOfSample;
  final int sampleCount;
  final String status;
  final String createdBy;

  final String customerCompany;
  final String siteContactPerson;
  final String siteCompany;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String equipmentMakeModel;
  final String operatingConditions;
  final String urgency;
  final String expectedTimeline;
  /// Operational priority for sample handling (distinct from [urgency]).
  final String samplePriority;
  final String internalNotes;
  final List<String> attachmentNames;
  final List<EnquiryRequestedTestRow> requestedTests;
  final List<ActivityTimelineEntry> activity;
  final String? quotationId;

  static const Object _sentinel = Object();

  String get requestedTestsSummary {
    final sel =
        requestedTests.where((t) => t.selected).map((t) => t.testCode).toList();
    if (sel.isEmpty) {
      return requestedTests.map((t) => t.testCode).take(3).join(', ');
    }
    return sel.take(5).join(', ');
  }

  EnquiryRecord copyWith({
    String? id,
    String? enquiryNo,
    DateTime? enquiryDate,
    String? customerName,
    String? siteName,
    String? enquirySource,
    String? typeOfSample,
    int? sampleCount,
    String? status,
    String? createdBy,
    String? customerCompany,
    String? siteContactPerson,
    String? siteCompany,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    String? equipmentMakeModel,
    String? operatingConditions,
    String? urgency,
    String? expectedTimeline,
    String? samplePriority,
    String? internalNotes,
    List<String>? attachmentNames,
    List<EnquiryRequestedTestRow>? requestedTests,
    List<ActivityTimelineEntry>? activity,
    Object? quotationId = _sentinel,
  }) {
    return EnquiryRecord(
      id: id ?? this.id,
      enquiryNo: enquiryNo ?? this.enquiryNo,
      enquiryDate: enquiryDate ?? this.enquiryDate,
      customerName: customerName ?? this.customerName,
      siteName: siteName ?? this.siteName,
      enquirySource: enquirySource ?? this.enquirySource,
      typeOfSample: typeOfSample ?? this.typeOfSample,
      sampleCount: sampleCount ?? this.sampleCount,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      customerCompany: customerCompany ?? this.customerCompany,
      siteContactPerson: siteContactPerson ?? this.siteContactPerson,
      siteCompany: siteCompany ?? this.siteCompany,
      contactPerson: contactPerson ?? this.contactPerson,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      equipmentMakeModel: equipmentMakeModel ?? this.equipmentMakeModel,
      operatingConditions: operatingConditions ?? this.operatingConditions,
      urgency: urgency ?? this.urgency,
      expectedTimeline: expectedTimeline ?? this.expectedTimeline,
      samplePriority: samplePriority ?? this.samplePriority,
      internalNotes: internalNotes ?? this.internalNotes,
      attachmentNames: attachmentNames ?? this.attachmentNames,
      requestedTests: requestedTests ?? this.requestedTests,
      activity: activity ?? this.activity,
      quotationId: quotationId == _sentinel
          ? this.quotationId
          : quotationId as String?,
    );
  }
}
