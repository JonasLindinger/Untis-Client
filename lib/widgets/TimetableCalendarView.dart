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
  late double scrollOffset;
  bool scrolled = false;

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
    scrollOffset = (offsetHour * 60 + offsetMinutes) * heightPerMinute;

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.axis == Axis.vertical) {
          setState(() => _verticalScroll = scroll.metrics.pixels);
          scrolled = true;
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
              hourIndicatorSettings: HourIndicatorSettings(
                color: Color.fromRGBO(0, 0, 0, 0) // Hide
              ),
              liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
                color: colors.onSurface,
                height: 2,
              ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        events.first.title ?? "No title",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1, // Limit to 1 line (or any number of lines)
                        overflow: TextOverflow.ellipsis, // Adds "..." at the end if text overflows
                      ),
                      Text(
                        events.first.description ?? "/",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,

                        ),
                        maxLines: 1, // Limit to 1 line (or any number of lines)
                        overflow: TextOverflow.ellipsis, // Adds "..." at the end if text overflows
                      ),
                    ],
                  )
                );
              },
              eventArranger: const SideEventArranger(),
              weekPageHeaderBuilder: WeekHeader.hidden,
              keepScrollOffset: true,
              showVerticalLines: false,
              showHalfHours: false,
              showQuarterHours: false,
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
          title: period.subject == null ? period.teacher!.id.toString() : period.subject!.name,
          description: period.rooms.isEmpty ? "" : period.rooms.first.name,
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
    final colors = Theme.of(context).colorScheme;

    const int startHour = 7;
    const int startMinute = 55;
    const int endHour = 18;
    const int endMinute = 0;
    const double hourHeight = 60*1.5; // height per hour in pixels
    const double headerHeight = 51.0; // adjust to your week view's header

    final double pixelsPerMinute = hourHeight / 60;
    final int totalMinutes = (endHour - startHour) * 60 + (endMinute - startMinute);

    return SizedBox(
      width: 55,
      height: totalMinutes * pixelsPerMinute + headerHeight,
      child: ClipRect(
        child: Container(
          margin: EdgeInsets.only(top: headerHeight),
          width: 55,
          height: totalMinutes * pixelsPerMinute + headerHeight,
          color: colors.surface,
          child: Stack(
            children: [
              for (int hour = startHour; hour <= endHour; hour++)
                for (int minute = 0; minute < 60; minute += 5)
                  if (_eventStartsOrEndsAt(hour, minute))
                    Positioned(
                      top: GetTop(0, hour, minute, startHour, startMinute, pixelsPerMinute),
                      left: 8,
                      right: 0,
                      child: Text(
                        GetTop(0, hour, minute, startHour, startMinute, pixelsPerMinute) < 0 ? "" :
                          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  double GetTop(double headerHeight, int hour, int minute, int startHour, int startMinute, double pixelsPerMinute) {
    return headerHeight +
        ((hour * 60 + minute) - (startHour * 60 + startMinute)) *
            pixelsPerMinute -
        _verticalScroll +
        (scrolled ? scrollOffset : 0);
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