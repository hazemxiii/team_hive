// ignore_for_file: file_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:team_hive/auth/login_page.dart';
import 'package:team_hive/service/app_colors.dart';
import 'package:team_hive/service/backend.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final BackendService _backend = BackendService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Style.section,
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      width: min(MediaQuery.sizeOf(context).width - 30, 300),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  color: Style.sec),
              child: Text(
                _backend.user.fName[0],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Style.back,
                    fontSize: 30),
              )),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_backend.user.fName} ${_backend.user.lName}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                IconButton(
                  color: Style.sec,
                  onPressed: () => EditNameDialog.show(context, () {
                    setState(() {});
                  }),
                  icon: const Icon(Icons.edit),
                )
              ],
            ),
          ),
          MaterialButton(
            color: Colors.red,
            textColor: Style.back,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            onPressed: _logout,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  Text("logOut"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _logout() async {
    await _backend.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
    }
  }
}

class EditNameDialog extends StatefulWidget {
  final Function onSave;
  const EditNameDialog({super.key, required this.onSave});

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();

  static void show(BuildContext context, Function onSave) {
    showDialog(
        context: context,
        builder: (_) => EditNameDialog(
              onSave: onSave,
            ));
  }
}

class _EditNameDialogState extends State<EditNameDialog> {
  late final TextEditingController _fNameController;
  late final TextEditingController _lNameController;
  final _formKey = GlobalKey<FormState>();

  final double _opacity = 0.2;

  @override
  void initState() {
    _fNameController = TextEditingController(text: BackendService().user.fName);
    _lNameController = TextEditingController(text: BackendService().user.lName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
            style: ButtonStyle(
                overlayColor: WidgetStatePropertyAll(
                    Style.main.withValues(alpha: _opacity)),
                foregroundColor: WidgetStatePropertyAll(Style.main)),
            onPressed: Navigator.of(context).pop,
            child: const Text("Cancel")),
        TextButton(
            style: ButtonStyle(
              overlayColor:
                  WidgetStatePropertyAll(Style.sec.withValues(alpha: _opacity)),
              foregroundColor: WidgetStatePropertyAll(Style.sec),
            ),
            onPressed: _save,
            child: const Text("Save"))
      ],
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              validator: _validator,
              controller: _fNameController,
              decoration: Style.getInputDecoration(
                false,
                hintText: "First Name",
              ),
            ),
            TextFormField(
              validator: _validator,
              controller: _lNameController,
              decoration: Style.getInputDecoration(
                false,
                hintText: "Last Name",
              ),
            )
          ],
        ),
      ),
    );
  }

  String? _validator(String? v) {
    if ((v ?? "").trim() == "") {
      return "Can't be Empty";
    }
    return null;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    String fName = _fNameController.text.trim();
    String lName = _lNameController.text.trim();
    bool success = await BackendService().editDisplayName(fName, lName);
    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        BackendService().user.setName(fName, lName);
        widget.onSave();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Couldn't Update Name")));
      }
    }
  }
}
