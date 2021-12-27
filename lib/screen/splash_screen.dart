import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:rento_vendor/screen/home_screen.dart';
import 'package:rento_vendor/screen/login_screen.dart';
import 'package:rento_vendor/screen/register_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash-screen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  @override
  void initState() {
    Timer(
        Duration(
          seconds: 3,
        ), () {
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => WelcomeScreen(),
      //     ));
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          Navigator.pushReplacementNamed(context, LoginScreen.id);
        } else {
          Navigator.pushReplacementNamed(context, HomeScreen.id);
        }
      });
    });
    if (mounted) {
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: deviceHeight(context) * 0.09,
            left: deviceWidth(context) * 0.09,
            right: deviceWidth(context) * 0.09,
            bottom: deviceHeight(context) * 0.09,
          ),
          child: Hero(tag: 'logo', child: Image.asset('images/splash.png')),
        ),
      ),
    );
  }
}
