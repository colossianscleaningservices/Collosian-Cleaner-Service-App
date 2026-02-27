import '../../export.dart';

class Constants {
  Constants._();

  static const appName = 'Colossians Cleaning Services';
  static const bullet = '•';

  static const cleanerBottomBarItems = [
    NavigationDestination(icon: Icon(IconsaxPlusLinear.home), selectedIcon: Icon(IconsaxPlusBold.home), label: 'Dashboard'),
    NavigationDestination(icon: Icon(IconsaxPlusLinear.calendar), selectedIcon: Icon(IconsaxPlusBold.calendar), label: 'Calendar'),
    NavigationDestination(icon: Icon(IconsaxPlusLinear.briefcase), selectedIcon: Icon(IconsaxPlusBold.briefcase), label: 'Jobs'),
    NavigationDestination(icon: Icon(IconsaxPlusLinear.clock), selectedIcon: Icon(IconsaxPlusBold.clock_1), label: 'Availability'),
    NavigationDestination(icon: Icon(IconsaxPlusLinear.user), selectedIcon: Icon(IconsaxPlusBold.user), label: 'Profile'),
  ];

  static const clientBottomBarItems = [
    NavigationDestination(icon: Icon(IconsaxPlusLinear.home), selectedIcon: Icon(IconsaxPlusBold.home), label: 'Dashboard'),
    NavigationDestination(icon: Icon(IconsaxPlusLinear.calendar), selectedIcon: Icon(IconsaxPlusBold.calendar), label: 'Calendar'),
    NavigationDestination(icon: Icon(IconsaxPlusLinear.briefcase), selectedIcon: Icon(IconsaxPlusBold.briefcase), label: 'Jobs'),
    // NavigationDestination(icon: Icon(IconsaxPlusLinear.notification), selectedIcon: Icon(IconsaxPlusBold.notification), label: 'Alerts'),
    NavigationDestination(icon: Icon(IconsaxPlusLinear.user), selectedIcon: Icon(IconsaxPlusBold.user), label: 'Profile'),
  ];


  static const jobCreated = 'job_created';
  static const jobRequestAccepted = 'job_request_accepted';
}
