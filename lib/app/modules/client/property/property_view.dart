import 'package:ccs_app/app/network/response/property_list_response.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'property_controller.dart';

class PropertyView extends GetView<PropertyController> {
  const PropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      appBar: const Header(
        title: 'My Properties',
        headerLogoIcon: false,
        hasBackIcon: true,
        titleCentered: false,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Obx(
          () {
            final list = controller.properties;
            if (list.isEmpty) {
              return NoDataView(
                title: 'No properties yet',
                subtitle: 'Add your first property to book cleanings.',
                icon: IconsaxPlusLinear.home_2,
                actionLabel: 'Add Property',
                onAction: controller.goToAddProperty,
              );
            }
            return SingleChildScrollView(
              padding: UiConstants.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppGrid(
                    maxExtent: 100,
                    axisSpacing: 8,
                    phoneCount: 1,
                    tabletCount: 2,
                    landscapeCount: 3,
                    child: List.generate(
                      controller.properties.length,
                      (index) => _PropertyCard(
                        property: controller.properties[index],
                        onTap: () => controller.goToEditProperty(index),
                        scheme: scheme,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Obx(() {
        return controller.properties.isEmpty
            ? SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: controller.goToAddProperty,
                icon: const Icon(IconsaxPlusLinear.add),
                label: const Text('Add Property'),
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              );
      }),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.onTap,
    required this.scheme,
  });

  final PropertyModel property;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppCard.iconContainer(
            context: context,
            child: Icon(IconsaxPlusLinear.home_2, color: scheme.secondary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold(property.propertyName ?? "N/A", size: 18, color: scheme.onSurface),
                const SizedBox(height: 2),
                CommonText.regular(
                  "${property.address}${property.address != null ? ', ' : ''}${property.city}",
                  size: 13,
                  color: scheme.onSurfaceVariant,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (property.propertyType != null) ...[
                  const SizedBox(height: 4),
                  AppCard(
                    enableShadows: false,
                    color: scheme.outlineVariant,
                    child: CommonText.medium(
                      ("${property.businessType!} ${Constants.bullet} ${property.propertyType!} ${Constants.bullet} ${property.subType}").toUpperCase(),
                      size: 12,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ).paddingSymmetric(horizontal: 10, vertical: 4),
                  ),
                ],
              ],
            ),
          ),
          Icon(IconsaxPlusLinear.arrow_right_3, size: 20, color: scheme.onSurfaceVariant),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}
