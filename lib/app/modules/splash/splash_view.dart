import 'package:ccs_app/app/gen/assets.gen.dart';
import 'package:ccs_app/export.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Assets.launcherSplashIcon.image(),
      ),
    );
  }
}

