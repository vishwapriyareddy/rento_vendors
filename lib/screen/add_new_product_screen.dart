//import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/product_provider.dart';
import 'package:rento_vendor/widgets/category_list.dart';

class AddNewProduct extends StatefulWidget {
  static const String id = 'addnewproduct-screen';

  const AddNewProduct({Key? key}) : super(key: key);

  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _collections = [
    'Featured Services',
    'Best Services',
    'Recently Added'
  ];
  String? dropdownValue;
  var _categoryTextController = TextEditingController();
  var _subCategoryTextController = TextEditingController();
  var _comparedPriceTextController = TextEditingController();

  bool _visible = false;
  bool _track = false;
  String? serviceName;
  String? description;
  double? price;
  double? comparedPrice;
  double? tax;

  @override
  Widget build(BuildContext context) {
    File? _image;
    var _provider = Provider.of<ProductProvider>(context);

    return DefaultTabController(
      length: 2,
      initialIndex:
          1, // will keep initial index to avoid textfield clearing automatically
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Material(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Container(
                          child: Text('Products / Add'),
                        ),
                      ),
                      TextButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_categoryTextController.text.isNotEmpty) {
                                if (_subCategoryTextController
                                    .text.isNotEmpty) {
                                  if (_provider.isPickAvail == true) {
                                    EasyLoading.show(status: 'Saving...');
                                    _provider
                                        .uploadServicesImages(
                                            _provider.image.path, serviceName)
                                        .then((url) {
                                      if (url != null) {
                                        EasyLoading.dismiss();
                                        _provider.saveProductDataToDb(
                                            context: context,
                                            comparedPrice: int.parse(
                                                _comparedPriceTextController
                                                    .text),
                                            collection: dropdownValue,
                                            description: description,
                                            price: price,
                                            tax: tax,
                                            serviceName: serviceName);
                                        setState(() {
                                          _formKey.currentState!.reset();
                                          _comparedPriceTextController.clear();
                                          _subCategoryTextController.clear();
                                          _track = false;
                                          _provider.isPickAvail = false;
                                          _visible = false;
                                        });
                                      } else {
                                        _provider.alertDialog(
                                            context: context,
                                            title: 'IMAGE UPLOAD',
                                            content:
                                                'Failed to upload Service image');
                                      }
                                    });
                                  } else {
                                    _provider.alertDialog(
                                        context: context,
                                        title: 'SERVICE IMAGE',
                                        content: 'Service Image not selected');
                                  }
                                } else {
                                  _provider.alertDialog(
                                      context: context,
                                      title: 'Sub Category',
                                      content: 'Sub Category not selected');
                                }
                              } else {
                                _provider.alertDialog(
                                    context: context,
                                    title: 'Main Category',
                                    content: 'Main Category not selected');
                              }
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).primaryColor)),
                          icon: Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                ),
              ),
              TabBar(
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(
                      text: 'GENERAL',
                    ),
                    Tab(
                      text: 'INVENTORY',
                    ),
                  ]),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: TabBarView(children: [
                      ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter Service Name';
                                    }
                                    setState(() {
                                      serviceName = value;
                                    });
                                    return null;
                                  },
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    labelText: 'Service Name*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter description';
                                    }
                                    setState(() {
                                      description = value;
                                    });
                                    return null;
                                  },
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  maxLength: 500,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    labelText: 'About Service*',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
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
                                    child: SizedBox(
                                      width: 150,
                                      height: 150,
                                      child: Card(
                                        child: Center(
                                          child: _provider.isPickAvail == false
                                              ? Center(
                                                  child: Text(
                                                  'Add Service Image',
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ))
                                              : Image.file(_provider.image),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter Selling Price';
                                    }
                                    setState(() {
                                      price = double.parse(value);
                                    });
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    labelText: 'Price*', //final Selling Price
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                  ),
                                ),
                                TextFormField(
                                  controller: _comparedPriceTextController,
                                  validator: (value) {
                                    if (price! > double.parse(value!)) {
                                      return 'Compared price should be higher than price';
                                    }
                                    // setState(() {
                                    //   comparedPrice = double.parse(value);
                                    // });
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    labelText:
                                        'Compared Price*', // Price before discount
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 20),
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
                                              return CategoryList();
                                            }).whenComplete(() {
                                          setState(() {
                                            _categoryTextController.text =
                                                _provider.selectedCategory;
                                            _visible = true;
                                          });
                                        });
                                      },
                                    )
                                  ]),
                                ),
                                Visibility(
                                  visible: _visible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 20),
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
                                              controller:
                                                  _subCategoryTextController,
                                              onChanged: (value) {},
                                              decoration: InputDecoration(
                                                hintText: 'not selected',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey),
                                                contentPadding: EdgeInsets.zero,
                                                enabledBorder:
                                                    UnderlineInputBorder(
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
                                                builder:
                                                    (BuildContext context) {
                                                  return SubCategoryList();
                                                }).whenComplete(() {
                                              setState(() {
                                                _subCategoryTextController
                                                        .text =
                                                    _provider
                                                        .selectedSubCategory;
                                              });
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Enter Tax%';
                                    }
                                    setState(() {
                                      tax = double.parse(value);
                                    });
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    labelText: 'Tax %',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SwitchListTile(
                                title: Text('Track Inventory'),
                                activeColor: Theme.of(context).primaryColor,
                                subtitle: Text(
                                  'Switch On to track Inventory',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                value: _track,
                                onChanged: (selected) {
                                  setState(() {
                                    _track = !_track;
                                  });
                                }),
                            Visibility(
                              visible: _track,
                              child: SizedBox(
                                  height: 300,
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          // TextFormField(
                                          //   validator: (value) {
                                          //     if (_track) {
                                          //       if (value!.isEmpty) {
                                          //         return 'Enter Inventory';
                                          //       }
                                          //       return null;
                                          //     }
                                          //   },
                                          //   keyboardType: TextInputType.number,
                                          //   onChanged: (value) {},
                                          //   decoration: InputDecoration(
                                          //     labelText: 'Inventory',
                                          //     labelStyle:
                                          //         TextStyle(color: Colors.grey),
                                          //     contentPadding: EdgeInsets.zero,
                                          //     enabledBorder:
                                          //         UnderlineInputBorder(
                                          //             borderSide: BorderSide(
                                          //       color: Colors.grey.shade300,
                                          //     )),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  )),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
