import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:rento_vendor/services/firebase_services.dart';
import 'package:rento_vendor/services/order_services.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceBoysList extends StatefulWidget {
  final DocumentSnapshot document;
  const ServiceBoysList({Key? key, required this.document}) : super(key: key);

  @override
  State<ServiceBoysList> createState() => _ServiceBoysListState();
}

class _ServiceBoysListState extends State<ServiceBoysList> {
  FirebaseServices _services = FirebaseServices();
  OrderServices _orders = OrderServices();
  DocumentSnapshot? _customerLocation;
  @override
  void initState() {
    _services.getcustomerdetails(widget.document.get('userId')).then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            _customerLocation = value;
          });
        }
      } else {
        print('no Data');
      }
    });
    super.initState();
  }
  // OrderServices _orderServices = OrderServices();
  // User user = FirebaseAuth.instance.currentUser!;
  // var _userLatitude = 0.0;
  // var _userLongitude = 0.0;
  // @override
  // void initState() {
  //   _services.getUserById(user.uid).then((result) {
  //     if (user != null) {
  //       setState(() {
  //         _userLatitude = result.get('latitude');
  //         _userLongitude = result.get('longitude');
  //       });
  //     } else {}
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    //print(widget.document.get('userId'));
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Color(0xFF3c5784),
              title: Text(
                'Select Service Boy',
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: _services.boys
                    .where('accVerified', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      // GeoPoint location = document.get('location');
                      // double distanceInMeters = _customerLocation != null
                      //     ? Geolocator.distanceBetween(
                      //             _customerLocation!.get('latitude'),
                      //             _customerLocation!.get('longitude'),
                      //             location.latitude,
                      //             location.longitude) /
                      //         1000
                      //     : 0.0;
                      // if (distanceInMeters > 10) {
                      //   return Container();
                      // }
                      // Map<String, dynamic> data =
                      //     document.data()! as Map<String, dynamic>;
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              EasyLoading.show(status: 'Assigning Provider');
                              _services
                                  .selectBoys(
                                      orderId: widget.document.id,
                                      phone: document.get('mobile'),
                                      name: document.get('name'),
                                      location: document.get('location'),
                                      image: document.get('imageUrl'),
                                      email: document.get('email'))
                                  .then((value) {
                                EasyLoading.showSuccess('Assigned Provider');
                                Navigator.pop(context);
                              });
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.network(document.get('imageUrl')),
                            ),
                            title: Text(document.get('name')),
                            //subtitle: Text(
                            //  '${distanceInMeters.toStringAsFixed(0)} Km'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    GeoPoint location =
                                        document.get('location');
                                    _orders.launchMap(
                                        location, document.get('name'));
                                  },
                                  icon: Icon(
                                    Icons.map,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _orders.launchCall(
                                        'tel:${document.get('mobile')}');
                                  },
                                  icon: Icon(
                                    Icons.phone,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(
                            height: 2,
                            color: Colors.grey,
                          )
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
