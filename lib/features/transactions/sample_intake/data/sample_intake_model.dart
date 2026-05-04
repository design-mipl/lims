/// Status values for sample intake receipts.
abstract final class SampleIntakeStatus {
  const SampleIntakeStatus._();

  static const String draft = 'draft';
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

  static const Object _sentinel = Object();

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
        'sampleDispatchedFromSite': sampleDispatchedFromSite,
        'sampleCollectedFromCollectionCenter':
            sampleCollectedFromCollectionCenter,
        'sampleReceivedAtCollectionCenter': sampleReceivedAtCollectionCenter,
        'sampleReceivedAtLab': sampleReceivedAtLab,
        'freightCharges': freightCharges,
        'dataEntryCompletedCount': dataEntryCompletedCount,
        'status': status,
      };

  static SampleIntakeModel fromJson(Map<String, dynamic> m) {
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
          m['sampleDispatchedFromSite'] as bool? ?? false,
      sampleCollectedFromCollectionCenter:
          m['sampleCollectedFromCollectionCenter'] as bool? ?? false,
      sampleReceivedAtCollectionCenter:
          m['sampleReceivedAtCollectionCenter'] as bool? ?? false,
      sampleReceivedAtLab: m['sampleReceivedAtLab'] as bool? ?? false,
      freightCharges: (m['freightCharges'] as num?)?.toDouble(),
      dataEntryCompletedCount:
          (m['dataEntryCompletedCount'] as num?)?.toInt() ?? 0,
      status: m['status'] as String? ?? SampleIntakeStatus.dataEntryPending,
    );
  }
}
