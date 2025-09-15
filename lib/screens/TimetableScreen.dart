import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:flutter/material.dart';
import '../utils/Timetable.dart';
import '../widgets/TimetableCalendarView.dart';

class TimetableScreen extends StatefulWidget {
  final UntisSession session;

  const TimetableScreen({super.key, required this.session});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late UntisSession session;

  @override
  void initState() {
    super.initState();
    session = widget.session;
    Timetable.GetTimetable(session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Timetable"),
      ),
      body: TimetableCalendarView(session: session),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          // handle navigation tap
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: "Week",
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_rounded),
            label: "List",
          ),
        ],
      ),
    );
  }
}