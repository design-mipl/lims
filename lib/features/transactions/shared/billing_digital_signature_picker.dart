import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Non-blocking signature file selection for billing listings.
abstract final class BillingDigitalSignaturePicker {
  static const _extensions = ['png', 'jpg', 'jpeg', 'pdf'];

  static Future<String?> pickFileName({
    required BuildContext context,
    required String fallbackFileName,
  }) async {
    // Yield so the row tap completes before the native picker opens.
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return null;

    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: _extensions,
          allowMultiple: false,
          withData: false,
          withReadStream: false,
          dialogTitle: 'Select digital signature',
          lockParentWindow: false,
        );
      } on Object catch (e) {
        if (kDebugMode) {
          debugPrint('BillingDigitalSignaturePicker custom filter failed: $e');
        }
        // Some desktop builds reject custom filters — retry once with image type.
        result = await FilePicker.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: false,
          withReadStream: false,
          dialogTitle: 'Select digital signature',
          lockParentWindow: false,
        );
      }

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.single;
      final picked = (file.name.trim().isNotEmpty
              ? file.name.trim()
              : file.path?.split(RegExp(r'[/\\]')).last ?? '')
          .trim();
      if (picked.isEmpty) return fallbackFileName;

      final lower = picked.toLowerCase();
      final allowed = _extensions.any((ext) => lower.endsWith('.$ext'));
      if (!allowed) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Invalid file type. Use PNG, JPG, or PDF.',
              ),
            ),
          );
        }
        return null;
      }
      return picked;
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('BillingDigitalSignaturePicker: $e\n$st');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open file picker. ${kDebugMode ? e : 'Try again.'}',
            ),
          ),
        );
      }
      return null;
    }
  }
}
