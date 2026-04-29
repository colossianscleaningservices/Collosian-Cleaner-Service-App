import 'package:ccs_app/app/network/response/faq_response.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../export.dart';
import '../../../network/repository/common_repository.dart';

class HelpSupportController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  final CommonRepository _commonRepository = CommonRepository();
  final RxList<Faq> faqList = <Faq>[].obs;
  var from = '';

  final supportMail = 'support@collosian.com'.obs;
  final supportPhone = '+44 (0) 123 456 7890'.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.text = Prefs().userFullName.toTitleCase();
    emailController.text = Prefs().getData(Prefs.email);

    if (Get.arguments != null) {
      if (Get.arguments.containsKey('from')) from = Get.arguments['from'];
    }

    supportMail.value = Prefs().getData(Prefs.supportMail);
    supportPhone.value = Prefs().getData(Prefs.supportPhone);
  }

  @override
  void onReady() {
    if (from.isEmpty) getFaqs();
    super.onReady();
  }

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
      (Get.context as BuildContext).hideKeyboard();
      Loader.show();
      final result = await _commonRepository.contactUs(name: name, email: email, message: message);
      result.handle(
        success: (value) {
          Notifier.success(value.message.toString());
        },
        contextTag: 'contact_support',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'contact_support');
    } finally {
      Loader.hide();
      messageController.clear();
      Get.back();
    }
  }

  Future<void> getFaqs() async {
    Loader.show();
    try {
      final result = await _commonRepository.getFaqs();
      result.handle(
        success: (value) {
          final data = value.data?.faq;
          if (data != null) faqList.addAll(data);
        },
        contextTag: 'get_faqs',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'get_faqs');
    } finally {
      Loader.hide();
    }
  }

  Future<void> openDialPad(String phoneNumber) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> openEmail() async {
    final Uri emailUri = Uri.parse(
      'mailto:$supportMail?subject=Support&body=Hello',
    );

    if (!await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $emailUri';
    }
  }
}
