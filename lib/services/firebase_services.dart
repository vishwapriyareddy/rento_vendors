// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseServices {
  User user = FirebaseAuth.instance.currentUser!;
  CollectionReference category =
      FirebaseFirestore.instance.collection('category');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  CollectionReference services =
      FirebaseFirestore.instance.collection('services');
  CollectionReference vendorBanner =
      FirebaseFirestore.instance.collection('vendorBanner');
  CollectionReference boys = FirebaseFirestore.instance.collection('boys');
  Future<void> publishService({id}) {
    return services.doc(id).update({'published': true});
  }

  Future<void> unPublishService({id}) {
    return services.doc(id).update({'published': false});
  }

  Future<void> deleteService({id}) {
    return services.doc(id).delete();
  }

  Future<void> saveBanner({url}) {
    return vendorBanner.add({'imageUrl': url, 'supervisorUid': user.uid});
  }

  Future<void> deleteBanner({id}) {
    return vendorBanner.doc(id).delete();
  }

  Future<void> selectBoys({orderId, location, name, image, phone, email}) {
    var result = orders.doc(orderId).update({
      'serviceProvider': {
        'location': location,
        'name': name,
        'image': image,
        'phone': phone,
        'email': email
      }
    });
    return result;
  }

  Future<DocumentSnapshot> getcustomerdetails(id) async {
    DocumentSnapshot doc = await users.doc(id).get();
    return doc;
  }
}
