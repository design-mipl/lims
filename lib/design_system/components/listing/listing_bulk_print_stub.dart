import 'package:flutter/material.dart';

/// Non-web: show placeholder until a platform print pipeline exists.
void listingBulkPrint(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Print feature coming soon')),
  );
}
