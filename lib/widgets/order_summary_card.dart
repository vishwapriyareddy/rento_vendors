import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/order_provider.dart';
import 'package:rento_vendor/services/order_services.dart';

class OrderSummaryCard extends StatelessWidget {
  final DocumentSnapshot document;
  const OrderSummaryCard({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? statusColor(DocumentSnapshot document) {
      if (document.get('orderStatus') == 'Accepted') {
        return Colors.blueGrey[400];
      }
      if (document.get('orderStatus') == 'Rejected') {
        return Colors.red;
      }
      if (document.get('orderStatus') == 'On the way') {
        return Colors.purple[900];
      }
      if (document.get('orderStatus') == 'Service Start') {
        return Colors.pink[900];
      }
      if (document.get('orderStatus') == 'Service Completed') {
        return Colors.green;
      }
      return Colors.orange;
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            horizontalTitleGap: 0,
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 14,
              child: Icon(CupertinoIcons.square_list,
                  size: 18, color: statusColor(document)),
            ),
            title: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                document.get('orderStatus'),
                style: TextStyle(
                    color: statusColor(document),
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
                      'On ${DateFormat.yMMMd().format(DateTime.parse(document.get('timestamp')))}',
                      style: TextStyle(
                        fontSize: 12,
                      )),
                  Text(
                    'Service Date: ${DateFormat.yMMMd().format(DateTime.parse(document.get('pickdate')))}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                  'Amount : ${document.get('total').toStringAsFixed(0)} Rupees',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
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
                          child: Image.network(document
                              .get('serviceBookings')[index]['serviceImage'])),
                      title: Text(
                        document.get('serviceBookings')[index]['serviceName'],
                        style: TextStyle(color: Colors.grey),
                      ),
                      subtitle: Text(
                        '${document.get('serviceBookings')[index]['price'].toString()}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  );
                },
                itemCount: document.get('serviceBookings').length,
              )
            ],
          ),
          Divider(
            height: 3,
            color: Colors.grey,
          ),
          statusContainer(document, context)!,
          Divider(
            height: 3,
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  showDialog(title, status, documentId, context) {
    OrderServices _orderServices = OrderServices();

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
                        color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                // style: ButtonStyle(
                //     backgroundColor: MaterialStateProperty.all(Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                    style: TextStyle(
                        color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                // style: ButtonStyle(
                //     backgroundColor: MaterialStateProperty.all(Colors.red)),
              ),
            ],
          );
        });
  }

  Widget? statusContainer(DocumentSnapshot document, context) {
    if (document.get('orderStatus') == 'Accepted') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
          child: TextButton(
            onPressed: () {
              print('Assign Service Provider');
            },
            child: Text('Assign Service Provider',
                style: TextStyle(color: Colors.white)),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.orangeAccent)),
          ),
        ),
      );
    }
    return Container(
      color: Colors.grey[300],
      height: 50,
      child: Row(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                showDialog('Accept Order', 'Accepted', document.id, context);
              },
              child: Text('Accept', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueGrey)),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AbsorbPointer(
              absorbing:
                  document.get('orderStatus') == 'Rejected' ? true : false,
              child: TextButton(
                onPressed: () {
                  showDialog('Reject Order', 'Rejected', document.id, context);
                },
                child: Text('Reject', style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        document.get('orderStatus') == 'Rejected'
                            ? Colors.grey
                            : Colors.red)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
