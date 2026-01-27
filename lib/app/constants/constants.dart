import '../../export.dart';

class Constants {
  Constants._();

  static const appName = 'Colossians Cleaning Services';

  static const cleanerTopHeading = [
    ("Dashboard", "Ready for today's work?"),
    ("Calendar", "View your schedule"),
    ("Jobs", "View your jobs"),
    ("Availability", "Edit your availability"),
    ("Profile", "Edit your profile"),
  ];

  static const clientTopHeading = [
    ("Dashboard", "Ready for today's work?"),
    ("Calendar", "View your schedule"),
    ("Jobs", "View your jobs"),
    ("Alerts", "View your alerts"),
    ("Profile", "Edit your profile"),
  ];

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
    NavigationDestination(icon: Icon(IconsaxPlusLinear.notification), selectedIcon: Icon(IconsaxPlusBold.notification), label: 'Alerts'),
    NavigationDestination(icon: Icon(IconsaxPlusLinear.user), selectedIcon: Icon(IconsaxPlusBold.user), label: 'Profile'),
  ];
}
