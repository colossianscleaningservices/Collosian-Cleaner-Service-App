import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../cleaner_dashboard_controller.dart';
import 'cleaner_jobs_view.dart';

/// Full jobs list opened from Calendar "View all jobs" (not a bottom-nav tab).
class CleanerAllJobsView extends GetView<CleanerDashboardController> {
  const CleanerAllJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const Header(
        title: 'All jobs',
        headerLogoIcon: false,
        hasBackIcon: true,
        titleCentered: false,
      ),
      backgroundColor: context.colorScheme.surface,
      body: const CleanerJobsView(),
    );
  }
}
