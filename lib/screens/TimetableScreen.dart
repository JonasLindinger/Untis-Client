import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:flutter/material.dart';
import 'package:untis_client/utils/CustomColors.dart';
import '../utils/Timetable.dart';
import '../widgets/TimetableCalendarView.dart';

class TimetableScreen extends StatefulWidget {
  final UntisSession session;

  const TimetableScreen({
    super.key,
    required this.session,
  });

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
        title: const Text(
          "Timetable",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: CustomColors.backgroundColor,
        foregroundColor: CustomColors.highlight,
      ),
      body: Container(
        color: CustomColors.backgroundColor,
        padding: const EdgeInsets.all(8.0),
        child: TimetableCalendarView(session: session),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: CustomColors.backgroundColor,
        selectedItemColor: CustomColors.primary,
        unselectedItemColor: CustomColors.highlight,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Week",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: "List",
          ),
        ],
      ),
    );
  }
}