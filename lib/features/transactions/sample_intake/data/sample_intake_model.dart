/// Status values for sample intake receipts (operational workflow).
abstract final class SampleIntakeStatus {
  const SampleIntakeStatus._();

  /// Quick / incomplete receipt — still on Receipt Tracking.
  static const String trackingDraft = 'trackingDraft';

  /// Legacy alias — treated like [trackingDraft] in filters/UI.
  static const String draft = 'draft';

  /// Full receipt submitted; eligible for Sample Intake queue / datasheet.
  static const String receiptComplete = 'receiptComplete';

  /// Legacy — deserialized as [receiptComplete].
  static const String dataEntryPending = 'dataEntryPending';

  static const String inProgress = 'inProgress';
  static const String completed = 'completed';
  static const String forwardedToLab = 'forwardedToLab';
}

class SampleIntakeModel {
  const SampleIntakeModel({
    required this.id,
    required this.lotNo,
    required this.receiptDate,
    required this.receiptTime,
    required this.courierName,
    required this.podNo,
    required this.noOfSamples,
    required this.customerName,
    required this.customerCompany,
    required this.customerAddress,
    required this.customerMobile,
    required this.customerEmail,
    required this.siteContactPerson,
    required this.siteCompany,
    required this.siteAddress,
    required this.siteMobile,
    required this.siteEmail,
    required this.reportExpectedBy,
    required this.workOrderNo,
    this.workOrderDate,
    this.additionalInformation,
    required this.sampleDispatchedFromSite,
    required this.sampleCollectedFromCollectionCenter,
    required this.sampleReceivedAtCollectionCenter,
    required this.sampleReceivedAtLab,
    this.freightCharges,
    required this.dataEntryCompletedCount,
    required this.status,
    this.receiptMode = '',
    this.receivedBy = '',
    this.quickRemarks = '',
    this.equipmentMake = '',
    this.equipmentModel = '',
    this.operatingConditions = '',
    this.receiptRunningHours,
    this.receiptTopUpVolume,
    this.previousLabReference = '',
    this.intakeCompletedAt,
    this.generatedBy = '',
    this.internalNotes = '',
    this.typeOfSample = '',
    this.primarySampleId = '',
    this.sampleDispatchedFromSiteAt,
    this.sampleCollectedFromCollectionCenterAt,
    this.sampleReceivedAtCollectionCenterAt,
    this.sampleReceivedAtLabAt,
  });

  final String id;
  final String lotNo;
  final DateTime receiptDate;
  final String receiptTime;
  final String courierName;
  final String podNo;
  final int noOfSamples;
  final String customerName;
  final String customerCompany;
  final String customerAddress;
  final String customerMobile;
  final String customerEmail;
  final String siteContactPerson;
  final String siteCompany;
  final String siteAddress;
  final String siteMobile;
  final String siteEmail;
  final DateTime? reportExpectedBy;
  final String workOrderNo;
  final DateTime? workOrderDate;
  final String? additionalInformation;
  final bool sampleDispatchedFromSite;
  final bool sampleCollectedFromCollectionCenter;
  final bool sampleReceivedAtCollectionCenter;
  final bool sampleReceivedAtLab;
  final double? freightCharges;
  final int dataEntryCompletedCount;
  final String status;

  /// Courier | Hand delivery (display / operational).
  final String receiptMode;
  final String receivedBy;
  final String quickRemarks;
  final String equipmentMake;
  final String equipmentModel;
  final String operatingConditions;
  final double? receiptRunningHours;
  final double? receiptTopUpVolume;
  final String previousLabReference;
  final DateTime? intakeCompletedAt;
  final String generatedBy;
  final String internalNotes;

  /// Receipt-level sample type (Complete Sample Receipt section).
  final String typeOfSample;

  /// First sample USN on receipt (set when grid rows exist).
  final String primarySampleId;

  /// Optional milestone dates (create form / API); legacy rows may have only bools.
  final DateTime? sampleDispatchedFromSiteAt;
  final DateTime? sampleCollectedFromCollectionCenterAt;
  final DateTime? sampleReceivedAtCollectionCenterAt;
  final DateTime? sampleReceivedAtLabAt;

  static const Object _sentinel = Object();

  static DateTime? _parseTrackingAt(Map<String, dynamic> m, String key) {
    final raw = m[key];
    if (raw == null) return null;
    return DateTime.tryParse(raw as String);
  }

  /// Receipt tracking phase still active (before full receipt submitted).
  bool get isReceiptTrackingPending =>
      status == SampleIntakeStatus.trackingDraft ||
      status == SampleIntakeStatus.draft;

  SampleIntakeModel copyWith({
    String? id,
    String? lotNo,
    DateTime? receiptDate,
    String? receiptTime,
    String? courierName,
    String? podNo,
    int? noOfSamples,
    String? customerName,
    String? customerCompany,
    String? customerAddress,
    String? customerMobile,
    String? customerEmail,
    String? siteContactPerson,
    String? siteCompany,
    String? siteAddress,
    String? siteMobile,
    String? siteEmail,
    Object? reportExpectedBy = _sentinel,
    String? workOrderNo,
    Object? workOrderDate = _sentinel,
    Object? additionalInformation = _sentinel,
    bool? sampleDispatchedFromSite,
    bool? sampleCollectedFromCollectionCenter,
    bool? sampleReceivedAtCollectionCenter,
    bool? sampleReceivedAtLab,
    Object? freightCharges = _sentinel,
    int? dataEntryCompletedCount,
    String? status,
    String? receiptMode,
    String? receivedBy,
    String? quickRemarks,
    String? equipmentMake,
    String? equipmentModel,
    String? operatingConditions,
    Object? receiptRunningHours = _sentinel,
    Object? receiptTopUpVolume = _sentinel,
    String? previousLabReference,
    Object? intakeCompletedAt = _sentinel,
    String? generatedBy,
    String? internalNotes,
    String? typeOfSample,
    String? primarySampleId,
    Object? sampleDispatchedFromSiteAt = _sentinel,
    Object? sampleCollectedFromCollectionCenterAt = _sentinel,
    Object? sampleReceivedAtCollectionCenterAt = _sentinel,
    Object? sampleReceivedAtLabAt = _sentinel,
  }) {
    return SampleIntakeModel(
      id: id ?? this.id,
      lotNo: lotNo ?? this.lotNo,
      receiptDate: receiptDate ?? this.receiptDate,
      receiptTime: receiptTime ?? this.receiptTime,
      courierName: courierName ?? this.courierName,
      podNo: podNo ?? this.podNo,
      noOfSamples: noOfSamples ?? this.noOfSamples,
      customerName: customerName ?? this.customerName,
      customerCompany: customerCompany ?? this.customerCompany,
      customerAddress: customerAddress ?? this.customerAddress,
      customerMobile: customerMobile ?? this.customerMobile,
      customerEmail: customerEmail ?? this.customerEmail,
      siteContactPerson: siteContactPerson ?? this.siteContactPerson,
      siteCompany: siteCompany ?? this.siteCompany,
      siteAddress: siteAddress ?? this.siteAddress,
      siteMobile: siteMobile ?? this.siteMobile,
      siteEmail: siteEmail ?? this.siteEmail,
      reportExpectedBy: reportExpectedBy == _sentinel
          ? this.reportExpectedBy
          : reportExpectedBy as DateTime?,
      workOrderNo: workOrderNo ?? this.workOrderNo,
      workOrderDate: workOrderDate == _sentinel
          ? this.workOrderDate
          : workOrderDate as DateTime?,
      additionalInformation: additionalInformation == _sentinel
          ? this.additionalInformation
          : additionalInformation as String?,
      sampleDispatchedFromSite:
          sampleDispatchedFromSite ?? this.sampleDispatchedFromSite,
      sampleCollectedFromCollectionCenter:
          sampleCollectedFromCollectionCenter ??
              this.sampleCollectedFromCollectionCenter,
      sampleReceivedAtCollectionCenter: sampleReceivedAtCollectionCenter ??
          this.sampleReceivedAtCollectionCenter,
      sampleReceivedAtLab:
          sampleReceivedAtLab ?? this.sampleReceivedAtLab,
      freightCharges: freightCharges == _sentinel
          ? this.freightCharges
          : freightCharges as double?,
      dataEntryCompletedCount:
          dataEntryCompletedCount ?? this.dataEntryCompletedCount,
      status: status ?? this.status,
      receiptMode: receiptMode ?? this.receiptMode,
      receivedBy: receivedBy ?? this.receivedBy,
      quickRemarks: quickRemarks ?? this.quickRemarks,
      equipmentMake: equipmentMake ?? this.equipmentMake,
      equipmentModel: equipmentModel ?? this.equipmentModel,
      operatingConditions: operatingConditions ?? this.operatingConditions,
      receiptRunningHours: receiptRunningHours == _sentinel
          ? this.receiptRunningHours
          : receiptRunningHours as double?,
      receiptTopUpVolume: receiptTopUpVolume == _sentinel
          ? this.receiptTopUpVolume
          : receiptTopUpVolume as double?,
      previousLabReference:
          previousLabReference ?? this.previousLabReference,
      intakeCompletedAt: intakeCompletedAt == _sentinel
          ? this.intakeCompletedAt
          : intakeCompletedAt as DateTime?,
      generatedBy: generatedBy ?? this.generatedBy,
      internalNotes: internalNotes ?? this.internalNotes,
      typeOfSample: typeOfSample ?? this.typeOfSample,
      primarySampleId: primarySampleId ?? this.primarySampleId,
      sampleDispatchedFromSiteAt: sampleDispatchedFromSiteAt == _sentinel
          ? this.sampleDispatchedFromSiteAt
          : sampleDispatchedFromSiteAt as DateTime?,
      sampleCollectedFromCollectionCenterAt:
          sampleCollectedFromCollectionCenterAt == _sentinel
              ? this.sampleCollectedFromCollectionCenterAt
              : sampleCollectedFromCollectionCenterAt as DateTime?,
      sampleReceivedAtCollectionCenterAt:
          sampleReceivedAtCollectionCenterAt == _sentinel
              ? this.sampleReceivedAtCollectionCenterAt
              : sampleReceivedAtCollectionCenterAt as DateTime?,
      sampleReceivedAtLabAt: sampleReceivedAtLabAt == _sentinel
          ? this.sampleReceivedAtLabAt
          : sampleReceivedAtLabAt as DateTime?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lotNo': lotNo,
        'receiptDate': receiptDate.toIso8601String(),
        'receiptTime': receiptTime,
        'courierName': courierName,
        'podNo': podNo,
        'noOfSamples': noOfSamples,
        'customerName': customerName,
        'customerCompany': customerCompany,
        'customerAddress': customerAddress,
        'customerMobile': customerMobile,
        'customerEmail': customerEmail,
        'siteContactPerson': siteContactPerson,
        'siteCompany': siteCompany,
        'siteAddress': siteAddress,
        'siteMobile': siteMobile,
        'siteEmail': siteEmail,
        'reportExpectedBy': reportExpectedBy?.toIso8601String(),
        'workOrderNo': workOrderNo,
        'workOrderDate': workOrderDate?.toIso8601String(),
        'additionalInformation': additionalInformation,
        'sampleDispatchedFromSite': sampleDispatchedFromSite ||
            sampleDispatchedFromSiteAt != null,
        'sampleCollectedFromCollectionCenter':
            sampleCollectedFromCollectionCenter ||
                sampleCollectedFromCollectionCenterAt != null,
        'sampleReceivedAtCollectionCenter':
            sampleReceivedAtCollectionCenter ||
                sampleReceivedAtCollectionCenterAt != null,
        'sampleReceivedAtLab':
            sampleReceivedAtLab || sampleReceivedAtLabAt != null,
        'freightCharges': freightCharges,
        'dataEntryCompletedCount': dataEntryCompletedCount,
        'status': status,
        'receiptMode': receiptMode,
        'receivedBy': receivedBy,
        'quickRemarks': quickRemarks,
        'equipmentMake': equipmentMake,
        'equipmentModel': equipmentModel,
        'operatingConditions': operatingConditions,
        'receiptRunningHours': receiptRunningHours,
        'receiptTopUpVolume': receiptTopUpVolume,
        'previousLabReference': previousLabReference,
        'intakeCompletedAt': intakeCompletedAt?.toIso8601String(),
        'generatedBy': generatedBy,
        'internalNotes': internalNotes,
        'typeOfSample': typeOfSample,
        'primarySampleId': primarySampleId,
        if (sampleDispatchedFromSiteAt != null)
          'sampleDispatchedFromSiteAt':
              sampleDispatchedFromSiteAt!.toIso8601String(),
        if (sampleCollectedFromCollectionCenterAt != null)
          'sampleCollectedFromCollectionCenterAt':
              sampleCollectedFromCollectionCenterAt!.toIso8601String(),
        if (sampleReceivedAtCollectionCenterAt != null)
          'sampleReceivedAtCollectionCenterAt':
              sampleReceivedAtCollectionCenterAt!.toIso8601String(),
        if (sampleReceivedAtLabAt != null)
          'sampleReceivedAtLabAt': sampleReceivedAtLabAt!.toIso8601String(),
      };

  static String _normalizeStatus(String? raw) {
    final s = raw ?? SampleIntakeStatus.receiptComplete;
    if (s == SampleIntakeStatus.dataEntryPending) {
      return SampleIntakeStatus.receiptComplete;
    }
    return s;
  }

  static SampleIntakeModel fromJson(Map<String, dynamic> m) {
    final atDisp = _parseTrackingAt(m, 'sampleDispatchedFromSiteAt');
    final atCol = _parseTrackingAt(m, 'sampleCollectedFromCollectionCenterAt');
    final atCc = _parseTrackingAt(m, 'sampleReceivedAtCollectionCenterAt');
    final atLab = _parseTrackingAt(m, 'sampleReceivedAtLabAt');
    return SampleIntakeModel(
      id: m['id'] as String? ?? '',
      lotNo: m['lotNo'] as String? ?? '',
      receiptDate: DateTime.tryParse(m['receiptDate'] as String? ?? '') ??
          DateTime.now(),
      receiptTime: m['receiptTime'] as String? ?? '',
      courierName: m['courierName'] as String? ?? '',
      podNo: m['podNo'] as String? ?? '',
      noOfSamples: (m['noOfSamples'] as num?)?.toInt() ?? 0,
      customerName: m['customerName'] as String? ?? '',
      customerCompany: m['customerCompany'] as String? ?? '',
      customerAddress: m['customerAddress'] as String? ?? '',
      customerMobile: m['customerMobile'] as String? ?? '',
      customerEmail: m['customerEmail'] as String? ?? '',
      siteContactPerson: m['siteContactPerson'] as String? ?? '',
      siteCompany: m['siteCompany'] as String? ?? '',
      siteAddress: m['siteAddress'] as String? ?? '',
      siteMobile: m['siteMobile'] as String? ?? '',
      siteEmail: m['siteEmail'] as String? ?? '',
      reportExpectedBy: m['reportExpectedBy'] != null
          ? DateTime.tryParse(m['reportExpectedBy'] as String)
          : null,
      workOrderNo: m['workOrderNo'] as String? ?? '',
      workOrderDate: m['workOrderDate'] != null
          ? DateTime.tryParse(m['workOrderDate'] as String)
          : null,
      additionalInformation: m['additionalInformation'] as String?,
      sampleDispatchedFromSite:
          (m['sampleDispatchedFromSite'] as bool? ?? false) || atDisp != null,
      sampleCollectedFromCollectionCenter:
          (m['sampleCollectedFromCollectionCenter'] as bool? ?? false) ||
              atCol != null,
      sampleReceivedAtCollectionCenter:
          (m['sampleReceivedAtCollectionCenter'] as bool? ?? false) ||
              atCc != null,
      sampleReceivedAtLab:
          (m['sampleReceivedAtLab'] as bool? ?? false) || atLab != null,
      freightCharges: (m['freightCharges'] as num?)?.toDouble(),
      dataEntryCompletedCount:
          (m['dataEntryCompletedCount'] as num?)?.toInt() ?? 0,
      status: _normalizeStatus(m['status'] as String?),
      receiptMode: m['receiptMode'] as String? ?? '',
      receivedBy: m['receivedBy'] as String? ?? '',
      quickRemarks: m['quickRemarks'] as String? ?? '',
      equipmentMake: m['equipmentMake'] as String? ?? '',
      equipmentModel: m['equipmentModel'] as String? ?? '',
      operatingConditions: m['operatingConditions'] as String? ?? '',
      receiptRunningHours: (m['receiptRunningHours'] as num?)?.toDouble(),
      receiptTopUpVolume: (m['receiptTopUpVolume'] as num?)?.toDouble(),
      previousLabReference: m['previousLabReference'] as String? ?? '',
      intakeCompletedAt: m['intakeCompletedAt'] != null
          ? DateTime.tryParse(m['intakeCompletedAt'] as String)
          : null,
      generatedBy: m['generatedBy'] as String? ?? '',
      internalNotes: m['internalNotes'] as String? ?? '',
      typeOfSample: m['typeOfSample'] as String? ?? '',
      primarySampleId: m['primarySampleId'] as String? ?? '',
      sampleDispatchedFromSiteAt: atDisp,
      sampleCollectedFromCollectionCenterAt: atCol,
      sampleReceivedAtCollectionCenterAt: atCc,
      sampleReceivedAtLabAt: atLab,
    );
  }
}
