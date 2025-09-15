import 'package:flutter/material.dart';
import 'package:dart_untis_mobile/dart_untis_mobile.dart';

import '../utils/Timetable.dart';

class TimetableCalendarView extends StatefulWidget {
  final UntisSession session;
  const TimetableCalendarView({super.key, required this.session});

  @override
  State<TimetableCalendarView> createState() => _TimetableCalendarViewState();
}

class _TimetableCalendarViewState extends State<TimetableCalendarView> {
  List<List<List<UntisPeriod?>>>? weeks; // weeks -> days -> periods
  int currentWeek = 0;

  final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  @override
  void initState() {
    super.initState();
    LoadTimetable();
  }

  Future<void> LoadTimetable() async {
    final result = await Timetable.GetTimeGrid(widget.session);

    if (result.isEmpty) return;

    // Split into weeks of 5 days (Mon-Fri)
    List<List<List<UntisPeriod?>>> tempWeeks = [];
    for (int i = 0; i < result.length; i += 5) {
      tempWeeks.add(result.skip(i).take(5).toList());
    }

    setState(() {
      weeks = tempWeeks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (weeks == null || weeks!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final week = weeks![currentWeek];

    // Determine earliest and latest periods for time column
    int earliestHour = 23;
    int latestHour = 0;
    for (var day in week) {
      for (var period in day) {
        if (period == null) continue;
        final start = period.startDateTime.hour;
        final end = period.endDateTime.hour;
        if (start < earliestHour) earliestHour = start;
        if (end > latestHour) latestHour = end;
      }
    }

    if (latestHour < earliestHour) latestHour = earliestHour + 1;
    final numberOfSlots = (latestHour - earliestHour + 1).clamp(1, 24);
    final timeSlots = List.generate(numberOfSlots, (index) => earliestHour + index);

    return Row(
      children: [
        TimeScale(timeSlots),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: weekdays.map((day) {
              return Day(day, week, timeSlots, earliestHour);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget Day(String day, List<List<UntisPeriod?>> week, List<int> timeSlots, int earliestHour) {
    final colors = Theme.of(context).colorScheme;

    final dayIndex = weekdays.indexOf(day);
    final dayPeriods = week[dayIndex];

    return Expanded(
      child: Column(
        children: [
          // Top bar (day)
          Container(
            height: 40,
            width: double.infinity,
            color: colors.secondaryContainer,
            alignment: Alignment.center,
            child: Text(
              day,
              style: TextStyle(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          // Periods
          Flexible(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Stack(
                  children: [
                    // Background time slots for spacing
                    Column(
                      children: timeSlots.map((_) => Container(height: 60)).toList(),
                    ),

                    // Actual periods
                    ...dayPeriods.map((period) {
                      if (period == null) return const SizedBox.shrink();

                      final startHour = period.startDateTime.hour;
                      final startMinute = period.startDateTime.minute;
                      final endHour = period.endDateTime.hour;
                      final endMinute = period.endDateTime.minute;

                      final startOffset = ((startHour + startMinute / 60) - earliestHour) * 60;
                      final height = ((endHour + endMinute / 60) - (startHour + startMinute / 60)) * 60;

                      return Positioned(
                        top: startOffset,
                        left: 0,
                        right: 0,
                        height: height,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                period.subject?.longName ?? "Unknown",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onPrimaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                period.room?.name ?? "Unknown",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colors.onPrimaryContainer.withOpacity(0.8)
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                period.teacher?.lastName ?? "Unknown",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colors.onPrimaryContainer.withOpacity(0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget TimeScale(List<int> timeSlots) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 50,
      child: Column(
        children: [
          // Top bar
          Container(
            height: 40,
            color: colors.secondaryContainer,
          ),

          // Small padding
          SizedBox(
            height: 4,
          ),

          // Times
          Column(
            children: timeSlots.map((hour) => Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade700),
                ),
              ),
              child: Text(
                '$hour:00',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}