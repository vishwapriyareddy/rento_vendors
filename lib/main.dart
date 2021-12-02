// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/auth_provider.dart';

import 'package:rento_vendor/screen/home_screen.dart';
import 'package:rento_vendor/screen/login_screen.dart';
import 'package:rento_vendor/screen/register_screen.dart';
import 'package:rento_vendor/screen/splash_screen.dart';
import 'package:rento_vendor/widgets/reset_password_screen.dart';

Future<void> main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // mAuth.getFirebaseAuthSettings().setAppVerificationDisabledForTesting(true);
  // (MultiProvider(
  //   providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
  //   child: runApp(MyApp()),
  // ));
  runApp(MultiProvider(
      providers: [Provider(create: (_) => AuthProvider())], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Color(0xFF3c5784), fontFamily: 'Lato'),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        ResetPassword.id: (context) => ResetPassword()
      },
    );
  }
}
