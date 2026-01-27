import 'package:ccs_app/export.dart';

class BoxedWidget extends StatelessWidget {
  const BoxedWidget({required this.child, this.maxWidth, super.key});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: kIsWeb ? (maxWidth ?? 1200.0) : double.infinity),
      child: child,
    ),
  );
}
