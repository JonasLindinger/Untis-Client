import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:flutter/material.dart';
import 'package:untis_client/screens/TimetableScreen.dart';
import 'package:untis_client/utils/CustomColors.dart';
import 'package:untis_client/utils/UntisConnection.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController serverUrlController = new TextEditingController();
    final TextEditingController schoolController = new TextEditingController();
    final TextEditingController usernameController = new TextEditingController();
    final TextEditingController passwordController = new TextEditingController();

    UntisConnection.TryAutoLogIn(
      onConnected: (session) {
        LoadHomeScreen(context, session);
      }
    );

    return MaterialApp(
      home: Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 30),
                child: Text(
                  "Log In",
                  style: TextStyle(
                    color: CustomColors.primary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InputField(
                icon: Icons.account_tree_rounded,
                label: "Your Untis-Server Url",
                hint: "https://your-server.com",
                controller: serverUrlController,
                type: TextInputType.url,
              ),
              InputField(
                icon: Icons.account_balance_rounded,
                label: "Schoolname",
                hint: "Best School",
                controller: schoolController,
              ),
              InputField(
                icon: Icons.account_circle_rounded,
                label: "Username",
                hint: "Max Mustermann",
                controller: usernameController,
              ),
              InputField(
                icon: Icons.password_rounded,
                label: "Passwort",
                hint: "#IHateSchool123",
                controller: passwordController,
                obscureText: true,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      UntisConnection.ConnectToUntis(
                        server: serverUrlController.text,
                        school: schoolController.text,
                        username: usernameController.text,
                        password: passwordController.text,
                        onConnected: (session) {
                          LoadHomeScreen(context, session);
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.secondary,
                      foregroundColor: CustomColors.highlight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Connect to Untis",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget InputField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
    bool obscureText = false,
    }) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: CustomColors.primary,
          ),
          labelText: label,
          labelStyle: TextStyle(color: CustomColors.primary),
          hintText: hint,
          hintStyle: TextStyle(color: CustomColors.primary.withOpacity(0.6)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CustomColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CustomColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        style: TextStyle(
          color: CustomColors.primary,
        ),
        cursorColor: CustomColors.primary,
      ),
    );
  }

  void LoadHomeScreen(BuildContext context, UntisSession session) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TimetableScreen(
        session: session
      )),
    );
  }
}
