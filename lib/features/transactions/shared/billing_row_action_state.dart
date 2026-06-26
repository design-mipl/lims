import 'package:flutter/foundation.dart';

/// Row-scoped loading flags for billing listings (GST verify, signature attach).
///
/// Notifies independently from [BillingListingProvider] so icon cells can
/// rebuild without refreshing the full table.
class BillingRowActionState extends ChangeNotifier {
  final Set<String> _gstVerifyingRowIds = <String>{};
  final Set<String> _signatureBusyRowIds = <String>{};
  bool _gstVerificationInProgress = false;

  bool get gstVerificationInProgress => _gstVerificationInProgress;
  Set<String> get gstVerifyingRowIds =>
      Set<String>.unmodifiable(_gstVerifyingRowIds);

  bool isGstVerifying(String rowId) => _gstVerifyingRowIds.contains(rowId);

  /// True while file picker or upload is in progress for this row.
  bool isSignatureBusy(String rowId) => _signatureBusyRowIds.contains(rowId);

  /// @deprecated Use [isSignatureBusy].
  bool isSignatureAttaching(String rowId) => isSignatureBusy(rowId);

  void startGstVerify(Iterable<String> rowIds) {
    _gstVerificationInProgress = true;
    _gstVerifyingRowIds
      ..clear()
      ..addAll(rowIds);
    notifyListeners();
  }

  void endGstVerify() {
    _gstVerificationInProgress = false;
    _gstVerifyingRowIds.clear();
    notifyListeners();
  }

  void startSignatureFlow(String rowId) {
    _signatureBusyRowIds.add(rowId);
    notifyListeners();
  }

  void endSignatureFlow(String rowId) {
    _signatureBusyRowIds.remove(rowId);
    notifyListeners();
  }

  /// @deprecated Use [startSignatureFlow].
  void startSignatureAttach(String rowId) => startSignatureFlow(rowId);

  /// @deprecated Use [endSignatureFlow].
  void endSignatureAttach(String rowId) => endSignatureFlow(rowId);
}
