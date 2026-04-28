import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../design_system/components/components.dart';
import '../../design_system/components/display/kpi_metric.dart';
import '../../design_system/tokens.dart';

class UIKitScreen extends StatefulWidget {
  const UIKitScreen({super.key});

  @override
  State<UIKitScreen> createState() => _UIKitScreenState();
}

class _UIKitScreenState extends State<UIKitScreen> {
  String? _selectedDept;
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
      color: AppTokens.pageBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(label: 'TYPOGRAPHY'),
                _TypographySection(),
                _SectionHeader(label: 'COLOR PALETTE'),
                _ColorPaletteSection(),
                _SectionHeader(label: 'BUTTONS'),
                _ButtonsSection(),
                _SectionHeader(label: 'INPUT FIELDS'),
                _InputFieldsSection(
                  selectedDept: _selectedDept,
                  onDeptChanged: (v) => setState(() => _selectedDept = v),
                  selectedStatus: _selectedStatus,
                  onStatusChanged: (v) => setState(() => _selectedStatus = v),
                ),
                _SectionHeader(label: 'STATUS CHIPS'),
                _StatusChipsSection(),
                _SectionHeader(label: 'TOGGLE & SWITCH'),
                _ToggleSwitchSection(),
                _SectionHeader(label: 'KPI CARDS'),
                _KpiCardsSection(),
                _SectionHeader(label: 'FORM SECTION (live example)'),
                _FormSectionExample(),
                _SectionHeader(label: 'SHADOWS & SURFACES'),
                _ShadowsSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTokens.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Divider(color: AppTokens.borderDefault, height: 1),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section 1 — Typography
// ---------------------------------------------------------------------------

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final rows = [
      _TypoRow('Page Title', GoogleFonts.poppins(fontSize: AppTokens.pageTitleSize, fontWeight: AppTokens.pageTitleWeight, color: AppTokens.textPrimary), 'Page Title — 18px w600'),
      _TypoRow('Page Subtitle', GoogleFonts.poppins(fontSize: AppTokens.pageSubtitleSize, fontWeight: AppTokens.pageSubtitleWeight, color: AppTokens.textMuted), 'Page subtitle — 12px w400 muted'),
      _TypoRow('Section Title', GoogleFonts.poppins(fontSize: AppTokens.sectionTitleSize, fontWeight: AppTokens.sectionTitleWeight, color: AppTokens.textPrimary), 'Section Title — 12px w600'),
      _TypoRow('Field Label', GoogleFonts.poppins(fontSize: AppTokens.fieldLabelSize, fontWeight: AppTokens.fieldLabelWeight, color: AppTokens.labelColor), 'Field Label — 11px w500'),
      _TypoRow('Body', GoogleFonts.poppins(fontSize: AppTokens.bodySize, fontWeight: AppTokens.bodyWeight, color: AppTokens.textPrimary), 'Body text — 13px w400'),
      _TypoRow('Body Small', GoogleFonts.poppins(fontSize: AppTokens.bodySmSize, fontWeight: AppTokens.bodyWeight, color: AppTokens.textPrimary), 'Body small — 12px w400'),
      _TypoRow('Table Cell', GoogleFonts.poppins(fontSize: AppTokens.tableCellSize, fontWeight: AppTokens.bodyWeight, color: AppTokens.textPrimary), 'Table cell — 12px w400'),
      _TypoRow('Caption', GoogleFonts.poppins(fontSize: AppTokens.captionSize, fontWeight: AppTokens.captionWeight, color: AppTokens.textMuted), 'Caption text — 11px w400 muted'),
      _TypoRow('Chip', GoogleFonts.poppins(fontSize: AppTokens.chipSize, fontWeight: AppTokens.chipWeight, color: AppTokens.textSecondary), 'Chip label — 11px w500'),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppTokens.borderDefault),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: rows.map((r) => _buildTypoRow(r)).toList(),
        ),
      ),
    );
  }

  Widget _buildTypoRow(_TypoRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              row.name,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: AppTokens.textMuted),
            ),
          ),
          Expanded(child: Text(row.sample, style: row.style)),
        ],
      ),
    );
  }
}

class _TypoRow {
  const _TypoRow(this.name, this.style, this.sample);
  final String name;
  final TextStyle style;
  final String sample;
}

// ---------------------------------------------------------------------------
// Section 2 — Color Palette
// ---------------------------------------------------------------------------

class _ColorPaletteSection extends StatelessWidget {
  const _ColorPaletteSection();

  @override
  Widget build(BuildContext context) {
    final groups = [
      _ColorGroup('Primary', [
        _Swatch('primary800', AppTokens.primary800, '#1A2744'),
        _Swatch('primary700', AppTokens.primary700, '#1F3057'),
        _Swatch('primary600', AppTokens.primary600, '#243669'),
        _Swatch('primary100', AppTokens.primary100, '#D0D5E8'),
        _Swatch('primary50', AppTokens.primary50, '#EEF1F8'),
      ]),
      _ColorGroup('Accent', [
        _Swatch('accent500', AppTokens.accent500, '#E53935'),
        _Swatch('accent600', AppTokens.accent600, '#CC2B2B'),
        _Swatch('accent100', AppTokens.accent100, '#F5C4B3'),
      ]),
      _ColorGroup('Surface', [
        _Swatch('pageBg', AppTokens.pageBg, '#F0F2F5'),
        _Swatch('cardBg', AppTokens.cardBg, '#FFFFFF'),
        _Swatch('surfaceSubtle', AppTokens.surfaceSubtle, '#F8FAFC'),
      ]),
      _ColorGroup('Border', [
        _Swatch('borderDefault', AppTokens.borderDefault, '#E2E8F0'),
        _Swatch('borderStrong', AppTokens.borderStrong, '#CBD5E1'),
      ]),
      _ColorGroup('Text', [
        _Swatch('textPrimary', AppTokens.textPrimary, '#111827'),
        _Swatch('textSecondary', AppTokens.textSecondary, '#6B7280'),
        _Swatch('textMuted', AppTokens.textMuted, '#9CA3AF'),
        _Swatch('textDisabled', AppTokens.textDisabled, '#D1D5DB'),
      ]),
      _ColorGroup('Semantic', [
        _Swatch('success500', AppTokens.success500, '#16A34A'),
        _Swatch('success100', AppTokens.success100, '#DCFCE7'),
        _Swatch('warning500', AppTokens.warning500, '#D97706'),
        _Swatch('warning100', AppTokens.warning100, '#FEF3C7'),
        _Swatch('error500', AppTokens.error500, '#DC2626'),
        _Swatch('error100', AppTokens.error100, '#FEE2E2'),
        _Swatch('info500', AppTokens.info500, '#2563EB'),
        _Swatch('info100', AppTokens.info100, '#DBEAFE'),
      ]),
      _ColorGroup('KPI', [
        _Swatch('kpiBlue', AppTokens.kpiBlue, '#2563EB'),
        _Swatch('kpiGreen', AppTokens.kpiGreen, '#16A34A'),
        _Swatch('kpiOrange', AppTokens.kpiOrange, '#D97706'),
        _Swatch('kpiRed', AppTokens.kpiRed, '#DC2626'),
        _Swatch('kpiPurple', AppTokens.kpiPurple, '#7C3AED'),
        _Swatch('kpiTeal', AppTokens.kpiTeal, '#0891B2'),
      ]),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppTokens.borderDefault),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groups.map((g) => _buildGroup(g)).toList(),
        ),
      ),
    );
  }

  Widget _buildGroup(_ColorGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppTokens.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: group.swatches.map(_buildSwatch).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwatch(_Swatch s) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: s.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTokens.borderDefault),
          ),
        ),
        const SizedBox(height: 4),
        Text(s.name, style: GoogleFonts.poppins(fontSize: 9, color: AppTokens.textMuted)),
        Text(s.hex, style: GoogleFonts.poppins(fontSize: 9, color: AppTokens.textMuted)),
      ],
    );
  }
}

class _ColorGroup {
  const _ColorGroup(this.name, this.swatches);
  final String name;
  final List<_Swatch> swatches;
}

class _Swatch {
  const _Swatch(this.name, this.color, this.hex);
  final String name;
  final Color color;
  final String hex;
}

// ---------------------------------------------------------------------------
// Section 3 — Buttons
// ---------------------------------------------------------------------------

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppTokens.borderDefault),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowLabel('Variants'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppButton(label: 'Primary', variant: AppButtonVariant.primary, onPressed: () {}),
                AppButton(label: 'Secondary', variant: AppButtonVariant.secondary, onPressed: () {}),
                AppButton(label: 'Tertiary', variant: AppButtonVariant.tertiary, onPressed: () {}),
                AppButton(label: 'Danger', variant: AppButtonVariant.danger, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 20),
            _rowLabel('Sizes'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppButton(label: 'Small', size: AppButtonSize.sm, onPressed: () {}),
                AppButton(label: 'Medium', size: AppButtonSize.md, onPressed: () {}),
                AppButton(label: 'Large', size: AppButtonSize.lg, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 20),
            _rowLabel('States'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppButton(label: 'With Icon', icon: LucideIcons.plus, onPressed: () {}),
                AppButton(label: 'Loading', isLoading: true, onPressed: () {}),
                AppButton(label: 'Disabled', isDisabled: true, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 20),
            _rowLabel('Icon Buttons'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppIconButton(icon: const Icon(LucideIcons.plus), variant: AppIconButtonVariant.filled, onPressed: () {}, tooltip: 'Add'),
                AppIconButton(icon: const Icon(LucideIcons.pencil), variant: AppIconButtonVariant.outlined, onPressed: () {}, tooltip: 'Edit'),
                AppIconButton(icon: const Icon(LucideIcons.eye), variant: AppIconButtonVariant.ghost, onPressed: () {}, tooltip: 'View'),
                AppIconButton(icon: const Icon(LucideIcons.trash2), variant: AppIconButtonVariant.danger, onPressed: () {}, tooltip: 'Delete'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppTokens.textSecondary),
    );
  }
}

// ---------------------------------------------------------------------------
// Section 4 — Input Fields
// ---------------------------------------------------------------------------

class _InputFieldsSection extends StatelessWidget {
  const _InputFieldsSection({
    required this.selectedDept,
    required this.onDeptChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final String? selectedDept;
  final ValueChanged<String?> onDeptChanged;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;

  static const _deptItems = [
    'Administration', 'Laboratory', 'Accounts', 'Sales',
    'Operations', 'Management', 'Quality Control', 'IT',
  ];

  static const _statusItems = ['Active', 'Inactive'];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppTokens.borderDefault),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppFormFieldRow(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppInput(label: 'Full Name', hint: 'e.g. John Smith', isRequired: true),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Email Address',
                  hint: 'e.g. john@company.com',
                  prefixIcon: const Icon(LucideIcons.mail, size: 14, color: AppTokens.textMuted),
                ),
                const SizedBox(height: 16),
                const AppInput(label: 'With Error', hint: 'Enter value', errorText: 'This field is required'),
                const SizedBox(height: 16),
                const AppInput(label: 'Disabled Field', hint: 'Cannot edit', enabled: false),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSelect<String>(
                  label: 'Department',
                  hint: 'Select department',
                  isRequired: true,
                  value: selectedDept,
                  items: _deptItems.map((d) => AppSelectItem(value: d, label: d)).toList(),
                  onChanged: onDeptChanged,
                ),
                const SizedBox(height: 16),
                AppSelect<String>(
                  label: 'Status',
                  hint: 'Select status',
                  value: selectedStatus,
                  items: _statusItems.map((s) => AppSelectItem(value: s, label: s)).toList(),
                  onChanged: onStatusChanged,
                ),
                const SizedBox(height: 16),
                const AppInput(label: 'Description', hint: 'Enter description...', maxLines: 3),
                const SizedBox(height: 16),
                const AppInput(label: 'Password', hint: '••••••••', obscureText: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section 5 — Status Chips
// ---------------------------------------------------------------------------

class _StatusChipsSection extends StatelessWidget {
  const _StatusChipsSection();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppTokens.borderDefault),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            StatusChip(status: 'Active'),
            StatusChip(status: 'Inactive'),
            StatusChip(status: 'Pending'),
            StatusChip(status: 'Completed'),
            StatusChip(status: 'Cancelled'),
            StatusChip(status: 'Draft'),
            StatusChip(status: 'InReview'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section 5b — Toggle & Switch
// ---------------------------------------------------------------------------

class _ToggleSwitchSection extends StatelessWidget {
  const _ToggleSwitchSection();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.cardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppTokens.borderDefault),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSegmentedControl(
              label: 'Status',
              value: 'active',
              options: const [
                AppSegmentOption(
                  value: 'active',
                  label: 'Active',
                  icon: LucideIcons.check,
                ),
                AppSegmentOption(
                  value: 'inactive',
                  label: 'Inactive',
                  icon: LucideIcons.ban,
                ),
              ],
              onChanged: (_) {},
            ),
            SizedBox(height: AppTokens.space3),
            AppToggleSwitch(
              label: 'Show in Navigation',
              value: true,
              activeLabel: 'Enabled',
              inactiveLabel: 'Disabled',
              onChanged: (_) {},
            ),
            SizedBox(height: AppTokens.space3),
            AppToggleSwitch(
              value: false,
              activeLabel: 'Active',
              inactiveLabel: 'Inactive',
              onChanged: (_) {},
            ),
            SizedBox(height: AppTokens.space3),
            AppToggleSwitch(
              value: true,
              activeLabel: 'Active',
              inactiveLabel: 'Inactive',
              enabled: false,
              onChanged: null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section 6 — KPI Cards
// ---------------------------------------------------------------------------

class _KpiCardsSection extends StatelessWidget {
  const _KpiCardsSection();

  @override
  Widget build(BuildContext context) {
    return KpiRow(
      cards: const [
        KpiCard(label: 'Total Records', value: '248', icon: LucideIcons.database, iconColor: AppTokens.kpiBlue),
        KpiCard(label: 'Active', value: '196', icon: LucideIcons.checkCircle, iconColor: AppTokens.kpiGreen),
        KpiCard(label: 'Inactive', value: '52', icon: LucideIcons.xCircle, iconColor: AppTokens.kpiOrange),
        KpiCard(label: 'Pending Review', value: '14', icon: LucideIcons.clock, iconColor: AppTokens.kpiPurple),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 7 — Form Section live example
// ---------------------------------------------------------------------------

class _FormSectionExample extends StatefulWidget {
  const _FormSectionExample();

  @override
  State<_FormSectionExample> createState() => _FormSectionExampleState();
}

class _FormSectionExampleState extends State<_FormSectionExample> {
  String _status = 'active';

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: 'Basic Details',
      children: [
        const AppInput(
          label: 'First Name',
          hint: 'Enter first name',
          isRequired: true,
        ),
        const AppInput(
          label: 'Last Name',
          hint: 'Enter last name',
          isRequired: true,
        ),
        AppInput(
          label: 'Email',
          hint: 'Enter email address',
          prefixIcon: const Icon(LucideIcons.mail, size: 14, color: AppTokens.textMuted),
        ),
        AppInput(
          label: 'Phone',
          hint: 'Enter phone number',
          prefixIcon: const Icon(LucideIcons.phone, size: 14, color: AppTokens.textMuted),
        ),
        AppFormFullWidth(
          child: AppTextarea(
            label: 'Address',
            hint: 'Enter full address',
            minLines: 2,
            maxLines: 4,
          ),
        ),
        AppFormFullWidth(
          child: AppSegmentedControl(
            label: 'Status',
            options: const [
              AppSegmentOption(value: 'active', label: 'Active', icon: LucideIcons.check),
              AppSegmentOption(value: 'inactive', label: 'Inactive', icon: LucideIcons.ban),
            ],
            value: _status,
            onChanged: (v) => setState(() => _status = v),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 8 — Shadows & Surfaces
// ---------------------------------------------------------------------------

class _ShadowsSection extends StatelessWidget {
  const _ShadowsSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        _ShadowCard(label: 'Shadow SM', shadows: AppTokens.shadowSm),
        _ShadowCard(label: 'Shadow MD', shadows: AppTokens.shadowMd),
        _ShadowCard(label: 'Shadow LG', shadows: AppTokens.shadowLg),
      ],
    );
  }
}

class _ShadowCard extends StatelessWidget {
  const _ShadowCard({required this.label, required this.shadows});
  final String label;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: AppTokens.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: shadows,
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: AppTokens.textMuted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
