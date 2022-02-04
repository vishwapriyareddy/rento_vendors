import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:rento_vendor/services/firebase_services.dart';
import 'package:rento_vendor/widgets/service_provider_boys_list.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderServices {
  User user = FirebaseAuth.instance.currentUser!;

  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future<void> updateOrderStatus(documentId, status) {
    var result = orders.doc(documentId).update({'orderStatus': status});
    return result;
  }

  // Future<double?> checkSupervisor() async {
  //   final snapshot = await orders.doc(user.uid).get();
  //   return snapshot.exists ? snapshot.get('userLocation') : null;
  // }

  Color? statusColor(DocumentSnapshot document) {
    if (document.get('orderStatus') == 'Accepted') {
      return Colors.blueGrey[400];
    }
    if (document.get('orderStatus') == 'Rejected') {
      return Colors.red;
    }
    if (document.get('orderStatus') == 'On the Way') {
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

  Icon? statusIcon(DocumentSnapshot document) {
    if (document.get('orderStatus') == 'Accepted') {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColor(document),
      );
    }
    if (document.get('orderStatus') == 'Rejected') {
      return Icon(
        Icons.assignment_late_outlined,
        color: statusColor(document),
      );
    }
    if (document.get('orderStatus') == 'On the Way') {
      return Icon(
        Icons.delivery_dining,
        color: statusColor(document),
      );
    }
    if (document.get('orderStatus') == 'Service Start') {
      return Icon(
        Icons.sailing,
        color: statusColor(document),
      );
    }
    if (document.get('orderStatus') == 'Service Completed') {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColor(document),
      );
    }
    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColor(document),
    );
  }

  Widget? statusContainer(DocumentSnapshot document, context) {
    FirebaseServices _services = FirebaseServices();
    if (document.get('serviceProvider')['name'].length > 1) {
      return document.get('serviceProvider')['image'] == null
          ? Container()
          : ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.network(document.get('serviceProvider')['image']),
              ),
              title: Text(document.get('serviceProvider')['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                      onTap: () {
                        GeoPoint location =
                            document.get('serviceProvider')['location'];
                        launchMap(
                            location, document.get('serviceProvider')['name']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Icon(Icons.map, color: Colors.white),
                        ),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                      onTap: () {
                        launchCall(
                            'tel:${document.get('serviceProvider')['phone']}');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Icon(Icons.phone_in_talk, color: Colors.white),
                        ),
                      )),
                ],
              ),
            );
    }
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

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ServiceBoysList(
                      document: document,
                    );
                  });
            },
            child: Text('Select Service Provider',
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
                showMyDialog('Accept Order', 'Accepted', document.id, context);
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
                  showMyDialog(
                      'Reject Order', 'Rejected', document.id, context);
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

  showMyDialog(title, status, documentId, context) {
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

  void launchCall(number) async {
    if (!await launch(number)) throw 'Could not launch $number';
  }

  void launchMap(GeoPoint location, name) async {
    final availableMaps = await MapLauncher.installedMaps;
    //print(
    //  availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

    await availableMaps.first.showMarker(
      coords: Coords(location.latitude, location.longitude),
      title: name,
    );
  }
}
