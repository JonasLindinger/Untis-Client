import 'package:dart_untis_mobile/dart_untis_mobile.dart';

class Timetable {
  static Future<void> GetTimetable(UntisSession session) async {
    // Gets the timetable from the current date
    final UntisTimetable timetable = await session.getTimetable(
      endDate: DateTime.now().add(const Duration(days: 7))
    );

    print(timetable.toString());

    // Use the timetable data
    for (final UntisPeriod period in timetable.periods) {
      print('Subject: ${period.subject?.longName}, Room: ${period.room?.name}, Teacher: ${period.teacher?.lastName}');
    }

    final UntisTimeGrid timegrid = await
    session.timeGrid;

    // Use Timetable and TimeGrid to group by day
    final List<List<UntisPeriod?>> days = timetable.groupedPeriods(timegrid);

    // Use this data
    for (final UntisPeriod? period in days[0]) {
      if (period == null) {
        print("Nothing here");
        continue;
      }
      final int hour = period.startDateTime.hour;
      final int minute = period.startDateTime.minute;
      print('Time: $hour:$minute Subject: ${period.subject}');
    }
  }
}