/// Order lifecycle after quotation sales review.
abstract final class OrderStatus {
  static const String draft = 'draft';
  static const String emailSent = 'emailSent';
  static const String underDiscussion = 'underDiscussion';
  static const String discountRevised = 'discountRevised';
  static const String convertedOrder = 'convertedOrder';
  static const String confirmed = 'confirmed';
  static const String rejected = 'rejected';
}

class OrderVersionEntry {
  const OrderVersionEntry({
    required this.versionNo,
    required this.revisedAt,
    required this.updatedBy,
    required this.originalAmount,
    required this.discountPercent,
    required this.revisedAmount,
    required this.status,
    this.remarks = '',
    this.readOnly = true,
  });

  final int versionNo;
  final DateTime revisedAt;
  final String updatedBy;
  final double originalAmount;
  final double discountPercent;
  final double revisedAmount;
  final String status;
  final String remarks;
  final bool readOnly;
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.orderNo,
    required this.quotationId,
    required this.quoteNo,
    required this.enquiryNo,
    required this.customerName,
    required this.siteName,
    required this.sampleType,
    required this.status,
    required this.versionNo,
    required this.originalAmount,
    required this.discountPercent,
    required this.revisedAmount,
    required this.updatedAt,
    required this.updatedBy,
    this.salesPerson = '',
    this.emailSent = false,
    this.convertedOrderRef,
    this.convertedAt,
    this.customerApproval = 'Pending',
    this.versions = const [],
  });

  final String id;
  final String orderNo;
  final String quotationId;
  final String quoteNo;
  final String enquiryNo;
  final String customerName;
  final String siteName;
  final String sampleType;
  final String status;
  final int versionNo;
  final double originalAmount;
  final double discountPercent;
  final double revisedAmount;
  final DateTime updatedAt;
  final String updatedBy;
  final String salesPerson;
  final bool emailSent;
  final String? convertedOrderRef;
  final DateTime? convertedAt;
  final String customerApproval;
  final List<OrderVersionEntry> versions;

  OrderRecord copyWith({
    String? id,
    String? orderNo,
    String? quotationId,
    String? quoteNo,
    String? enquiryNo,
    String? customerName,
    String? siteName,
    String? sampleType,
    String? status,
    int? versionNo,
    double? originalAmount,
    double? discountPercent,
    double? revisedAmount,
    DateTime? updatedAt,
    String? updatedBy,
    String? salesPerson,
    bool? emailSent,
    Object? convertedOrderRef = _sentinel,
    Object? convertedAt = _sentinel,
    String? customerApproval,
    List<OrderVersionEntry>? versions,
  }) {
    return OrderRecord(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      quotationId: quotationId ?? this.quotationId,
      quoteNo: quoteNo ?? this.quoteNo,
      enquiryNo: enquiryNo ?? this.enquiryNo,
      customerName: customerName ?? this.customerName,
      siteName: siteName ?? this.siteName,
      sampleType: sampleType ?? this.sampleType,
      status: status ?? this.status,
      versionNo: versionNo ?? this.versionNo,
      originalAmount: originalAmount ?? this.originalAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      revisedAmount: revisedAmount ?? this.revisedAmount,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      salesPerson: salesPerson ?? this.salesPerson,
      emailSent: emailSent ?? this.emailSent,
      convertedOrderRef: convertedOrderRef == _sentinel
          ? this.convertedOrderRef
          : convertedOrderRef as String?,
      convertedAt: convertedAt == _sentinel
          ? this.convertedAt
          : convertedAt as DateTime?,
      customerApproval: customerApproval ?? this.customerApproval,
      versions: versions ?? this.versions,
    );
  }

  static const Object _sentinel = Object();
}
