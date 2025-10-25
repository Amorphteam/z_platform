import 'dart:convert';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter/services.dart';
import '../model/time_zone_model.dart';


class TimeZoneHelper {
  static List<TimeZoneModel>? _timeZones;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/json/timezonesDB.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _timeZones = jsonList.map((json) {
        // Helper function to safely parse numeric values
        double parseDouble(dynamic value) {
          if (value is num) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          return 0.0;
        }

        int parseInt(dynamic value) {
          if (value is num) return value.toInt();
          if (value is String) return int.tryParse(value) ?? 0;
          return 0;
        }

        // Ensure all required fields are present and of correct type
        final Map<String, dynamic> safeJson = {
          'country_code': json['country_code']?.toString() ?? '',
          'latitude': parseDouble(json['latitude']),
          'longitude': parseDouble(json['longitude']),
          'comments': json['comments']?.toString() ?? '',
          'zone': json['zone']?.toString() ?? '',
          'diff': parseInt(json['diff']),
        };
        return TimeZoneModel.fromJson(safeJson);
      }).toList();
      _isInitialized = true;
    } catch (e) {
      print('Error loading timezone data: $e');
      _timeZones = [];
      _isInitialized = true; // Mark as initialized even if empty to prevent infinite retries
    }
  }

  static List<TimeZoneModel> get timeZones {
    if (!_isInitialized) {
      throw StateError('TimeZoneHelper not initialized. Call initialize() first.');
    }
    return _timeZones ?? [];
  }




  static Future<TimeZoneModel?> getTimeZone() async {
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final timeZoneModel = TimeZoneModel(
        zone: timezoneInfo.toString()
      );
      return timeZoneModel;
    } catch (e) {
      return null;
    }
  }

}