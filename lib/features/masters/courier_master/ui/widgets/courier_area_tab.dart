import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../../site_master/data/site_model.dart';
import '../../../site_master/state/site_provider.dart';
import '../../data/courier_model.dart';

/// Area mapping tab — read table or editable rows linked to Site Master.
class CourierAreaTab extends StatelessWidget {
  const CourierAreaTab({
    super.key,
    required this.areas,
    required this.isEditing,
    this.onAreasChanged,
  });

  final List<CourierAreaMapping> areas;
  final bool isEditing;
  final ValueChanged<List<CourierAreaMapping>>? onAreasChanged;

  static List<AppSelectItem<String>> siteItems(List<SiteModel> sites) {
    return [
      const AppSelectItem<String>(value: '', label: 'No site linked'),
      ...sites.map(
        (s) => AppSelectItem<String>(
          value: s.id,
          label: (s.displayName?.trim().isNotEmpty == true)
              ? s.displayName!.trim()
              : s.code,
          code: s.code,
        ),
      ),
    ];
  }

  static String siteLabel(CourierAreaMapping row, List<SiteModel> sites) {
    if (row.siteId == null || row.siteId!.isEmpty) return '—';
    for (final s in sites) {
      if (s.id == row.siteId) {
        return (s.displayName?.trim().isNotEmpty == true)
            ? s.displayName!.trim()
            : s.code;
      }
    }
    return row.siteName ?? row.siteId!;
  }

  Future<void> _removeAt(
    BuildContext context,
    int index,
    CourierAreaMapping row,
  ) async {
    final needConfirm =
        row.id.isNotEmpty && !row.id.startsWith('temp');
    if (needConfirm) {
      final ok = await AppConfirmDialog.show(
        context: context,
        title: 'Remove Area',
        message:
            'Remove area mapping "${row.area.isEmpty ? row.id : row.area}"?',
        confirmLabel: 'Remove',
        variant: AppConfirmDialogVariant.warning,
      );
      if (ok != true || !context.mounted) return;
    }
    final next = [...areas]..removeAt(index);
    onAreasChanged?.call(next);
  }

  void _patch(int index, CourierAreaMapping next) {
    final copy = [...areas];
    copy[index] = next;
    onAreasChanged?.call(copy);
  }

  @override
  Widget build(BuildContext context) {
    final sites = context.watch<SiteProvider>().sites;
    final items = siteItems(sites);

    return Padding(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Area Mapping',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.sectionTitleSize,
                    fontWeight: AppTokens.sectionTitleWeight,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ),
              if (isEditing)
                AppButton(
                  label: '+ Add Area',
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.sm,
                  icon: LucideIcons.plus,
                  onPressed: () {
                    final tempId =
                        'temp-area-${DateTime.now().microsecondsSinceEpoch}';
                    onAreasChanged?.call([
                      ...areas,
                      CourierAreaMapping(id: tempId, area: ''),
                    ]);
                  },
                ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          if (areas.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No areas added yet',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.bodySize,
                        color: AppTokens.textMuted,
                      ),
                    ),
                    SizedBox(height: AppTokens.space3),
                    if (isEditing)
                      AppButton(
                        label: 'Add Area',
                        variant: AppButtonVariant.primary,
                        icon: LucideIcons.plus,
                        onPressed: () {
                          final tempId =
                              'temp-area-${DateTime.now().microsecondsSinceEpoch}';
                          onAreasChanged?.call([
                            CourierAreaMapping(id: tempId, area: ''),
                          ]);
                        },
                      ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTokens.borderDefault),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.all(AppTokens.space3),
                  itemCount: areas.length,
                  separatorBuilder: (context, unusedIndex) => Divider(
                    height: AppTokens.space4,
                    color: AppTokens.borderDefault,
                  ),
                  itemBuilder: (context, index) {
                    final row = areas[index];
                    if (!isEditing) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTokens.space2,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Area',
                                    style: GoogleFonts.poppins(
                                      fontSize: AppTokens.captionSize,
                                      color: AppTokens.textMuted,
                                    ),
                                  ),
                                  Text(
                                    row.area.isEmpty ? '—' : row.area,
                                    style: GoogleFonts.poppins(
                                      fontSize: AppTokens.bodySize,
                                      color: AppTokens.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Site',
                                    style: GoogleFonts.poppins(
                                      fontSize: AppTokens.captionSize,
                                      color: AppTokens.textMuted,
                                    ),
                                  ),
                                  Text(
                                    siteLabel(row, sites),
                                    style: GoogleFonts.poppins(
                                      fontSize: AppTokens.bodySize,
                                      color: AppTokens.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return _AreaEditRow(
                      key: ValueKey(row.id),
                      row: row,
                      sites: sites,
                      siteItems: items,
                      onPatch: (m) => _patch(index, m),
                      onDelete: () => _removeAt(context, index, row),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AreaEditRow extends StatefulWidget {
  const _AreaEditRow({
    super.key,
    required this.row,
    required this.sites,
    required this.siteItems,
    required this.onPatch,
    required this.onDelete,
  });

  final CourierAreaMapping row;
  final List<SiteModel> sites;
  final List<AppSelectItem<String>> siteItems;
  final ValueChanged<CourierAreaMapping> onPatch;
  final VoidCallback onDelete;

  @override
  State<_AreaEditRow> createState() => _AreaEditRowState();
}

class _AreaEditRowState extends State<_AreaEditRow> {
  late TextEditingController _areaCtrl;

  @override
  void initState() {
    super.initState();
    _areaCtrl = TextEditingController(text: widget.row.area);
  }

  @override
  void didUpdateWidget(covariant _AreaEditRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row.area != widget.row.area &&
        _areaCtrl.text != widget.row.area) {
      _areaCtrl.text = widget.row.area;
    }
  }

  @override
  void dispose() {
    _areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final sid = row.siteId ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppInput(
              label: 'Area',
              hint: 'Service area',
              controller: _areaCtrl,
              size: AppInputSize.sm,
              onChanged: (v) => widget.onPatch(row.copyWith(area: v)),
            ),
          ),
          SizedBox(width: AppTokens.space3),
          Expanded(
            flex: 2,
            child: AppSelect<String>(
              label: 'Site',
              hint: 'Search site',
              value: sid.isEmpty ? '' : sid,
              items: widget.siteItems,
              isSearchable: true,
              onChanged: (v) {
                final id = v ?? '';
                String? siteName;
                if (id.isNotEmpty) {
                  for (final s in widget.sites) {
                    if (s.id == id) {
                      siteName =
                          (s.displayName?.trim().isNotEmpty == true)
                              ? s.displayName!.trim()
                              : s.code;
                      break;
                    }
                  }
                }
                widget.onPatch(
                  row.copyWith(
                    siteId: id.isEmpty ? null : id,
                    siteName: siteName,
                  ),
                );
              },
              size: AppInputSize.sm,
            ),
          ),
          SizedBox(width: AppTokens.space2),
          Padding(
            padding: EdgeInsets.only(top: AppTokens.space6),
            child: AppIconButton(
              tooltip: 'Delete row',
              icon: Icon(LucideIcons.trash2),
              variant: AppIconButtonVariant.outlined,
              onPressed: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
