import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/baqyat_sound_model.dart';
import '../model/mobile_app_model.dart';
import '../model/qamari_date_model.dart';

class ApiClient {
  static const String baseUrl = 'https://api.masaha.org';

  Future<String> getLastHijriDataUpdateTimestamp() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/hijridate/last-update'),
      headers: {
        'Accept-Language': 'en',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to load last Hijri update');
    }
  }

  Future<QamariDateModel> getHijriDate() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/hijridate/date'),
      headers: {
        'Accept-Language': 'en',
      },
    );

    if (response.statusCode == 200) {
      return QamariDateModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Qamari date');
    }
  }

  Future<MobileAppsResponse> getMobileApps() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mobile-apps/list'),
      headers: {
        'Accept-Language': 'en',
      },
    );

    if (response.statusCode == 200) {
      return MobileAppsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load mobile apps');
    }
  }

  Future<String> getLastBaqyatDataUpdateTimestamp() async {
    final response = await http.get(
      Uri.parse('https://www.masaha.org/api/sounds/baqyat/last-update'),
      headers: {
        'Accept-Language': 'en',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['data'] as String;
    } else {
      throw Exception('Failed to load last Baqyat update');
    }
  }

  Future<BaqyatSoundsResponse> getBaqyatSounds() async {
    final response = await http.get(
      Uri.parse('https://www.masaha.org/api/sounds/baqyat/list'),
      headers: {
        'Accept-Language': 'en',
      },
    );

    if (response.statusCode == 200) {
      return BaqyatSoundsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Baqyat sounds');
    }
  }
}
