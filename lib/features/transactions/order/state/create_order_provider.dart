import '../../../../core/di/service_locator.dart';
import '../../../../core/providers/base_provider.dart';
import '../../quotation/data/quotation_model.dart';
import '../data/order_api.dart';
import '../data/order_form_model.dart';

class CreateOrderProvider extends BaseProvider {
  CreateOrderProvider({OrderApi? api}) : _api = api ?? sl<OrderApi>();

  final OrderApi _api;

  OrderFormRecord? form;
  List<QuotationRecord> quotationOptions = [];

  Future<void> initNew() async {
    await runAsync(() async {
      quotationOptions = await _api.fetchQuotationsForOrderPicker();
      form = _api.newDraftForm();
    });
  }

  Future<void> initFromFormId(String id) async {
    await runAsync(() async {
      quotationOptions = await _api.fetchQuotationsForOrderPicker();
      form = await _api.fetchFormById(id);
      form ??= _api.newDraftForm();
    });
  }

  Future<void> applyQuotation(String quotationId) async {
    if (quotationId.isEmpty || form == null) return;
    await runAsync(() async {
      final next = await _api.prefillFormFromQuotation(
        quotationId,
        base: form,
      );
      if (next != null) form = next;
    });
  }

  void patchForm(OrderFormRecord next) {
    form = next;
    notifyListeners();
  }

  Future<bool> saveDraft() async {
    if (form == null) return false;
    var ok = false;
    await runAsync(() async {
      form = await _api.saveForm(
        form!.copyWith(status: OrderFormStatus.draft),
      );
      ok = true;
    });
    return ok && !hasError;
  }

  Future<bool> confirmOrder() async {
    if (form == null || form!.quotationId.isEmpty) return false;
    var ok = false;
    await runAsync(() async {
      form = await _api.saveForm(
        form!.copyWith(status: OrderFormStatus.confirmed),
      );
      ok = true;
    });
    return ok && !hasError;
  }
}
