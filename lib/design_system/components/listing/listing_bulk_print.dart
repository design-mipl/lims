import 'package:flutter/material.dart';

import 'listing_bulk_print_stub.dart'
    if (dart.library.html) 'listing_bulk_print_web.dart' as impl;

/// Bulk "print selected" — uses browser print on web, snackbar elsewhere.
void listingBulkPrint(BuildContext context) => impl.listingBulkPrint(context);
