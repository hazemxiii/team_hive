import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_hive/models/sign_up.dart';
import 'package:team_hive/service/app_colors.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool _isPassHidden = true;
  bool _isConfirmHidden = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: SignUp.formKeys[0],
        child: Column(
          children: [
            _emailInput(),
            const SizedBox(
              height: 10,
            ),
            _passwordInput(
                _isPassHidden, "Password", _togglePassHidden, SignUp.password),
            const SizedBox(
              height: 10,
            ),
            _passwordInput(
              _isConfirmHidden,
              "Confirm Password",
              _toggleConfirmHidden,
              SignUp.confirmPassword,
            )
          ],
        ));
  }

  Widget _emailInput() {
    return TextFormField(
      validator: SignUp.emailValidator,
      controller: SignUp.email,
      style: TextStyle(color: Style.main),
      cursorColor: Style.main,
      decoration: Style.getInputDecoration(true,
          hintText: "Email", suffix: const Icon(Icons.email)),
    );
  }

  Widget _passwordInput(bool isHidden, String label, VoidCallback onPressed,
      TextEditingController controller) {
    return TextFormField(
      controller: controller,
      validator: SignUp.passwordValidator,
      style: TextStyle(color: Style.main),
      cursorColor: Style.main,
      obscureText: isHidden,
      decoration: Style.getInputDecoration(true,
          hintText: label,
          suffix: IconButton(
              onPressed: onPressed,
              icon: isHidden
                  ? const Icon(Icons.visibility_off)
                  : const Icon(Icons.visibility))),
    );
  }

  void _togglePassHidden() {
    setState(() {
      _isPassHidden = !_isPassHidden;
    });
  }

  void _toggleConfirmHidden() {
    setState(() {
      _isConfirmHidden = !_isConfirmHidden;
    });
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
        key: SignUp.formKeys[1],
        child: Column(
          children: [
            _input("First Name", SignUp.fName),
            const SizedBox(
              height: 10,
            ),
            _input("Last Name", SignUp.lName),
            const SizedBox(
              height: 20,
            ),
            // TODO: implement image picker
            // const ImagePickerWidget()
          ],
        ));
  }

  Widget _input(String hint, TextEditingController controller) {
    return TextFormField(
      validator: SignUp.nameValidator,
      controller: controller,
      style: TextStyle(color: Style.main),
      cursorColor: Style.main,
      decoration: Style.getInputDecoration(true, hintText: hint),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  // MemoryImage? image;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Profile Picture",
          style: Style.headingStyle.copyWith(fontSize: 14),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            _imageWidget(),
            const VerticalDivider(
              width: 10,
            ),
            MaterialButton(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              onPressed: _pickImage,
              child: Text(
                "Upload Image",
                style:
                    TextStyle(color: Style.main, fontWeight: FontWeight.bold),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _imageWidget() {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: _pickImage,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
            image: SignUp.image != null
                ? DecorationImage(image: SignUp.image!, fit: BoxFit.cover)
                : null,
            border: Border.fromBorderSide(BorderSide(color: Style.main)),
            borderRadius: const BorderRadius.all(Radius.circular(999))),
        child: SignUp.image == null
            ? Icon(
                Icons.camera_alt,
                color: Style.main,
              )
            : null,
      ),
    );
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();

    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      SignUp.image = MemoryImage(await file.readAsBytes());
    }
    setState(() {});
  }
}
