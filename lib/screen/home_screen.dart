import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rento_vendor/screen/login_screen.dart';
import 'package:rento_vendor/screen/register_screen.dart';
import 'package:rento_vendor/widgets/drawer_menu_widget.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home-screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(),
      appBar: AppBar(
        backgroundColor: Color(0xFF3c5784),
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.menu,
        //     color: Theme.of(context).primaryColor,
        //   ),
        //   onPressed: () {},
        // ),
        title: Text('Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              CupertinoIcons.search,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.bell,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          ),
        ],
      ),
      body: Center(
          // child: ElevatedButton(
          //     onPressed: () {
          //       FirebaseAuth.instance.signOut();
          //       Navigator.pushReplacementNamed(context, LoginScreen.id);
          //     },
          //     child: Text('Log Out')),

          child: Text('Dashboard')),
    );
  }
}
