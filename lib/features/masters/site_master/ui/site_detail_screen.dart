import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/site_model.dart';
import '../state/site_provider.dart';
import 'widgets/site_header.dart';
import 'widgets/site_overview_tab.dart';

class SiteDetailScreen extends StatefulWidget {
  const SiteDetailScreen({super.key, this.siteId, this.startEdit = false});

  /// `null` when creating a site at `/sites/create`.
  final String? siteId;

  /// When true (e.g. listing row Edit), Overview opens in inline edit mode.
  final bool startEdit;

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  final GlobalKey<SiteOverviewTabState> _overviewKey =
      GlobalKey<SiteOverviewTabState>();

  bool _isEditing = false;
  bool _scheduledStartInlineEdit = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.siteId == null ? true : false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = widget.siteId;
      if (id != null) {
        context.read<SiteProvider>().fetchById(id);
      }
    });
  }

  void _scheduleInlineEditOnce() {
    if (!widget.startEdit ||
        widget.siteId == null ||
        _scheduledStartInlineEdit) {
      return;
    }
    _scheduledStartInlineEdit = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _isEditing = true);
    });
  }

  Future<void> _onSavePressed() async {
    await _overviewKey.currentState?.saveInline();
  }

  void _onCancelPressed() {
    if (widget.siteId == null) {
      context.go('/sites');
      return;
    }
    setState(() => _isEditing = false);
  }

  void _onStartEditPressed() {
    setState(() => _isEditing = true);
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<SiteProvider, bool>((p) => p.saving);
    final p = context.watch<SiteProvider>();
    final site = p.selected;

    if (widget.siteId != null) {
      if (p.isLoading && site == null) {
        return const Material(
          type: MaterialType.transparency,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (!p.isLoading && site == null) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Text(
              p.hasError
                  ? (p.error ?? 'Something went wrong')
                  : 'Site not found',
              style: GoogleFonts.poppins(
                fontSize: AppTokens.bodySize,
                color: AppTokens.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        );
      }
    }

    _scheduleInlineEditOnce();

    final SiteModel? resolvedSite = widget.siteId == null ? null : site;
    final currentLabel =
        resolvedSite?.displayName ?? resolvedSite?.code ?? 'New Site';

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Sites',
        parentRoute: '/sites',
        currentLabel: currentLabel,
        lockNonOverviewTabs: false,
        overviewTabIndex: 0,
        headerCard: SiteHeader(
          site: resolvedSite,
          isEditing: _isEditing,
          saving: saving,
          onStartEdit: _onStartEditPressed,
          onCancelEdit: _onCancelPressed,
          onSaveEdit: _onSavePressed,
        ),
        tabLabels: const ['Overview'],
        tabViews: [
          SiteOverviewTab(
            key: _overviewKey,
            site: resolvedSite,
            isEditing: _isEditing,
            onSaveSucceeded: () => setState(() => _isEditing = false),
          ),
        ],
      ),
    );
  }
}
