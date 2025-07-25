import 'package:flutter/material.dart';

class AttendanceEntry {
  final DateTime date;
  final TimeOfDay timeIn;
  final TimeOfDay timeOut;

  AttendanceEntry({
    required this.date,
    required this.timeIn,
    required this.timeOut,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date']);
    final timeIn = _parseTime(json['timeIn']);
    final timeOut = _parseTime(json['timeOut']);

    return AttendanceEntry(
      date: date,
      timeIn: timeIn,
      timeOut: timeOut,
    );
  }

  static TimeOfDay _parseTime(String? timeString) {
    if (timeString != null && timeString.isNotEmpty) {
      final timeParts = timeString.split(':').map(int.parse).toList();
      return TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
    } else {
      // If timeString is null or empty, return default time (midnight)
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }
}
