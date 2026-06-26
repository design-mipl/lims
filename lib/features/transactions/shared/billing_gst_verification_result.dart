/// Outcome of a bulk or single **Direct to GST** verification run.
class BillingGstVerificationResult {
  const BillingGstVerificationResult._({
    required this.success,
    this.errorMessage,
    this.verifiedItems = const [],
    this.timestamp,
  });

  factory BillingGstVerificationResult.success({
    required List<BillingGstVerifiedItem> items,
    required DateTime timestamp,
  }) {
    return BillingGstVerificationResult._(
      success: true,
      verifiedItems: items,
      timestamp: timestamp,
    );
  }

  factory BillingGstVerificationResult.failure(String message) {
    return BillingGstVerificationResult._(
      success: false,
      errorMessage: message,
    );
  }

  final bool success;
  final String? errorMessage;
  final List<BillingGstVerifiedItem> verifiedItems;
  final DateTime? timestamp;
}

/// Per-document GST verification details for the success popup.
class BillingGstVerifiedItem {
  const BillingGstVerifiedItem({
    required this.documentId,
    required this.documentNo,
    required this.gstRefNo,
  });

  final String documentId;
  final String documentNo;
  final String gstRefNo;
}
