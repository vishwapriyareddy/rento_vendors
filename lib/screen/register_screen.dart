// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:rento_vendor/widgets/image_picker.dart';
import 'package:rento_vendor/widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  static const String id = 'register-screen';

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child:
                  Column(children: const [ServicePicCard(), RegisterForm()])),
        )),
      ),
    );
  }
}
