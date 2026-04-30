import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../data/customer_model.dart';
import '../../state/customer_provider.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key, required this.customerId});

  final String customerId;

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  Future<void> _showAddModal() async {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final nameError = ValueNotifier<String?>(null);
    final provider = context.read<CustomerProvider>();

    await AppFormModal.show(
      context: context,
      title: 'Add Contact',
      body: ValueListenableBuilder<String?>(
        valueListenable: nameError,
        builder: (ctx, currentNameError, _) => AppFormSection(
          title: 'Contact Details',
          children: [
            AppInput(
              label: 'Contact Person',
              hint: 'Enter contact person',
              isRequired: true,
              controller: nameCtrl,
              errorText: currentNameError,
            ),
            AppInput(
              label: 'Mobile',
              hint: 'Enter mobile',
              controller: mobileCtrl,
              keyboardType: TextInputType.phone,
            ),
            AppInput(
              label: 'Email',
              hint: 'Enter email',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      onCancel: () => Navigator.of(context).pop(),
      onPrimary: () async {
        final navigator = Navigator.of(context);
        if (nameCtrl.text.trim().isEmpty) {
          nameError.value = 'Contact Person is required';
          return;
        }
        nameError.value = null;
        await provider.addContact(widget.customerId, {
          'name': nameCtrl.text.trim(),
          'mobile': mobileCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
        });
        if (mounted) navigator.pop();
      },
      isPrimaryLoading: provider.isLoading,
    );
    nameError.dispose();
    nameCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
  }

  Future<void> _showEditModal(ContactPersonModel contact) async {
    final nameCtrl = TextEditingController(text: contact.name);
    final mobileCtrl = TextEditingController(text: contact.mobile ?? '');
    final emailCtrl = TextEditingController(text: contact.email ?? '');
    final nameError = ValueNotifier<String?>(null);
    final provider = context.read<CustomerProvider>();

    await AppFormModal.show(
      context: context,
      title: 'Edit Contact',
      body: ValueListenableBuilder<String?>(
        valueListenable: nameError,
        builder: (ctx, currentNameError, _) => AppFormSection(
          title: 'Contact Details',
          children: [
            AppInput(
              label: 'Contact Person',
              hint: 'Enter contact person',
              isRequired: true,
              controller: nameCtrl,
              errorText: currentNameError,
            ),
            AppInput(
              label: 'Mobile',
              hint: 'Enter mobile',
              controller: mobileCtrl,
              keyboardType: TextInputType.phone,
            ),
            AppInput(
              label: 'Email',
              hint: 'Enter email',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      onCancel: () => Navigator.of(context).pop(),
      onPrimary: () async {
        final navigator = Navigator.of(context);
        if (nameCtrl.text.trim().isEmpty) {
          nameError.value = 'Contact Person is required';
          return;
        }
        nameError.value = null;
        await provider.updateContact(
          widget.customerId,
          contact.id,
          {
            'name': nameCtrl.text.trim(),
            'mobile': mobileCtrl.text.trim(),
            'email': emailCtrl.text.trim(),
          },
        );
        if (mounted) navigator.pop();
      },
      isPrimaryLoading: provider.isLoading,
    );
    nameError.dispose();
    nameCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
  }

  Future<void> _confirmDelete(ContactPersonModel row) async {
    final confirm = await AppConfirmDialog.show(
      context: context,
      title: 'Delete Contact',
      message: 'Delete "${row.name}" from this customer?',
      confirmLabel: 'Delete',
      variant: AppConfirmDialogVariant.danger,
    );
    if (confirm == true && mounted) {
      await context.read<CustomerProvider>().deleteContact(
            widget.customerId,
            row.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = context.select<CustomerProvider, List<ContactPersonModel>>(
      (p) {
        if (p.selected?.id != widget.customerId) return const [];
        return p.selected!.contacts;
      },
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(AppTokens.space4),
            child: Row(
              children: [
                Text(
                  '${contacts.length} contacts',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.textSm,
                    color: AppTokens.textMuted,
                  ),
                ),
                const Spacer(),
                AppButton(
                  label: '+ Add Contact',
                  variant: AppButtonVariant.primary,
                  onPressed: _showAddModal,
                ),
              ],
            ),
          ),
          Divider(
            height: AppTokens.borderWidthSm,
            thickness: AppTokens.borderWidthSm,
            color: AppTokens.border,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contacts.length,
            separatorBuilder: (_, int index) => Divider(
              height: AppTokens.borderWidthSm,
              thickness: AppTokens.borderWidthSm,
              color: AppTokens.border,
            ),
            itemBuilder: (_, int i) {
              final contact = contacts[i];
              return _ContactCard(
                contact: contact,
                onEdit: () => _showEditModal(contact),
                onDelete: () => _confirmDelete(contact),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  final ContactPersonModel contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTokens.space4),
      child: Row(
        children: [
          AppAvatar(name: contact.name, size: AppAvatarSize.md),
          SizedBox(width: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: GoogleFonts.poppins(
                    fontWeight: AppTokens.weightSemibold,
                    color: AppTokens.textPrimary,
                    fontSize: AppTokens.bodySize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (contact.mobile != null && contact.mobile!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: AppTokens.space1),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.phone,
                          size: AppTokens.textSm,
                          color: AppTokens.textMuted,
                        ),
                        SizedBox(width: AppTokens.space1),
                        Expanded(
                          child: Text(
                            contact.mobile!,
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.textSm,
                              color: AppTokens.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (contact.email != null && contact.email!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: AppTokens.space1),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.mail,
                          size: AppTokens.textSm,
                          color: AppTokens.textMuted,
                        ),
                        SizedBox(width: AppTokens.space1),
                        Expanded(
                          child: Text(
                            contact.email!,
                            style: GoogleFonts.poppins(
                              fontSize: AppTokens.textSm,
                              color: AppTokens.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icon(LucideIcons.pencil),
            tooltip: 'Edit',
            variant: AppIconButtonVariant.ghost,
            onPressed: onEdit,
          ),
          AppIconButton(
            icon: Icon(LucideIcons.trash2),
            tooltip: 'Delete',
            variant: AppIconButtonVariant.ghost,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
