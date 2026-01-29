import 'package:get_storage/get_storage.dart';

class Prefs {
  Prefs._();

  static final Prefs instance = Prefs._();

  factory Prefs() => instance;

  static const _boxName = 'ccs_prefs';
  static const _kToken = 'token';

  late final GetStorage _box;

  Future<void> init() async {
    await GetStorage.init(_boxName);
    _box = GetStorage(_boxName);
  }

  String? get token => _box.read<String>(_kToken);

  Future<void> setToken(String? token) async {
    if (token == null) {
      await _box.remove(_kToken);
      return;
    }
    await _box.write(_kToken, token);
  }

  Future<void> clearAll() async {
    await _box.erase();
  }
}
