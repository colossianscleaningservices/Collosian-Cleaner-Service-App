import 'package:ccs_app/app/network/response/faq_response.dart';
import 'package:ccs_app/app/services/pref.dart';

import '../../../../export.dart';
import '../../../network/repository/common_repository.dart';

class HelpSupportController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  final CommonRepository _commonRepository = CommonRepository();

  final RxList<Faq> faqList = <Faq>[].obs;

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();

    nameController.text = Prefs().userFullName.toTitleCase();

    emailController.text = Prefs().getData(Prefs.email);

    getFaqs();

  }

  @override
  void onReady() {
    super.onReady();
    Loader.show();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> onSubmitMessage() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final message = messageController.text.trim();

    if (name.isEmpty) {
      Notifier.info('Please fill the name.');
      return;
    }

    if (email.isEmpty) {
      Notifier.info('Please fill  email.');
      return;
    }

    if (message.isEmpty) {
      Notifier.info('Message field can not be empty.');
      return;
    }

    try {
      final result = await _commonRepository.contactUs(name: name, email: email, message: message);
      result.when(
        success: (value) {
          Notifier.success(value.message.toString());
        },
        error: (e) async {
          await Notifier.apiError(e, contextTag: 'contact_support');
        },
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'contact_support');
    } finally {
      messageController.clear();
    }
  }

  Future<void> getFaqs() async {
    try {
      final result = await _commonRepository.getFaqs();
      result.when(
        success: (value) {
          final data = value.data?.faq;
          if(data != null) faqList.addAll(data);
        },
        error: (e) async {
          await Notifier.apiError(e, contextTag: 'get_faqs');
        },
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'get_faqs');
    } finally{
      Loader.hide();
    }
  }


}
