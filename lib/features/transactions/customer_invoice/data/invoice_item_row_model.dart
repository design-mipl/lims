import 'package:flutter/foundation.dart';

/// Invoice line item on Create Customer Invoice (UI / draft).
@immutable
class InvoiceItemRowModel {
  const InvoiceItemRowModel({
    required this.srNo,
    required this.id,
    required this.labDate,
    required this.labNo,
    required this.reportId,
    required this.typeOfSample,
    required this.lineItem,
    required this.rate,
    required this.quantity,
    required this.site,
    required this.status,
    required this.references,
    required this.contactPerson,
  });

  final int srNo;
  final String id;
  final DateTime labDate;
  final String labNo;
  final String reportId;
  final String typeOfSample;
  final String lineItem;
  final double rate;
  final double quantity;
  final String site;
  final String status;
  final String references;
  final String contactPerson;

  double get amount => rate * quantity;

  InvoiceItemRowModel copyWith({
    int? srNo,
    String? id,
    DateTime? labDate,
    String? labNo,
    String? reportId,
    String? typeOfSample,
    String? lineItem,
    double? rate,
    double? quantity,
    String? site,
    String? status,
    String? references,
    String? contactPerson,
  }) {
    return InvoiceItemRowModel(
      srNo: srNo ?? this.srNo,
      id: id ?? this.id,
      labDate: labDate ?? this.labDate,
      labNo: labNo ?? this.labNo,
      reportId: reportId ?? this.reportId,
      typeOfSample: typeOfSample ?? this.typeOfSample,
      lineItem: lineItem ?? this.lineItem,
      rate: rate ?? this.rate,
      quantity: quantity ?? this.quantity,
      site: site ?? this.site,
      status: status ?? this.status,
      references: references ?? this.references,
      contactPerson: contactPerson ?? this.contactPerson,
    );
  }
}
