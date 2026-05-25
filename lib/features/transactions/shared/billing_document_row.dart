/// Shared row model for Customer Invoice and Credit Note listings.
///
/// GST / eInvoice fields ([gstVerified], [irnNumber], [qrCodeData],
/// [gstVerificationResponse]) are populated after **Direct to GST** verification.
/// [digitalSignatureAttached] / [digitalSignatureFileName] track row-wise CEO
/// digital signature upload before GST. [ceoSignatureOnTemplate] flags signature on
/// the UltraLabs PDF/template after GST verification when a signature is attached.
class BillingDocumentListingRow {
  const BillingDocumentListingRow({
    required this.id,
    required this.eInvoiceActive,
    required this.docDate,
    required this.documentNo,
    required this.customer,
    required this.dueDays,
    required this.total,
    required this.amountReceived,
    required this.statusLabel,
    this.gstVerified = false,
    this.irnNumber,
    this.qrCodeData,
    this.gstVerificationResponse,
    this.digitalSignatureAttached = false,
    this.digitalSignatureFileName,
    this.ceoSignatureOnTemplate = false,
  });

  final String id;
  final bool eInvoiceActive;
  final DateTime docDate;
  final String documentNo;
  final String customer;
  final int dueDays;
  final double total;
  final double amountReceived;
  final String statusLabel;

  /// True after successful GST / eInvoice verification for this document.
  final bool gstVerified;

  /// Invoice Reference Number (IRN) from GST portal (mock until API).
  final String? irnNumber;

  /// Payload / token used to render QR on invoice (mock).
  final String? qrCodeData;

  /// Raw or JSON summary of GST verification response (mock).
  final String? gstVerificationResponse;

  /// True when a digital signature file is attached for this document row.
  final bool digitalSignatureAttached;

  /// Mock filename for the attached digital signature (persisted in mock API).
  final String? digitalSignatureFileName;

  /// When true, generated PDF includes CEO signature block (template flag).
  final bool ceoSignatureOnTemplate;

  double get outstanding => total - amountReceived;

  BillingDocumentListingRow copyWith({
    bool? eInvoiceActive,
    DateTime? docDate,
    String? documentNo,
    String? customer,
    int? dueDays,
    double? total,
    double? amountReceived,
    String? statusLabel,
    bool? gstVerified,
    String? irnNumber,
    String? qrCodeData,
    String? gstVerificationResponse,
    bool? digitalSignatureAttached,
    String? digitalSignatureFileName,
    bool? ceoSignatureOnTemplate,
  }) {
    return BillingDocumentListingRow(
      id: id,
      eInvoiceActive: eInvoiceActive ?? this.eInvoiceActive,
      docDate: docDate ?? this.docDate,
      documentNo: documentNo ?? this.documentNo,
      customer: customer ?? this.customer,
      dueDays: dueDays ?? this.dueDays,
      total: total ?? this.total,
      amountReceived: amountReceived ?? this.amountReceived,
      statusLabel: statusLabel ?? this.statusLabel,
      gstVerified: gstVerified ?? this.gstVerified,
      irnNumber: irnNumber ?? this.irnNumber,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      gstVerificationResponse:
          gstVerificationResponse ?? this.gstVerificationResponse,
      digitalSignatureAttached:
          digitalSignatureAttached ?? this.digitalSignatureAttached,
      digitalSignatureFileName:
          digitalSignatureFileName ?? this.digitalSignatureFileName,
      ceoSignatureOnTemplate:
          ceoSignatureOnTemplate ?? this.ceoSignatureOnTemplate,
    );
  }
}
