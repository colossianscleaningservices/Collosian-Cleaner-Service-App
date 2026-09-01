import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:flutter_rating/flutter_rating.dart';

import '../../../../export.dart';
import 'client_job_detail_controller.dart';

class AddReview extends GetView<ClientJobDetailController> {
  const AddReview({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      appBar: Header(
        title: 'Rate Your Cleaner',
        subtitle: 'Your feedback helps us improve',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText.semiBold(
                'Visit feedback',
                size: 16,
                color: scheme.onSurfaceVariant,
              ).marginOnly(bottom: 4),
              CommonText.regular(
                'A few quick questions about your visit',
                size: 13,
                color: scheme.onSurfaceVariant,
              ).marginOnly(bottom: 16),

              CommonText.semiBold(
                'Did the cleaner arrive on time?',
                size: 15,
                color: scheme.onSurface,
              ).marginOnly(bottom: 6),
              Obx(() => RadioGroup<UserOptions>(
                    groupValue: controller.arrive.value,
                    onChanged: (UserOptions? value) => controller.arrive.value = value,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: ListTile(
                            title: CommonText.regular('Yes'),
                            leading: Radio<UserOptions>(value: UserOptions.yes),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            title: CommonText.regular('No'),
                            leading: Radio<UserOptions>(value: UserOptions.no),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  )).marginOnly(bottom: 16),
              CommonText.semiBold(
                'Was the cleaner wearing our company\'s uniform?',
                size: 15,
                color: scheme.onSurface,
              ).marginOnly(bottom: 6),
              Obx(() => RadioGroup<UserOptions>(
                    groupValue: controller.uniform.value,
                    onChanged: (UserOptions? value) => controller.uniform.value = value,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: ListTile(
                            title: CommonText.regular('Yes'),
                            leading: Radio<UserOptions>(value: UserOptions.yes),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            title: CommonText.regular('No'),
                            leading: Radio<UserOptions>(value: UserOptions.no),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  )).marginOnly(bottom: 16),
              CommonText.semiBold(
                'Did the cleaner complete the job in the allocated time?',
                size: 15,
                color: scheme.onSurface,
              ).marginOnly(bottom: 6),
              Obx(() => RadioGroup<UserOptions>(
                    groupValue: controller.completedJob.value,
                    onChanged: (UserOptions? value) => controller.completedJob.value = value,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: ListTile(
                            title: CommonText.regular('Yes'),
                            leading: Radio<UserOptions>(value: UserOptions.yes),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            title: CommonText.regular('No'),
                            leading: Radio<UserOptions>(value: UserOptions.no),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  )).marginOnly(bottom: 16),
              CommonText.semiBold(
                'Would you like to request this cleaner again?',
                size: 15,
                color: scheme.onSurface,
              ).marginOnly(bottom: 6),
              Obx(() => RadioGroup<UserOptions>(
                    groupValue: controller.requestAgain.value,
                    onChanged: (UserOptions? value) => controller.requestAgain.value = value,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: ListTile(
                            title: CommonText.regular('Yes'),
                            leading: Radio<UserOptions>(value: UserOptions.yes),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            title: CommonText.regular('No'),
                            leading: Radio<UserOptions>(value: UserOptions.no),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  )).marginOnly(bottom: 24),

              CommonText.semiBold(
                'Overall rating',
                size: 16,
                color: scheme.onSurfaceVariant,
              ).marginOnly(bottom: 4),
              CommonText.regular(
                'How would you rate this visit?',
                size: 13,
                color: scheme.onSurfaceVariant,
              ).marginOnly(bottom: 12),

              Obx(() {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: UiConstants.defaultPadding,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: StarRating(
                    size: 36,
                    mainAxisAlignment: MainAxisAlignment.center,
                    color: scheme.primary,
                    borderColor: scheme.outline.withValues(alpha: 0.5),
                    rating: controller.rating.value,
                    allowHalfRating: false,
                    onRatingChanged: (rating) => controller.rating.value = rating,
                  ),
                );
              }).marginOnly(bottom: 24),

              CommonText.semiBold(
                'Additional comments',
                size: 16,
                color: scheme.onSurfaceVariant,
              ).marginOnly(bottom: 4),
              CommonText.regular(
                'Optional — anything else you\'d like to share?',
                size: 13,
                color: scheme.onSurfaceVariant,
              ).marginOnly(bottom: 8),
              CommonTextField(
                hint: 'e.g. suggestions, praise, or areas to improve',
                controller: controller.messageController,
                maxLines: 6,
                minLines: 4,
                action: TextInputAction.done,
              ).marginOnly(bottom: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SingleActionBottomBar(
        label: 'Submit Feedback',
        onPressed: () => controller.submitReview(),
      ),
    );
  }
}
