import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/qamari_date_model.dart';
import '../model/mobile_app_model.dart';

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
}
