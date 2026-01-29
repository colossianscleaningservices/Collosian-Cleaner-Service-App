import 'package:ccs_app/export.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: UiConstants.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Constants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
