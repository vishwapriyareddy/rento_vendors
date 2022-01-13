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
    'On the way',
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
                            return Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  ListTile(
                                    horizontalTitleGap: 0,
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 14,
                                      child: Icon(
                                        CupertinoIcons.square_list,
                                        size: 18,
                                        color: document.get('orderStatus') ==
                                                'Rejected'
                                            ? Colors.red
                                            : document.get('orderStatus') ==
                                                    'Accepted'
                                                ? Colors.blueGrey[400]
                                                : Colors.orange,
                                      ),
                                    ),
                                    title: Text(
                                      document.get('orderStatus'),
                                      style: TextStyle(
                                          color: document.get('orderStatus') ==
                                                  'Rejected'
                                              ? Colors.red
                                              : document.get('orderStatus') ==
                                                      'Accepted'
                                                  ? Colors.blueGrey[400]
                                                  : Colors.orange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        'On ${DateFormat.yMMMd().format(DateTime.parse(document.get('timestamp')))}',
                                        style: TextStyle(
                                          fontSize: 12,
                                        )),
                                    trailing: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Payment Type : Paid Online',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                        Text(
                                          'Amount : ${document.get('total').toStringAsFixed(0)} Rupees',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ExpansionTile(
                                    title: Text(
                                      'Order details',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black),
                                    ),
                                    subtitle: Text('View Order Details',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListTile(
                                              leading: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  // backgroundColor: Colors.white,
                                                  child: Image.network(document
                                                          .get(
                                                              'serviceBookings')[
                                                      index]['serviceImage'])),
                                              title: Text(
                                                document.get('serviceBookings')[
                                                    index]['serviceName'],
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              subtitle: Text(
                                                '${document.get('serviceBookings')[index]['price'].toString()}',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          );
                                        },
                                        itemCount: document
                                            .get('serviceBookings')
                                            .length,
                                      )
                                    ],
                                  ),
                                  Divider(
                                    height: 3,
                                    color: Colors.grey,
                                  ),
                                  document.get('orderStatus') == 'Accepted'
                                      ? Container(
                                          color: Colors.grey[300],
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                40.0, 8, 40, 8),
                                            child: TextButton(
                                              onPressed: () {
                                                print(
                                                    'Assign Service Provider');
                                              },
                                              child: Text(
                                                  'Assign Service Provider',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.orangeAccent)),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          height: 50,
                                          child: Row(children: [
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        'Accept Order',
                                                        'Accepted',
                                                        document.id);
                                                  },
                                                  child: Text('Accept',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Colors
                                                                  .blueGrey)),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: AbsorbPointer(
                                                  absorbing: document.get(
                                                              'orderStatus') ==
                                                          'Rejected'
                                                      ? true
                                                      : false,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      showDialog(
                                                          'Rcject Order',
                                                          'Rejected',
                                                          document.id);
                                                    },
                                                    child: Text('Reject',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(document.get(
                                                                            'orderStatus') ==
                                                                        'Rejected'
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .red)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ),
                                  Divider(
                                    height: 3,
                                    color: Colors.grey,
                                  )
                                ],
                              ),
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

  showDialog(title, status, documentId) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text('Are you sure ?'),
            actions: [
              TextButton(
                onPressed: () {
                  EasyLoading.show(status: 'Updating status');
                  status == 'Accepted'
                      ? _orderServices
                          .updateOrderStatus(documentId, status)
                          .then((value) {
                          EasyLoading.showSuccess('Updated successfully');
                        })
                      : _orderServices
                          .updateOrderStatus(documentId, status)
                          .then((value) {
                          EasyLoading.showSuccess('Updated successfully');
                        });
                  Navigator.pop(context);
                },
                child: Text('OK',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                // style: ButtonStyle(
                //     backgroundColor: MaterialStateProperty.all(Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                // style: ButtonStyle(
                //     backgroundColor: MaterialStateProperty.all(Colors.red)),
              ),
            ],
          );
        });
  }
}
