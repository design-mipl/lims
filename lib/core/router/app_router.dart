import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../di/service_locator.dart';
import '../../features/coming_soon/coming_soon_screen.dart';
import '../../features/masters/bank_master/state/bank_master_provider.dart';
import '../../features/masters/bank_master/ui/bank_master_screen.dart';
import '../../features/masters/courier_master/state/courier_provider.dart';
import '../../features/masters/courier_master/ui/courier_detail_screen.dart';
import '../../features/masters/courier_master/ui/courier_screen.dart';
import '../../features/masters/customer_master/state/customer_provider.dart';
import '../../features/masters/customer_master/ui/customer_detail_screen.dart';
import '../../features/masters/customer_master/ui/customer_form_page.dart';
import '../../features/masters/customer_master/ui/customer_screen.dart';
import '../../features/masters/site_master/state/site_provider.dart';
import '../../features/masters/site_master/ui/site_detail_screen.dart';
import '../../features/masters/site_master/ui/site_screen.dart';
import '../../features/masters/ferrography_master/state/ferrography_master_provider.dart';
import '../../features/masters/ferrography_master/ui/ferrography_master_screen.dart';
import '../../features/masters/hsn_master/state/hsn_master_provider.dart';
import '../../features/masters/hsn_master/ui/hsn_master_screen.dart';
import '../../features/masters/item_master/state/item_master_provider.dart';
import '../../features/masters/item_master/ui/item_master_screen.dart';
import '../../features/masters/plant_master/state/plant_provider.dart';
import '../../features/masters/plant_master/ui/plant_screen.dart';
import '../../features/masters/problem_master/state/problem_master_provider.dart';
import '../../features/masters/problem_master/ui/problem_master_screen.dart';
import '../../features/masters/sub_assembly_master/state/sub_assembly_master_provider.dart';
import '../../features/masters/sub_assembly_master/ui/sub_assembly_master_screen.dart';
import '../../features/masters/unit_master/state/unit_master_provider.dart';
import '../../features/masters/unit_master/ui/unit_master_screen.dart';
import '../../features/ui_kit/ui_kit_screen.dart';
import '../../features/dev/form_template_preview_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/transactions/action_taken/state/action_taken_provider.dart';
import '../../features/transactions/action_taken/ui/action_taken_screen.dart';
import '../../features/transactions/action_taken/ui/action_taken_workspace_screen.dart';
import '../../features/transactions/lab_code/state/lab_code_provider.dart';
import '../../features/transactions/lab_code/ui/lab_code_detail_screen.dart';
import '../../features/transactions/lab_code/ui/lab_code_screen.dart';
import '../../features/transactions/lab_verification_chemist/state/lab_verification_chemist_provider.dart';
import '../../features/transactions/lab_verification_chemist/ui/lab_verification_chemist_detail_screen.dart';
import '../../features/transactions/lab_verification_chemist/ui/lab_verification_chemist_screen.dart';
import '../../features/transactions/lab_manager_assignment/state/lab_manager_assignment_provider.dart';
import '../../features/transactions/lab_manager_assignment/ui/lab_manager_assignment_screen.dart';
import '../../features/transactions/lab_manager_certification/state/lab_manager_certification_provider.dart';
import '../../features/transactions/lab_manager_certification/ui/lab_manager_certification_screen.dart';
import '../../features/transactions/lab_manager_verification/state/lab_manager_verification_provider.dart';
import '../../features/transactions/lab_manager_verification/ui/lab_manager_verification_screen.dart';
import '../../features/transactions/shared/lab_manager_listing_detail_screen.dart';
import '../../features/transactions/enquiry/state/enquiry_provider.dart';
import '../../features/transactions/enquiry/ui/enquiry_detail_screen.dart';
import '../../features/transactions/enquiry/ui/enquiry_form_page.dart';
import '../../features/transactions/enquiry/ui/enquiry_screen.dart';
import '../../features/transactions/quotation/state/quotation_provider.dart';
import '../../features/transactions/quotation/ui/quotation_approved_screen.dart';
import '../../features/transactions/quotation/ui/quotation_history_screen.dart';
import '../../features/transactions/quotation/ui/create_quotation_page.dart';
import '../../features/transactions/quotation/ui/quotation_pending_screen.dart';
import '../../features/transactions/quotation/ui/quotation_sales_review_screen.dart';
import '../../features/transactions/chemist_test_details/state/chemist_test_details_provider.dart';
import '../../features/transactions/chemist_test_details/ui/chemist_test_details_screen.dart';
import '../../features/transactions/credit_note/data/create_credit_note_prefill.dart';
import '../../features/transactions/credit_note/state/create_credit_note_provider.dart';
import '../../features/transactions/credit_note/ui/credit_note_detail_screen.dart';
import '../../features/transactions/credit_note/ui/credit_note_screen.dart';
import '../../features/transactions/credit_note/ui/create_credit_note_page.dart';
import '../../features/transactions/customer_invoice/ui/create_customer_invoice_page.dart';
import '../../features/transactions/customer_invoice/ui/customer_invoice_screen.dart';
import '../../features/transactions/customer_invoice/ui/view_customer_invoice_page.dart';
import '../../features/transactions/quotation/ui/quotation_workspace_screen.dart';
import '../../features/transactions/sample_intake/state/sample_intake_provider.dart';
import '../../features/transactions/sample_intake/ui/create_sample_receipt_page.dart';
import '../../features/transactions/sample_intake/ui/generate_lab_code_workspace_screen.dart';
import '../../features/transactions/sample_intake/ui/sample_intake_detail_page.dart';
import '../../features/transactions/sample_intake/ui/sample_intake_history_screen.dart';
import '../../features/transactions/sample_intake/ui/sample_intake_hub_screen.dart';
import '../../features/transactions/sample_intake/ui/sample_receipt_detail_form_screen.dart';
import '../../features/transactions/nabl_no/state/nabl_no_provider.dart';
import '../../features/transactions/supervisor_comments/state/supervisor_comments_provider.dart';
import '../../features/transactions/supervisor_comments/ui/supervisor_review_workspace_screen.dart';
import '../../features/transactions/supervisor_nabl/ui/supervisor_nabl_workspace_screen.dart';
import '../../features/user_management/departments/state/departments_provider.dart';
import '../../features/user_management/departments/ui/departments_screen.dart';
import '../../features/user_management/modules/state/modules_provider.dart';
import '../../features/user_management/modules/ui/modules_screen.dart';
import '../../features/user_management/roles/state/roles_provider.dart';
import '../../features/user_management/roles/ui/roles_screen.dart';
import '../../features/user_management/users/state/user_permissions_provider.dart';
import '../../features/user_management/users/state/users_provider.dart';
import '../../features/user_management/users/ui/user_form_page.dart';
import '../../features/user_management/users/ui/user_permissions_screen.dart';
import '../../features/user_management/users/ui/user_view_page.dart';
import '../../features/user_management/users/ui/users_screen.dart';

Set<int>? _parseSampleIntakeRowIndexes(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final out = <int>{};
  for (final part in raw.split(',')) {
    final v = int.tryParse(part.trim());
    if (v != null) out.add(v);
  }
  return out.isEmpty ? null : out;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/dashboard'),
    ShellRoute(
      builder: (context, state, child) {
        return ShellScreen(state: state, child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, _) => const ComingSoonScreen(
            moduleName: 'Dashboard',
            subtitle: 'Overview and analytics',
          ),
        ),
        GoRoute(
          path: '/dev/form-preview',
          builder: (context, _) => const FormTemplatePreviewScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Transactions'),
        ),
        GoRoute(
          path: '/transactions/enquiry/create',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<EnquiryProvider>(),
            child: const EnquiryFormPage(),
          ),
        ),
        GoRoute(
          path: '/transactions/enquiry/:id/view',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<EnquiryProvider>(),
              child: EnquiryDetailScreen(enquiryId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/enquiry/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<EnquiryProvider>(),
              child: EnquiryFormPage(enquiryId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/enquiry',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<EnquiryProvider>(),
            child: const EnquiryScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/quotation',
          redirect: (context, state) => '/transactions/quotation/pending',
        ),
        GoRoute(
          path: '/transactions/quotation/pending',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<QuotationProvider>(),
            child: const QuotationPendingScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/quotation/create',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<CustomerProvider>(),
            child: const CreateQuotationPage(),
          ),
        ),
        GoRoute(
          path: '/transactions/quotation/approved',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<QuotationProvider>(),
            child: const QuotationApprovedScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/quotation/:quoteId/workspace',
          builder: (context, state) {
            final id = state.pathParameters['quoteId']!;
            return ChangeNotifierProvider(
              create: (_) => sl<QuotationProvider>(),
              child: QuotationWorkspaceScreen(quoteId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/quotation/:quoteId/sales-review',
          builder: (context, state) {
            final id = state.pathParameters['quoteId']!;
            return ChangeNotifierProvider(
              create: (_) => sl<QuotationProvider>(),
              child: QuotationSalesReviewScreen(quoteId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/quotation/:quoteId/history',
          builder: (context, state) {
            final id = state.pathParameters['quoteId']!;
            return ChangeNotifierProvider(
              create: (_) => sl<QuotationProvider>(),
              child: QuotationHistoryScreen(quoteId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/quotation/:quoteId/timeline',
          redirect: (context, state) =>
              '/transactions/quotation/${state.pathParameters['quoteId']}/history',
        ),
        GoRoute(
          path: '/transactions/chemist-test-details',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => ChemistTestDetailsProvider(),
            child: const ChemistTestDetailsScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/sample-receipt',
          redirect: (context, state) => '/transactions/sample-intake',
        ),
        GoRoute(
          path: '/transactions/sample-intake/receipt-tracking',
          redirect: (context, state) => '/transactions/sample-intake',
        ),
        GoRoute(
          path: '/transactions/sample-intake/intake-queue',
          redirect: (context, state) => '/transactions/sample-intake',
        ),
        GoRoute(
          path: '/transactions/sample-intake/completed-intake',
          redirect: (context, state) =>
              '/transactions/sample-intake?tab=completed',
        ),
        GoRoute(
          path: '/transactions/sample-intake/create-samples',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => sl<SampleIntakeProvider>()),
              ChangeNotifierProvider(create: (_) => sl<CustomerProvider>()),
              ChangeNotifierProvider(create: (_) => sl<CourierProvider>()),
            ],
            child: const CreateSampleReceiptPage(),
          ),
        ),
        GoRoute(
          path: '/transactions/sample-intake/create',
          builder: (context, state) {
            final q = state.uri.queryParameters;
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => sl<SampleIntakeProvider>(),
                ),
                ChangeNotifierProvider(create: (_) => sl<CustomerProvider>()),
                ChangeNotifierProvider(create: (_) => sl<CourierProvider>()),
              ],
              child: CreateSampleReceiptPage(
                prefillEnquiryId: q['enquiryId'],
                prefillQuotationId: q['quotationId'],
              ),
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id/generate-lab-code',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final rows = _parseSampleIntakeRowIndexes(
              state.uri.queryParameters['rows'],
            );
            return ChangeNotifierProvider(
              create: (_) => sl<SampleIntakeProvider>(),
              child: GenerateLabCodeWorkspaceScreen(
                receiptId: id,
                presetRowIndexes: rows,
              ),
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id/datasheet',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<SampleIntakeProvider>(),
              child: SampleIntakeDetailPage(receiptId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id/enter-data',
          redirect: (context, state) {
            final id = state.pathParameters['id']!;
            return '/transactions/sample-intake/$id/datasheet';
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id/complete',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<SampleIntakeProvider>(),
              child: SampleReceiptDetailFormScreen(
                receiptId: id,
                readOnly: false,
              ),
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id/history',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<SampleIntakeProvider>(),
              child: SampleIntakeHistoryScreen(receiptId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id/view',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final startEdit = state.uri.queryParameters['edit'] == '1';
            return ChangeNotifierProvider(
              create: (_) => sl<SampleIntakeProvider>(),
              child: SampleReceiptDetailFormScreen(
                receiptId: id,
                readOnly: true,
                startInEditMode: startEdit,
              ),
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<SampleIntakeProvider>(),
              child: SampleReceiptDetailFormScreen(
                receiptId: id,
                readOnly: true,
                startInEditMode: true,
              ),
            );
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake/:id',
          redirect: (context, state) {
            final id = state.pathParameters['id']!;
            return '/transactions/sample-intake/$id/view';
          },
        ),
        GoRoute(
          path: '/transactions/sample-intake',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => sl<SampleIntakeProvider>(),
            child: SampleIntakeHubScreen(
              initialHubTab: switch (state.uri.queryParameters['tab']) {
                'completed' => SampleIntakeHubTab.completedReceipt,
                'sample-receipt' => SampleIntakeHubTab.sampleReceipt,
                _ => SampleIntakeHubTab.receiptTracking,
              },
            ),
          ),
        ),
        GoRoute(
          path: '/transactions/lab-code/:id/view',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<LabCodeProvider>(),
              child: LabCodeDetailScreen(itemId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/lab-code',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<LabCodeProvider>(),
            child: const LabCodeScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/lab-assignment',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<LabManagerAssignmentProvider>(),
            child: const LabManagerAssignmentScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/verification/:id/view',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return LabManagerListingDetailScreen(
              rowId: id,
              module: LabManagerListingDetailModule.verification,
            );
          },
        ),
        GoRoute(
          path: '/transactions/verification',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<LabManagerVerificationProvider>(),
            child: const LabManagerVerificationScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/lab-verification-chemist/:id/view',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<LabVerificationChemistProvider>(),
              child: LabVerificationChemistDetailScreen(itemId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/lab-verification-chemist',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<LabVerificationChemistProvider>(),
            child: const LabVerificationChemistScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/lab-manager-certification/:id/view',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return LabManagerListingDetailScreen(
              rowId: id,
              module: LabManagerListingDetailModule.certification,
            );
          },
        ),
        GoRoute(
          path: '/transactions/lab-manager-certification',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => sl<LabManagerCertificationProvider>(),
            child: const LabManagerCertificationScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/report-review',
          redirect: (context, state) => '/transactions/supervisor-review',
        ),
        GoRoute(
          path: '/transactions/supervisor-comments',
          redirect: (context, state) => '/transactions/supervisor-review',
        ),
        GoRoute(
          path: '/transactions/nabl-no',
          redirect: (context, state) => '/transactions/supervisor-review',
        ),
        GoRoute(
          path: '/transactions/supervisor-review/:id/view',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => sl<SupervisorCommentsProvider>(),
              child: SupervisorReviewWorkspaceScreen(itemId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/supervisor-review',
          builder: (context, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => sl<SupervisorCommentsProvider>(),
              ),
              ChangeNotifierProvider(create: (_) => sl<NablNoProvider>()),
            ],
            child: const SupervisorNablWorkspaceScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/action-taken/:itemId/workspace',
          builder: (context, state) {
            final id = state.pathParameters['itemId']!;
            return ChangeNotifierProvider.value(
              value: sl<ActionTakenProvider>(),
              child: ActionTakenWorkspaceScreen(itemId: id),
            );
          },
        ),
        GoRoute(
          path: '/transactions/action-taken',
          builder: (context, _) => ChangeNotifierProvider.value(
            value: sl<ActionTakenProvider>(),
            child: const ActionTakenScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions/customer-invoice/:id/view',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final startEdit = state.uri.queryParameters['edit'] == '1';
            return ChangeNotifierProvider(
              create: (_) => CustomerProvider()..fetchAll(),
              child: ViewCustomerInvoicePage(
                invoiceId: id,
                startInEditMode: startEdit,
              ),
            );
          },
        ),
        GoRoute(
          path: '/transactions/customer-invoice/create',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => CustomerProvider()..fetchAll(),
            child: const CreateCustomerInvoicePage(),
          ),
        ),
        GoRoute(
          path: '/transactions/customer-invoice',
          builder: (context, _) => const CustomerInvoiceScreen(),
        ),
        GoRoute(
          path: '/transactions/credit-note/create',
          builder: (context, state) {
            final prefill = state.extra is CreateCreditNotePrefill
                ? state.extra! as CreateCreditNotePrefill
                : null;
            return ChangeNotifierProvider(
              create: (_) {
                final p = CreateCreditNoteProvider();
                if (prefill != null) {
                  p.applyPrefill(prefill);
                }
                return p;
              },
              child: const CreateCreditNotePage(),
            );
          },
        ),
        GoRoute(
          path: '/transactions/credit-note/:id/view',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final startEdit = state.uri.queryParameters['edit'] == '1';
            return CreditNoteDetailScreen(
              noteId: id,
              startInEditMode: startEdit,
            );
          },
        ),
        GoRoute(
          path: '/transactions/credit-note',
          builder: (context, _) => const CreditNoteScreen(),
        ),
        GoRoute(
          path: '/masters',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Masters'),
        ),
        GoRoute(
          path: '/masters/customer',
          redirect: (context, state) => '/customers',
        ),
        GoRoute(
          path: '/customers',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => CustomerProvider()..fetchAll(),
            child: const CustomerScreen(),
          ),
        ),
        GoRoute(
          path: '/customers/create',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => CustomerProvider()..fetchAll(),
            child: const CustomerFormPage(),
          ),
        ),
        GoRoute(
          path: '/customers/:id',
          builder: (context, state) {
            final extra = state.extra as Map?;
            return ChangeNotifierProvider(
              create: (_) => CustomerProvider()..fetchAll(),
              child: CustomerDetailScreen(
                customerId: state.pathParameters['id']!,
                initialTab: extra?['tab']?.toString() ?? 'overview',
                startInlineEdit: extra?['edit'] == true,
              ),
            );
          },
        ),
        GoRoute(path: '/masters/site', redirect: (context, state) => '/sites'),
        GoRoute(
          path: '/sites',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => SiteProvider()..fetchAll(),
            child: const SiteScreen(),
          ),
        ),
        GoRoute(
          path: '/sites/create',
          builder: (context, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => SiteProvider()..fetchAll()),
              ChangeNotifierProvider(
                create: (_) => CustomerProvider()..fetchAll(),
              ),
            ],
            child: const SiteDetailScreen(startEdit: true),
          ),
        ),
        GoRoute(
          path: '/sites/:id',
          builder: (context, state) {
            final extra = state.extra as Map?;
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => SiteProvider()..fetchAll(),
                ),
                ChangeNotifierProvider(
                  create: (_) => CustomerProvider()..fetchAll(),
                ),
              ],
              child: SiteDetailScreen(
                siteId: state.pathParameters['id']!,
                startEdit: extra?['startEdit'] == true,
              ),
            );
          },
        ),
        GoRoute(
          path: '/masters/courier',
          redirect: (context, state) => '/couriers',
        ),
        GoRoute(
          path: '/couriers',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => CourierProvider()..fetchAll(),
            child: const CourierScreen(),
          ),
        ),
        GoRoute(
          path: '/couriers/create',
          builder: (context, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => CourierProvider()..fetchAll(),
              ),
              ChangeNotifierProvider(create: (_) => SiteProvider()..fetchAll()),
            ],
            child: const CourierDetailScreen(courierId: null, startEdit: true),
          ),
        ),
        GoRoute(
          path: '/couriers/:id',
          builder: (context, state) {
            final extra = state.extra as Map?;
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => CourierProvider()..fetchAll(),
                ),
                ChangeNotifierProvider(
                  create: (_) => SiteProvider()..fetchAll(),
                ),
              ],
              child: CourierDetailScreen(
                courierId: state.pathParameters['id']!,
                startEdit: extra?['startEdit'] == true,
              ),
            );
          },
        ),
        GoRoute(
          path: '/masters/plant',
          redirect: (context, state) => '/plants',
        ),
        GoRoute(
          path: '/plants',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => PlantProvider()..fetchAll(),
            child: const PlantScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/bank',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => BankMasterProvider()..fetchAll(),
            child: const BankMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/item',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => ItemMasterProvider()..fetchAll(),
            child: const ItemMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/equipment',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Equipment Master'),
        ),
        GoRoute(
          path: '/masters/sample-type',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Type of Sample Master'),
        ),
        GoRoute(
          path: '/masters/grade',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Grade Master'),
        ),
        GoRoute(
          path: '/masters/department',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Department Master'),
        ),
        GoRoute(
          path: '/masters/designation',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Designation Master'),
        ),
        GoRoute(
          path: '/masters/test',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Test Master'),
        ),
        GoRoute(
          path: '/masters/method',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Method Master'),
        ),
        GoRoute(
          path: '/masters/instrument',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Instrument Master'),
        ),
        GoRoute(
          path: '/masters/parameter',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Parameter Master'),
        ),
        GoRoute(
          path: '/masters/unit',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => UnitMasterProvider()..fetchAll(),
            child: const UnitMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/problem',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => ProblemMasterProvider()..fetchAll(),
            child: const ProblemMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/sub-assembly',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => SubAssemblyMasterProvider()..fetchAll(),
            child: const SubAssemblyMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/ferrography',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => FerrographyMasterProvider()..fetchAll(),
            child: const FerrographyMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/hsn',
          builder: (context, _) => ChangeNotifierProvider(
            create: (_) => HsnMasterProvider()..fetchAll(),
            child: const HsnMasterScreen(),
          ),
        ),
        GoRoute(
          path: '/masters/storage',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Storage Master'),
        ),
        GoRoute(
          path: '/housekeeping',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Housekeeping'),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, _) =>
              const ComingSoonScreen(moduleName: 'Reports'),
        ),
        GoRoute(path: '/ui-kit', builder: (context, _) => const UIKitScreen()),
        GoRoute(
          path: '/users',
          redirect: (context, state) => '/user-management/departments',
        ),
        GoRoute(
          path: '/user-management',
          redirect: (context, state) {
            if (state.uri.path == '/user-management') {
              return '/user-management/departments';
            }
            return null;
          },
          routes: [
            GoRoute(
              path: 'departments',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => DepartmentsProvider()..fetchAll(),
                child: const DepartmentsScreen(),
              ),
            ),
            GoRoute(
              path: 'users/create',
              builder: (context, state) => MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => UsersProvider()..fetchAll(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => DepartmentsProvider()..fetchAll(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => RolesProvider()..fetchAll(),
                  ),
                ],
                child: const UserFormPage(),
              ),
            ),
            GoRoute(
              path: 'users/:id/edit',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (_) => UsersProvider()..fetchAll(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => DepartmentsProvider()..fetchAll(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => RolesProvider()..fetchAll(),
                    ),
                  ],
                  child: UserFormPage(userId: id),
                );
              },
            ),
            GoRoute(
              path: 'users/:id/permissions',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final extra = state.extra as Map<String, dynamic>?;
                final name = extra?['name'] as String? ?? '';
                final role = extra?['role'] as String?;
                final isAdmin = extra?['isAdmin'] as bool? ?? false;
                return ChangeNotifierProvider(
                  create: (_) => sl<UserPermissionsProvider>()
                    ..load(
                      userId: id,
                      userName: name,
                      userRole: role,
                      isAdmin: isAdmin,
                    ),
                  child: UserPermissionsScreen(
                    userId: id,
                    userName: name,
                    userRole: role,
                    isAdmin: isAdmin,
                  ),
                );
              },
            ),
            GoRoute(
              path: 'users/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ChangeNotifierProvider(
                  create: (_) => UsersProvider()..fetchAll(),
                  child: UserViewPage(userId: id),
                );
              },
            ),
            GoRoute(
              path: 'users',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => UsersProvider()..fetchAll(),
                child: const UsersScreen(),
              ),
            ),
            GoRoute(
              path: 'roles',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => RolesProvider()..fetchAll(),
                child: const RolesScreen(),
              ),
            ),
            GoRoute(
              path: 'modules',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => ModulesProvider()..fetchAll(),
                child: const ModulesScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
