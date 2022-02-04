import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/order_provider.dart';
import 'package:rento_vendor/services/order_services.dart';
import 'package:intl/intl.dart';
import 'package:rento_vendor/widgets/drawer_menu_widget.dart';
import 'package:rento_vendor/widgets/order_summary_card.dart';

class OrderScreen extends StatefulWidget {
  static const String id = 'orders-screen';
  OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderServices _orderServices = OrderServices();

  User user = FirebaseAuth.instance.currentUser!;
  int tag = 0;

  List<String> options = [
    'All Orders',
    'Ordered',
    'Accepted',
    'On the Way',
    'Service Start',
    'Service Completed',
  ];

  @override
  Widget build(BuildContext context) {
    var _orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3c5784),
        title: const Text('My Orders', style: TextStyle(color: Colors.white)),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(
        //       CupertinoIcons.search,
        //       color: Colors.white,
        //     ),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: const Icon(
        //       CupertinoIcons.bell,
        //       color: Colors.white,
        //     ),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Container(
              //   height: 40,
              //   width: MediaQuery.of(context).size.width,
              //   color: Theme.of(context).primaryColor,
              //   child: Center(
              //       child: Text('My Orders',
              //           style: TextStyle(color: Colors.white))),
              // ),
              SizedBox(
                height: 56,
                width: MediaQuery.of(context).size.width,
                child: ChipsChoice<int>.single(
                  value: tag,
                  onChanged: (val) {
                    if (val == 0) {
                      setState(() {
                        _orderProvider.status = null;
                      });
                    }
                    setState(() {
                      tag = val;
                      if (tag > 0) {
                        _orderProvider.status = options[val];
                      }
                    });
                  },
                  choiceItems: C2Choice.listFrom<int, String>(
                    source: options,
                    value: (i, v) => i,
                    label: (i, v) => v,
                  ),
                  choiceStyle: C2ChoiceStyle(
                    color: Colors.green,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                ),
              ),
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _orderServices.orders
                      .where('supervoisor.supervisorUid', isEqualTo: user.uid)
                      .where('orderStatus',
                          isEqualTo: tag > 0 ? _orderProvider.status : null)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.size == 0) {
                      //TODO: No Orders screen
                      return Center(
                          child: Text(tag > 0
                              ? 'No ${options[tag]} orders'
                              : 'No Orders,Continue Booking..'));
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return OrderSummaryCard(
                              document: document,
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 60,
              )
            ],
          ),
        ),
      ),
    );
  }
}
