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
  int page = 0;

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

    const int startHour = 7;
    const int startMinute = 55;
    const int endHour = 18;
    const int endMinute = 0;
    const double hourHeight = 60*1.5; // height per hour in pixels
    const double headerHeight = 51.0; // adjust to your week view's header

    final double pixelsPerMinute = hourHeight / 60;

    late final Widget _timeLabels = _buildTimeLabels(
      startHour,
      startMinute,
      endHour,
      endMinute,
      pixelsPerMinute,
      colors,
    );

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
                    color: isMarker ? Colors.transparent : colors.primary,
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
              onPageChange: (date, i) {
                if (page != i) { // Check if page changed
                  setState(() {
                    _verticalScroll = 0;
                    scrolled = false;
                    page = i;
                  });
                }
              },
              onEventTap: (events, date) {
                showEventPopup(context, events.first, date);
              },
              eventArranger: SideEventArranger(),
              weekPageHeaderBuilder: WeekHeader.hidden,
              keepScrollOffset: false,
              showVerticalLines: false,
              showHalfHours: false,
              showQuarterHours: false,
            ),
            Container(
              width: 55,
              margin: EdgeInsets.only(top: headerHeight),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.surface, colors.surface],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ClipRect(
                child: Stack(
                  children: [
                    // Movable timestamp column
                    AnimatedPositioned(
                      duration: _verticalScroll == 0 ? Duration(milliseconds: 250) : Duration(microseconds: 0),
                      top: -_verticalScroll + (scrolled ? scrollOffset : 0), // moves opposite to your WeekView scroll
                      left: 0,
                      right: 0,
                      child: _timeLabels,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLabels(
      int startHour,
      int startMinute,
      int endHour,
      int endMinute,
      double pixelsPerMinute,
      ColorScheme colors,
      ) {
    List<Widget> labels = [];

    final totalMinutes =
        (endHour * 60 + endMinute) - (startHour * 60 + startMinute);

    for (int hour = startHour; hour <= endHour; hour++) {
      for (int minute = 0; minute < 60; minute += 5) {
        // Only render if inside range
        final total = hour * 60 + minute;
        if (total < startHour * 60 + startMinute ||
            total > endHour * 60 + endMinute) continue;

        if (_eventStartsOrEndsAt(hour, minute)) {
          // Align to the absolute minute distance from the *exact start point*
          final offsetMinutes = (total - (startHour * 60 + startMinute));
          final top = offsetMinutes * pixelsPerMinute;

          labels.add(
            Positioned(
              top: top,
              left: 8,
              right: 0,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      }
    }

    // Total height in pixels (perfectly aligned to WeekView)
    final totalHeight = totalMinutes * pixelsPerMinute;

    return SizedBox(
      height: totalHeight,
      child: Stack(children: labels),
    );
  }

  void showEventPopup(BuildContext context, CalendarEventData event, DateTime time) {
    final colors = Theme.of(context).colorScheme;

    UntisPeriod period = event.event as UntisPeriod;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: colors.primary,
              padding: EdgeInsets.all(16),
              width: 500,
              height: 600,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    period.subject!.longName + " (" + period.subject!.name + ")", // Physics (PH)
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Room: " + period.room!.name,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                    ),
                  ),
                  Expanded(child: Container()),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the popup
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          event: period,
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