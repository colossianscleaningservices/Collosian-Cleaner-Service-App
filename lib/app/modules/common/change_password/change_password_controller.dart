import 'package:ccs_app/export.dart';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final showCurrentPassword = false.obs;
  final showNewPassword = false.obs;
  final showConfirmPassword = false.obs;

  final isLoading = false.obs;

  @override
  void onClose() {
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) return 'Current password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'New password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Include at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include at least one number';
    if (value == currentPasswordCtrl.text) return 'New password must be different';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != newPasswordCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // TODO: Call API to change password
      await Future.delayed(const Duration(seconds: 2));
      Notifier.success('Password changed successfully');
      Get.back();
    } catch (e) {
      Notifier.error('Failed to change password');
    } finally {
      isLoading.value = false;
    }
  }
}
