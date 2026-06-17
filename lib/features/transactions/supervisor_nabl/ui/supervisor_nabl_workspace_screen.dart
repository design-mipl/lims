import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens.dart';
import 'nabl_no_listing_pane.dart';
import 'supervisor_comments_listing_pane.dart';

/// Combined Supervisor Comments + NABL No. shell with primary module tabs.
class SupervisorNablWorkspaceScreen extends StatefulWidget {
  const SupervisorNablWorkspaceScreen({super.key});

  @override
  State<SupervisorNablWorkspaceScreen> createState() =>
      _SupervisorNablWorkspaceScreenState();
}

class _SupervisorNablWorkspaceScreenState
    extends State<SupervisorNablWorkspaceScreen> {
  int _primaryTab = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space5,
              AppTokens.space4,
              AppTokens.space5,
              AppTokens.space2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _primaryTab == 0 ? 'Supervisor Comments' : 'NABL No.',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.pageTitleSize,
                    fontWeight: AppTokens.pageTitleWeight,
                    color: AppTokens.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: AppTokens.space1),
                Text(
                  _primaryTab == 0
                      ? 'Review and complete supervisor comments on sample rows post-verification.'
                      : 'Track NABL registrations and laboratory code linkage for reports.',
                  style: GoogleFonts.poppins(
                    fontSize: AppTokens.pageSubtitleSize,
                    fontWeight: AppTokens.pageSubtitleWeight,
                    color: AppTokens.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          ListingTabStrip(
            tabs: const [
              TabConfig(label: 'Supervisor Comments'),
              TabConfig(label: 'NABL No.'),
            ],
            selected: _primaryTab,
            onSelect: (i) => setState(() => _primaryTab = i),
          ),
          Expanded(
            child: IndexedStack(
              index: _primaryTab,
              children: const [
                SupervisorCommentsListingPane(showPageHeader: false),
                NablNoListingPane(showPageHeader: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
