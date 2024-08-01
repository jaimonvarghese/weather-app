import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

class LocalStorageService {
  static const String _cityKey = 'city';
  static const String _weatherBox = 'weatherBox';

  static Future<String?> getCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey);
  }

  static Future<void> saveCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
  }

  static Future<void> saveWeatherData(Map<String, dynamic> weatherData) async {
    var box = await Hive.openBox(_weatherBox);
    await box.put('weatherData', weatherData);
  }

  static Future<Map<String, dynamic>?> getWeatherData() async {
    var box = await Hive.openBox(_weatherBox);
    return box.get('weatherData');
  }
}
