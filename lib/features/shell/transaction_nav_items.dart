import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../design_system/components/components.dart';
import '../../design_system/tokens.dart';

/// Transaction submodule sidebar entries — order matches Ultra Labs workflow.
///
/// Nested nav can attach under items such as Sample Intake when sub-routes ship.
const List<NavItem> kTransactionNavChildren = [
  NavItem(
    path: '/transactions/enquiry',
    label: 'Enquiry',
    icon: Icon(LucideIcons.mail, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/quotation',
    label: 'Quotation',
    icon: Icon(LucideIcons.fileText, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/sample-intake',
    label: 'Sample Intake',
    icon: Icon(LucideIcons.clipboardList, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/lab-code',
    label: 'Lab Code',
    icon: Icon(LucideIcons.hash, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/lab-assignment',
    label: 'Lab Manager Assignment',
    icon: Icon(LucideIcons.users, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/chemist-test-details',
    label: 'Chemist Test Details',
    icon: Icon(LucideIcons.microscope, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/verification',
    label: 'Lab Manager Verification',
    icon: Icon(LucideIcons.checkCircle, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/lab-verification-chemist',
    label: 'Lab Verification Chemist',
    icon: Icon(LucideIcons.flaskConical, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/supervisor-review',
    label: 'Supervisor Review',
    icon: Icon(LucideIcons.messageSquareText, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/action-taken',
    label: 'Action Taken',
    icon: Icon(LucideIcons.activity, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/customer-invoice',
    label: 'Customer Invoice',
    icon: Icon(LucideIcons.receipt, size: AppTokens.iconButtonIconMd),
  ),
  NavItem(
    path: '/transactions/credit-note',
    label: 'Credit Note',
    icon: Icon(LucideIcons.banknote, size: AppTokens.iconButtonIconMd),
  ),
];
