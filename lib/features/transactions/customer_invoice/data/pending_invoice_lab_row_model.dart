import 'package:flutter/foundation.dart';

/// Pending uninvoiced lab line shown in “Pending Invoice Selection” workspace.
@immutable
class PendingInvoiceLabRow {
  const PendingInvoiceLabRow({
    required this.serialNo,
    required this.id,
    required this.customerId,
    required this.labDate,
    required this.labNo,
    required this.reportId,
    required this.typeOfSample,
    required this.site,
    required this.referenceNo,
    required this.contactPerson,
    required this.lineItem,
    required this.suggestedRate,
  });

  final int serialNo;
  final String id;
  final String customerId;
  final DateTime labDate;
  final String labNo;
  final String reportId;
  final String typeOfSample;
  final String site;
  final String referenceNo;
  final String contactPerson;
  final String lineItem;
  final double suggestedRate;
}
