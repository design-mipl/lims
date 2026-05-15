import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../../../masters/customer_master/data/customer_model.dart';
import '../data/pending_invoice_lab_row_model.dart';

/// Right-edge drawer — Bill To customer picker (Name + Pending). Row tap selects and closes.
Future<CustomerModel?> showCustomerInvoiceBillToDrawer(
  BuildContext context, {
  required List<CustomerModel> customers,
  required List<PendingInvoiceLabRow> pendingLabs,
  required Set<String> excludedPendingIds,
}) {
  return showGeneralDialog<CustomerModel>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppTokens.neutral900.withValues(alpha: 0.30),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      final h = MediaQuery.sizeOf(ctx).height;
      return Align(
        alignment: Alignment.centerRight,
        child: SafeArea(
          child: Material(
            color: AppTokens.cardBg,
            child: SizedBox(
              width: _billToPanelWidth(ctx),
              height: h,
              child: _BillToDrawerBody(
                customers: customers,
                pendingLabs: pendingLabs,
                excludedPendingIds: excludedPendingIds,
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

double _billToPanelWidth(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  const minPanel = 420.0;
  const maxPanel = 520.0;
  const edge = AppTokens.space4 * 2;
  if (w <= edge + minPanel) {
    return math.max(0, w - AppTokens.space2);
  }
  return (w - edge).clamp(minPanel, maxPanel);
}

String _customerPickerName(CustomerModel c) {
  final d = c.displayName?.trim();
  if (d != null && d.isNotEmpty) return d;
  return c.companyName;
}

class _BillToDrawerBody extends StatefulWidget {
  const _BillToDrawerBody({
    required this.customers,
    required this.pendingLabs,
    required this.excludedPendingIds,
  });

  final List<CustomerModel> customers;
  final List<PendingInvoiceLabRow> pendingLabs;
  final Set<String> excludedPendingIds;

  @override
  State<_BillToDrawerBody> createState() => _BillToDrawerBodyState();
}

class _BillToDrawerBodyState extends State<_BillToDrawerBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _listingReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _listingReady = true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _pendingCount(CustomerModel c) {
    return widget.pendingLabs
        .where(
          (p) =>
              p.customerId == c.id &&
              !widget.excludedPendingIds.contains(p.id),
        )
        .length;
  }

  List<CustomerModel> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return widget.customers;
    return widget.customers.where((c) {
      final name = _customerPickerName(c).toLowerCase();
      final company = c.companyName.toLowerCase();
      return name.contains(q) || company.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    const colWidth = 200.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        border: Border(
          left: BorderSide(
            color: AppTokens.borderDefault,
            width: AppTokens.borderWidthSm,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppTokens.space4,
              AppTokens.space4,
              AppTokens.space2,
              AppTokens.space2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Select Bill To Customer',
                    style: GoogleFonts.poppins(
                      fontSize: AppTokens.textMd,
                      fontWeight: AppTokens.weightSemibold,
                      color: AppTokens.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                AppIconButton(
                  tooltip: 'Close',
                  icon: Icon(LucideIcons.x, size: AppTokens.iconButtonIconMd),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTokens.borderLight),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppTokens.space4,
              AppTokens.space3,
              AppTokens.space4,
              AppTokens.space2,
            ),
            child: AppInput(
              hint: 'Search by name…',
              controller: _searchCtrl,
              size: AppInputSize.md,
              onChanged: (_) => setState(() {}),
              prefixIcon: Icon(
                LucideIcons.search,
                size: AppTokens.iconButtonIconSm,
              ),
            ),
          ),
          Divider(height: 1, color: AppTokens.borderLight),
          Expanded(
            child: _listingReady
                ? RepaintBoundary(
                    child: AppListingScreen<CustomerModel>(
                      showPageHeader: false,
                      title: '',
                      subtitle: '',
                      showKpis: false,
                      showExport: false,
                      showImport: false,
                      showPrint: false,
                      showColumnToggle: false,
                      showToolbar: false,
                      showSearch: false,
                      showBulkBar: false,
                      showCheckboxes: false,
                      showPaginationFooter: false,
                      tableScrollableMinWidth: colWidth * 2,
                      showTableHorizontalScrollbar: true,
                      tableBodyFillsViewport: false,
                      disableOuterVerticalScroll: true,
                      listingShellPadding: EdgeInsets.zero,
                      scaleDataColumnsToFillViewport: true,
                      columns: [
                        TableColumn<CustomerModel>(
                          key: 'name',
                          label: 'Name',
                          width: colWidth,
                          sortable: true,
                          sortValue: (c) =>
                              _customerPickerName(c).toLowerCase(),
                          cellBuilder: (c) => Text(
                            _customerPickerName(c),
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.tableCellSize,
                              color: AppTokens.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        TableColumn<CustomerModel>(
                          key: 'pending',
                          label: 'Pending',
                          width: colWidth,
                          sortable: true,
                          sortValue: (c) => _pendingCount(c),
                          cellBuilder: (c) => Text(
                            '${_pendingCount(c)}',
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.tableCellSize,
                              color: AppTokens.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                      rows: rows,
                      onRowTap: (c) =>
                          Navigator.of(context).pop<CustomerModel>(c),
                      mobileCardBuilder: (c) => ListTile(
                        title: Text(_customerPickerName(c)),
                        subtitle: Text('Pending: ${_pendingCount(c)}'),
                      ),
                      totalCount: rows.length,
                      currentPage: 1,
                      pageSize: rows.isEmpty ? 1 : rows.length,
                      onPageChanged: (_) {},
                      onPageSizeChanged: (_) {},
                    ),
                  )
                : Center(
                    child: SizedBox(
                      width: AppTokens.space5,
                      height: AppTokens.space5,
                      child: CircularProgressIndicator(
                        strokeWidth: AppTokens.borderWidthMd,
                        color: AppTokens.primary800,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
