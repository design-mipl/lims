import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../../design_system/app_theme.dart';
import '../../features/masters/bank_master/data/bank_master_api.dart';
import '../../features/masters/courier_master/data/courier_api.dart';
import '../../features/masters/courier_master/state/courier_provider.dart';
import '../../features/masters/customer_master/data/customer_api.dart';
import '../../features/masters/customer_master/state/customer_provider.dart';
import '../../features/masters/ferrography_master/data/ferrography_master_api.dart';
import '../../features/masters/hsn_master/data/hsn_master_api.dart';
import '../../features/masters/item_master/data/item_master_api.dart';
import '../../features/masters/plant_master/data/plant_api.dart';
import '../../features/masters/plant_master/state/plant_provider.dart';
import '../../features/masters/problem_master/data/problem_master_api.dart';
import '../../features/masters/site_master/data/site_api.dart';
import '../../features/masters/site_master/state/site_provider.dart';
import '../../features/masters/sub_assembly_master/data/sub_assembly_master_api.dart';
import '../../features/masters/unit_master/data/unit_master_api.dart';
import '../../features/user_management/departments/data/departments_api.dart';
import '../../features/user_management/modules/data/modules_api.dart';
import '../../features/user_management/roles/data/roles_api.dart';
import '../../features/user_management/users/data/user_permissions_api.dart';
import '../../features/user_management/users/data/users_api.dart';
import '../../features/user_management/users/state/user_permissions_provider.dart';
import '../../features/transactions/enquiry/data/enquiry_api.dart';
import '../../features/transactions/enquiry/state/enquiry_provider.dart';
import '../../features/transactions/lab_code/data/lab_code_api.dart';
import '../../features/transactions/lab_code/state/lab_code_provider.dart';
import '../../features/transactions/lab_verification_chemist/data/lab_verification_chemist_api.dart';
import '../../features/transactions/lab_verification_chemist/state/lab_verification_chemist_provider.dart';
import '../../features/transactions/lab_manager_assignment/state/lab_manager_assignment_provider.dart';
import '../../features/transactions/lab_manager_certification/data/lab_manager_certification_api.dart';
import '../../features/transactions/lab_manager_certification/state/lab_manager_certification_provider.dart';
import '../../features/transactions/lab_manager_verification/data/lab_manager_verification_api.dart';
import '../../features/transactions/lab_manager_verification/state/lab_manager_verification_provider.dart';
import '../../features/transactions/nabl_no/data/nabl_no_api.dart';
import '../../features/transactions/nabl_no/state/nabl_no_provider.dart';
import '../../features/transactions/supervisor_comments/data/supervisor_comments_api.dart';
import '../../features/transactions/supervisor_comments/state/supervisor_comments_provider.dart';
import '../../features/transactions/quotation/data/quotation_api.dart';
import '../../features/transactions/quotation/state/quotation_provider.dart';
import '../../features/transactions/sample_intake/data/sample_intake_api.dart';
import '../../features/transactions/sample_intake/state/sample_intake_provider.dart';
import '../../features/transactions/action_taken/data/action_taken_api.dart';
import '../../features/transactions/action_taken/state/action_taken_provider.dart';
import '../../features/transactions/chemist_test_details/data/chemist_test_details_api.dart';
import '../../features/transactions/chemist_test_details/state/chemist_test_details_provider.dart';
import '../../features/transactions/credit_note/data/credit_note_api.dart';
import '../../features/transactions/customer_invoice/data/customer_invoice_api.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // SharedPreferences — singleton
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ThemeNotifier — singleton, loaded from prefs
  final themeConfig = await ThemeConfig.load();
  final themeNotifier = ThemeNotifier(themeConfig);
  sl.registerSingleton<ThemeNotifier>(themeNotifier);

  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  sl.registerLazySingleton<BankMasterApi>(() => BankMasterApi());
  sl.registerLazySingleton<CustomerApi>(() => CustomerApi());
  sl.registerLazySingleton<ItemMasterApi>(() => ItemMasterApi());
  sl.registerLazySingleton<UnitMasterApi>(() => UnitMasterApi());
  sl.registerLazySingleton<ProblemMasterApi>(() => ProblemMasterApi());
  sl.registerLazySingleton<SubAssemblyMasterApi>(() => SubAssemblyMasterApi());
  sl.registerLazySingleton<FerrographyMasterApi>(() => FerrographyMasterApi());
  sl.registerLazySingleton<HsnMasterApi>(() => HsnMasterApi());
  sl.registerLazySingleton<PlantApi>(() => PlantApi());
  sl.registerLazySingleton<CourierApi>(() => CourierApi());
  sl.registerLazySingleton<SiteApi>(() => SiteApi());
  sl.registerLazySingleton<LabCodeApi>(() => LabCodeApi());
  sl.registerLazySingleton<LabVerificationChemistApi>(
      () => LabVerificationChemistApi());
  sl.registerLazySingleton<LabManagerVerificationApi>(
      () => LabManagerVerificationApi());
  sl.registerLazySingleton<EnquiryApi>(() => EnquiryApi());
  sl.registerLazySingleton<QuotationApi>(
      () => QuotationApi(enquiryApi: sl<EnquiryApi>()));
  sl.registerLazySingleton<LabManagerCertificationApi>(
      () => LabManagerCertificationApi());
  sl.registerLazySingleton<SampleIntakeApi>(() => SampleIntakeApi());
  sl.registerLazySingleton<SupervisorCommentsApi>(() => SupervisorCommentsApi());
  sl.registerLazySingleton<NablNoApi>(() => NablNoApi());
  sl.registerLazySingleton<ActionTakenApi>(() => ActionTakenApi());
  sl.registerLazySingleton<ChemistTestDetailsApi>(() => ChemistTestDetailsApi());
  sl.registerLazySingleton<CustomerInvoiceApi>(() => CustomerInvoiceApi());
  sl.registerLazySingleton<CreditNoteApi>(() => CreditNoteApi());

  sl.registerLazySingleton<DepartmentsApi>(() => DepartmentsApi());
  sl.registerLazySingleton<RolesApi>(() => RolesApi());
  sl.registerLazySingleton<ModulesApi>(() => ModulesApi());
  sl.registerLazySingleton<UsersApi>(() => UsersApi());
  sl.registerLazySingleton<UserPermissionsApi>(() => UserPermissionsApi());
  sl.registerFactory<UserPermissionsProvider>(() => UserPermissionsProvider());
  sl.registerFactory<CustomerProvider>(() => CustomerProvider());
  sl.registerFactory<PlantProvider>(() => PlantProvider());
  sl.registerFactory<CourierProvider>(() => CourierProvider());
  sl.registerFactory<SiteProvider>(() => SiteProvider());
  sl.registerFactory<LabCodeProvider>(() => LabCodeProvider());
  sl.registerFactory<LabVerificationChemistProvider>(
      () => LabVerificationChemistProvider());
  sl.registerFactory<LabManagerAssignmentProvider>(() => LabManagerAssignmentProvider());
  sl.registerFactory<LabManagerVerificationProvider>(
      () => LabManagerVerificationProvider());
  sl.registerFactory<EnquiryProvider>(() => EnquiryProvider());
  sl.registerFactory<QuotationProvider>(() => QuotationProvider());
  sl.registerFactory<LabManagerCertificationProvider>(
      () => LabManagerCertificationProvider());
  sl.registerFactory<SampleIntakeProvider>(() => SampleIntakeProvider());
  sl.registerFactory<SupervisorCommentsProvider>(
      () => SupervisorCommentsProvider());
  sl.registerFactory<NablNoProvider>(() => NablNoProvider());
  sl.registerLazySingleton<ActionTakenProvider>(() => ActionTakenProvider());
  sl.registerFactory<ChemistTestDetailsProvider>(() => ChemistTestDetailsProvider());
}
