import 'package:dart_untis_mobile/dart_untis_mobile.dart';

class UntisConnection {
  static Future<void> ConnectToUntis(String server, String school, String username, String password) async {
    final session = await UntisSession.init(
      server,
      school,
      username,
      password,
    );

    print("Connected as: " + session.username);
  }
}