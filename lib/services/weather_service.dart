import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_key.dart';


class WeatherService {
  static const String _apiKey = apiKey;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final response = await http.get(Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current weather data');
    }
  }

  static Future<Map<String, dynamic>> fetchWeatherForecast(String city) async {
    final response = await http.get(Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather forecast data');
    }
  }
}
