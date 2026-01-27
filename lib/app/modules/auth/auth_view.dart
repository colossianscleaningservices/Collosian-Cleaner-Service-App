import 'package:ccs_app/export.dart';

/// Auth entry route. For now we route to Login.
class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != Routes.LOGIN) {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
    return const SizedBox.shrink();
  }
}

