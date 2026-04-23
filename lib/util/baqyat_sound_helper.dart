import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../model/baqyat_sound_model.dart';

class BaqyatSoundHelper {
  static const String _lastUpdateKey = 'baqyat_last_update';
  static const String _baqyatSoundsKey = 'baqyat_sounds_list';

  static const Map<String, dynamic> _defaultBaqyatData = {
    'success': true,
    'statusCode': 200,
    'data': [
      {
        'id': 2140,
        'title': 'دعاء الحزين',
        'files': [
          {
            'ReaderID': 7,
            'ReaderName': 'عبد الحي آل قنبر',
            'picPath':
                'https://www.masaha.org/public/uploads/mafatih/readers/zlcAai6XqFsObvQ0FuU2.jpg',
            'Path': null,
            'pathM4a':
                'https://www.masaha.org/public/uploads/mafatih/files/audio/2140__X9aSE.m4a',
            'size': '1900055',
            'duration': '307.735',
          }
        ],
      }
    ],
  };

  static Future<void> saveLastUpdateTimestamp(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdateKey, date);
  }

  static Future<String?> getLastUpdateTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdateKey);
  }

  static Future<bool> isUpdateDateChanged(String newDate) async {
    final lastDate = await getLastUpdateTimestamp();
    return lastDate != newDate;
  }

  static Future<void> saveBaqyatSoundsLocally(BaqyatSoundsResponse sounds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baqyatSoundsKey, json.encode(sounds.toJson()));
  }

  static Future<BaqyatSoundsResponse> getBaqyatSoundsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_baqyatSoundsKey);

    if (jsonString == null) {
      return BaqyatSoundsResponse.fromJson(_defaultBaqyatData);
    }

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return BaqyatSoundsResponse.fromJson(jsonMap);
    } on Object catch (_) {
      return BaqyatSoundsResponse.fromJson(_defaultBaqyatData);
    }
  }

  Future<BaqyatSoundsResponse> getBaqyatSounds() async {
    try {
      final latestUpdateTime = await ApiClient().getLastBaqyatDataUpdateTimestamp();
      final hasDateChanged = await isUpdateDateChanged(latestUpdateTime);

      if (hasDateChanged) {
        final success = await getAndSaveNewBaqyatSoundsOnline();
        if (success) {
          await saveLastUpdateTimestamp(latestUpdateTime);
          return getBaqyatSoundsLocally();
        }
      }

      return getBaqyatSoundsLocally();
    } on Object catch (_) {
      return getBaqyatSoundsLocally();
    }
  }

  Future<bool> getAndSaveNewBaqyatSoundsOnline() async {
    try {
      final sounds = await ApiClient().getBaqyatSounds();
      await saveBaqyatSoundsLocally(sounds);
      return true;
    } on Object catch (_) {
      return false;
    }
  }
}
