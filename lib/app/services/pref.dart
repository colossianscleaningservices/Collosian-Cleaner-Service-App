import 'package:ccs_app/app/constants/role_constants.dart';
import 'package:get_storage/get_storage.dart';

class Prefs {
  Prefs._();

  static final Prefs instance = Prefs._();

  factory Prefs() => instance;

  static const _boxName = 'ccs_prefs';
  static const _kToken = 'token';

  static const String id = 'id';
  static const String email = 'email';
  static const String firstName = 'first_name';
  static const String image = 'image';
  static const String lastName = 'last_name';
  static const String phoneNumber = 'phone_number';
  static const String roleId = 'role_id';
  static const String timezone = 'timezone';
  static const String ipAddress = 'ip_address';
  static const String adminsKey = "admins_ids";
  static const String supportMail = "support_mail";
  static const String supportPhone = "support_phone";

  late final GetStorage _box;

  Future<void> init() async {
    await GetStorage.init(_boxName);
    _box = GetStorage(_boxName);
    _setTimezoneIfMissing();
  }

  void _setTimezoneIfMissing() {
    if (_box.read<String>(timezone) == null) {
      _box.write(timezone, DateTime.now().timeZoneName);
    }
  }

  /// Fetches public IP via get_ip_address (JSON) and stores in [ipAddress]. Call from main.dart.

  String get token => _box.read<String>(_kToken) ?? '';

  Future<void> setToken(String? token) async {
    if (token == null) {
      await _box.remove(_kToken);
      return;
    }
    await _box.write(_kToken, token);
  }

  void putData(String key, String value) => _box.write(key, value);

  void putTimeZoneData(String key, String value) => _box.write(key, value);

  String getData(String key) => _box.read<String>(key) ?? '';

  String getTimeZoneData(String key) => _box.read<String>(key) ?? DateTime.now().timeZoneName;

  String get userId => getData(id);

  String get userFullName => '${getData(firstName)} ${getData(lastName)}'.trim();

  String get userRoleString => RoleConstants.roleIdToRoleKey(int.tryParse(getData(roleId)));

  /// Get Admin IDs
  List<int> getAdminsIds() {
    final data = _box.read<List>(adminsKey);

    if (data == null) return [];

    return data.map((e) => e as int).toList();
  }

  /// Add Admin ID
  Future<void> addAdminId(int id) async {
    final List<int> admins = getAdminsIds();

    if (!admins.contains(id)) {
      admins.add(id);
      await _box.write(adminsKey, admins);
    }
  }

  /// Clear Admins
  Future<void> clearAdmins() async {
    await _box.remove(adminsKey);
  }

  Future<void> clearAll() async {
    await _box.erase();
    _setTimezoneIfMissing();
  }
}
