import 'package:ccs_app/app/gen/assets.gen.dart';
import 'package:ccs_app/export.dart';

/// Asset path for the auth logo. Place your app logo at assets/images/logo.png.
const String kAuthLogoAsset = 'assets/images/logo.png';

/// Shared logo widget for login, sign-up, and role selection screens.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.height = 120, this.imageHeight = 100});

  final double height;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Assets.imagesAppLogo.image(
          height: height,
        );
  }
}
