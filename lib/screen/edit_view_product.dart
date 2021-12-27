import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/product_provider.dart';
import 'package:rento_vendor/services/firebase_services.dart';
import 'package:rento_vendor/widgets/category_list.dart';

class EditViewProduct extends StatefulWidget {
  final String serviceId;
  const EditViewProduct({Key? key, required this.serviceId}) : super(key: key);

  @override
  _EditViewProductState createState() => _EditViewProductState();
}

class _EditViewProductState extends State<EditViewProduct> {
  FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  var _serviceNameText = TextEditingController();
  var _priceText = TextEditingController();
  var _comparedPriceText = TextEditingController();
  var _descriptionText = TextEditingController();
  var _categoryTextController = TextEditingController();
  var _subCategoryTextController = TextEditingController();
  var _taxTextController = TextEditingController();

  double? discount;
  String? image;
  String? categoryImage;
  String? dropdownValue;
  bool _visible = false;
  bool _editing = true;
  File? _image;
  DocumentSnapshot? doc;
  final List<String> _collections = [
    'Featured Services',
    'Best Services',
    'Recently Added'
  ];
  @override
  void initState() {
    getServiceDetails();
    // TODO: implement initState
    super.initState();
  }

  Future<void> getServiceDetails() async {
    _services.services
        .doc(widget.serviceId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          doc = document;
          _serviceNameText.text = document.get('serviceName');
          _priceText.text = document.get('price').toString();
          _comparedPriceText.text = document.get('comparedPrice').toString();
          var difference = int.parse(_comparedPriceText.text) -
              double.parse(_priceText.text);
          discount = (difference / int.parse(_comparedPriceText.text) * 100);
          image = document.get('serviceImage');
          _descriptionText.text = document.get('description');
          _categoryTextController.text =
              document.get('category')['mainCategory'];
          _subCategoryTextController.text =
              document.get('category')['subCategory'];
          dropdownValue = document.get('collection');
          _taxTextController.text = document.get('tax').toString();
          categoryImage = document.get('categoryImage');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProductProvider>(context);
    //  _provider.resetProvider();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3c5784),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  _editing = false;
                });
              },
              child: Text('Edit', style: TextStyle(color: Colors.white)))
        ],
      ),
      bottomSheet: Container(
          height: 60,
          child: Row(
            children: [
              Expanded(
                  child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )),
              Expanded(
                  child: AbsorbPointer(
                absorbing: _editing,
                child: InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.show(status: 'Saving...');
                      if (_provider.isPickAvail == true) {
                        _provider
                            .uploadServicesImages(
                                _provider.image.path, _serviceNameText.text)
                            .then((url) {
                          if (url != null) {
                            EasyLoading.dismiss();
                            _provider.updateProduct(
                                context: context,
                                serviceName: _serviceNameText.text,
                                tax: double.parse(_taxTextController.text),
                                price: double.parse(_priceText.text),
                                description: _descriptionText.text,
                                collection: dropdownValue,
                                comparedPrice:
                                    int.parse(_comparedPriceText.text),
                                serviceId: widget.serviceId,
                                image: image,
                                category: _categoryTextController.text,
                                subCategory: _subCategoryTextController.text,
                                categoryImage: categoryImage);
                          }
                        });
                      }
                    } else {
                      _provider.updateProduct(
                          context: context,
                          serviceName: _serviceNameText.text,
                          tax: double.parse(_taxTextController.text),
                          price: double.parse(_priceText.text),
                          description: _descriptionText.text,
                          collection: dropdownValue,
                          comparedPrice: int.parse(_comparedPriceText.text),
                          serviceId: widget.serviceId,
                          image: image,
                          category: _categoryTextController.text,
                          subCategory: _subCategoryTextController.text,
                          categoryImage: categoryImage);
                      EasyLoading.dismiss();
                    }
                      _provider.resetProvider();
                    //   EasyLoading.dismiss();
                  },
                  child: Container(
                    width: 50,
                    color: Color(0xFF3c5784),
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ))
            ],
          )),
      body: doc == null
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: [
                    AbsorbPointer(
                      absorbing: _editing,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            child: TextFormField(
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none),
                              controller: _serviceNameText,
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12.0, top: 2),
                                  child: Image.asset(
                                    'images/rupee.png',
                                    fit: BoxFit.contain,
                                    width: MediaQuery.of(context).size.width *
                                        0.041,
                                  ),
                                ),
                                Container(
                                  width: 80,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      // prefixIcon: Image.asset(
                                      //   'images/rupee.png',
                                      //   fit: BoxFit.contain,
                                      //   //  width: MediaQuery.of(context).size.width *
                                      //   //    0.02,
                                      // ),
                                    ),
                                    controller: _priceText,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset(
                                    'images/rupee.png',
                                    fit: BoxFit.contain,
                                    width: MediaQuery.of(context).size.width *
                                        0.04,
                                  ),
                                ),
                                Container(
                                  width: 80,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      // prefixIcon: Image.asset(
                                      //   'images/rupee.png',
                                      //   fit: BoxFit.contain,
                                      //   //  width: MediaQuery.of(context).size.width *
                                      //   //    0.02,
                                      // ),
                                    ),
                                    controller: _comparedPriceText,
                                    style: TextStyle(
                                        fontSize: 15,
                                        decoration: TextDecoration.lineThrough),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.red,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: Text(
                                      '${discount!.toStringAsFixed(0)}% OFF',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text('Inclusive of all Taxes',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          InkWell(
                            onTap: () {
                              _provider.getProductImage().then((image) {
                                setState(() {
                                  _image = image;
                                });
                                if (image != null) {
                                  _provider.isPickAvail = true;
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                image!,
                                height: 300,
                              ),
                            ),
                          ),
                          Text('About this service',
                              style: TextStyle(fontSize: 20)),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: TextFormField(
                              maxLines: null,
                              controller: _descriptionText,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(color: Colors.grey),
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            child: Row(children: [
                              Text('Category',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16)),
                              SizedBox(width: 10),
                              Expanded(
                                child: AbsorbPointer(
                                  absorbing:
                                      true, // this will block user entering category name mannually
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Select Category Name';
                                      }

                                      return null;
                                    },
                                    controller: _categoryTextController,
                                    onChanged: (value) {},
                                    decoration: InputDecoration(
                                      hintText: 'not selected',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      contentPadding: EdgeInsets.zero,
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _editing ? false : true,
                                child: IconButton(
                                  icon: Icon(Icons.edit_outlined),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CategoryList();
                                        }).whenComplete(() {
                                      setState(() {
                                        _categoryTextController.text =
                                            _provider.selectedCategory;
                                        _visible = true;
                                      });
                                    });
                                  },
                                ),
                              )
                            ]),
                          ),
                          Visibility(
                            visible: _visible,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 20),
                              child: Row(
                                children: [
                                  Text(
                                    'Sub Category',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Select Sub Category Name';
                                          }

                                          return null;
                                        },
                                        controller: _subCategoryTextController,
                                        onChanged: (value) {},
                                        decoration: InputDecoration(
                                          hintText: 'not selected',
                                          labelStyle:
                                              TextStyle(color: Colors.grey),
                                          contentPadding: EdgeInsets.zero,
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          )),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SubCategoryList();
                                          }).whenComplete(() {
                                        setState(() {
                                          _subCategoryTextController.text =
                                              _provider.selectedSubCategory;
                                        });
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                              child: Row(
                            children: [
                              Text('Collection',
                                  style: TextStyle(color: Colors.grey)),
                              SizedBox(
                                width: 10,
                              ),
                              DropdownButton<String>(
                                hint: Text('Select Collection'),
                                items: _collections
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                      value: value, child: Text(value));
                                }).toList(),
                                value: dropdownValue,
                                icon: Icon(Icons.arrow_drop_down),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValue = value.toString();
                                  });
                                },
                              )
                            ],
                          )),
                          Row(
                            children: [
                              Text('Tax %:'),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  //  height: 20,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none),
                                    controller: _taxTextController,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 90)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
