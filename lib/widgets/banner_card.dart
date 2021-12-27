import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rento_vendor/services/firebase_services.dart';

class BannerCard extends StatelessWidget {
  const BannerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return StreamBuilder<QuerySnapshot>(
        stream: _services.vendorBanner.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Container(
            height: 180,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                return Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        child: Image.network(
                          document.get('imageUrl'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                        right: 10,
                        top: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () {
                              EasyLoading.show(status: 'Deleting..');
                              _services.deleteBanner(id: document.id);
                              EasyLoading.dismiss();
                            },
                            icon: Icon(Icons.delete_outline),
                            color: Colors.red,
                          ),
                        ))
                  ],
                );
              }).toList(),
            ),
          );
        });
  }
}
