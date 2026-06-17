import 'package:flutter/material.dart';

import '../../supervisor_nabl/ui/nabl_no_listing_pane.dart';

/// Legacy entry point; prefer [/transactions/supervisor-review].
/// Requires a [NablNoProvider] ancestor.
class NablNoScreen extends StatelessWidget {
  const NablNoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NablNoListingPane(showPageHeader: true);
  }
}
