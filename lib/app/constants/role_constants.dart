// ignore_for_file: constant_identifier_names
class RoleConstants {
  RoleConstants._();

  static const int roleIdClient = 1;
  static const int roleIdCleaner = 2;
  static const int roleIdCommon = 3;

  static const String roleKeyClient = 'client';
  static const String roleKeyCleaner = 'cleaner';
  static const String roleKeyAdmin = 'admin';

  static String roleIdToRoleKey(int? roleId) {
    if (roleId == null) return roleKeyClient;
    return switch (roleId) {
      roleIdClient => roleKeyClient,
      roleIdCleaner => roleKeyCleaner,
      _ => roleKeyClient,
    };
  }

  static bool isClient(int? roleId) => roleId == roleIdClient;

  static bool isCleaner(int? roleId) => roleId == roleIdCleaner;
}

enum UserRole {
  client,
  cleaner,
}

extension UserRoleX on UserRole {
  int get roleId => this == UserRole.client ? RoleConstants.roleIdClient : RoleConstants.roleIdCleaner;

  String get roleKey => this == UserRole.client ? RoleConstants.roleKeyClient : RoleConstants.roleKeyCleaner;
}
