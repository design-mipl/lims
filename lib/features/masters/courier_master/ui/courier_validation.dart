/// Lightweight validators for Courier Master forms (no Flutter imports).
abstract final class CourierValidators {
  static bool emailOptionalValid(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return true;
    return RegExp(r'^[\w.\-+]+@[\w-]+\.[\w.-]+$').hasMatch(s);
  }

  /// Ten-digit Indian mobile (allows spaces/dashes in input).
  static bool mobileRequiredValid(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10;
  }

  static bool mobileOptionalValid(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return true;
    return mobileRequiredValid(s);
  }
}
