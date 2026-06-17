import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/order_model.dart';

Future<void> showOrderVersionHistoryDialog(
  BuildContext context, {
  required OrderRecord order,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: AppTokens.modalBarrierScrim,
    builder: (ctx) => _OrderVersionHistoryDialog(order: order),
  );
}

class _OrderVersionHistoryDialog extends StatelessWidget {
  const _OrderVersionHistoryDialog({required this.order});

  final OrderRecord order;

  static const double _dialogWidth = 1020;
  static const double _maxBodyHeight = 360;
  static const double _rowHeight = 36;
  static const double _headerHeight = 36;

  static const List<({String label, double width, bool center})> _columns = [
    (label: 'Version No.', width: 88, center: false),
    (label: 'Revision Date', width: 112, center: false),
    (label: 'Updated By', width: 120, center: false),
    (label: 'Original Amount', width: 118, center: false),
    (label: 'Discount %', width: 96, center: false),
    (label: 'Revised Amount', width: 118, center: false),
    (label: 'Status', width: 128, center: true),
    (label: 'Remarks', width: 200, center: false),
  ];

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _money(double v) => v.toStringAsFixed(2);

  StatusChip _versionStatusChip(String status) {
    final label = switch (status) {
      OrderStatus.emailSent => 'Email sent',
      OrderStatus.underDiscussion => 'Under review',
      OrderStatus.discountRevised => 'Discount revised',
      OrderStatus.convertedOrder => 'Converted',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.rejected => 'Rejected',
      OrderStatus.draft => 'Draft',
      _ => status,
    };
    final key = switch (status) {
      OrderStatus.confirmed || OrderStatus.convertedOrder => 'completed',
      OrderStatus.rejected => 'critical',
      OrderStatus.emailSent || OrderStatus.underDiscussion => 'inReview',
      OrderStatus.discountRevised => 'pending',
      _ => 'draft',
    };
    return StatusChip(status: key, customLabel: label);
  }

  TextStyle get _headerStyle => GoogleFonts.poppins(
        fontSize: AppTokens.captionSize,
        fontWeight: AppTokens.weightSemibold,
        color: AppTokens.textSecondary,
        letterSpacing: 0.4,
      );

  TextStyle get _cellStyle => GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        color: AppTokens.textPrimary,
      );

  Widget _headerCell(String label, double width, {bool center = false}) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _headerStyle,
        ),
      ),
    );
  }

  Widget _bodyCell(
    Widget child,
    double width, {
    bool center = false,
  }) {
    return SizedBox(
      width: width,
      height: _rowHeight,
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: child,
      ),
    );
  }

  Widget _bodyText(String text, {int maxLines = 1}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: _cellStyle,
    );
  }

  Widget _versionRow(OrderVersionEntry v) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
      child: Row(
        children: [
          _bodyCell(_bodyText('V${v.versionNo}'), _columns[0].width),
          _bodyCell(_bodyText(_formatDate(v.revisedAt)), _columns[1].width),
          _bodyCell(_bodyText(v.updatedBy), _columns[2].width),
          _bodyCell(_bodyText(_money(v.originalAmount)), _columns[3].width),
          _bodyCell(
            _bodyText('${v.discountPercent.toStringAsFixed(1)}%'),
            _columns[4].width,
          ),
          _bodyCell(_bodyText(_money(v.revisedAmount)), _columns[5].width),
          _bodyCell(
            _versionStatusChip(v.status),
            _columns[6].width,
            center: true,
          ),
          SizedBox(
            width: _columns[7].width,
            height: _rowHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _bodyText(
                v.remarks.isEmpty ? '—' : v.remarks,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      height: _headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
      decoration: BoxDecoration(
        color: AppTokens.surfaceSubtle,
        border: Border(
          bottom: BorderSide(color: AppTokens.borderDefault),
        ),
      ),
      child: Row(
        children: [
          for (final c in _columns)
            _headerCell(c.label, c.width, center: c.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final versions = order.versions;

    return Dialog(
      backgroundColor: AppTokens.cardBg,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space6,
        vertical: AppTokens.space5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
        side: const BorderSide(color: AppTokens.borderDefault),
      ),
      child: SizedBox(
        width: _dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space5,
                AppTokens.space4,
                AppTokens.space3,
                AppTokens.space3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Version History — ${order.orderNo}',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.textLg,
                        fontWeight: AppTokens.weightSemibold,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      LucideIcons.x,
                      size: AppTokens.iconButtonIconMd,
                      color: AppTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space5,
                0,
                AppTokens.space5,
                AppTokens.space5,
              ),
              child: versions.isEmpty
                  ? Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppTokens.space3),
                      child: Text(
                        'No version entries recorded.',
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.bodySize,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTokens.borderDefault),
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusMd),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusMd),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: _columns.fold<double>(
                              0,
                              (sum, c) => sum + c.width,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _tableHeader(),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: _maxBodyHeight,
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: versions.length,
                                    separatorBuilder: (context, index) => Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppTokens.borderDefault,
                                    ),
                                    itemBuilder: (_, i) =>
                                        _versionRow(versions[i]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
