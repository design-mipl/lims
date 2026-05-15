import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/supervisor_review_workspace_model.dart';
import '../state/supervisor_comments_provider.dart';
import 'supervisor_review_workspace_grouped_table.dart';

/// Full-page supervisor review workspace (test parameters + analysis).
class SupervisorReviewWorkspaceScreen extends StatefulWidget {
  const SupervisorReviewWorkspaceScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<SupervisorReviewWorkspaceScreen> createState() =>
      _SupervisorReviewWorkspaceScreenState();
}

class _SupervisorReviewWorkspaceScreenState
    extends State<SupervisorReviewWorkspaceScreen> {
  SupervisorCommentsProvider? _provider;
  final _problemCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();
  final _recommendationCtrl = TextEditingController();
  String? _boundWorkspaceId;
  bool _problemUserEdited = false;

  DateTime? _reportDate;
  String _severityFilter = '';

  static const double _wSev = 96;
  static const double _wName = 224;
  static const double _wVal = 104;
  static const double _wLim = 112;
  static const double _wFresh = 136;
  static const double _wTyp = 104;
  static const double _wHi = 104;
  static const double _wRep = 104;
  static const double _wChem = 160;
  static const double _wHistMerged = 132;

  List<double> _columnWidths(SupervisorReviewWorkspace ws) {
    final widths = <double>[
      _wSev,
      _wName,
      _wVal,
      _wLim,
      _wLim,
      _wLim,
      _wLim,
      _wLim,
      _wLim,
      _wFresh,
      _wTyp,
      _wHi,
      _wRep,
      _wChem,
    ];
    for (var i = 0; i < ws.historicalComparisonHeaders.length; i++) {
      widths.add(_wHistMerged);
    }
    return widths;
  }

  List<String> _columnLabels(SupervisorReviewWorkspace ws) {
    return [
      'Severity',
      'Test Name',
      'Value',
      'Min Value',
      'Max Value',
      'Customer Min',
      'Customer Max',
      'Fluid Min',
      'Fluid Max',
      'Fresh Fluid Value',
      'Typical',
      'Highlight',
      'Report',
      'Chemist',
      ...ws.historicalComparisonHeaders,
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<SupervisorCommentsProvider>();
      _provider!.addListener(_onProviderChanged);
      await _provider!.loadReviewWorkspace(widget.itemId);
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
    _problemCtrl.dispose();
    _commentsCtrl.dispose();
    _recommendationCtrl.dispose();
    _provider?.removeListener(_onProviderChanged);
    super.dispose();
  }

  String _derivedProblemText(List<SupervisorReviewTestLine> lines) {
    final names = <String>[];
    for (final line in lines) {
      if (line.severity == SupervisorReviewSeverity.critical ||
          line.severity == SupervisorReviewSeverity.warning) {
        names.add(line.parameterName);
      }
    }
    return names.join(', ');
  }

  void _scheduleDerivedProblemSync(SupervisorReviewWorkspace ws) {
    if (_problemUserEdited) return;
    final derived = _derivedProblemText(ws.lines);
    if (_problemCtrl.text != derived) {
      _problemCtrl.text = derived;
    }
    if (ws.problem != derived) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _problemUserEdited) return;
        final pr = context.read<SupervisorCommentsProvider>();
        final w = pr.reviewWorkspace;
        if (w?.supervisorCommentsId != ws.supervisorCommentsId) return;
        if (w!.problem != derived) {
          pr.updateReviewWorkspace(w.copyWith(problem: derived));
        }
      });
    }
  }

  void _syncAnalysisFields(SupervisorReviewWorkspace? ws) {
    if (ws == null) return;
    if (_boundWorkspaceId != ws.supervisorCommentsId) {
      _boundWorkspaceId = ws.supervisorCommentsId;
      _problemUserEdited = false;
      _problemCtrl.text = ws.problem;
      _commentsCtrl.text = ws.comments;
      _recommendationCtrl.text = ws.recommendation;
      _reportDate = null;
      _severityFilter = '';
    }
  }

  bool _linePassesFilters(SupervisorReviewTestLine line) {
    if (_reportDate != null) {
      final want = DateTime(
        _reportDate!.year,
        _reportDate!.month,
        _reportDate!.day,
      );
      final got = DateTime(
        line.recordedOn.year,
        line.recordedOn.month,
        line.recordedOn.day,
      );
      if (got != want) return false;
    }
    if (_severityFilter.isNotEmpty) {
      final want = switch (_severityFilter) {
        'critical' => SupervisorReviewSeverity.critical,
        'caution' => SupervisorReviewSeverity.warning,
        'normal' => SupervisorReviewSeverity.normal,
        _ => null,
      };
      if (want != null && line.severity != want) return false;
    }
    return true;
  }

  List<SupervisorReviewTestLine> _sortedForGroupedDisplay(
    List<SupervisorReviewTestLine> lines,
  ) {
    final methodKeys = <String>[];
    final seen = <String>{};
    for (final l in lines) {
      final k = l.methodGroup.trim().isEmpty ? 'General' : l.methodGroup.trim();
      if (seen.add(k)) methodKeys.add(k);
    }
    final rank = {for (var i = 0; i < methodKeys.length; i++) methodKeys[i]: i};
    final copy = [...lines];
    copy.sort((a, b) {
      final ma = a.methodGroup.trim().isEmpty ? 'General' : a.methodGroup.trim();
      final mb = b.methodGroup.trim().isEmpty ? 'General' : b.methodGroup.trim();
      final c = rank[ma]!.compareTo(rank[mb]!);
      if (c != 0) return c;
      return a.parameterName.compareTo(b.parameterName);
    });
    return copy;
  }

  List<SupervisorReviewTestLine> _filteredLines(
    List<SupervisorReviewTestLine> lines,
  ) {
    return _sortedForGroupedDisplay(lines.where(_linePassesFilters).toList());
  }

  Color? _severityRowBackground(SupervisorReviewTestLine r) {
    switch (r.severity) {
      case SupervisorReviewSeverity.critical:
        return Color.alphaBlend(
          AppTokens.error100.withValues(alpha: 0.78),
          AppTokens.cardBg,
        );
      case SupervisorReviewSeverity.warning:
        return Color.alphaBlend(
          AppTokens.warning100.withValues(alpha: 0.72),
          AppTokens.cardBg,
        );
      case SupervisorReviewSeverity.normal:
        return null;
    }
  }

  void _onPrint() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Print queued (UI only)',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  Future<void> _onSave(SupervisorCommentsProvider pr) async {
    final ws = pr.reviewWorkspace;
    if (ws == null) return;
    pr.updateReviewWorkspace(
      ws.copyWith(
        problem: _problemCtrl.text,
        comments: _commentsCtrl.text,
        recommendation: _recommendationCtrl.text,
      ),
    );
    await pr.saveReviewDraft();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
      ),
    );
  }

  static final EdgeInsets _analysisFieldPadding = EdgeInsets.symmetric(
    horizontal: AppTokens.space3,
    vertical: AppTokens.space4,
  );

  Widget _analysisFields(BuildContext context, SupervisorCommentsProvider pr) {
    final theme = Theme.of(context);
    final surface = theme.brightness == Brightness.dark
        ? theme.cardColor
        : AppTokens.cardBg;
    final borderColor = theme.brightness == Brightness.dark
        ? AppTokens.neutral700
        : AppTokens.borderDefault;

    final titleStyle = GoogleFonts.poppins(
      fontSize: AppTokens.sectionTitleSize,
      fontWeight: AppTokens.sectionTitleWeight,
      color: theme.brightness == Brightness.dark
          ? theme.colorScheme.onSurface
          : AppTokens.textPrimary,
      decoration: TextDecoration.none,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: borderColor,
          width: AppTokens.borderWidthSm,
        ),
        boxShadow: AppTokens.shadowSm,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Analysis', style: titleStyle),
            SizedBox(height: AppTokens.space3),
            AppInput(
              label: 'Problem',
              hint: 'Comma-separated flagged tests…',
              controller: _problemCtrl,
              maxLines: 3,
              minLines: 2,
              size: AppInputSize.md,
              contentPadding: _analysisFieldPadding,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (_) {
                _problemUserEdited = true;
                final w = pr.reviewWorkspace;
                if (w == null) return;
                pr.updateReviewWorkspace(w.copyWith(problem: _problemCtrl.text));
              },
            ),
            SizedBox(height: AppTokens.space3),
            AppInput(
              label: 'Comments',
              hint: 'Supervisor comments…',
              controller: _commentsCtrl,
              maxLines: 3,
              minLines: 2,
              size: AppInputSize.md,
              contentPadding: _analysisFieldPadding,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (_) {
                final w = pr.reviewWorkspace;
                if (w == null) return;
                pr.updateReviewWorkspace(w.copyWith(comments: _commentsCtrl.text));
              },
            ),
            SizedBox(height: AppTokens.space3),
            AppInput(
              label: 'Recommendation',
              hint: 'Recommendation…',
              controller: _recommendationCtrl,
              maxLines: 3,
              minLines: 2,
              size: AppInputSize.md,
              contentPadding: _analysisFieldPadding,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (_) {
                final w = pr.reviewWorkspace;
                if (w == null) return;
                pr.updateReviewWorkspace(
                  w.copyWith(recommendation: _recommendationCtrl.text),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pr = context.watch<SupervisorCommentsProvider>();
    final row = pr.reviewSampleRow;
    final ws = pr.reviewWorkspace;
    _syncAnalysisFields(ws);
    if (ws != null) {
      _scheduleDerivedProblemSync(ws);
    }

    if (pr.isLoading && (row == null || ws == null)) {
      return const Material(
        type: MaterialType.transparency,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (row == null ||
        ws == null ||
        ws.supervisorCommentsId != widget.itemId) {
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
                label: 'Back',
                variant: AppButtonVariant.primary,
                onPressed: () => context.go('/transactions/supervisor-review'),
              ),
            ],
          ),
        ),
      );
    }

    final tableRows = _filteredLines(ws.lines);

    final toolbarRow = SizedBox(
      height: AppTokens.listingToolbarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    LabCodeLabIdDateField(
                      hint: 'Report Date',
                      selectedDate: _reportDate,
                      onDateSelected: (d) => setState(() {
                        _reportDate = d;
                      }),
                    ),
                    SizedBox(width: AppTokens.space2),
                    SizedBox(
                      width: 160,
                      height: AppTokens.inputHeight,
                      child: AppSelect<String>(
                        hint: 'Severity',
                        value:
                            _severityFilter.isEmpty ? null : _severityFilter,
                        items: const [
                          AppSelectItem(value: '', label: 'All'),
                          AppSelectItem(value: 'critical', label: 'Critical'),
                          AppSelectItem(value: 'caution', label: 'Cautious'),
                          AppSelectItem(value: 'normal', label: 'Normal'),
                        ],
                        onChanged: (v) => setState(() {
                          _severityFilter = v ?? '';
                        }),
                        size: AppInputSize.sm,
                        isSearchable: false,
                        overlayWidthMatchesTrigger: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: AppTokens.space2),
          AppButton(
            label: 'Print',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.md,
            onPressed: pr.isLoading ? null : _onPrint,
          ),
          SizedBox(width: AppTokens.space2),
          AppButton(
            label: 'Save',
            variant: AppButtonVariant.primary,
            size: AppButtonSize.md,
            onPressed: pr.isLoading ? null : () => _onSave(pr),
            isLoading: pr.isLoading,
          ),
        ],
      ),
    );

    final horizontalInset = AppTokens.space5;

    final pageBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalInset,
            0,
            horizontalInset,
            AppTokens.space2,
          ),
          child: toolbarRow,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalInset,
              0,
              horizontalInset,
              AppTokens.space3,
            ),
            child: SupervisorReviewWorkspaceGroupedTable(
              columnWidths: _columnWidths(ws),
              columnLabels: _columnLabels(ws),
              rows: tableRows,
              provider: pr,
              rowBackgroundColor: _severityRowBackground,
              emptyMessage: 'No test parameters',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalInset,
            0,
            horizontalInset,
            AppTokens.space4,
          ),
          child: _analysisFields(context, pr),
        ),
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Supervisor Review',
        parentRoute: '/transactions/supervisor-review',
        currentLabel: 'Supervisor Review Workspace',
        headerCard: null,
        plainTabPanel: true,
        tabController: null,
        tabLabels: const ['Overview'],
        tabViews: [
          pageBody,
        ],
      ),
    );
  }
}
