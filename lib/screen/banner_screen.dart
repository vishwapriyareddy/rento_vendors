import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/product_provider.dart';
import 'package:rento_vendor/services/firebase_services.dart';
import 'package:rento_vendor/widgets/banner_card.dart';

class BannerScreen extends StatefulWidget {
  static const String id = 'banner-screen';

  const BannerScreen({Key? key}) : super(key: key);

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  FirebaseServices _services = FirebaseServices();
  bool _visible = false;
  File? _image;
  var _imagePathText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3c5784),
          title: const Text('Banners'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                CupertinoIcons.search,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                CupertinoIcons.bell,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            BannerCard(),
            SizedBox(
              height: 20,
            ),
            Divider(
              thickness: 3,
            ),
            Container(
                child: Center(
                    child: Text('ADD NEW BANNER',
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: Colors.grey[200],
                              child: _image != null
                                  ? Image.file(_image!, fit: BoxFit.fill)
                                  : Center(
                                      child: Text('No Image Selected'),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _imagePathText,
                      enabled: false,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: _visible ? false : true,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).primaryColor)),
                                onPressed: () {
                                  setState(() {
                                    _visible = true;
                                  });
                                },
                                child: Text('Add New Banner',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _visible,
                      child: Container(
                          child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context)
                                                    .primaryColor)),
                                    onPressed: () {
                                      getBannerImage().then((value) {
                                        if (_image != null) {
                                          setState(() {
                                            _imagePathText.text = _image!.path;
                                          });
                                        }
                                      });
                                    },
                                    child: Text('Upload Image',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AbsorbPointer(
                                  absorbing: _image != null ? false : true,
                                  child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  _image != null
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.grey)),
                                      onPressed: () {
                                        EasyLoading.show(status: 'Saving...');
                                        uploadBannerImages(_image!.path,
                                                _provider.serviceName)
                                            .then((url) {
                                          if (url != null) {
                                            _services.saveBanner(url: url);
                                            setState(() {
                                              _imagePathText.clear();
                                              _image = null;
                                            });
                                            EasyLoading.dismiss();
                                            _provider.alertDialog(
                                                context: context,
                                                title: 'Banner Upload',
                                                content:
                                                    'Banner Uploaded Successfully..');
                                          } else {
                                            EasyLoading.dismiss();
                                            _provider.alertDialog(
                                                context: context,
                                                title: 'Banner Upload',
                                                content:
                                                    'Banner Upload Falied');
                                          }
                                        });
                                      },
                                      child: Text('Save',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold))),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.black45)),
                                    onPressed: () {
                                      setState(() {
                                        _visible = false;
                                        _imagePathText.clear();
                                        _image = null;
                                      });
                                    },
                                    child: Text('Cancel',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ],
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Future<File> getBannerImage() async {
    final picker = ImagePicker();

    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected');
    }
    return _image!;
  }

  Future<String> uploadBannerImages(filePath, serviceName) async {
    File file = File(filePath);
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;
    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage.ref('vendorBanner/$serviceName/$timeStamp').putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    String downloadURL = await _storage
        .ref('vendorBanner/$serviceName/$timeStamp')
        .getDownloadURL();
    // this.serviceUrl = downloadURL;
    // notifyListeners();
    return downloadURL;
    // Within your widgets:
    // Image.network(downloadURL);
  }
}
