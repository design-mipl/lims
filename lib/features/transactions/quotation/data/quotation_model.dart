import '../../shared/activity_timeline_models.dart';

abstract final class QuotationStatus {
  static const String pendingPrep = 'pendingPrep';
  static const String inReview = 'inReview';
  static const String approved = 'approved';
  static const String changesRequested = 'changesRequested';
}

class QuotationPricingLine {
  const QuotationPricingLine({
    required this.id,
    required this.testCode,
    required this.description,
    this.qty = 1,
    this.rate = 0,
    this.selected = false,
  });

  final String id;
  final String testCode;
  final String description;
  final int qty;
  final double rate;
  final bool selected;

  double get amount => qty * rate;

  QuotationPricingLine copyWith({
    String? id,
    String? testCode,
    String? description,
    int? qty,
    double? rate,
    bool? selected,
  }) {
    return QuotationPricingLine(
      id: id ?? this.id,
      testCode: testCode ?? this.testCode,
      description: description ?? this.description,
      qty: qty ?? this.qty,
      rate: rate ?? this.rate,
      selected: selected ?? this.selected,
    );
  }
}

class QuotationRecord {
  const QuotationRecord({
    required this.id,
    required this.quoteNo,
    required this.enquiryId,
    required this.enquiryNo,
    required this.customerName,
    required this.siteName,
    required this.typeOfSample,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.preparedBy,
    required this.lines,
    this.discountAmount = 0,
    this.gstPercent = 18,
    this.terms = '',
    this.notes = '',
    this.internalComments = '',
    this.attachmentNames = const [],
    this.activity = const [],
    this.approvedDiscountAmount,
    this.discussionNotes = '',
    this.orderReference,
  });

  final String id;
  final String quoteNo;
  final String enquiryId;
  final String enquiryNo;
  final String customerName;
  final String siteName;
  final String typeOfSample;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String preparedBy;
  final List<QuotationPricingLine> lines;

  final double discountAmount;
  final double gstPercent;
  final String terms;
  final String notes;
  final String internalComments;
  final List<String> attachmentNames;
  final List<ActivityTimelineEntry> activity;

  final double? approvedDiscountAmount;
  final String discussionNotes;
  final String? orderReference;

  double get subtotal =>
      lines.fold<double>(0, (sum, line) => sum + line.amount);

  double get taxableBase => (subtotal - discountAmount).clamp(0, double.infinity);
  double get gstAmount => taxableBase * gstPercent / 100;
  double get grandTotal => taxableBase + gstAmount;

  static const Object _sentinel = Object();

  QuotationRecord copyWith({
    String? id,
    String? quoteNo,
    String? enquiryId,
    String? enquiryNo,
    String? customerName,
    String? siteName,
    String? typeOfSample,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? preparedBy,
    List<QuotationPricingLine>? lines,
    double? discountAmount,
    double? gstPercent,
    String? terms,
    String? notes,
    String? internalComments,
    List<String>? attachmentNames,
    List<ActivityTimelineEntry>? activity,
    Object? approvedDiscountAmount = _sentinel,
    String? discussionNotes,
    Object? orderReference = _sentinel,
  }) {
    return QuotationRecord(
      id: id ?? this.id,
      quoteNo: quoteNo ?? this.quoteNo,
      enquiryId: enquiryId ?? this.enquiryId,
      enquiryNo: enquiryNo ?? this.enquiryNo,
      customerName: customerName ?? this.customerName,
      siteName: siteName ?? this.siteName,
      typeOfSample: typeOfSample ?? this.typeOfSample,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preparedBy: preparedBy ?? this.preparedBy,
      lines: lines ?? this.lines,
      discountAmount: discountAmount ?? this.discountAmount,
      gstPercent: gstPercent ?? this.gstPercent,
      terms: terms ?? this.terms,
      notes: notes ?? this.notes,
      internalComments: internalComments ?? this.internalComments,
      attachmentNames: attachmentNames ?? this.attachmentNames,
      activity: activity ?? this.activity,
      approvedDiscountAmount: approvedDiscountAmount == _sentinel
          ? this.approvedDiscountAmount
          : approvedDiscountAmount as double?,
      discussionNotes: discussionNotes ?? this.discussionNotes,
      orderReference: orderReference == _sentinel
          ? this.orderReference
          : orderReference as String?,
    );
  }
}
