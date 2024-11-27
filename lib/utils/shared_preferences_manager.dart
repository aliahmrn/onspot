import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static final SharedPreferencesManager _instance = SharedPreferencesManager._internal();
  late SharedPreferences _prefs;

  SharedPreferencesManager._internal();

  static Future<void> init() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _instance._prefs;
}
