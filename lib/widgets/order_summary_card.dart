import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/auth_provider.dart';
import 'package:rento_vendor/providers/order_provider.dart';
import 'package:rento_vendor/services/firebase_services.dart';
import 'package:rento_vendor/services/order_services.dart';
import 'package:rento_vendor/widgets/service_provider_boys_list.dart';

class OrderSummaryCard extends StatefulWidget {
  final DocumentSnapshot document;
  const OrderSummaryCard({Key? key, required this.document}) : super(key: key);

  @override
  State<OrderSummaryCard> createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  OrderServices _orders = OrderServices();
  FirebaseServices _services = FirebaseServices();
  DocumentSnapshot? _customer;
  @override
  void initState() {
    _services.getcustomerdetails(widget.document.get('userId')).then((value) {
      if (mounted) {
        if (value != null) {
          setState(() {
            _customer = value;
          });
        } else {
          print('no Data');
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              horizontalTitleGap: 0,
              leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 14,
                  child: _orders.statusIcon(widget.document)),
              title: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  widget.document.get('orderStatus'),
                  style: TextStyle(
                      color: _orders.statusColor(widget.document),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'On ${DateFormat.yMMMd().format(DateTime.parse(widget.document.get('timestamp')))}',
                        style: TextStyle(
                          fontSize: 12,
                        )),
                    Text(
                      'Service Date: ${DateFormat.yMMMd().format(DateTime.parse(widget.document.get('pickdate')))}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Payment Type : Paid Online',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    'Amount : ${widget.document.get('total').toStringAsFixed(0)} Rupees',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
            _customer != null
                ? ListTile(
                    title: Row(
                      children: [
                        Text('Customer',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Text(
                      _customer!.get('address'),
                      style: TextStyle(fontSize: 12),
                      maxLines: 1,
                    ),
                    trailing: InkWell(
                        onTap: () {
                          _orders.launchCall('tel:${_customer!.get('number')}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child:
                                Icon(Icons.phone_in_talk, color: Colors.white),
                          ),
                        )),
                  )
                : Container(),
            ExpansionTile(
              title: Text(
                'Order details',
                style: TextStyle(fontSize: 10, color: Colors.black),
              ),
              subtitle: Text('View Order Details',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            // backgroundColor: Colors.white,
                            child: Image.network(
                                widget.document.get('serviceBookings')[index]
                                    ['serviceImage'])),
                        title: Text(
                          widget.document.get('serviceBookings')[index]
                              ['serviceName'],
                          style: TextStyle(color: Colors.grey),
                        ),
                        subtitle: Text(
                          '${widget.document.get('serviceBookings')[index]['price'].toString()}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    );
                  },
                  itemCount: widget.document.get('serviceBookings').length,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 12, top: 8, bottom: 8),
                  child: Card(
                    child: Column(
                      children: [
                        Row(children: [
                          Text('Service : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          Text(
                              widget.document.get('supervoisor')['serviceName'],
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ])
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(
              height: 3,
              color: Colors.grey,
            ),
            _orders.statusContainer(widget.document, context)!,
            Divider(
              height: 3,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}
