import 'package:ccs_app/app/constants/ui_constants.dart';
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

class AgreementView extends GetView<AuthController> {
  const AgreementView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final totalSteps = controller.sectionList.length;

    return Obx(() {
      final currentStep = controller.stepCurrentIndex.value;
      final section = controller.sectionList[currentStep];
      final questions = section.questions ?? [];
      final isLastStep = currentStep == totalSteps - 1;
      final isStepComplete = controller.isAgreementStepComplete(currentStep);

      return AppScaffold(
        backgroundColor: scheme.surface,
        appBar: Header(title: section.title ?? ''),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step progress – improved styling
              SingleChildScrollView(
                controller: controller.stepScrollController,
                scrollDirection: Axis.horizontal,
                child: StepProgress(
                  stepNodeSize: 40,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  theme: StepProgressThemeData(
                    shape: StepNodeShape.circle,
                    defaultForegroundColor: scheme.outline.withValues(alpha: 0.5),
                    activeForegroundColor: scheme.secondary,
                    enableRippleEffect: true,
                    stepAnimationDuration: const Duration(milliseconds: 220),
                    stepLineSpacing: 4,
                    nodeLabelAlignment: StepLabelAlignment.bottom,
                    nodeLabelStyle: StepLabelStyle(
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                      defualtColor: scheme.onSurfaceVariant,
                      activeColor: scheme.secondary,
                      margin: const EdgeInsets.only(top: 6),
                      maxWidth: 44,
                    ),
                    stepNodeStyle: StepNodeStyle(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      activeDecoration: BoxDecoration(
                        color: scheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      enableRippleEffect: true,
                    ),
                    stepLineStyle: StepLineStyle(
                      foregroundColor: scheme.outline.withValues(alpha: 0.35),
                      activeColor: scheme.secondary.withValues(alpha: 0.8),
                      lineThickness: 3,
                      borderRadius: const Radius.circular(2),
                    ),
                  ),
                  nodeTitles: List.generate(
                    totalSteps,
                    (i) => 'Step ${i + 1}',
                  ),
                  controller: controller.stepProgressController,
                  totalSteps: totalSteps,
                  currentStep: currentStep,
                  onStepNodeTapped: (index) {
                    controller.stepCurrentIndex.value = index;
                    controller.stepProgressController.setCurrentStep(index);
                  },
                  onStepChanged: (index) {
                    controller.stepCurrentIndex.value = index;
                  },
                ).marginOnly(bottom: UiConstants.gap),
              ),

              // Section header: "Step X of Y"
              CommonText.regular(
                'Step ${currentStep + 1} of $totalSteps',
                size: 14,
                color: scheme.onSurfaceVariant,
              ).marginOnly(bottom: UiConstants.gap),

              // Questions list
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length,
                  controller: controller.scrollController,
                  separatorBuilder: (_, __) => SizedBox(height: 0),
                  itemBuilder: (context, questionIndex) {
                    final item = questions[questionIndex];
                    final selectedAnswer = controller.getAgreementAnswer(currentStep, questionIndex);

                    return AppCard(
                      radius: UiConstants.radiusLarge,
                      enableShadows: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question number badge + question text
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppCard(
                                enableShadows: false,
                                color: scheme.secondaryContainer,
                                radius: UiConstants.radiusSmall,
                                child: CommonText.semiBold(
                                  '${questionIndex + 1}',
                                  size: 14,
                                  color: scheme.onSecondaryContainer,
                                ).paddingSymmetric(horizontal: 12, vertical: 6),
                              ).marginOnly(right: UiConstants.gap),
                              Expanded(
                                child: CommonText.semiBold(
                                  item.question ?? '',
                                  size: 16,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ).marginOnly(bottom: UiConstants.gap),
                          // Answer options with larger tap targets
                          ...List.generate(
                            item.answers?.length ?? 0,
                            (answerIndex) {
                              final answer = item.answers?[answerIndex] ?? '';
                              final isSelected = selectedAnswer == answer;
                              return InkWell(
                                onTap: () => controller.setAgreementAnswer(currentStep, questionIndex, answer),
                                borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: answer,
                                      groupValue: selectedAnswer,
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.setAgreementAnswer(currentStep, questionIndex, value);
                                        }
                                      },
                                      fillColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                                        if (states.contains(WidgetState.selected)) {
                                          return scheme.secondary;
                                        }
                                        return scheme.outline.withValues(alpha: 0.6);
                                      }),
                                    ),
                                    Expanded(
                                      child: CommonText.regular(
                                        answer,
                                        size: 15,
                                        color: isSelected ? scheme.onSurface : scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ).paddingAll(UiConstants.defaultPadding),
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
                openUrl('http://staging-frontend.colossianscareservices.co.uk/');
              } else {
                try {
                  controller.scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  controller.stepScrollController.animateTo(controller.stepCurrentIndex.value.toDouble(), duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
