import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UntisConnection {
  static const SERVERPREF = "SERVER";
  static const SCHOOLPREF = "SCHOOL";
  static const USERPREF = "USER";
  static const PASSWORDPREF = "PASSWORD";

  static Future<void> TryAutoLogIn({
    Function() onConnected = UntisConnection.Ignore
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(SERVERPREF) &&
      prefs.containsKey(SCHOOLPREF) &&
      prefs.containsKey(USERPREF) &&
      prefs.containsKey(PASSWORDPREF)) {

      // Auto login
      await ConnectToUntis(
        server: prefs.getString(SERVERPREF)!,
        school: prefs.getString(SCHOOLPREF)!,
        username: prefs.getString(USERPREF)!,
        password: prefs.getString(PASSWORDPREF)!
      );

      // Call the on connected method
      onConnected();
    }
    else {
      // No date to login
    }
  }

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

    // Saving data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SERVERPREF, server);
    prefs.setString(SCHOOLPREF, school);
    prefs.setString(USERPREF, username);
    prefs.setString(PASSWORDPREF, password);

    // Call the on connected method
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