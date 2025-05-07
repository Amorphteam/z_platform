
import 'dart:math' as math;

class PrayTime {
  // ---------------------- Global Variables --------------------
  int _calcMethod = 0; // calculation method
  int _asrJuristic = 0; // Juristic method for Asr
  int _dhuhrMinutes = 0; // minutes after mid-day for Dhuhr
  int _adjustHighLats = 1; // adjusting method for higher latitudes
  int _timeFormat = 0; // time format
  double _lat = 0; // latitude
  double _lng = 0; // longitude
  double _timeZone = 0; // time-zone
  double _jDate = 0; // Julian date

  // ------------------------------------------------------------
  // Calculation Methods
  int jafari = 0; // Ithna Ashari
  int karachi = 1; // University of Islamic Sciences, Karachi
  int isna = 2; // Islamic Society of North America (ISNA)
  int mwl = 3; // Muslim World League (MWL)
  int makkah = 4; // Umm al-Qura, Makkah
  int egypt = 5; // Egyptian General Authority of Survey
  int custom = 7; // Custom Setting
  int tehran = 6; // Institute of Geophysics, University of Tehran

  // Juristic Methods
  int shafii = 0; // Shafii (standard)
  int hanafi = 1; // Hanafi

  // Adjusting Methods for Higher Latitudes
  int none = 0; // No adjustment
  int midNight = 1; // middle of night
  int oneSeventh = 2; // 1/7th of night
  int angleBased = 3; // angle/60th of night

  // Time Formats
  int time24 = 0; // 24-hour format
  int time12 = 1; // 12-hour format
  int time12NS = 2; // 12-hour format with no suffix
  int floating = 3; // floating point number

  // Time Names
  List<String> _timeNames = [];
  String _invalidTime = "-----"; // The string used for invalid times

  // --------------------- Technical Settings --------------------
  int _numIterations = 1; // number of iterations needed to compute times

  // ------------------- Calc Method Parameters --------------------
  Map<int, List<double>> _methodParams = {};

  double myMidnight = 0;
  String mySMidnight = "0";

  List<double>? _prayerTimesCurrent;
  List<int> _offsets = List.filled(8, 0);

  PrayTime() {
    // Initialize vars
    setCalcMethod(0);
    setAsrJuristic(0);
    setDhuhrMinutes(0);
    setAdjustHighLats(1);
    setTimeFormat(0);

    // Time Names
    _timeNames = [
      "Fajr",
      "Sunrise",
      "Dhuhr",
      "Asr",
      "Sunset",
      "Maghrib",
      "Isha"
    ];

    // Method Parameters
    _methodParams[jafari] = [16, 0, 4, 0, 14];
    _methodParams[karachi] = [18, 1, 0, 0, 18];
    _methodParams[isna] = [15, 1, 0, 0, 15];
    _methodParams[mwl] = [18, 1, 0, 0, 17];
    _methodParams[makkah] = [18.5, 1, 0, 1, 90];
    _methodParams[egypt] = [19.5, 1, 0, 0, 17.5];
    _methodParams[tehran] = [17.7, 0, 4.5, 0, 14];
    _methodParams[custom] = [18, 0, 3.75, 0, 14];
  }

  // ---------------------- Trigonometric Functions -----------------------
  double _fixangle(double a) {
    a = a - (360 * (a / 360.0).floor());
    a = a < 0 ? (a + 360) : a;
    return a;
  }

  double _fixhour(double a) {
    a = a - 24.0 * (a / 24.0).floor();
    a = a < 0 ? (a + 24) : a;
    return a;
  }

  double _radiansToDegrees(double alpha) {
    return ((alpha * 180.0) / math.pi);
  }

  double _degreesToRadians(double alpha) {
    return ((alpha * math.pi) / 180.0);
  }

  double _dsin(double d) {
    return (math.sin(_degreesToRadians(d)));
  }

  double _dcos(double d) {
    return (math.cos(_degreesToRadians(d)));
  }

  double _dtan(double d) {
    return (math.tan(_degreesToRadians(d)));
  }

  double _darcsin(double x) {
    double val = math.asin(x);
    return _radiansToDegrees(val);
  }

  double _darccos(double x) {
    double val = math.acos(x);
    return _radiansToDegrees(val);
  }

  double _darctan(double x) {
    double val = math.atan(x);
    return _radiansToDegrees(val);
  }

  double _darctan2(double y, double x) {
    double val = math.atan2(y, x);
    return _radiansToDegrees(val);
  }

  double _darccot(double x) {
    double val = math.atan2(1.0, x);
    return _radiansToDegrees(val);
  }

  // ---------------------- Julian Date Functions -----------------------
  double _julianDate(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    int A = (year / 100.0).floor();
    int B = 2 - A + (A / 4.0).floor();
    double JD = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        B -
        1524.5;
    return JD;
  }

  // ---------------------- Calculation Functions -----------------------
  List<double> _sunPosition(double jd) {
    double D = jd - 2451545;
    double g = _fixangle(357.529 + 0.98560028 * D);
    double q = _fixangle(280.459 + 0.98564736 * D);
    double L = _fixangle(q + (1.915 * _dsin(g)) + (0.020 * _dsin(2 * g)));

    double e = 23.439 - (0.00000036 * D);
    double d = _darcsin(_dsin(e) * _dsin(L));
    double RA = (_darctan2((_dcos(e) * _dsin(L)), (_dcos(L)))) / 15.0;
    RA = _fixhour(RA);
    double EqT = q / 15.0 - RA;

    return [d, EqT];
  }

  double _equationOfTime(double jd) {
    return _sunPosition(jd)[1];
  }

  double _sunDeclination(double jd) {
    return _sunPosition(jd)[0];
  }

  double _computeMidDay(double t) {
    double T = _equationOfTime(_jDate + t);
    double Z = _fixhour(12 - T);
    return Z;
  }

  double _computeTime(double G, double t) {
    double D = _sunDeclination(_jDate + t);
    double Z = _computeMidDay(t);
    double Beg = -_dsin(G) - _dsin(D) * _dsin(_lat);
    double Mid = _dcos(D) * _dcos(_lat);
    double V = _darccos(Beg / Mid) / 15.0;

    return Z + (G > 90 ? -V : V);
  }

  double _computeAsr(double step, double t) {
    double D = _sunDeclination(_jDate + t);
    double G = -_darccot(step + _dtan((_lat - D).abs()));
    return _computeTime(G, t);
  }

  // ---------------------- Misc Functions -----------------------
  double timeDiff(double time1, double time2) {
    return _fixhour(time2 - time1);
  }

  // -------------------- Interface Functions --------------------
  List<String> getDatePrayerTimes(
      int year, int month, int day, double latitude, double longitude, double tZone) {
    _lat = latitude;
    _lng = longitude;
    _timeZone = tZone;
    _jDate = _julianDate(year, month, day);
    double lonDiff = longitude / (15.0 * 24.0);
    _jDate = _jDate - lonDiff;
    return _computeDayTimes();
  }

  List<String> getPrayerTimes(
      DateTime date, double latitude, double longitude, double tZone) {
    return getDatePrayerTimes(
        date.year, date.month, date.day, latitude, longitude, tZone);
  }

  void setCustomParams(List<double> params) {
    for (int i = 0; i < 5; i++) {
      if (params[i] == -1) {
        params[i] = _methodParams[_calcMethod]![i];
        _methodParams[custom] = params;
      } else {
        _methodParams[custom]![i] = params[i];
      }
    }
    setCalcMethod(custom);
  }

  void setFajrAngle(double angle) {
    List<double> params = [angle, -1, -1, -1, -1];
    setCustomParams(params);
  }

  void setMaghribAngle(double angle) {
    List<double> params = [-1, 0, angle, -1, -1];
    setCustomParams(params);
  }

  void setIshaAngle(double angle) {
    List<double> params = [-1, -1, -1, 0, angle];
    setCustomParams(params);
  }

  void setMaghribMinutes(double minutes) {
    List<double> params = [-1, 1, minutes, -1, -1];
    setCustomParams(params);
  }

  void setIshaMinutes(double minutes) {
    List<double> params = [-1, -1, -1, 1, minutes];
    setCustomParams(params);
  }

  String _floatToTime24(double time) {
    if (time.isNaN) {
      return _invalidTime;
    }

    time = _fixhour(time + 0.5 / 60.0); // add 0.5 minutes to round
    int hours = time.floor();
    int minutes = ((time - hours) * 60.0).floor();

    String result;
    if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
      result = "0$hours:0${minutes.round()}";
    } else if ((hours >= 0 && hours <= 9)) {
      result = "0$hours:${minutes.round()}";
    } else if ((minutes >= 0 && minutes <= 9)) {
      result = "$hours:0${minutes.round()}";
    } else {
      result = "$hours:${minutes.round()}";
    }
    return result;
  }

  String _floatToTime12(double time, bool noSuffix) {
    if (time.isNaN) {
      return _invalidTime;
    }

    time = _fixhour(time + 0.5 / 60); // add 0.5 minutes to round
    int hours = time.floor();
    int minutes = ((time - hours) * 60).floor();
    String suffix, result;

    if (hours >= 12) {
      suffix = "م  ";
    } else {
      suffix = "ص  ";
    }

    hours = ((((hours + 12) - 1) % (12)) + 1);

    if (!noSuffix) {
      if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
        result = "$suffix 0$hours:0${minutes.round()}";
      } else if ((hours >= 0 && hours <= 9)) {
        result = "$suffix 0$hours:${minutes.round()}";
      } else if ((minutes >= 0 && minutes <= 9)) {
        result = "$suffix $hours:0${minutes.round()}";
      } else {
        result = "$suffix $hours:${minutes.round()}";
      }
    } else {
      if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
        result = "0$hours:0${minutes.round()}";
      } else if ((hours >= 0 && hours <= 9)) {
        result = "0$hours:${minutes.round()}";
      } else if ((minutes >= 0 && minutes <= 9)) {
        result = "$hours:0${minutes.round()}";
      } else {
        result = "$hours:${minutes.round()}";
      }
    }
    return result;
  }

  String _floatToTime12NS(double time) {
    return _floatToTime12(time, true);
  }

  // ---------------------- Compute Prayer Times -----------------------
  List<double> _computeTimes(List<double> times) {
    List<double> t = _dayPortion(times);

    double Fajr = _computeTime(
        180 - _methodParams[_calcMethod]![0], t[0]);

    double Sunrise = _computeTime(180 - 0.833, t[1]);

    double Dhuhr = _computeMidDay(t[2]);
    double Asr = _computeAsr((1 + _asrJuristic).toDouble(), t[3]);
    double Sunset = _computeTime(0.833, t[4]);

    double Maghrib = _computeTime(
        _methodParams[_calcMethod]![2], t[5]);
    double Isha = _computeTime(
        _methodParams[_calcMethod]![4], t[6]);

    myMidnight = Sunset + ((timeDiff(Sunset, Fajr)) / 2);

    return [Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha, myMidnight];
  }

  List<String> _computeDayTimes() {
    List<double> times = [5, 6, 12, 13, 18, 18, 18, 23]; // default times

    for (int i = 1; i <= _numIterations; i++) {
      times = _computeTimes(times);
    }

    times = _adjustTimes(times);
    times = _tuneTimes(times);

    return _adjustTimesFormat(times);
  }

  List<double> _adjustTimes(List<double> times) {
    for (int i = 0; i < times.length; i++) {
      times[i] += _timeZone - _lng / 15;
    }

    times[2] += _dhuhrMinutes / 60; // Dhuhr
    if (_methodParams[_calcMethod]![1] == 1) // Maghrib
    {
      times[5] = times[4] + _methodParams[_calcMethod]![2] / 60;
    }
    if (_methodParams[_calcMethod]![3] == 1) // Isha
    {
      times[6] = times[5] + _methodParams[_calcMethod]![4] / 60;
    }

    if (_adjustHighLats != none) {
      times = _adjustHighLatTimes(times);
    }

    return times;
  }

  List<String> _adjustTimesFormat(List<double> times) {
    List<String> result = [];

    if (_timeFormat == floating) {
      for (double time in times) {
        result.add(time.toString());
      }
      return result;
    }

    for (int i = 0; i < times.length; i++) {
      if (_timeFormat == time12) {
        result.add(_floatToTime12(times[i], false));
      } else if (_timeFormat == time12NS) {
        result.add(_floatToTime12(times[i], true));
      } else {
        result.add(_floatToTime24(times[i]));
      }
    }
    return result;
  }

  List<double> _adjustHighLatTimes(List<double> times) {
    double nightTime = timeDiff(times[4], times[1]); // sunset to sunrise

    // Adjust Fajr
    double FajrDiff = _nightPortion(_methodParams[_calcMethod]![0]) * nightTime;

    if (times[0].isNaN || timeDiff(times[0], times[1]) > FajrDiff) {
      times[0] = times[1] - FajrDiff;
    }

    // Adjust Isha
    double IshaAngle =
        (_methodParams[_calcMethod]![3] == 0) ? _methodParams[_calcMethod]![4] : 18;
    double IshaDiff = _nightPortion(IshaAngle) * nightTime;
    if (times[6].isNaN || timeDiff(times[4], times[6]) > IshaDiff) {
      times[6] = times[4] + IshaDiff;
    }

    // Adjust Maghrib
    double MaghribAngle =
        (_methodParams[_calcMethod]![1] == 0) ? _methodParams[_calcMethod]![2] : 4;
    double MaghribDiff = _nightPortion(MaghribAngle) * nightTime;
    if (times[5].isNaN || timeDiff(times[4], times[5]) > MaghribDiff) {
      times[5] = times[4] + MaghribDiff;
    }

    return times;
  }

  double _nightPortion(double angle) {
    double calc = 0;

    if (_adjustHighLats == angleBased) {
      calc = (angle) / 60.0;
    } else if (_adjustHighLats == midNight) {
      calc = 0.5;
    } else if (_adjustHighLats == oneSeventh) {
      calc = 0.14286;
    }

    return calc;
  }

  List<double> _dayPortion(List<double> times) {
    for (int i = 0; i < 7; i++) {
      times[i] /= 24;
    }
    return times;
  }

  void tune(List<int> offsetTimes) {
    for (int i = 0; i < offsetTimes.length; i++) {
      _offsets[i] = offsetTimes[i];
    }
  }

  List<double> _tuneTimes(List<double> times) {
    for (int i = 0; i < times.length; i++) {
      times[i] = times[i] + _offsets[i] / 60.0;
    }
    return times;
  }

  // Getters and Setters
  int getCalcMethod() => _calcMethod;
  void setCalcMethod(int value) => _calcMethod = value;

  int getAsrJuristic() => _asrJuristic;
  void setAsrJuristic(int value) => _asrJuristic = value;

  int getDhuhrMinutes() => _dhuhrMinutes;
  void setDhuhrMinutes(int value) => _dhuhrMinutes = value;

  int getAdjustHighLats() => _adjustHighLats;
  void setAdjustHighLats(int value) => _adjustHighLats = value;

  int getTimeFormat() => _timeFormat;
  void setTimeFormat(int value) => _timeFormat = value;

  double getLat() => _lat;
  void setLat(double value) => _lat = value;

  double getLng() => _lng;
  void setLng(double value) => _lng = value;

  double getTimeZone() => _timeZone;
  void setTimeZone(double value) => _timeZone = value;

  double getJDate() => _jDate;
  void setJDate(double value) => _jDate = value;

  List<String> getTimeNames() => _timeNames;
}
