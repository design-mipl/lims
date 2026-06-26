/// Operational order form — confirmation record sourced from quotation.
abstract final class OrderFormStatus {
  static const String draft = 'draft';
  static const String confirmed = 'confirmed';
}

class OrderSampleLine {
  const OrderSampleLine({
    required this.id,
    required this.typeOfSample,
    required this.sampleCount,
    required this.testName,
    required this.priority,
    required this.expectedTimeline,
    required this.rate,
  });

  final String id;
  final String typeOfSample;
  final int sampleCount;
  final String testName;
  final String priority;
  final String expectedTimeline;
  final double rate;

  double get amount => sampleCount * rate;
}

class OrderFormRecord {
  const OrderFormRecord({
    required this.id,
    required this.orderNo,
    required this.orderDate,
    required this.quotationId,
    required this.quoteNo,
    required this.enquiryNo,
    required this.status,
    required this.customerName,
    required this.siteName,
    required this.contactPerson,
    required this.mobile,
    required this.email,
    required this.sampleLines,
    required this.total,
    required this.discount,
    required this.gstAmount,
    required this.freight,
    required this.grandTotal,
    this.customerPoNo = '',
    this.customerPoDate,
    this.supplierRef = '',
    this.dispatchMode = '',
    this.remarks = '',
    this.customerPoFileName,
    this.supportingFileNames = const [],
  });

  final String id;
  final String orderNo;
  final DateTime orderDate;
  final String quotationId;
  final String quoteNo;
  final String enquiryNo;
  final String status;

  final String customerPoNo;
  final DateTime? customerPoDate;

  final String customerName;
  final String siteName;
  final String contactPerson;
  final String mobile;
  final String email;

  final List<OrderSampleLine> sampleLines;

  final double total;
  final double discount;
  final double gstAmount;
  final double freight;
  final double grandTotal;

  final String supplierRef;
  final String dispatchMode;
  final String remarks;

  final String? customerPoFileName;
  final List<String> supportingFileNames;

  OrderFormRecord copyWith({
    String? id,
    String? orderNo,
    DateTime? orderDate,
    String? quotationId,
    String? quoteNo,
    String? enquiryNo,
    String? status,
    String? customerPoNo,
    Object? customerPoDate = _sentinel,
    String? customerName,
    String? siteName,
    String? contactPerson,
    String? mobile,
    String? email,
    List<OrderSampleLine>? sampleLines,
    double? total,
    double? discount,
    double? gstAmount,
    double? freight,
    double? grandTotal,
    String? supplierRef,
    String? dispatchMode,
    String? remarks,
    Object? customerPoFileName = _sentinel,
    List<String>? supportingFileNames,
  }) {
    return OrderFormRecord(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      orderDate: orderDate ?? this.orderDate,
      quotationId: quotationId ?? this.quotationId,
      quoteNo: quoteNo ?? this.quoteNo,
      enquiryNo: enquiryNo ?? this.enquiryNo,
      status: status ?? this.status,
      customerPoNo: customerPoNo ?? this.customerPoNo,
      customerPoDate: customerPoDate == _sentinel
          ? this.customerPoDate
          : customerPoDate as DateTime?,
      customerName: customerName ?? this.customerName,
      siteName: siteName ?? this.siteName,
      contactPerson: contactPerson ?? this.contactPerson,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      sampleLines: sampleLines ?? this.sampleLines,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      gstAmount: gstAmount ?? this.gstAmount,
      freight: freight ?? this.freight,
      grandTotal: grandTotal ?? this.grandTotal,
      supplierRef: supplierRef ?? this.supplierRef,
      dispatchMode: dispatchMode ?? this.dispatchMode,
      remarks: remarks ?? this.remarks,
      customerPoFileName: customerPoFileName == _sentinel
          ? this.customerPoFileName
          : customerPoFileName as String?,
      supportingFileNames:
          supportingFileNames ?? this.supportingFileNames,
    );
  }

  static const Object _sentinel = Object();
}
