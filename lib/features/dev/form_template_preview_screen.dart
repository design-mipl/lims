/// Temporary internal preview screen for form templates.
/// Remove before production.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/components/components.dart';
import '../../design_system/tokens.dart';

/// Dev-only gallery for [AppFormModal], [AppFormDrawer], and [AppFormPage].
class FormTemplatePreviewScreen extends StatefulWidget {
  const FormTemplatePreviewScreen({super.key});

  @override
  State<FormTemplatePreviewScreen> createState() =>
      _FormTemplatePreviewScreenState();
}

class _FormTemplatePreviewScreenState extends State<FormTemplatePreviewScreen> {
  final _modalName = TextEditingController();
  final _modalEmail = TextEditingController();
  final _modalPhone = TextEditingController();
  final _modalRole = TextEditingController();

  final _drawerName = TextEditingController();
  final _drawerPhone = TextEditingController();
  final _drawerEmail = TextEditingController();
  final _drawerGstin = TextEditingController();
  final _drawerCompany = TextEditingController();
  final _drawerBill = TextEditingController();
  final _drawerShip = TextEditingController();
  final _drawerOpening = TextEditingController();

  final _pageCustomer = TextEditingController();
  final _pageSite = TextEditingController();
  final _pageSampleId = TextEditingController();
  final _pageNotes = TextEditingController();

  @override
  void dispose() {
    _modalName.dispose();
    _modalEmail.dispose();
    _modalPhone.dispose();
    _modalRole.dispose();
    _drawerName.dispose();
    _drawerPhone.dispose();
    _drawerEmail.dispose();
    _drawerGstin.dispose();
    _drawerCompany.dispose();
    _drawerBill.dispose();
    _drawerShip.dispose();
    _drawerOpening.dispose();
    _pageCustomer.dispose();
    _pageSite.dispose();
    _pageSampleId.dispose();
    _pageNotes.dispose();
    super.dispose();
  }

  void _openModal() {
    AppFormModal.show(
      context: context,
      title: 'Quick add',
      subtitle: 'Compact modal layout',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormFieldRow(
            children: [
              AppInput(
                label: 'Name',
                hint: 'Full name',
                controller: _modalName,
                required: true,
                size: AppInputSize.sm,
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          AppFormFieldRow(
            children: [
              AppInput(
                label: 'Email',
                hint: 'name@company.com',
                controller: _modalEmail,
                keyboardType: TextInputType.emailAddress,
                size: AppInputSize.sm,
              ),
              AppInput(
                label: 'Phone',
                hint: '+91 …',
                controller: _modalPhone,
                keyboardType: TextInputType.phone,
                size: AppInputSize.sm,
              ),
            ],
          ),
          SizedBox(height: AppTokens.space3),
          AppFormFieldRow(
            children: [
              AppInput(
                label: 'Role',
                hint: 'e.g. Analyst',
                controller: _modalRole,
                size: AppInputSize.sm,
              ),
            ],
          ),
        ],
      ),
      onPrimary: () => Navigator.of(context).maybePop(),
    );
  }

  void _openDrawer() {
    AppFormDrawer.show(
      context: context,
      title: 'Add Customer',
      subtitle: 'Create customer profile and billing information',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormSection(
            title: 'Basic Details',
            child: AppFormFieldRow(
              children: [
                AppInput(
                  label: 'Name',
                  controller: _drawerName,
                  required: true,
                  size: AppInputSize.sm,
                ),
                AppInput(
                  label: 'Phone',
                  controller: _drawerPhone,
                  keyboardType: TextInputType.phone,
                  size: AppInputSize.sm,
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.space3),
          AppFormSection(
            title: 'Company Details',
            description: 'Optional',
            trailing: AppButton(
              label: 'Fetch Details',
              onPressed: () {},
              variant: AppButtonVariant.tertiary,
              size: AppButtonSize.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormFieldRow(
                  children: [
                    AppInput(
                      label: 'GSTIN',
                      controller: _drawerGstin,
                      size: AppInputSize.sm,
                    ),
                    AppInput(
                      label: 'Company Name',
                      controller: _drawerCompany,
                      size: AppInputSize.sm,
                    ),
                  ],
                ),
                SizedBox(height: AppTokens.space3),
                AppInput(
                  label: 'Email',
                  controller: _drawerEmail,
                  keyboardType: TextInputType.emailAddress,
                  size: AppInputSize.sm,
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.space3),
          AppFormSection(
            title: 'Address Details',
            trailing: AppButton(
              label: '+ Add Address',
              onPressed: () {},
              variant: AppButtonVariant.tertiary,
              size: AppButtonSize.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextarea(
                  label: 'Billing Address',
                  controller: _drawerBill,
                ),
                SizedBox(height: AppTokens.space3),
                AppTextarea(
                  label: 'Shipping Address',
                  controller: _drawerShip,
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.space3),
          AppFormSection(
            title: 'Optional Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppInput(
                  label: 'Opening Balance',
                  controller: _drawerOpening,
                  keyboardType: TextInputType.number,
                  size: AppInputSize.sm,
                ),
                SizedBox(height: AppTokens.space3),
                AppInput(
                  label: 'TDS',
                  hint: 'Toggle placeholder',
                  readOnly: true,
                  onTap: () {},
                  size: AppInputSize.sm,
                ),
                SizedBox(height: AppTokens.space3),
                AppInput(
                  label: 'TCS',
                  hint: 'Toggle placeholder',
                  readOnly: true,
                  onTap: () {},
                  size: AppInputSize.sm,
                ),
              ],
            ),
          ),
        ],
      ),
      onPrimary: () => Navigator.of(context).maybePop(),
    );
  }

  double _embeddedPageHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    final h = mq.size.height - mq.padding.vertical - AppTokens.topbarHeight;
    return h.clamp(480.0, 920.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(AppTokens.space4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Form Template Preview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: AppTokens.weightSemibold,
              ),
            ),
            SizedBox(height: AppTokens.space2),
            Text(
              'Modal, drawer, and full-page shells (mock fields only).',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppTokens.neutral400
                    : AppTokens.neutral600,
              ),
            ),
            SizedBox(height: AppTokens.space6),
            AppCard(
              padding: EdgeInsets.all(AppTokens.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Modal',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: AppTokens.weightSemibold),
                  ),
                  SizedBox(height: AppTokens.space3),
                  AppButton(
                    label: 'Open Modal Form',
                    onPressed: _openModal,
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.md,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTokens.space4),
            AppCard(
              padding: EdgeInsets.all(AppTokens.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2. Drawer',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: AppTokens.weightSemibold),
                  ),
                  SizedBox(height: AppTokens.space3),
                  AppButton(
                    label: 'Open Drawer Form',
                    onPressed: _openDrawer,
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.md,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTokens.space4),
            AppCard(
              padding: EdgeInsets.all(AppTokens.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3. Full page',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: AppTokens.weightSemibold),
                  ),
                  SizedBox(height: AppTokens.space2),
                  Text(
                    'Embedded [AppFormPage] with bounded height (shell scroll workaround).',
                    style: theme.textTheme.bodySmall,
                  ),
                  SizedBox(height: AppTokens.space4),
                  SizedBox(
                    height: _embeddedPageHeight(context),
                    child: AppFormPage(
                      title: 'Create Sample Receipt',
                      subtitle: 'Mock workflow — no persistence',
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/dashboard');
                        }
                      },
                      actions: [
                        AppButton(
                          label: 'Save draft',
                          onPressed: () {},
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.sm,
                        ),
                        AppButton(
                          label: 'Print',
                          onPressed: () {},
                          variant: AppButtonVariant.tertiary,
                          size: AppButtonSize.sm,
                        ),
                      ],
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppFormSection(
                            title: 'Customer & Site',
                            child: AppFormFieldRow(
                              children: [
                                AppInput(
                                  label: 'Customer',
                                  controller: _pageCustomer,
                                  required: true,
                                  size: AppInputSize.sm,
                                ),
                                AppInput(
                                  label: 'Site',
                                  controller: _pageSite,
                                  size: AppInputSize.sm,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppTokens.space3),
                          AppFormSection(
                            title: 'Sample Details',
                            child: AppFormFieldRow(
                              children: [
                                AppInput(
                                  label: 'Sample ID',
                                  controller: _pageSampleId,
                                  size: AppInputSize.sm,
                                ),
                                AppInput(
                                  label: 'Received on',
                                  hint: 'DD/MM/YYYY',
                                  readOnly: true,
                                  onTap: () {},
                                  size: AppInputSize.sm,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppTokens.space3),
                          AppFormSection(
                            title: 'Tests & Parameters',
                            description: 'Line items would render here in a real screen.',
                            child: AppInput(
                              label: 'Placeholder',
                              hint: 'Nested table / grid',
                              readOnly: true,
                              size: AppInputSize.sm,
                            ),
                          ),
                          SizedBox(height: AppTokens.space3),
                          AppFormSection(
                            title: 'Notes & Attachments',
                            child: AppTextarea(
                              label: 'Notes',
                              controller: _pageNotes,
                            ),
                          ),
                        ],
                      ),
                      onCancel: () {},
                      cancelLabel: 'Cancel',
                      onSaveAndContinue: () {},
                      saveAndContinueLabel: 'Save & continue',
                      onPrimary: () {},
                      primaryLabel: 'Save',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTokens.space8),
          ],
        ),
      ),
    );
  }
}
