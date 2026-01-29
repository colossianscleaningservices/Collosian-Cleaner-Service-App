import 'package:ccs_app/app/widget/layout/app_scaffold.dart';

import '../../../../export.dart';
import '../../../widget/widgets.dart';
import 'cleaner_references_controller.dart';

class CleanerReferencesView extends GetView<CleanerReferencesController> {
  const CleanerReferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppScaffold(
      appBar: Header(title: "References"),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _EmptyState(scheme: scheme).marginAll(16)

            /*AppGrid(
              maxExtent: 160,
              controller: ScrollController(keepScrollOffset: false),
              //physics: const NeverScrollableScrollPhysics(),
              phoneCount: 1,
              tabletCount: 2,
              landscapeCount: 3,
              axisSpacing: 0,
              child: [],
            ).marginOnly(bottom: 16),*/
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.ADD_REFERENCES),
        icon: const Icon(Icons.add),
        label: const Text('Add References'),
      ),
    );
  }
}
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            IconsaxPlusLinear.document,
            size: 48,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          CommonText.medium(
            'No references added yet.',
            size: 16,
            color: scheme.onSurface,
          ),
          const SizedBox(height: 8),
          CommonText.regular(
            'References will appear here when available.',
            size: 14,
            color: scheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}