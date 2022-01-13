import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/product_provider.dart';
import 'package:rento_vendor/screen/banner_screen.dart';
import 'package:rento_vendor/screen/home_screen.dart';
import 'package:rento_vendor/screen/login_screen.dart';
import 'package:rento_vendor/screen/order_screen.dart';
import 'package:rento_vendor/screen/product_screen.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  User user = FirebaseAuth.instance.currentUser!;
  DocumentSnapshot? vendorData;
  @override
  void initState() {
    getVendorData();
    super.initState();
  }

  Future<DocumentSnapshot> getVendorData() async {
    var result = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(user.uid)
        .get();

    setState(() {
      vendorData = result;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);
    _provider.getServiceName(
        vendorData != null ? vendorData!.get('servicename') : '');
    return Drawer(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFF3c5784),
            Color(0xFF3c5784),
            Color(0xFF000000),
            Color(0xFF3c5784),
            Color(0xFF3c5784),
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Material(
          color: Colors.transparent,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: vendorData != null
                        ? NetworkImage(vendorData!.get('imageUrl'))
                        : null),
                decoration: BoxDecoration(color: Colors.transparent),
                accountName: Text(vendorData != null
                    ? vendorData!.get('servicename')
                    : 'service name'),
                accountEmail: Text("")),
            MenuList(
              title: "Dashboard",
              iconName: Icons.dashboard_outlined,
              press: () {
                Navigator.pushNamed(context, HomeScreen.id);
              },
            ),
            MenuList(
              title: "Services",
              iconName: Icons.shopping_bag_outlined,
              press: () {
                Navigator.pushNamed(context, ProductScreen.id);
              },
            ),
            MenuList(
              title: "Banner",
              iconName: CupertinoIcons.photo,
              press: () {
                Navigator.pushNamed(context, BannerScreen.id);
              },
            ),
            MenuList(
              title: "Orders",
              iconName: Icons.list_alt_outlined,
              press: () {
                Navigator.pushNamed(context, OrderScreen.id);
              },
            ),
            MenuList(
              title: "Reports",
              iconName: Icons.stacked_bar_chart,
              press: () {},
            ),
            MenuList(
              title: "Settings",
              iconName: Icons.settings_outlined,
              press: () {},
            ),
            MenuList(
                title: "Log Out",
                iconName: Icons.arrow_back_ios,
                press: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, LoginScreen.id);
                })
          ]),
        ),
      ),
    );
  }
}

class MenuList extends StatelessWidget {
  final String title;
  final IconData iconName;
  final VoidCallback press;
  const MenuList(
      {Key? key,
      required this.title,
      required this.iconName,
      required this.press});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Flexible(
          child: Container(
              height: 45,
              width: 170,

              // width: 170,
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconName,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ])),
        ),
      ),
    );
  }
}
