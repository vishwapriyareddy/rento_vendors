import 'dart:io';
//import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider with ChangeNotifier {
  String selectedCategory = 'not selected';
  String selectedSubCategory = 'not selected';
  String? categoryImage;
  bool isPickAvail = false;
  String? serviceName;
  String? serviceUrl;
  late File image;
  dynamic _pickImageError;
  selectCategory(mainCategory, categoryImage) {
    this.selectedCategory = mainCategory;
    this.categoryImage = categoryImage;
    notifyListeners();
  }

  selectSubCategory(selected) {
    this.selectedSubCategory = selected;
    notifyListeners();
  }

  getServiceName(serviceName) {
    this.serviceName = serviceName;
    notifyListeners();
  }

  resetProvider() {
    this.selectedCategory = null.toString();
    // this.selectedSubCategory = null.toString();
    categoryImage = null;
    serviceUrl = null;
    //image = null;
    notifyListeners();
  }

  Future<String> uploadServicesImages(filePath, serviceName) async {
    File file = File(filePath);
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;
    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage
          .ref('serviceImage/${this.serviceName}/$serviceName$timeStamp')
          .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    String downloadURL = await _storage
        .ref('serviceImage/${this.serviceName}/$serviceName$timeStamp')
        .getDownloadURL();
    this.serviceUrl = downloadURL;
    notifyListeners();
    return downloadURL;
    // Within your widgets:
    // Image.network(downloadURL);
  }

  Future<File> getProductImage() async {
    final picker = ImagePicker();

    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    } else {
      _pickImageError = 'No image selected';
      print('No image selected');
      notifyListeners();
    }
    return image;
  }

  alertDialog({context, title, content}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void>? saveProductDataToDb(
      {serviceName,
      description,
      price,
      comparedPrice,
      collection,
      tax,
      context}) {
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;
    User user = FirebaseAuth.instance.currentUser!;
    CollectionReference _services =
        FirebaseFirestore.instance.collection('services');
    try {
      _services.doc(timeStamp.toString()).set({
        'supervoisor': {
          'servicename': this.serviceName,
          'supervisorUid': user.uid
        },
        'serviceName': serviceName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'category': {
          'mainCategory': this.selectedCategory,
          'subCategory': this.selectedSubCategory,
          'categoryImage': this.categoryImage
        },
        'tax': tax,
        'published': false,
        'serviceId': timeStamp.toString(),
        'serviceImage': serviceUrl
      });
      this.alertDialog(
          context: context,
          title: 'SAVED DATA',
          content: 'Service details saved successfully');
    } catch (e) {
      this.alertDialog(
          context: context, title: 'SAVE DATA', content: '${e.toString()}');
    }
    return null;
  }

  Future<void>? updateProduct(
      {serviceName,
      description,
      price,
      comparedPrice,
      collection,
      tax,
      context,
      serviceId,
      image,
      category,
      subCategory,
      categoryImage}) {
    //  var timeStamp = Timestamp.now().millisecondsSinceEpoch;
    // User user = FirebaseAuth.instance.currentUser!;
    CollectionReference _services =
        FirebaseFirestore.instance.collection('services');
    try {
      _services.doc(serviceId).update({
        // 'supervoisor': {
        //   'servicename': this.serviceName,
        //   'supervisorUid': user.uid
        // },
        'serviceName': serviceName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'category': {
          'mainCategory': category,
          'subCategory': subCategory,
          'categoryImage':
              this.categoryImage == null ? categoryImage : this.categoryImage
        },
        'tax': tax,
        'serviceImage': serviceUrl == null ? image : this.serviceUrl
      });
      this.alertDialog(
          context: context,
          title: 'SAVED DATA',
          content: 'Service details saved successfully');
    } catch (e) {
      this.alertDialog(
          context: context, title: 'SAVE DATA', content: '${e.toString()}');
    }
    return null;
  }
}
