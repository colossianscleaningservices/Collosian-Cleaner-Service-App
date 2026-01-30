import 'package:ccs_app/app/widget/common/header.dart';
import 'package:ccs_app/app/widget/common/text.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cleaner_review_controller.dart';

class CleanerReviewView extends GetView<CleanerReviewController> {
  const CleanerReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: Header(title: 'Reviews'),
      body: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText.semiBold('Name').marginOnly(bottom: 8),
                  CommonText.semiBold('Client: Client Name').marginOnly(bottom: 8),
                  Row(
                    children: [
                      CommonText.regular('Rating:').marginOnly(right: 8),
                      // Ratin
                    ],
                  )
                ],
              ).paddingAll(24),
            ).marginAll(8);
          }).marginAll(8),
    );
  }
}
