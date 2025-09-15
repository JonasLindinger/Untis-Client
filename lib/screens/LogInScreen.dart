import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:flutter/material.dart';
import 'package:untis_client/screens/TimetableScreen.dart';
import 'package:untis_client/utils/UntisConnection.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final serverUrlController = TextEditingController();
    final schoolController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    UntisConnection.TryAutoLogIn(
      onConnected: (session) => LoadHomeScreen(context, session),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Log In",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              InputField(
                icon: Icons.account_tree_rounded,
                label: "Untis Server URL",
                hint: "https://your-server.com",
                controller: serverUrlController,
                type: TextInputType.url,
              ),
              InputField(
                icon: Icons.account_balance_rounded,
                label: "School name",
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
                label: "Password",
                hint: "••••••••",
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  UntisConnection.ConnectToUntis(
                    server: serverUrlController.text,
                    school: schoolController.text,
                    username: usernameController.text,
                    password: passwordController.text,
                    onConnected: (session) => LoadHomeScreen(context, session),
                  );
                },
                child: const Text(
                  "Connect to Untis",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void LoadHomeScreen(BuildContext context, UntisSession session) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TimetableScreen(session: session)),
    );
  }
}