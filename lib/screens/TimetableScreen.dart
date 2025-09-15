import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:flutter/cupertino.dart';
import 'package:untis_client/utils/Timetable.dart';

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

    Timetable.GetTimeTable(session);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
