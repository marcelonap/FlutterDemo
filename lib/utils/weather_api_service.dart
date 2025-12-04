import 'dart:io';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class WeatherApiService {
  static WeatherApiService instance = WeatherApiService();

  Future<String> fetchWeatherWithArguments({
    String lat = "",
    String lon = "",
    DateTime? time,
  }) async {
    final uri = buildWeatherUri(lat: lat, lon: lon, dateTime: time);
    final response = await http.get(uri);
    print("Weather api response: ${response.toString()}");

    if (response.statusCode != 200) {
      print("Weather request failed: ${response.reasonPhrase}");
      return "";
    }

    final json = jsonDecode(response.body);

    final times = json['hourly']['time'] as List<dynamic>;
    final temperatures = json['hourly']['temperature_2m'] as List<dynamic>;

    return temperatures[0].toString();
  }

  Uri buildWeatherUri({
    required String lat,
    required String lon,
    required DateTime? dateTime,
  }) {
    final date = dateTime!.toIso8601String().split("T").first;
    return Uri.https("api.open-meteo.com", "/v1/forecast", {
      "latitude": lat,
      "longitude": lon,
      "hourly": "temperature_2m",
      "start_date": date,
      "end_date": date,
    });
  }
}
