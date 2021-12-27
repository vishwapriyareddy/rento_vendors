//import 'dart:html';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rento_vendor/providers/auth_provider.dart';
import 'package:rento_vendor/screen/home_screen.dart';
import 'package:rento_vendor/screen/login_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _cpasswordTextController = TextEditingController();
  var _addressTextController = TextEditingController();
  var _nameTextController = TextEditingController();
  var _dialogTextController = TextEditingController();

  String? email;
  String? password;
  String? mobile;
  String? serviceName;
  bool _isLoading = false;
  Future<String> uploadFile(filePath) async {
    File file = File(filePath);
    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage
          .ref('uploads/serviceProfilePic/${_nameTextController.text}')
          .putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e.code);
    }
    String downloadURL = await _storage
        .ref('uploads/serviceProfilePic/${_nameTextController.text}')
        .getDownloadURL();
    return downloadURL;
    // Within your widgets:
    // Image.network(downloadURL);
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    scaffoldMessage(message) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    return _isLoading
        ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3c5784)))
        : Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Service Name";
                        }
                        setState(() {
                          _nameTextController.text = value;
                        });
                        setState(() {
                          serviceName = value;
                        });
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.add_business),
                          labelText: 'Service name',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor)),
                          focusColor: Theme.of(context).primaryColor)),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Mobile Number";
                        }
                        setState(() {
                          mobile = value;
                        });
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixText: '+91',
                          prefixIcon: Icon(Icons.phone_android),
                          labelText: 'Mobile number',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor)),
                          focusColor: Theme.of(context).primaryColor)),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                      controller: _emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Email";
                        }
                        final bool _isValid =
                            EmailValidator.validate(_emailTextController.text);
                        if (!_isValid) {
                          return 'Invalid Email Format';
                        }
                        setState(() {
                          email = value;
                        });
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor)),
                          focusColor: Theme.of(context).primaryColor)),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Password";
                        }
                        if (value.length < 6) {
                          return "Minimum 6 charactres";
                        }
                        setState(() {
                          password = value;
                        });
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          labelText: 'Password',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor)),
                          focusColor: Theme.of(context).primaryColor)),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Confirm Password";
                        }
                        if (value.length < 6) {
                          return "Minimum 6 charactres";
                        }
                        if (_passwordTextController.text !=
                            _cpasswordTextController.text) {
                          return "Password doesn't match";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          labelText: 'Confirm Password',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor)),
                          focusColor: Theme.of(context).primaryColor)),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                      maxLines: 6,
                      controller: _addressTextController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please press Navigation button";
                        }
                        if (_authData.serviceLatitude == null) {
                          return "Please press Navigation button";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.contact_mail_outlined),
                          suffixIcon: IconButton(
                              onPressed: () {
                                _addressTextController.text =
                                    'Locating...\nPlease wait...';
                                _authData.getCurrentPosition().then((address) {
                                  if (address != null) {
                                    setState(() {
                                      _addressTextController.text =
                                          '${_authData.selectedAddress}';
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Could not find location...Try again')));
                                  }
                                });
                              },
                              icon: Icon(Icons.location_searching)),
                          labelText: 'Service Location',
                          //  contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor)),
                          focusColor: Theme.of(context).primaryColor)),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                      onChanged: (value) {
                        _dialogTextController.text = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Service Name";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.comment),
                          labelText: 'Service Dialog ',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor)),
                          focusColor: Theme.of(context).primaryColor)),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (_authData.isPickAvail == true) {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              _authData
                                  .registerVendor(email, password)
                                  .then((credential) {
                                if (credential.user!.uid != null) {
                                  uploadFile(_authData.image.path).then((url) {
                                    if (url != null) {
                                      _authData.saveVendorDataToDb(
                                        url: url,
                                        mobile: mobile,
                                        serviceName: serviceName,
                                        dialog: _dialogTextController.text,
                                      );
                                      //!
                                      //  .then((value) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      Navigator.pushReplacementNamed(
                                          context, HomeScreen.id);
                                      //});
                                    } else {
                                      scaffoldMessage(
                                          'Failed to upload Service profile pic');
                                    }
                                  });
                                } else {
                                  scaffoldMessage(_authData.error);
                                }
                              });
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //     SnackBar(content: Text('Processing Data')));
                            }
                          } else {
                            scaffoldMessage('Service pic need to be added');
                          }
                        },
                        child: Text('Register',
                            style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                  child: Text('Already Registered?  Login here.',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
  }
}
