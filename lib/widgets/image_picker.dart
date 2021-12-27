import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/auth_provider.dart';

class ServicePicCard extends StatefulWidget {
  const ServicePicCard({Key? key}) : super(key: key);

  @override
  State<ServicePicCard> createState() => _ServicePicCardState();
}

class _ServicePicCardState extends State<ServicePicCard> {
  @override
  Widget build(BuildContext context) {
    File _image;

    final _authData = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: () {
          _authData.getImage().then((image) {
            setState(() {
              _image = image;
            });
            if (image != null) {
              _authData.isPickAvail = true;
            }
            // print(_authData.image);
          });
        },
        child: SizedBox(
            height: 150,
            width: 150,
            child: Card(
                child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _authData.isPickAvail == false
                  ? Center(
                      child: Text(
                      'Add Service Image',
                      style: TextStyle(color: Colors.grey),
                    ))
                  : Image.file(
                      _authData.image,
                      fit: BoxFit.fill,
                    ),
            ))),
      ),
    );
  }
}
