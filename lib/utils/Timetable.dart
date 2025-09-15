import 'package:dart_untis_mobile/dart_untis_mobile.dart';

class Timetable {
  static Future<void> GetTimeTable(UntisSession session) async {
    // Gets the timetable from the current date
    final UntisTimetable timetable = await session.getTimetable(
      endDate: DateTime.now().add(const Duration(days: 7))
    );

    print(timetable.toString());

    // Use the timetable data
    for (final UntisPeriod period in timetable.periods) {
      print('Subject: ${period.subject?.longName}, Room: ${period.room?.name}, Teacher: ${period.teacher?.lastName}');
    }
  }
}