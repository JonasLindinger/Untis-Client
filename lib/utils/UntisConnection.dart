import 'package:dart_untis_mobile/dart_untis_mobile.dart';

class UntisConnection {
  static Future<void> ConnectToUntis({
    required String server,
    required String school,
    required String username,
    required String password,
    Function() onConnected = UntisConnection.Ignore,
  }) async {
    server = GetServerURL(server);

    var session;
    try {
      session = await UntisSession.init(
        server,
        school,
        username,
        password,
      );
    }
    catch (e, st) {
      print(e);
      print(st);
    }

    if (session == null) {
      print("Failed to connect to Untis!");
      return;
    }

    print("Connected as: " + session.username);
    onConnected();
  }
  static void Ignore() {}

  static String GetServerURL(String url) {
    url = url.replaceAll("https://", ""); // Remove https://
    url = url.replaceAll("http://", ""); // Remove http://
    url = url.replaceAll(" ", "");  // Remove all spaces
    url = removeTrailingSlash(url); // Remove the last "/" if there is one.

    return url;
  }
  static String removeTrailingSlash(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }
}