

import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  static String valueSharedPreferences = '';

  static Future<bool> saveLoginSession(value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setBool(valueSharedPreferences, value);
  }

  static Future getLoginSession() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(valueSharedPreferences);
  }
}
