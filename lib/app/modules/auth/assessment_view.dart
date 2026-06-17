import 'package:ccs_app/app/constants/ui_constants.dart';
import 'package:ccs_app/app/network/response/assessment_question_response.dart' as aq;
import 'package:ccs_app/app/utils/extension.dart';
import 'package:ccs_app/app/widget/common/header.dart';
import 'package:ccs_app/app/widget/common/text.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/app/widget/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_progress/step_progress.dart';

import '../../utils/notifier.dart';
import 'auth_controller.dart';

class AssessmentView extends GetView<AuthController> {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Obx(() {
      final totalSteps = controller.assessmentCategories.length;
      if (totalSteps == 0) {
        return AppScaffold(
          backgroundColor: scheme.surface,
          appBar: Header(title: 'Assessment'),
          body: Center(child: CommonText.regular('No assessment sections available.', color: scheme.onSurfaceVariant)),
        );
      }
      final currentStep = controller.stepCurrentIndex.value.clamp(0, totalSteps - 1);
      final category = controller.assessmentCategories[currentStep];
      final questions = currentStep < controller.assessmentQuestionsByStep.length ? controller.assessmentQuestionsByStep[currentStep] : <aq.Questions>[];
      final isLastStep = currentStep == totalSteps - 1;
      final isStepComplete = controller.isAgreementStepComplete(currentStep);

      return AppScaffold(
        backgroundColor: scheme.surface,
        appBar: Header(title: "Assessment"),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonText.semiBold(
                category.name ?? '',
                size: 18,
                fontWeight: FontWeight.w700,
              ).marginSymmetric(horizontal: 8).marginOnly(top: 8),
              // Step progress – improved styling
              SingleChildScrollView(
                controller: controller.stepScrollController,
                scrollDirection: Axis.horizontal,
                child: StepProgress(
                  stepNodeSize: 32,
                  theme: StepProgressThemeData(
                    shape: StepNodeShape.circle,
                    defaultForegroundColor: scheme.outline.withValues(alpha: 0.5),
                    activeForegroundColor: scheme.secondary,
                    enableRippleEffect: false,
                    stepAnimationDuration: const Duration(milliseconds: 220),
                    nodeLabelAlignment: StepLabelAlignment.bottom,
                    nodeLabelStyle: StepLabelStyle(
                      titleStyle: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      defualtColor: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                      activeColor: scheme.secondary,
                      margin: const EdgeInsets.only(top: 6),
                      maxWidth: 50,
                    ),
                    stepNodeStyle: StepNodeStyle(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        shape: BoxShape.circle,
                      ),
                      activeDecoration: BoxDecoration(
                        color: scheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    stepLineStyle: StepLineStyle(
                      isBreadcrumb: true,
                      foregroundColor: scheme.surface,
                      activeColor: scheme.secondary,
                    ),
                  ),
                  nodeTitles: List.generate(totalSteps, (i) => 'Step ${i + 1}'),
                  controller: controller.stepProgressController,
                  totalSteps: totalSteps,
                  currentStep: currentStep,
                  onStepNodeTapped: (index) {
                    controller.stepCurrentIndex.value = index;
                    controller.stepProgressController.setCurrentStep(index);
                  },
                  onStepChanged: (index) => controller.stepCurrentIndex.value = index,
                ),
              ).marginSymmetric(vertical: 16),
              // Questions list (API type: Questions with questionText, options)
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length,
                  controller: controller.scrollController,
                  separatorBuilder: (_, __) => SizedBox(height: 0),
                  itemBuilder: (context, questionIndex) {
                    final item = questions[questionIndex];
                    final questionText = item.questionText ?? '';
                    final options = item.options ?? [];
                    final selectedAnswer = controller.getAgreementAnswer(currentStep, questionIndex);

                    return AppCard(
                      radius: UiConstants.radiusLarge,
                      enableShadows: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppCard(
                                enableShadows: false,
                                color: scheme.secondaryContainer,
                                radius: UiConstants.radiusSmall,
                                child: CommonText.extraBold(
                                  '${questionIndex + 1}',
                                  size: 14,
                                  color: scheme.secondary,
                                ).paddingSymmetric(horizontal: 12, vertical: 6),
                              ).marginOnly(right: UiConstants.gap),
                              Expanded(
                                child: CommonText.semiBold(
                                  questionText,
                                  size: 16,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ).marginOnly(left: UiConstants.gap, right: UiConstants.gap, top: UiConstants.gap),
                          item.answerType == 'multiple'
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: context.colorScheme.secondary,
                                    ).marginOnly(right: 4).marginOnly(left: UiConstants.margin32),
                                    Flexible(
                                      child: CommonText.semiBold(
                                        'You can select more options.',
                                        size: 14,
                                        color: scheme.primary.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ).marginOnly(left: UiConstants.gap, right: UiConstants.gap, top: 2)
                              : SizedBox.shrink(),
                          ListView.builder(
                            itemBuilder: (context, index) {
                              final option = options[index];
                              final label = option.text ?? option.label ?? '';
                              final value = option.label ?? option.text ?? '';
                              final isSelected = selectedAnswer == value;

                              return InkWell(
                                onTap: () => controller.setAgreementAnswer(currentStep, questionIndex, value),
                                child: Row(
                                  children: [
                                    if (item.answerType == 'multiple') ...[
                                      Checkbox(value: false, onChanged: (value) => {}),
                                    ] else ...[
                                      Radio<String>(
                                        value: value,
                                        groupValue: selectedAnswer,
                                        onChanged: (v) {
                                          if (v != null) controller.setAgreementAnswer(currentStep, questionIndex, v);
                                        },
                                        fillColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                                          if (states.contains(WidgetState.selected)) return scheme.secondary;
                                          return scheme.outline;
                                        }),
                                      ),
                                    ],
                                    Expanded(
                                      child: CommonText.regular(
                                        label,
                                        size: 14,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? scheme.onSurface : scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: options.length,
                          ),
                        ],
                      ).paddingSymmetric(vertical: 0),
                    ).marginAll(8);
                  },
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: UiConstants.defaultPadding),
        ),
        bottomNavigationBar: DualActionBottomBar(
          primaryLabel: isLastStep ? 'Accept & continue' : 'Continue',
          primaryOnPressed: () {
            if (isStepComplete) {
              if (isLastStep) {
                controller.saveCleanerAssessment();
                /*openUrl('http://staging-frontend.colossianscareservices.co.uk/');*/
              } else {
                try {
                  controller.scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  controller.stepScrollController
                      .animateTo(controller.stepCurrentIndex.value.toDouble(), duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } catch (e) {
                  e.printError();
                }
                controller.stepProgressController.nextStep();
              }
            } else {
              Notifier.error('Please answer all questions');
            }
          },
          secondaryLabel: 'Back',
          secondaryOnPressed: () {
            if (controller.stepProgressController.currentStep == 0) return;
            controller.stepProgressController.previousStep();
          },
          showSecondary: controller.stepProgressController.currentStep != 0,
        ),
      );
    });
  }
}
