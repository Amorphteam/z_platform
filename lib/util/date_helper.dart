import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zahra/model/time_zone_model.dart';
import 'package:zahra/repository/database_repository.dart';
import 'package:zahra/util/prayer_time.dart';
import 'package:zahra/util/time_zone_helper.dart';
import '../api/api_client.dart';
import '../model/occasion.dart';
import '../model/qamari_date_model.dart';
import 'dart:convert';

class AMPM {
  final String ampm;
  final bool tomorrow;

  AMPM({required this.ampm, required this.tomorrow});
}

class DateHelper {
  static const String _lastDateKey = 'last_api_date';
  static const String _qamariDateKey = 'qamari_date';

  static Future<void> saveLastDateTimestamp(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDateKey, date);
  }

  static Future<String?> getLastDateTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastDateKey);
  }

  static Future<bool> isDateChanged(String newDate) async {
    final lastDate = await getLastDateTimestamp();
    return lastDate != newDate;
  }

  Future<QamariDateModel> getHijriDates() async {
    try {
      final date = await ApiClient().getLastHijriDataUpdateTimestamp();
      final hasDateChanged = await DateHelper.isDateChanged(date);
      
      if (hasDateChanged) {
        final success = await getAndSaveNewHijriDateOnline();
        if (success) {
          await DateHelper.saveLastDateTimestamp(date);
          // After successful save, get the updated local data
          return await DateHelper.getHijriDateLocally();
        } else {
          // If online fetch failed, fallback to local data
          return await DateHelper.getHijriDateLocally();
        }
      } else {
        // If date hasn't changed, just get local data
        return await DateHelper.getHijriDateLocally();
      }
    } catch (e) {
      // If any error occurs, fallback to local data
      return await DateHelper.getHijriDateLocally();
    }
  }

  static Future<void> saveHijriDateLocally(QamariDateModel qamariDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_qamariDateKey, json.encode(qamariDate.toJson()));

  }

  static const _defaultHijriData = {
    "success": true,
    "statusCode": 200,
    "data": [
      {
        "gDate": "29/05/2025",
        "hDay": 1,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "30/05/2025",
        "hDay": 2,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "31/05/2025",
        "hDay": 3,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "01/06/2025",
        "hDay": 4,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "02/06/2025",
        "hDay": 5,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "03/06/2025",
        "hDay": 6,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "04/06/2025",
        "hDay": 7,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "05/06/2025",
        "hDay": 8,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "06/06/2025",
        "hDay": 9,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "07/06/2025",
        "hDay": 10,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "08/06/2025",
        "hDay": 11,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "09/06/2025",
        "hDay": 12,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "10/06/2025",
        "hDay": 13,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "11/06/2025",
        "hDay": 14,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "12/06/2025",
        "hDay": 15,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "13/06/2025",
        "hDay": 16,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "14/06/2025",
        "hDay": 17,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "15/06/2025",
        "hDay": 18,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "16/06/2025",
        "hDay": 19,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "17/06/2025",
        "hDay": 20,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "18/06/2025",
        "hDay": 21,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "19/06/2025",
        "hDay": 22,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "20/06/2025",
        "hDay": 23,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "21/06/2025",
        "hDay": 24,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "22/06/2025",
        "hDay": 25,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "23/06/2025",
        "hDay": 26,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "24/06/2025",
        "hDay": 27,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "25/06/2025",
        "hDay": 28,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "26/06/2025",
        "hDay": 29,
        "hMonth": 12,
        "hYear": 1446
      },
      {
        "gDate": "27/06/2025",
        "hDay": 1,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "28/06/2025",
        "hDay": 2,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "29/06/2025",
        "hDay": 3,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "30/06/2025",
        "hDay": 4,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "01/07/2025",
        "hDay": 5,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "02/07/2025",
        "hDay": 6,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "03/07/2025",
        "hDay": 7,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "04/07/2025",
        "hDay": 8,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "05/07/2025",
        "hDay": 9,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "06/07/2025",
        "hDay": 10,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "07/07/2025",
        "hDay": 11,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "08/07/2025",
        "hDay": 12,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "09/07/2025",
        "hDay": 13,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "10/07/2025",
        "hDay": 14,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "11/07/2025",
        "hDay": 15,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "12/07/2025",
        "hDay": 16,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "13/07/2025",
        "hDay": 17,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "14/07/2025",
        "hDay": 18,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "15/07/2025",
        "hDay": 19,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "16/07/2025",
        "hDay": 20,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "17/07/2025",
        "hDay": 21,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "18/07/2025",
        "hDay": 22,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "19/07/2025",
        "hDay": 23,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "20/07/2025",
        "hDay": 24,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "21/07/2025",
        "hDay": 25,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "22/07/2025",
        "hDay": 26,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "23/07/2025",
        "hDay": 27,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "24/07/2025",
        "hDay": 28,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "25/07/2025",
        "hDay": 29,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "26/07/2025",
        "hDay": 30,
        "hMonth": 1,
        "hYear": 1447
      },
      {
        "gDate": "27/07/2025",
        "hDay": 1,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "28/07/2025",
        "hDay": 2,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "29/07/2025",
        "hDay": 3,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "30/07/2025",
        "hDay": 4,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "31/07/2025",
        "hDay": 5,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "01/08/2025",
        "hDay": 6,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "02/08/2025",
        "hDay": 7,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "03/08/2025",
        "hDay": 8,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "04/08/2025",
        "hDay": 9,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "05/08/2025",
        "hDay": 10,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "06/08/2025",
        "hDay": 11,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "07/08/2025",
        "hDay": 12,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "08/08/2025",
        "hDay": 13,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "09/08/2025",
        "hDay": 14,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "10/08/2025",
        "hDay": 15,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "11/08/2025",
        "hDay": 16,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "12/08/2025",
        "hDay": 17,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "13/08/2025",
        "hDay": 18,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "14/08/2025",
        "hDay": 19,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "15/08/2025",
        "hDay": 20,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "16/08/2025",
        "hDay": 21,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "17/08/2025",
        "hDay": 22,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "18/08/2025",
        "hDay": 23,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "19/08/2025",
        "hDay": 24,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "20/08/2025",
        "hDay": 25,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "21/08/2025",
        "hDay": 26,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "22/08/2025",
        "hDay": 27,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "23/08/2025",
        "hDay": 28,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "24/08/2025",
        "hDay": 29,
        "hMonth": 2,
        "hYear": 1447
      },
      {
        "gDate": "25/08/2025",
        "hDay": 1,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "26/08/2025",
        "hDay": 2,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "27/08/2025",
        "hDay": 3,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "28/08/2025",
        "hDay": 4,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "29/08/2025",
        "hDay": 5,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "30/08/2025",
        "hDay": 6,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "31/08/2025",
        "hDay": 7,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "01/09/2025",
        "hDay": 8,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "02/09/2025",
        "hDay": 9,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "03/09/2025",
        "hDay": 10,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "04/09/2025",
        "hDay": 11,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "05/09/2025",
        "hDay": 12,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "06/09/2025",
        "hDay": 13,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "07/09/2025",
        "hDay": 14,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "08/09/2025",
        "hDay": 15,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "09/09/2025",
        "hDay": 16,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "10/09/2025",
        "hDay": 17,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "11/09/2025",
        "hDay": 18,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "12/09/2025",
        "hDay": 19,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "13/09/2025",
        "hDay": 20,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "14/09/2025",
        "hDay": 21,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "15/09/2025",
        "hDay": 22,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "16/09/2025",
        "hDay": 23,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "17/09/2025",
        "hDay": 24,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "18/09/2025",
        "hDay": 25,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "19/09/2025",
        "hDay": 26,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "20/09/2025",
        "hDay": 27,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "21/09/2025",
        "hDay": 28,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "22/09/2025",
        "hDay": 29,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "23/09/2025",
        "hDay": 30,
        "hMonth": 3,
        "hYear": 1447
      },
      {
        "gDate": "24/09/2025",
        "hDay": 1,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "25/09/2025",
        "hDay": 2,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "26/09/2025",
        "hDay": 3,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "27/09/2025",
        "hDay": 4,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "28/09/2025",
        "hDay": 5,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "29/09/2025",
        "hDay": 6,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "30/09/2025",
        "hDay": 7,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "01/10/2025",
        "hDay": 8,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "02/10/2025",
        "hDay": 9,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "03/10/2025",
        "hDay": 10,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "04/10/2025",
        "hDay": 11,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "05/10/2025",
        "hDay": 12,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "06/10/2025",
        "hDay": 13,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "07/10/2025",
        "hDay": 14,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "08/10/2025",
        "hDay": 15,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "09/10/2025",
        "hDay": 16,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "10/10/2025",
        "hDay": 17,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "11/10/2025",
        "hDay": 18,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "12/10/2025",
        "hDay": 19,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "13/10/2025",
        "hDay": 20,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "14/10/2025",
        "hDay": 21,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "15/10/2025",
        "hDay": 22,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "16/10/2025",
        "hDay": 23,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "17/10/2025",
        "hDay": 24,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "18/10/2025",
        "hDay": 25,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "19/10/2025",
        "hDay": 26,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "20/10/2025",
        "hDay": 27,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "21/10/2025",
        "hDay": 28,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "22/10/2025",
        "hDay": 29,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "23/10/2025",
        "hDay": 30,
        "hMonth": 4,
        "hYear": 1447
      },
      {
        "gDate": "24/10/2025",
        "hDay": 1,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "25/10/2025",
        "hDay": 2,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "26/10/2025",
        "hDay": 3,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "27/10/2025",
        "hDay": 4,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "28/10/2025",
        "hDay": 5,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "29/10/2025",
        "hDay": 6,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "30/10/2025",
        "hDay": 7,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "31/10/2025",
        "hDay": 8,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "01/11/2025",
        "hDay": 9,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "02/11/2025",
        "hDay": 10,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "03/11/2025",
        "hDay": 11,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "04/11/2025",
        "hDay": 12,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "05/11/2025",
        "hDay": 13,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "06/11/2025",
        "hDay": 14,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "07/11/2025",
        "hDay": 15,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "08/11/2025",
        "hDay": 16,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "09/11/2025",
        "hDay": 17,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "10/11/2025",
        "hDay": 18,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "11/11/2025",
        "hDay": 19,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "12/11/2025",
        "hDay": 20,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "13/11/2025",
        "hDay": 21,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "14/11/2025",
        "hDay": 22,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "15/11/2025",
        "hDay": 23,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "16/11/2025",
        "hDay": 24,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "17/11/2025",
        "hDay": 25,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "18/11/2025",
        "hDay": 26,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "19/11/2025",
        "hDay": 27,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "20/11/2025",
        "hDay": 28,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "21/11/2025",
        "hDay": 29,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "22/11/2025",
        "hDay": 30,
        "hMonth": 5,
        "hYear": 1447
      },
      {
        "gDate": "23/11/2025",
        "hDay": 1,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "24/11/2025",
        "hDay": 2,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "25/11/2025",
        "hDay": 3,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "26/11/2025",
        "hDay": 4,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "27/11/2025",
        "hDay": 5,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "28/11/2025",
        "hDay": 6,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "29/11/2025",
        "hDay": 7,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "30/11/2025",
        "hDay": 8,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "01/12/2025",
        "hDay": 9,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "02/12/2025",
        "hDay": 10,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "03/12/2025",
        "hDay": 11,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "04/12/2025",
        "hDay": 12,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "05/12/2025",
        "hDay": 13,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "06/12/2025",
        "hDay": 14,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "07/12/2025",
        "hDay": 15,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "08/12/2025",
        "hDay": 16,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "09/12/2025",
        "hDay": 17,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "10/12/2025",
        "hDay": 18,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "11/12/2025",
        "hDay": 19,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "12/12/2025",
        "hDay": 20,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "13/12/2025",
        "hDay": 21,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "14/12/2025",
        "hDay": 22,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "15/12/2025",
        "hDay": 23,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "16/12/2025",
        "hDay": 24,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "17/12/2025",
        "hDay": 25,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "18/12/2025",
        "hDay": 26,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "19/12/2025",
        "hDay": 27,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "20/12/2025",
        "hDay": 28,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "21/12/2025",
        "hDay": 29,
        "hMonth": 6,
        "hYear": 1447
      },
      {
        "gDate": "22/12/2025",
        "hDay": 1,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "23/12/2025",
        "hDay": 2,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "24/12/2025",
        "hDay": 3,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "25/12/2025",
        "hDay": 4,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "26/12/2025",
        "hDay": 5,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "27/12/2025",
        "hDay": 6,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "28/12/2025",
        "hDay": 7,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "29/12/2025",
        "hDay": 8,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "30/12/2025",
        "hDay": 9,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "31/12/2025",
        "hDay": 10,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "01/01/2026",
        "hDay": 11,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "02/01/2026",
        "hDay": 12,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "03/01/2026",
        "hDay": 13,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "04/01/2026",
        "hDay": 14,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "05/01/2026",
        "hDay": 15,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "06/01/2026",
        "hDay": 16,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "07/01/2026",
        "hDay": 17,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "08/01/2026",
        "hDay": 18,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "09/01/2026",
        "hDay": 19,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "10/01/2026",
        "hDay": 20,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "11/01/2026",
        "hDay": 21,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "12/01/2026",
        "hDay": 22,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "13/01/2026",
        "hDay": 23,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "14/01/2026",
        "hDay": 24,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "15/01/2026",
        "hDay": 25,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "16/01/2026",
        "hDay": 26,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "17/01/2026",
        "hDay": 27,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "18/01/2026",
        "hDay": 28,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "19/01/2026",
        "hDay": 29,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "20/01/2026",
        "hDay": 30,
        "hMonth": 7,
        "hYear": 1447
      },
      {
        "gDate": "21/01/2026",
        "hDay": 1,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "22/01/2026",
        "hDay": 2,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "23/01/2026",
        "hDay": 3,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "24/01/2026",
        "hDay": 4,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "25/01/2026",
        "hDay": 5,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "26/01/2026",
        "hDay": 6,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "27/01/2026",
        "hDay": 7,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "28/01/2026",
        "hDay": 8,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "29/01/2026",
        "hDay": 9,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "30/01/2026",
        "hDay": 10,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "31/01/2026",
        "hDay": 11,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "01/02/2026",
        "hDay": 12,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "02/02/2026",
        "hDay": 13,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "03/02/2026",
        "hDay": 14,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "04/02/2026",
        "hDay": 15,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "05/02/2026",
        "hDay": 16,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "06/02/2026",
        "hDay": 17,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "07/02/2026",
        "hDay": 18,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "08/02/2026",
        "hDay": 19,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "09/02/2026",
        "hDay": 20,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "10/02/2026",
        "hDay": 21,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "11/02/2026",
        "hDay": 22,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "12/02/2026",
        "hDay": 23,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "13/02/2026",
        "hDay": 24,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "14/02/2026",
        "hDay": 25,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "15/02/2026",
        "hDay": 26,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "16/02/2026",
        "hDay": 27,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "17/02/2026",
        "hDay": 28,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "18/02/2026",
        "hDay": 29,
        "hMonth": 8,
        "hYear": 1447
      },
      {
        "gDate": "19/02/2026",
        "hDay": 1,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "20/02/2026",
        "hDay": 2,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "21/02/2026",
        "hDay": 3,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "22/02/2026",
        "hDay": 4,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "23/02/2026",
        "hDay": 5,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "24/02/2026",
        "hDay": 6,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "25/02/2026",
        "hDay": 7,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "26/02/2026",
        "hDay": 8,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "27/02/2026",
        "hDay": 9,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "28/02/2026",
        "hDay": 10,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "01/03/2026",
        "hDay": 11,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "02/03/2026",
        "hDay": 12,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "03/03/2026",
        "hDay": 13,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "04/03/2026",
        "hDay": 14,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "05/03/2026",
        "hDay": 15,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "06/03/2026",
        "hDay": 16,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "07/03/2026",
        "hDay": 17,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "08/03/2026",
        "hDay": 18,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "09/03/2026",
        "hDay": 19,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "10/03/2026",
        "hDay": 20,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "11/03/2026",
        "hDay": 21,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "12/03/2026",
        "hDay": 22,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "13/03/2026",
        "hDay": 23,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "14/03/2026",
        "hDay": 24,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "15/03/2026",
        "hDay": 25,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "16/03/2026",
        "hDay": 26,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "17/03/2026",
        "hDay": 27,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "18/03/2026",
        "hDay": 28,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "19/03/2026",
        "hDay": 29,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "20/03/2026",
        "hDay": 30,
        "hMonth": 9,
        "hYear": 1447
      },
      {
        "gDate": "21/03/2026",
        "hDay": 1,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "22/03/2026",
        "hDay": 2,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "23/03/2026",
        "hDay": 3,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "24/03/2026",
        "hDay": 4,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "25/03/2026",
        "hDay": 5,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "26/03/2026",
        "hDay": 6,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "27/03/2026",
        "hDay": 7,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "28/03/2026",
        "hDay": 8,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "29/03/2026",
        "hDay": 9,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "30/03/2026",
        "hDay": 10,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "31/03/2026",
        "hDay": 11,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "01/04/2026",
        "hDay": 12,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "02/04/2026",
        "hDay": 13,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "03/04/2026",
        "hDay": 14,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "04/04/2026",
        "hDay": 15,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "05/04/2026",
        "hDay": 16,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "06/04/2026",
        "hDay": 17,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "07/04/2026",
        "hDay": 18,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "08/04/2026",
        "hDay": 19,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "09/04/2026",
        "hDay": 20,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "10/04/2026",
        "hDay": 21,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "11/04/2026",
        "hDay": 22,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "12/04/2026",
        "hDay": 23,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "13/04/2026",
        "hDay": 24,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "14/04/2026",
        "hDay": 25,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "15/04/2026",
        "hDay": 26,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "16/04/2026",
        "hDay": 27,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "17/04/2026",
        "hDay": 28,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "18/04/2026",
        "hDay": 29,
        "hMonth": 10,
        "hYear": 1447
      },
      {
        "gDate": "19/04/2026",
        "hDay": 1,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "20/04/2026",
        "hDay": 2,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "21/04/2026",
        "hDay": 3,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "22/04/2026",
        "hDay": 4,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "23/04/2026",
        "hDay": 5,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "24/04/2026",
        "hDay": 6,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "25/04/2026",
        "hDay": 7,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "26/04/2026",
        "hDay": 8,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "27/04/2026",
        "hDay": 9,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "28/04/2026",
        "hDay": 10,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "29/04/2026",
        "hDay": 11,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "30/04/2026",
        "hDay": 12,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "01/05/2026",
        "hDay": 13,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "02/05/2026",
        "hDay": 14,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "03/05/2026",
        "hDay": 15,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "04/05/2026",
        "hDay": 16,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "05/05/2026",
        "hDay": 17,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "06/05/2026",
        "hDay": 18,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "07/05/2026",
        "hDay": 19,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "08/05/2026",
        "hDay": 20,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "09/05/2026",
        "hDay": 21,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "10/05/2026",
        "hDay": 22,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "11/05/2026",
        "hDay": 23,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "12/05/2026",
        "hDay": 24,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "13/05/2026",
        "hDay": 25,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "14/05/2026",
        "hDay": 26,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "15/05/2026",
        "hDay": 27,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "16/05/2026",
        "hDay": 28,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "17/05/2026",
        "hDay": 29,
        "hMonth": 11,
        "hYear": 1447
      },
      {
        "gDate": "18/05/2026",
        "hDay": 1,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "19/05/2026",
        "hDay": 2,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "20/05/2026",
        "hDay": 3,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "21/05/2026",
        "hDay": 4,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "22/05/2026",
        "hDay": 5,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "23/05/2026",
        "hDay": 6,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "24/05/2026",
        "hDay": 7,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "25/05/2026",
        "hDay": 8,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "26/05/2026",
        "hDay": 9,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "27/05/2026",
        "hDay": 10,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "28/05/2026",
        "hDay": 11,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "29/05/2026",
        "hDay": 12,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "30/05/2026",
        "hDay": 13,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "31/05/2026",
        "hDay": 14,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "01/06/2026",
        "hDay": 15,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "02/06/2026",
        "hDay": 16,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "03/06/2026",
        "hDay": 17,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "04/06/2026",
        "hDay": 18,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "05/06/2026",
        "hDay": 19,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "06/06/2026",
        "hDay": 20,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "07/06/2026",
        "hDay": 21,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "08/06/2026",
        "hDay": 22,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "09/06/2026",
        "hDay": 23,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "10/06/2026",
        "hDay": 24,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "11/06/2026",
        "hDay": 25,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "12/06/2026",
        "hDay": 26,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "13/06/2026",
        "hDay": 27,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "14/06/2026",
        "hDay": 28,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "15/06/2026",
        "hDay": 29,
        "hMonth": 12,
        "hYear": 1447
      },
      {
        "gDate": "16/06/2026",
        "hDay": 30,
        "hMonth": 12,
        "hYear": 1447
      }
    ]
  };


  static Future<QamariDateModel> getHijriDateLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_qamariDateKey);
    
    if (jsonString == null) {
      return QamariDateModel.fromJson(_defaultHijriData);
    }
    
    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return QamariDateModel.fromJson(jsonMap);
    } catch (e) {
      // If there's any error parsing the stored data, fallback to default data
      return QamariDateModel.fromJson(_defaultHijriData);
    }
  }

  static Future<bool> isQamariDateChanged(QamariDateModel newDate) async {
    final lastDate = await getHijriDateLocally();
    return lastDate.data != newDate.data;
  }

  Future<bool> getAndSaveNewHijriDateOnline() async {
    final apiClient = ApiClient();
    try {
      await apiClient.getHijriDate();
      final hijriDate = await apiClient.getHijriDate();
      await DateHelper.saveHijriDateLocally(hijriDate);
      return true;
    } catch (error) {
      print('Error getting Qamari date: $error');
      return false;
    }
  }


  static DateTime getDate(String time) {
    final format = DateFormat('HH:mm');
    return format.parse(time);
  }

  static List<int> getHourMinute(String time) {
    final date = getDate(time);
    return [date.hour, date.minute];
  }

  static String getToday() {
    final format = DateFormat('d-M-yyyy', 'en');
    return format.format(DateTime.now());
  }

  static String getTodayInArabic() {
    final format = DateFormat('EEE', 'ar');
    return format.format(DateTime.now());
  }

  static Future<TimeZoneModel?> getTimeZone() async {
     final currentTimeZone = await TimeZoneHelper.getTimeZone();
     return currentTimeZone;
  }

  static List<double?> getCoordinate(TimeZoneModel timeZone) {
    return [timeZone.latitude, timeZone.longitude];
  }

  static Future<AMPM?> getAMPM({
    required double latitude,
    required double longitude,
    required List<String> sunTimes,
  }) async {
    final sunRise = getDate(sunTimes[0]);
    final sunSet = getDate(sunTimes[1]);

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTime = getDate('$currentHour:$currentMinute');
    final midnight = getDate('23:59');

    if (currentTime.isAfter(sunRise) && currentTime.isBefore(sunSet)) {
      return AMPM(ampm: 'am', tomorrow: false);
    } else {
      // This is pm time check for pm1 and pm2
      // pm1 starts from sunset to midnight
      // pm2 starts from midnight to sunrise
      if (currentTime.isAfter(sunSet) && currentTime.isBefore(midnight)) {
        return AMPM(ampm: 'pm', tomorrow: true);
      } else if (currentTime.isAfter(midnight) && currentTime.isBefore(sunRise)) {
        return AMPM(ampm: 'pm', tomorrow: false);
      }

      return AMPM(ampm: 'pm', tomorrow: false);
    }
  }

  Future<String?> getTodayCalendarHijri({required QamariDateModel qamariDate, int dayDiff = 0}) async {
    final currentDate = getToday();
    final parts = currentDate.split('-');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1])?.toInt() ?? 0;
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    if (qamariDate.data.isEmpty) return null;

    // Find the matching date in the Qamari data
    final matchingDate = qamariDate.data.firstWhere(
      (date) => date.gDate == '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year',
      orElse: () => qamariDate.data.first,
    );

    // Apply the day difference
    final adjustedDay = matchingDate.hDay + dayDiff;
    
    return '${matchingDate.hYear}-${matchingDate.hMonth.toString().padLeft(2, '0')}-${adjustedDay.toString().padLeft(2, '0')}';
  }

  static List<String> getSunRiseSunSet(double? latitude, double? longitude) {
    final pt = PrayTime();
    pt.setTimeFormat(pt.time24); // time24
    pt.setCalcMethod(pt.custom); // custom
    pt.setAsrJuristic(pt.shafii); // shafii
    pt.setAdjustHighLats(pt.angleBased); // angleBased
    
    final offsets = [0, -120, 0, 0, 0, 0, 0, 0]; // {Fajr,Sunrise,Dhuhr,Asr,Sunset,Maghrib,Isha}
    pt.tune(offsets);

    final now = DateTime.now();
    final prayerTimes = pt.getPrayerTimes(now, latitude??0, longitude??0, pt.getTimeZone());
    
    return [prayerTimes[1], prayerTimes[4]]; // Return sunrise and sunset times
  }

  static Future<AMPM?> handleAMPM() async {
    try {
      // 1. Get timezone
      final timeZone = await getTimeZone();
      if (timeZone == null) return null;

      // 2. Get coordinates from timezone
      final coordinates = getCoordinate(timeZone);
      if (coordinates.length != 2) return null;

      // 3. Get sunrise and sunset times
      final sunTimes = getSunRiseSunSet(coordinates[0]??0, coordinates[1]??0);
      if (sunTimes.length != 2) return null;

      // 4. Calculate AM/PM
      return getAMPM(
        latitude: coordinates[0]??0,
        longitude: coordinates[1]??0,
        sunTimes: sunTimes,
      );
    } catch (e) {
      print('Error in getAMPMWithLocation: $e');
      return null;
    }
  }

  static Future<List<Occasion>> getOccasionsForCurrentDate() async {
    try {
      // Initialize timezone
      await TimeZoneHelper.initialize();
      
      // Get dates
      final hijriDates = await DateHelper().getHijriDates();
      final todayHijri = await DateHelper().getTodayCalendarHijri(qamariDate: hijriDates);
      
      if (todayHijri == null) {
        return [];
      }

      // Parse the Hijri date
      final parts = todayHijri.split('-');
      if (parts.length != 3) {
        return [];
      }

      final month = int.tryParse(parts[1]) ?? 0;
      final day = int.tryParse(parts[2]) ?? 0;
      
      // Get occasions
      final occasions = await DatabaseRepository().getOccasionsByDate(day, month);
      
      return occasions;
    } catch (e) {
      print('Error getting occasions: $e');
      return [];
    }
  }
}
