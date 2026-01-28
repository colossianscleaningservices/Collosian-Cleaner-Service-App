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
    final scheme = context.colorScheme;
    return SizedBox(
      height: height,
      child: Center(
        child: Image.asset(
          kAuthLogoAsset,
          height: imageHeight,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconsaxPlusLinear.home_hashtag, size: 64, color: scheme.primary),
              const SizedBox(height: 8),
              CommonText.bold('CCS', size: 24, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
