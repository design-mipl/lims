import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../state/action_taken_provider.dart';

/// Full-page workspace for entering corrective action (opened from listing row tap).
class ActionTakenWorkspaceScreen extends StatefulWidget {
  const ActionTakenWorkspaceScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<ActionTakenWorkspaceScreen> createState() =>
      _ActionTakenWorkspaceScreenState();
}

class _ActionTakenWorkspaceScreenState extends State<ActionTakenWorkspaceScreen> {
  ActionTakenProvider? _provider;

  late final TextEditingController _commentsCtrl;
  late final TextEditingController _recommendationCtrl;
  late final TextEditingController _actionTakenCtrl;

  static final EdgeInsets _workspaceFieldPadding = EdgeInsets.symmetric(
    horizontal: AppTokens.space3,
    vertical: AppTokens.space3,
  );

  @override
  void initState() {
    super.initState();
    _commentsCtrl = TextEditingController();
    _recommendationCtrl = TextEditingController();
    _actionTakenCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<ActionTakenProvider>();
      _provider!.addListener(_onProviderChanged);
      await _provider!.loadWorkspace(widget.itemId);
      if (!mounted) return;
      final draft = _provider!.workspaceDraft;
      if (draft != null) {
        _commentsCtrl.text = draft.comments;
        _recommendationCtrl.text = draft.recommendation;
        _actionTakenCtrl.text = draft.actionTaken;
        setState(() {});
      }
    });
  }

  void _onProviderChanged() {
    final pr = _provider;
    if (pr == null || !pr.hasError || !mounted) return;
    final message = pr.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      pr.clearError();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    _commentsCtrl.dispose();
    _recommendationCtrl.dispose();
    _actionTakenCtrl.dispose();
    super.dispose();
  }

  void _onCancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/transactions/action-taken');
    }
  }

  Future<void> _onSave(ActionTakenProvider p) async {
    await p.saveWorkspace(
      comments: _commentsCtrl.text,
      recommendation: _recommendationCtrl.text,
      actionTaken: _actionTakenCtrl.text,
    );
    if (!mounted || p.hasError) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Action workspace saved',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ActionTakenProvider>();
    final row = p.workspaceRow;

    if (p.isLoading && row == null) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: SizedBox(
            width: AppTokens.inlineProgressIndicatorSize + AppTokens.space3,
            height: AppTokens.inlineProgressIndicatorSize + AppTokens.space3,
            child: CircularProgressIndicator(
              strokeWidth: AppTokens.inlineProgressIndicatorStrokeWidth,
              color: AppTokens.primary800,
            ),
          ),
        ),
      );
    }

    if (row == null || row.id != widget.itemId) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Record not found',
                style: GoogleFonts.poppins(
                  fontSize: AppTokens.bodySize,
                  color: AppTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppTokens.space3),
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.primary,
                onPressed: _onCancel,
              ),
            ],
          ),
        ),
      );
    }

    final draft = p.workspaceDraft;
    final theme = Theme.of(context);
    final cardSurface = theme.brightness == Brightness.dark
        ? theme.cardColor
        : AppTokens.cardBg;
    final cardBorder = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.borderDefault;

    final sectionTitleStyle = GoogleFonts.poppins(
      fontSize: AppTokens.sectionTitleSize,
      fontWeight: AppTokens.sectionTitleWeight,
      color: theme.brightness == Brightness.dark
          ? theme.colorScheme.onSurface
          : AppTokens.textPrimary,
    );

    final workspaceCard = DecoratedBox(
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: cardBorder,
          width: AppTokens.borderWidthSm,
        ),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Action Workspace',
              style: sectionTitleStyle,
            ),
            SizedBox(height: AppTokens.space3),
            AppInput(
              label: 'Comments',
              controller: _commentsCtrl,
              maxLines: 8,
              minLines: 4,
              size: AppInputSize.md,
              contentPadding: _workspaceFieldPadding,
              textAlignVertical: TextAlignVertical.center,
            ),
            SizedBox(height: AppTokens.space3),
            AppInput(
              label: 'Recommendation',
              controller: _recommendationCtrl,
              maxLines: 8,
              minLines: 4,
              size: AppInputSize.md,
              contentPadding: _workspaceFieldPadding,
              textAlignVertical: TextAlignVertical.center,
            ),
            SizedBox(height: AppTokens.space3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: AppInput(
                    label: 'Action taken',
                    hint: 'Enter corrective action…',
                    controller: _actionTakenCtrl,
                    maxLines: 8,
                    minLines: 4,
                    size: AppInputSize.md,
                    contentPadding: _workspaceFieldPadding,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
                SizedBox(width: AppTokens.space4),
                SizedBox(
                  width: 148,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Action date',
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.fieldLabelSize,
                          fontWeight: AppTokens.fieldLabelWeight,
                          color: AppTokens.labelColor,
                        ),
                      ),
                      SizedBox(height: AppTokens.space1),
                      LabCodeLabIdDateField(
                        hint: 'Select date',
                        selectedDate: draft?.actionDate,
                        onDateSelected: p.setWorkspaceActionDate,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final body = SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppTokens.space4,
        right: AppTokens.space4,
        bottom: AppTokens.space4,
      ),
      child: workspaceCard,
    );

    final companyLabel = GoogleFonts.poppins(
      fontSize: AppTokens.textSm,
      fontWeight: AppTokens.weightMedium,
      color: AppTokens.textMuted,
    );
    final companyValue = GoogleFonts.poppins(
      fontSize: AppTokens.textSm,
      color: AppTokens.textPrimary,
    );

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Action Taken',
        parentRoute: '/transactions/action-taken',
        currentLabel: row.labId,
        tabController: null,
        plainTabPanel: true,
        headerCard: Padding(
          padding: EdgeInsets.symmetric(vertical: AppTokens.space1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppAvatar(
                name: row.labId,
                size: AppAvatarSize.md,
              ),
              SizedBox(width: AppTokens.space2),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        '${row.labId} · Workspace',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.bodySize,
                          fontWeight: AppTokens.weightSemibold,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTokens.space2),
                    Icon(
                      LucideIcons.clipboardList,
                      size: AppTokens.iconButtonIconSm,
                      color: AppTokens.textMuted,
                    ),
                    SizedBox(width: AppTokens.space1),
                    Flexible(
                      flex: 2,
                      child: Text(
                        'Corrective action entry',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: AppTokens.textSm,
                          color: AppTokens.textMuted,
                          fontWeight: AppTokens.weightRegular,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTokens.space3),
                    Text('Company:', style: companyLabel),
                    SizedBox(width: AppTokens.space1),
                    Flexible(
                      flex: 3,
                      child: Text(
                        row.companyName.isEmpty ? '—' : row.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: companyValue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppTokens.space3),
              AppButton(
                label: 'Save',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.md,
                onPressed: () => _onSave(p),
              ),
            ],
          ),
        ),
        tabLabels: const ['Workspace'],
        tabViews: [
          body,
        ],
      ),
    );
  }
}
