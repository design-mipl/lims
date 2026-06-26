import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'billing_listing_provider.dart';
import 'billing_row_action_state.dart';

/// Provides [BillingListingProvider] and exposes [BillingRowActionState] for
/// localized row-level rebuilds in billing listing cells.
class BillingListingScope extends StatelessWidget {
  const BillingListingScope({
    super.key,
    required this.createProvider,
    required this.child,
  });

  final BillingListingProvider Function() createProvider;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BillingListingProvider>(
      create: (_) => createProvider(),
      child: Builder(
        builder: (context) {
          return ChangeNotifierProvider<BillingRowActionState>.value(
            value: context.read<BillingListingProvider>().rowActions,
            child: child,
          );
        },
      ),
    );
  }
}
