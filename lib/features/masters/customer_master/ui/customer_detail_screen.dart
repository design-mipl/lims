import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../state/customer_provider.dart';
import 'widgets/contacts_tab.dart';
import 'widgets/customer_header.dart';
import 'widgets/overview_tab.dart';
import 'widgets/sample_types_tab.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    this.initialTab = 'overview',
    this.startInlineEdit = false,
  });

  final String customerId;
  final String initialTab;

  /// When true (e.g. listing row Edit), Overview opens in inline edit mode.
  final bool startInlineEdit;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<OverviewTabState> _overviewKey = GlobalKey<OverviewTabState>();

  late final TabController _tabController;

  bool _isEditing = false;
  bool _scheduledStartInlineEdit = false;

  void _onTabLock() {
    if (_isEditing && !_tabController.indexIsChanging) return;
    if (_isEditing &&
        _tabController.indexIsChanging &&
        _tabController.index != 0) {
      _tabController.index = 0;
    }
  }

  int get _initialTabIndex {
    switch (widget.initialTab) {
      case 'contacts':
        return 1;
      case 'samples':
        return 2;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _initialTabIndex,
    );
    _tabController.addListener(_onTabLock);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CustomerProvider>().fetchById(widget.customerId);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabLock);
    _tabController.dispose();
    super.dispose();
  }

  void _scheduleInlineEditOnce() {
    if (!widget.startInlineEdit ||
        !_initialTabIsOverview ||
        _scheduledStartInlineEdit) {
      return;
    }
    _scheduledStartInlineEdit = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _isEditing = true);
      if (_tabController.index != 0) {
        _tabController.index = 0;
      }
    });
  }

  bool get _initialTabIsOverview =>
      widget.initialTab == 'overview' || widget.initialTab.isEmpty;

  Future<void> _onSavePressed() async {
    await _overviewKey.currentState?.saveInline();
  }

  void _onCancelPressed() {
    setState(() => _isEditing = false);
  }

  void _onStartEditPressed() {
    setState(() => _isEditing = true);
    if (_tabController.index != 0) {
      _tabController.index = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<CustomerProvider, bool>((p) => p.saving);
    final p = context.watch<CustomerProvider>();
    final customer = p.selected;
    if (p.isLoading && customer == null) {
      return const Material(
        type: MaterialType.transparency,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (customer == null) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Text(
            'Customer not found',
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.textPrimary,
            ),
          ),
        ),
      );
    }

    _scheduleInlineEditOnce();

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Customers',
        parentRoute: '/customers',
        currentLabel: customer.companyName,
        tabController: _tabController,
        lockNonOverviewTabs: _isEditing,
        overviewTabIndex: 0,
        headerCard: CustomerHeader(
          customer: customer,
          isEditing: _isEditing,
          saving: saving,
          onStartEdit: _onStartEditPressed,
          onCancelEdit: _onCancelPressed,
          onSaveEdit: _onSavePressed,
        ),
        tabLabels: const [
          'Overview',
          'Contacts',
          'Sample Types',
        ],
        tabViews: [
          OverviewTab(
            key: _overviewKey,
            customer: customer,
            isEditing: _isEditing,
            onSaveSucceeded: () => setState(() => _isEditing = false),
          ),
          ContactsTab(customerId: customer.id),
          SampleTypesTab(customerId: customer.id),
        ],
      ),
    );
  }
}
