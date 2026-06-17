import 'package:flutter/material.dart';

import '../../supervisor_nabl/ui/supervisor_comments_listing_pane.dart';

/// Legacy entry point; prefer [/transactions/supervisor-review].
/// Requires a [SupervisorCommentsProvider] ancestor.
class SupervisorCommentsScreen extends StatelessWidget {
  const SupervisorCommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SupervisorCommentsListingPane(showPageHeader: true);
  }
}
