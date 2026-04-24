import 'package:flutter/foundation.dart';

/// Abstract base for feature [ChangeNotifier] providers.
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Call this before any async operation.
  Future<void> runAsync(Future<void> Function() fn) async {
    setLoading(true);
    clearError();
    try {
      await fn();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
