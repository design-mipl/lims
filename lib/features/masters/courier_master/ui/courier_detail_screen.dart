import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import '../data/courier_model.dart';
import '../state/courier_provider.dart';
import 'courier_validation.dart';
import 'widgets/courier_area_tab.dart';
import 'widgets/courier_contact_tab.dart';
import 'widgets/courier_header.dart';
import 'widgets/courier_overview_tab.dart';

class CourierDetailScreen extends StatefulWidget {
  const CourierDetailScreen({
    super.key,
    this.courierId,
    this.startEdit = false,
  });

  final String? courierId;

  /// When true (e.g. listing row Edit), detail opens in inline edit mode.
  final bool startEdit;

  @override
  State<CourierDetailScreen> createState() => _CourierDetailScreenState();
}

class _CourierDetailScreenState extends State<CourierDetailScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<CourierOverviewTabState> _overviewKey =
      GlobalKey<CourierOverviewTabState>();

  late final TabController _tabController;

  bool _isEditing = false;
  bool _scheduledStartInlineEdit = false;

  List<CourierAreaMapping> _areas = [];
  List<CourierContactMapping> _contacts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isEditing = widget.courierId == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = widget.courierId;
      if (id != null) {
        context.read<CourierProvider>().fetchById(id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _scheduleInlineEditOnce() {
    if (!widget.startEdit ||
        widget.courierId == null ||
        _scheduledStartInlineEdit) {
      return;
    }
    _scheduledStartInlineEdit = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = context.read<CourierProvider>().selected;
      setState(() {
        _isEditing = true;
        if (c != null) {
          _areas = List<CourierAreaMapping>.from(c.areaMappings);
          _contacts = List<CourierContactMapping>.from(c.contactMappings);
        }
      });
    });
  }

  List<CourierAreaMapping> _cleanAreas(List<CourierAreaMapping> raw) {
    return raw.where((a) {
      final emptyArea = a.area.trim().isEmpty;
      final emptySite = a.siteId == null || a.siteId!.isEmpty;
      return !(emptyArea && emptySite);
    }).toList();
  }

  List<CourierContactMapping> _cleanContacts(List<CourierContactMapping> raw) {
    return raw.where((c) {
      final pn = c.contactPerson.trim();
      final mob = c.mobile.trim();
      final em = c.email?.trim() ?? '';
      return pn.isNotEmpty || mob.isNotEmpty || em.isNotEmpty;
    }).toList();
  }

  String? _mappingValidationMessage(
    List<CourierAreaMapping> rawAreas,
    List<CourierContactMapping> rawContacts,
  ) {
    final areas = _cleanAreas(rawAreas);
    for (final a in areas) {
      if (a.area.trim().isEmpty) {
        return 'Each area mapping needs an area name.';
      }
    }
    final keys = <String>{};
    for (final a in areas) {
      final key =
          '${a.area.trim().toLowerCase()}|${a.siteId ?? ''}';
      if (keys.contains(key)) {
        return 'Duplicate area and site combination.';
      }
      keys.add(key);
    }

    final contacts = _cleanContacts(rawContacts);
    for (final row in contacts) {
      if (row.contactPerson.trim().isEmpty || row.mobile.trim().isEmpty) {
        return 'Contact mappings need contact person and mobile.';
      }
      if (!CourierValidators.mobileRequiredValid(row.mobile)) {
        return 'Enter valid 10-digit mobiles for all contacts.';
      }
      if (!CourierValidators.emailOptionalValid(row.email ?? '')) {
        return 'Enter valid emails for contacts.';
      }
    }

    return null;
  }

  Future<void> _onSavePressed() async {
    final messenger = ScaffoldMessenger.of(context);
    final prov = context.read<CourierProvider>();
    final excludeId = widget.courierId;

    final overview = _overviewKey.currentState?.validateAndCollectPayload(
      prov,
      excludeId,
    );
    if (overview == null) return;

    final mapErr = _mappingValidationMessage(_areas, _contacts);
    if (mapErr != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            mapErr,
            style: GoogleFonts.poppins(
              fontSize: AppTokens.bodySize,
              color: AppTokens.white,
            ),
          ),
          backgroundColor: AppTokens.error500,
        ),
      );
      return;
    }

    final cleanedAreas = _cleanAreas(_areas);
    final cleanedContacts = _cleanContacts(_contacts);

    final persisted = prov.selected;
    final payload = <String, dynamic>{
      ...overview,
      'areaMappings': cleanedAreas.map((e) => e.toJson()).toList(),
      'contactMappings': cleanedContacts.map((e) => e.toJson()).toList(),
      'status': persisted?.status ?? 'active',
    };

    if (widget.courierId == null) {
      final created = await prov.create(payload);
      if (!mounted || created == null || prov.hasError) return;
      context.go('/couriers/${created.id}');
      return;
    }

    await prov.update(widget.courierId!, payload);
    if (!mounted || prov.hasError) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Courier updated',
          style: GoogleFonts.poppins(
            fontSize: AppTokens.bodySize,
            color: AppTokens.white,
          ),
        ),
        backgroundColor: AppTokens.primary800,
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      _isEditing = false;
      final c = prov.selected;
      if (c != null) {
        _areas = List<CourierAreaMapping>.from(c.areaMappings);
        _contacts = List<CourierContactMapping>.from(c.contactMappings);
      }
    });
  }

  Future<void> _onCancelPressed() async {
    if (widget.courierId == null) {
      context.go('/couriers');
      return;
    }
    final id = widget.courierId!;
    await context.read<CourierProvider>().fetchById(id);
    if (!mounted) return;
    final c = context.read<CourierProvider>().selected;
    setState(() {
      _isEditing = false;
      if (c != null) {
        _areas = List<CourierAreaMapping>.from(c.areaMappings);
        _contacts = List<CourierContactMapping>.from(c.contactMappings);
      }
    });
  }

  void _onStartEditPressed() {
    final c = context.read<CourierProvider>().selected;
    setState(() {
      _isEditing = true;
      if (c != null) {
        _areas = List<CourierAreaMapping>.from(c.areaMappings);
        _contacts = List<CourierContactMapping>.from(c.contactMappings);
      }
    });
    if (_tabController.index != 0) {
      _tabController.index = 0;
    }
  }

  String _currentLabel(CourierModel? courier) {
    if (widget.courierId == null) return 'New Courier';
    if (courier == null) return 'Courier';
    return courier.companyName.trim().isNotEmpty
        ? courier.companyName
        : courier.personName;
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<CourierProvider, bool>((p) => p.saving);
    final p = context.watch<CourierProvider>();
    final courier =
        widget.courierId == null ? null : p.selected;

    if (widget.courierId != null) {
      if (p.isLoading && courier == null) {
        return const Material(
          type: MaterialType.transparency,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (!p.isLoading && courier == null) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Text(
              p.hasError
                  ? (p.error ?? 'Something went wrong')
                  : 'Courier not found',
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

    final areaRows =
        _isEditing ? _areas : (courier?.areaMappings ?? const []);
    final contactRows = _isEditing
        ? _contacts
        : (courier?.contactMappings ?? const []);

    return Material(
      type: MaterialType.transparency,
      child: DetailTemplate(
        parentLabel: 'Couriers',
        parentRoute: '/couriers',
        currentLabel: _currentLabel(courier),
        tabController: _tabController,
        lockNonOverviewTabs: false,
        overviewTabIndex: 0,
        headerCard: CourierHeader(
          courier: courier,
          isEditing: _isEditing,
          saving: saving,
          onStartEdit: _onStartEditPressed,
          onCancelEdit: _onCancelPressed,
          onSaveEdit: _onSavePressed,
        ),
        tabLabels: const [
          'Overview',
          'Area Mapping',
          'Contact Mapping',
        ],
        tabViews: [
          CourierOverviewTab(
            key: _overviewKey,
            courier: courier,
            isEditing: _isEditing,
          ),
          CourierAreaTab(
            areas: areaRows,
            isEditing: _isEditing,
            onAreasChanged: _isEditing
                ? (next) => setState(() => _areas = next)
                : null,
          ),
          CourierContactTab(
            contacts: contactRows,
            isEditing: _isEditing,
            onContactsChanged: _isEditing
                ? (next) => setState(() => _contacts = next)
                : null,
          ),
        ],
      ),
    );
  }
}
