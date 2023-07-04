import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerConfig {
  static SharedPreferences? sharedPrefs;

  static Future<void> initSharedPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  static Future<void> setIsLoop(bool isLoop) async {
    await sharedPrefs!.setBool('isLoop', isLoop);
  }

  static bool? getIsLoop() {
   return sharedPrefs!.getBool('isLoop');
  }
}
