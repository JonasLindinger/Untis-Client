import 'dart:math';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:dart_untis_mobile/dart_untis_mobile.dart';

class TimetableCalendarView extends StatefulWidget {
  final UntisSession session;

  const TimetableCalendarView({super.key, required this.session});

  @override
  State<TimetableCalendarView> createState() => _TimetableCalendarViewState();
}

class _TimetableCalendarViewState extends State<TimetableCalendarView> {
  final EventController _controller = EventController();
  late UntisTimetable timetable;
  late List<UntisYear> years;
  late UntisTimeGrid timeGrid;

  bool initialized = false;

  double _verticalScroll = 0.0;
  final GlobalKey _weekViewKey = GlobalKey();
  final String _markerTitle = '____marker____';
  late UntisPeriod _earliestPeriod;
  late int earliestHour;
  late int earliestMinute;

  @override
  void initState() {
    super.initState();
    _loadWeekData(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (!initialized) return const Center(child: CircularProgressIndicator());

    final earliestPeriod = timetable.periods.reduce(
            (a, b) => a.startDateTime.isBefore(b.startDateTime) ? a : b);
    final latestPeriod = timetable.periods.reduce(
            (a, b) => a.endDateTime.isAfter(b.endDateTime) ? a : b);

    earliestHour = earliestPeriod.startDateTime.hour;
    earliestMinute = earliestPeriod.startDateTime.minute;
    final latestHour = max(latestPeriod.endDateTime.hour, 18);

    double heightPerMinute = 1.5;

    int offsetHour = 0;
    int offsetMinutes = earliestMinute;
    double scrollOffset = (offsetHour * 60 + offsetMinutes) * heightPerMinute;

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.axis == Axis.vertical) {
          setState(() => _verticalScroll = scroll.metrics.pixels);
        }
        return false;
      },
      child: CalendarControllerProvider(
        controller: _controller,
        child: Stack(
          children: [
            WeekView(
              key: _weekViewKey,
              controller: _controller,
              backgroundColor: colors.background,
              scrollOffset: scrollOffset,
              startHour: earliestHour,
              endHour: latestHour + 1,
              heightPerMinute: heightPerMinute,
              showLiveTimeLineInAllDays: true,
              weekDays: const [
                WeekDays.monday,
                WeekDays.tuesday,
                WeekDays.wednesday,
                WeekDays.thursday,
                WeekDays.friday,
              ],
              timeLineBuilder: (_) => Container(),
              eventTileBuilder: (date, events, boundary, start, end) {
                final isMarker = events.first.title == _markerTitle;
                return Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isMarker ? Colors.transparent : Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isMarker
                      ? null
                      : Text(
                    events.first.title ?? "No title",
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                );
              },
              eventArranger: const SideEventArranger(),
              weekPageHeaderBuilder: WeekHeader.hidden,
              keepScrollOffset: true,
            ),
            buildTimeScale(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadWeekData(DateTime date) async {
    try {
      timeGrid = await widget.session.timeGrid;
      years = await widget.session.schoolYears;

      timetable = await widget.session.getTimetable(
        startDate: years.last.startDate,
        endDate: years.last.endDate,
      );

      _controller.removeWhere((event) => true);
      for (var period in timetable.periods) {
        _controller.add(CalendarEventData(
          title: period.id.toString(),
          date: DateTime(period.startDateTime.year,
              period.startDateTime.month, period.startDateTime.day),
          startTime: period.startDateTime,
          endTime: period.endDateTime,
        ));
      }

      _earliestPeriod = timetable.periods.reduce(
              (a, b) => a.startDateTime.isBefore(b.startDateTime) ? a : b);

      // add invisible marker
      _controller.add(CalendarEventData(
        title: _markerTitle,
        date: DateTime(
          _earliestPeriod.startDateTime.year,
          _earliestPeriod.startDateTime.month,
          _earliestPeriod.startDateTime.day,
        ),
        startTime: _earliestPeriod.startDateTime,
        endTime: _earliestPeriod.startDateTime.add(const Duration(minutes: 1)),
      ));

      setState(() {
        initialized = true;
      });
    } catch (e, st) {
      debugPrint("Failed to load timetable: $e\n$st");
    }
  }

  Widget buildTimeScale() {
    const int startHour = 7;
    const int startMinute = 55;
    const int endHour = 18;
    const int endMinute = 0;
    const double hourHeight = 60.0; // height per hour in pixels
    const double headerHeight = 50.0; // adjust to your week view's header

    final double pixelsPerMinute = hourHeight / 60.0;
    final int totalMinutes = (endHour - startHour) * 60 + (endMinute - startMinute);

    return SizedBox(
      width: 60,
      height: totalMinutes * pixelsPerMinute + headerHeight,
      child: Stack(
        children: [
          for (int hour = startHour; hour <= endHour; hour++)
            for (int minute = 0; minute < 60; minute += 5)
              if (_eventStartsOrEndsAt(hour, minute))
                Positioned(
                  top: headerHeight + ((hour - startHour) * 60 + (minute - startMinute)) * pixelsPerMinute - _verticalScroll,
                  left: 0,
                  right: 0,
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
        ],
      ),
    );
  }

  double getTopForTime(int hour, int minute) {
    const double rowHeight = 60; // 1 hour = 60 pixels in week view
    return hour * rowHeight + (minute / 60) * rowHeight;
  }

  bool _eventStartsOrEndsAt(int hour, int minute) {
    for (var ev in _controller.events) {
      final st = ev.startTime;
      final en = ev.endTime;

      if (st != null && st.hour == hour && st.minute == minute) {
        return true;
      }
      if (en != null && en.hour == hour && en.minute == minute) {
        return true;
      }
    }
    return false;
  }
}