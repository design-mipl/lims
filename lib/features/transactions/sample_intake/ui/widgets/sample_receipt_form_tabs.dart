import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../design_system/components/components.dart';
import '../../../../../design_system/tokens.dart';
import '../../../shared/form_read_only_field.dart';

/// Sample receipt detail: merged [Overview] + [Entry Data] tabs only.
abstract final class SampleReceiptFormTabs {
  static const List<String> detailTabLabels = [
    'Overview',
    'Entry Data',
  ];

  /// Single scroll: all former section tabs merged into one 50/50 layout.
  static Widget buildMergedOverviewTab({
    required bool readOnly,
    required TextEditingController lotCtrl,
    required TextEditingController receiptDateCtrl,
    required TextEditingController receiptTimeCtrl,
    required TextEditingController courierCtrl,
    required TextEditingController podCtrl,
    required TextEditingController noSamplesCtrl,
    required TextEditingController custNameCtrl,
    required TextEditingController custCompanyCtrl,
    required TextEditingController custAddressCtrl,
    required TextEditingController custMobileCtrl,
    required TextEditingController custEmailCtrl,
    required TextEditingController siteContactCtrl,
    required TextEditingController siteCompanyCtrl,
    required TextEditingController siteAddressCtrl,
    required TextEditingController siteMobileCtrl,
    required TextEditingController siteEmailCtrl,
    required TextEditingController reportExpectedCtrl,
    required TextEditingController workOrderNoCtrl,
    required TextEditingController workOrderDateCtrl,
    required TextEditingController additionalCtrl,
    required TextEditingController freightCtrl,
    required bool dispatchedFromSite,
    required bool collectedFromCc,
    required bool receivedAtCc,
    required bool receivedAtLab,
    required void Function(bool) onDispatchedFromSite,
    required void Function(bool) onCollectedFromCc,
    required void Function(bool) onReceivedAtCc,
    required void Function(bool) onReceivedAtLab,
    String? lotError,
    String? dateError,
    String? samplesError,
    void Function(String?)? onLotErrorCleared,
    void Function(String?)? onDateErrorCleared,
    void Function(String?)? onSamplesErrorCleared,
  }) {
    Widget movementToggle({
      required String label,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: AppTokens.fieldLabelSize,
                fontWeight: AppTokens.fieldLabelWeight,
                color: AppTokens.labelColor,
              ),
            ),
          ),
          SizedBox(width: AppTokens.space2),
          AppToggleSwitch(
            value: value,
            enabled: !readOnly,
            onChanged: onChanged,
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space4),
      child: AppFormPageLayout(
        left: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: 'Basic Receipt Details',
            children: readOnly
                ? [
                    FormReadOnlyField(label: 'Lot No.', value: lotCtrl.text),
                    FormReadOnlyField(
                      label: 'Receipt Date',
                      value: receiptDateCtrl.text,
                    ),
                    FormReadOnlyField(
                      label: 'Receipt Time',
                      value: receiptTimeCtrl.text,
                    ),
                  ]
                : [
                    AppInput(
                      label: 'Lot No.',
                      hint: 'Enter lot number',
                      controller: lotCtrl,
                      isRequired: true,
                      errorText: lotError,
                      onChanged: (_) => onLotErrorCleared?.call(null),
                    ),
                    AppInput(
                      label: 'Receipt Date',
                      hint: 'YYYY-MM-DD',
                      controller: receiptDateCtrl,
                      isRequired: true,
                      errorText: dateError,
                      onChanged: (_) => onDateErrorCleared?.call(null),
                    ),
                    AppInput(
                      label: 'Receipt Time',
                      hint: 'HH:mm',
                      controller: receiptTimeCtrl,
                    ),
                  ],
          ),
          AppFormSection(
            title: 'Customer Details',
            children: readOnly
                ? [
                    FormReadOnlyField(
                      label: 'Customer',
                      value: custNameCtrl.text,
                    ),
                    FormReadOnlyField(
                      label: 'Company',
                      value: custCompanyCtrl.text,
                    ),
                    FormReadOnlyField(
                      label: 'Mobile',
                      value: custMobileCtrl.text,
                    ),
                  ]
                : [
                    AppInput(
                      label: 'Customer',
                      hint: 'Enter customer name',
                      controller: custNameCtrl,
                    ),
                    AppInput(
                      label: 'Company',
                      hint: 'Enter company name',
                      controller: custCompanyCtrl,
                    ),
                    AppInput(
                      label: 'Mobile',
                      hint: 'Enter mobile',
                      controller: custMobileCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
          ),
          AppFormSection(
            title: 'Site Details',
            children: readOnly
                ? [
                    FormReadOnlyField(
                      label: 'Site Contact Person',
                      value: siteContactCtrl.text,
                    ),
                    FormReadOnlyField(
                      label: 'Company',
                      value: siteCompanyCtrl.text,
                    ),
                    FormReadOnlyField(
                      label: 'Mobile',
                      value: siteMobileCtrl.text,
                    ),
                  ]
                : [
                    AppInput(
                      label: 'Site Contact Person',
                      hint: 'Enter contact name',
                      controller: siteContactCtrl,
                    ),
                    AppInput(
                      label: 'Company',
                      hint: 'Enter site company',
                      controller: siteCompanyCtrl,
                    ),
                    AppInput(
                      label: 'Mobile',
                      hint: 'Enter mobile',
                      controller: siteMobileCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
          ),
          AppFormSection(
            title: 'Work & Report Details',
            children: readOnly
                ? [
                    FormReadOnlyField(
                      label: 'Report Expected By',
                      value: reportExpectedCtrl.text,
                    ),
                    FormReadOnlyField(
                      label: 'Work Order No.',
                      value: workOrderNoCtrl.text,
                    ),
                  ]
                : [
                    AppInput(
                      label: 'Report Expected By',
                      hint: 'YYYY-MM-DD',
                      controller: reportExpectedCtrl,
                    ),
                    AppInput(
                      label: 'Work Order No.',
                      hint: 'Enter work order number',
                      controller: workOrderNoCtrl,
                    ),
                  ],
          ),
          AppFormSection(
            title: 'Sample Movement Tracking',
            children: readOnly
                ? [
                    FormReadOnlyField(
                      label: 'Sample Dispatched from Site',
                      value: dispatchedFromSite ? 'Yes' : 'No',
                    ),
                    FormReadOnlyField(
                      label: 'Sample Collected from Collection Center',
                      value: collectedFromCc ? 'Yes' : 'No',
                    ),
                  ]
                : [
                    AppFormFullWidth(
                      child: movementToggle(
                        label: 'Sample Dispatched from Site',
                        value: dispatchedFromSite,
                        onChanged: onDispatchedFromSite,
                      ),
                    ),
                    AppFormFullWidth(
                      child: movementToggle(
                        label: 'Sample Collected from Collection Center',
                        value: collectedFromCc,
                        onChanged: onCollectedFromCc,
                      ),
                    ),
                  ],
          ),
          AppFormSection(
            title: 'Financial Details',
            children: readOnly
                ? [
                    FormReadOnlyField(
                      label: 'Freight Charges',
                      value: freightCtrl.text,
                    ),
                  ]
                : [
                    AppInput(
                      label: 'Freight Charges',
                      hint: '0.00',
                      controller: freightCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
          ),
        ]),
        right: AppFormPageLayout.sectionsColumn([
          AppFormSection(
            title: '\u200b',
            children: readOnly
                ? [
                    FormReadOnlyField(
                      label: 'Courier Name',
                      value: courierCtrl.text,
                    ),
                    FormReadOnlyField(label: 'POD No.', value: podCtrl.text),
                    FormReadOnlyField(
                      label: 'No. of Samples',
                      value: noSamplesCtrl.text,
                    ),
                  ]
                : [
                    AppInput(
                      label: 'Courier Name',
                      hint: 'Enter courier',
                      controller: courierCtrl,
                    ),
                    AppInput(
                      label: 'POD No.',
                      hint: 'Enter POD number',
                      controller: podCtrl,
                    ),
                    AppInput(
                      label: 'No. of Samples',
                      hint: 'Enter number of samples',
                      controller: noSamplesCtrl,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      errorText: samplesError,
                      onChanged: (_) => onSamplesErrorCleared?.call(null),
                    ),
                  ],
          ),
          AppFormSection(
            title: '\u200b',
            children: readOnly
                ? [
                    AppFormFullWidth(
                      child: FormReadOnlyField(
                        label: 'Address',
                        value: custAddressCtrl.text,
                      ),
                    ),
                    FormReadOnlyField(
                      label: 'Email',
                      value: custEmailCtrl.text,
                    ),
                  ]
                : [
                    AppFormFullWidth(
                      child: AppInput(
                        label: 'Address',
                        hint: 'Enter address',
                        controller: custAddressCtrl,
                      ),
                    ),
                    AppInput(
                      label: 'Email',
                      hint: 'Enter email',
                      controller: custEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
          ),
          AppFormSection(
            title: '\u200b',
            children: readOnly
                ? [
                    AppFormFullWidth(
                      child: FormReadOnlyField(
                        label: 'Address',
                        value: siteAddressCtrl.text,
                      ),
                    ),
                    FormReadOnlyField(
                      label: 'Email',
                      value: siteEmailCtrl.text,
                    ),
                  ]
                : [
                    AppFormFullWidth(
                      child: AppInput(
                        label: 'Address',
                        hint: 'Enter site address',
                        controller: siteAddressCtrl,
                      ),
                    ),
                    AppInput(
                      label: 'Email',
                      hint: 'Enter email',
                      controller: siteEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
          ),
          AppFormSection(
            title: '\u200b',
            children: readOnly
                ? [
                    FormReadOnlyField(
                      label: 'Work Order Date',
                      value: workOrderDateCtrl.text,
                    ),
                    AppFormFullWidth(
                      child: FormReadOnlyField(
                        label: 'Additional Information',
                        value: additionalCtrl.text,
                      ),
                    ),
                  ]
                : [
                    AppInput(
                      label: 'Work Order Date',
                      hint: 'YYYY-MM-DD',
                      controller: workOrderDateCtrl,
                    ),
                    AppFormFullWidth(
                      child: AppTextarea(
                        label: 'Additional Information',
                        hint: 'Notes for the lab',
                        controller: additionalCtrl,
                        maxLines: 4,
                      ),
                    ),
                  ],
          ),
          AppFormSection(
            title: '\u200b',
            children: readOnly
                ? [
                    FormReadOnlyField(
                      label: 'Sample Received at Collection Center',
                      value: receivedAtCc ? 'Yes' : 'No',
                    ),
                    FormReadOnlyField(
                      label: 'Sample Received at Lab',
                      value: receivedAtLab ? 'Yes' : 'No',
                    ),
                  ]
                : [
                    AppFormFullWidth(
                      child: movementToggle(
                        label: 'Sample Received at Collection Center',
                        value: receivedAtCc,
                        onChanged: onReceivedAtCc,
                      ),
                    ),
                    AppFormFullWidth(
                      child: movementToggle(
                        label: 'Sample Received at Lab',
                        value: receivedAtLab,
                        onChanged: onReceivedAtLab,
                      ),
                    ),
                  ],
          ),
          AppFormSection(
            title: '\u200b',
            children: [SizedBox(height: AppTokens.space1)],
          ),
        ]),
      ),
    );
  }
}
