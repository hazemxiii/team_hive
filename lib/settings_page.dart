import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_hive/auth/login_page.dart';
import 'package:team_hive/service/firebase.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          await context.read<FirebaseService>().signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false);
          }
        },
        child: const Text("LogOut"));
  }
}
