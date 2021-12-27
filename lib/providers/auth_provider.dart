import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AuthProvider extends ChangeNotifier {
  //Image picker data
  late File image;
  bool isPickAvail = false;
  dynamic _pickImageError;
  String pickerError = '';
  String error = '';
  //service data
  double? serviceLatitude;
  double? serviceLongitude;
  String? selectedAddress;
  bool permissionAllowed = false;
  String? email;
  Future<File> getImage() async {
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

  Future<String> getCurrentPosition() async {
    // Location location = Location();

    // bool _serviceEnabled;
    // PermissionStatus _permissionGranted;
    // LocationData _locationData;

    // _serviceEnabled = await location.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await location.requestService();
    //   if (!_serviceEnabled) {
    //     return;
    //   }
    // }

    // _permissionGranted = await location.hasPermission();
    // if (_permissionGranted == PermissionStatus.denied) {
    //   _permissionGranted = await location.requestPermission();
    //   if (_permissionGranted != PermissionStatus.granted) {
    //     return;
    //   }
    // }

    // _locationData = await location.getLocation();
    // serviceLatitude = _locationData.latitude;
    // serviceLongitude = _locationData.longitude;
    // notifyListeners();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    print(position);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (position != null) {
      this.serviceLatitude = position.latitude;
      this.serviceLongitude = position.longitude;
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark newPlacemark = placemarks.first;
      selectedAddress = newPlacemark.locality! +
          '\n' +
          newPlacemark.street! +
          '\t' +
          newPlacemark.subLocality! +
          '\t' +
          newPlacemark.thoroughfare! +
          '\t' +
          newPlacemark.name! +
          '\t' +
          newPlacemark.postalCode!;
      this.permissionAllowed = true;
      notifyListeners();
    } else {
      print('Permission not allowed');
    }
    return selectedAddress!;
  } //register vendorusers using email

  Future<UserCredential> registerVendor(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        error = 'The password provided is too weak.';
        notifyListeners();
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        error = 'The account already exists for that email.';
        notifyListeners();
        print('The account already exists for that email.');
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential!;
  }

  Future<UserCredential> loginVendor(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        error = 'No user found for that email.';
        notifyListeners();
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        error = 'Wrong password provided for that user.';
        notifyListeners();
        print('Wrong password provided for that user.');
      }
      // this.error = e.code;

      //notifyListeners();
    } catch (e) {
      this.error = e.toString(); //e.code
      notifyListeners();
      print(e);
    }
    return userCredential!;
  }

  Future<void>? resetPassword(email) async {
    this.email = email;
    notifyListeners();
    //UserCredential? userCredential;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        error = 'No user found for that email.';
        notifyListeners();
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        error = 'Wrong password provided for that user.';
        notifyListeners();
        print('Wrong password provided for that user.');
      }
      // this.error = e.code;

      //notifyListeners();
    } catch (e) {
      this.error = e.toString(); //e.code
      notifyListeners();
      print(e);
    }
    return null;
  }

//save vendor data to Firestore
  Future<void>? saveVendorDataToDb(
      {String? url, String? serviceName, String? mobile, String? dialog}) {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentReference _vendors =
        FirebaseFirestore.instance.collection('vendors').doc(user!.uid);
    _vendors.set({
      'uid': user.uid,
      'servicename': serviceName,
      'mobile': mobile,
      'email': email!,
      'dialog': dialog,
      'address': selectedAddress,
      'location': GeoPoint(serviceLatitude!, serviceLongitude!),
      'serviceOpen': true,
      'rating': 0.00,
      'totalRating': 0,
      'isTopPicked': false,
      'imageUrl': url,
      'accVerified': false
    });
    return null;
  }
}
