import 'package:ccs_app/export.dart';

class ClientNotificationsView extends StatelessWidget {
  const ClientNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: UiConstants.padding,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: []),
      ),
    );
  }
}
