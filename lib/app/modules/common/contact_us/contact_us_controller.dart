import 'package:ccs_app/export.dart';

class ContactUsController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void onEmailTap() {
    Notifier.info('support@collosian.com');
    // TODO: url_launcher mailto:support@collosian.com
  }

  void onCallTap() {
    Notifier.info('+44 (0) 123 456 7890');
    // TODO: url_launcher tel:+441234567890
  }

  void onSubmitMessage() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final message = messageController.text.trim();
    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      Notifier.info('Please fill in name, email and message.');
      return;
    }
    Notifier.info('Message sent. We\'ll get back to you soon.');
    nameController.clear();
    emailController.clear();
    messageController.clear();
  }
}
