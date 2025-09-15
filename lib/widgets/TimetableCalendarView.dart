import 'package:flutter/material.dart';
import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import '../utils/Timetable.dart';
import 'dart:ui';

class CustomColors {
  static const Color backgroundColor = Color.fromRGBO(54, 54, 54, 1);
  static const Color primary = Color.fromRGBO(50, 144, 143, 1);
  static const Color secondary = Color.fromRGBO(230, 149, 151, 1);
  static const Color highlight = Color.fromRGBO(249, 251, 242, 1);
  static const Color other = Color.fromRGBO(215, 249, 255, 1);
}

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
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
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

    return Column(
      children: [
        // Day headers + spacing for time column
        Row(
          children: [
            Container(width: 50), // space for time column
            ...weekdays.map((d) => Expanded(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                color: CustomColors.primary,
                child: Text(
                  d,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )).toList(),
          ],
        ),
        const SizedBox(height: 4),
        // Main timetable
        Expanded(
          child: Row(
            children: [
              // Time column
              Container(
                width: 50,
                color: CustomColors.backgroundColor,
                child: Column(
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  )).toList(),
                ),
              ),
              // Week view scrollable horizontally
              Expanded(
                child: PageView.builder(
                  itemCount: weeks!.length,
                  onPageChanged: (index) => setState(() => currentWeek = index),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, pageIndex) {
                    final pageWeek = weeks![pageIndex];

                    return Row(
                      children: pageWeek.map((day) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: CustomColors.backgroundColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Stack(
                              children: [
                                // Background time slots for spacing
                                Column(
                                  children: timeSlots.map((_) => Container(height: 60)).toList(),
                                ),
                                // Periods
                                ...day.map((period) {
                                  if (period == null) return Container();

                                  final startHour = period.startDateTime.hour;
                                  final startMinute = period.startDateTime.minute;
                                  final endHour = period.endDateTime.hour;
                                  final endMinute = period.endDateTime.minute;

                                  final startOffset = ((startHour + startMinute / 60) - earliestHour) * 60;
                                  final height = ((endHour + endMinute / 60) - (startHour + startMinute / 60)) * 60;

                                  return Positioned(
                                    top: startOffset,
                                    left: 4,
                                    right: 4,
                                    height: height,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: CustomColors.secondary,
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
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            period.room?.name ?? "Unknown",
                                            style: const TextStyle(
                                                fontSize: 10, color: Colors.white70),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            period.teacher?.lastName ?? "Unknown",
                                            style: const TextStyle(
                                                fontSize: 10, color: Colors.white70),
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
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}