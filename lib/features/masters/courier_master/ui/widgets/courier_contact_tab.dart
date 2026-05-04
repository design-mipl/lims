import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/courier_model.dart';

/// Contact mapping tab — person / mobile / email rows.
class CourierContactTab extends StatelessWidget {
  const CourierContactTab({
    super.key,
    required this.contacts,
    required this.isEditing,
    this.onContactsChanged,
  });

  final List<CourierContactMapping> contacts;
  final bool isEditing;
  final ValueChanged<List<CourierContactMapping>>? onContactsChanged;

  Future<void> _removeAt(
    BuildContext context,
    int index,
    CourierContactMapping row,
  ) async {
    final needConfirm =
        row.id.isNotEmpty && !row.id.startsWith('temp');
    if (needConfirm) {
      final ok = await AppConfirmDialog.show(
        context: context,
        title: 'Remove Contact',
        message:
            'Remove contact "${row.contactPerson.isEmpty ? row.id : row.contactPerson}"?',
        confirmLabel: 'Remove',
        variant: AppConfirmDialogVariant.warning,
      );
      if (ok != true || !context.mounted) return;
    }
    final next = [...contacts]..removeAt(index);
    onContactsChanged?.call(next);
  }

  void _patch(int index, CourierContactMapping next) {
    final copy = [...contacts];
    copy[index] = next;
    onContactsChanged?.call(copy);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Contact Mapping',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.sectionTitleSize,
                    fontWeight: AppTokens.sectionTitleWeight,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ),
              if (isEditing)
                AppButton(
                  label: '+ Add Contact',
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.sm,
                  icon: LucideIcons.plus,
                  onPressed: () {
                    final tempId =
                        'temp-contact-${DateTime.now().microsecondsSinceEpoch}';
                    onContactsChanged?.call([
                      ...contacts,
                      CourierContactMapping(
                        id: tempId,
                        contactPerson: '',
                        mobile: '',
                      ),
                    ]);
                  },
                ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          if (contacts.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No contacts added yet',
                      style: GoogleFonts.poppins(
                        fontSize: AppTokens.bodySize,
                        color: AppTokens.textMuted,
                      ),
                    ),
                    SizedBox(height: AppTokens.space3),
                    if (isEditing)
                      AppButton(
                        label: 'Add Contact',
                        variant: AppButtonVariant.primary,
                        icon: LucideIcons.plus,
                        onPressed: () {
                          final tempId =
                              'temp-contact-${DateTime.now().microsecondsSinceEpoch}';
                          onContactsChanged?.call([
                            CourierContactMapping(
                              id: tempId,
                              contactPerson: '',
                              mobile: '',
                            ),
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
                  itemCount: contacts.length,
                  separatorBuilder: (context, unusedIndex) => Divider(
                    height: AppTokens.space4,
                    color: AppTokens.borderDefault,
                  ),
                  itemBuilder: (context, index) {
                    final row = contacts[index];
                    if (!isEditing) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTokens.space2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.contactPerson.isEmpty
                                  ? '—'
                                  : row.contactPerson,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.bodySize,
                                fontWeight: AppTokens.weightMedium,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            SizedBox(height: AppTokens.space1),
                            Text(
                              row.mobile.isEmpty ? '—' : row.mobile,
                              style: GoogleFonts.poppins(
                                fontSize: AppTokens.captionSize,
                                color: AppTokens.textMuted,
                              ),
                            ),
                            if (row.email != null &&
                                row.email!.trim().isNotEmpty)
                              Text(
                                row.email!,
                                style: GoogleFonts.poppins(
                                  fontSize: AppTokens.captionSize,
                                  color: AppTokens.textMuted,
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return _ContactEditRow(
                      key: ValueKey(row.id),
                      row: row,
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

class _ContactEditRow extends StatefulWidget {
  const _ContactEditRow({
    super.key,
    required this.row,
    required this.onPatch,
    required this.onDelete,
  });

  final CourierContactMapping row;
  final ValueChanged<CourierContactMapping> onPatch;
  final VoidCallback onDelete;

  @override
  State<_ContactEditRow> createState() => _ContactEditRowState();
}

class _ContactEditRowState extends State<_ContactEditRow> {
  late TextEditingController _personCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _personCtrl =
        TextEditingController(text: widget.row.contactPerson);
    _mobileCtrl = TextEditingController(text: widget.row.mobile);
    _emailCtrl = TextEditingController(text: widget.row.email ?? '');
  }

  @override
  void didUpdateWidget(covariant _ContactEditRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final r = widget.row;
    if (oldWidget.row.contactPerson != r.contactPerson &&
        _personCtrl.text != r.contactPerson) {
      _personCtrl.text = r.contactPerson;
    }
    if (oldWidget.row.mobile != r.mobile && _mobileCtrl.text != r.mobile) {
      _mobileCtrl.text = r.mobile;
    }
    if (oldWidget.row.email != r.email &&
        _emailCtrl.text != (r.email ?? '')) {
      _emailCtrl.text = r.email ?? '';
    }
  }

  @override
  void dispose() {
    _personCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppInput(
              label: 'Contact Person',
              controller: _personCtrl,
              size: AppInputSize.sm,
              onChanged: (v) =>
                  widget.onPatch(row.copyWith(contactPerson: v)),
            ),
          ),
          SizedBox(width: AppTokens.space2),
          Expanded(
            flex: 2,
            child: AppInput(
              label: 'Mobile',
              hint: '10-digit',
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              size: AppInputSize.sm,
              onChanged: (v) => widget.onPatch(row.copyWith(mobile: v)),
            ),
          ),
          SizedBox(width: AppTokens.space2),
          Expanded(
            flex: 2,
            child: AppInput(
              label: 'Email',
              hint: 'Optional',
              controller: _emailCtrl,
              size: AppInputSize.sm,
              onChanged: (v) => widget.onPatch(
                row.copyWith(
                  email: v.trim().isEmpty ? null : v.trim(),
                ),
              ),
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
