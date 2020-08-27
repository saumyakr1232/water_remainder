import 'dart:convert';

class SleepData {
  final int duration;
  final String startTime;

  SleepData({this.duration, this.startTime});

  Map toJson() {
    return {"duration": duration, "startTime": startTime};
  }

  factory SleepData.fromJson(Map<String, dynamic> map) {
    return SleepData(
      duration: map['duration'] as int,
      startTime: map['startTime'] as String,
    );
  }

  String json() {
    return jsonEncode(this);
  }
}
