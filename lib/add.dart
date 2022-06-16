import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';

import 'home.dart';


class Add extends StatefulWidget {
  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  String downloadURL = "";

  String name = "";
  String price = "";
  String description = "";

  final _formKey = GlobalKey<FormState>();

  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> downloadURLExample() async {
    downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('logo.png')
        .getDownloadURL();

    return 'http://'+downloadURL;
  }

  Future<void> uploadFile(String filePath, String filename) async {
    File file = File(filePath);
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(filename)
          .putFile(file);
    } catch (e) {}
  }

  void addProductInfo(String name, String price, String description) {

    FirebaseFirestore.instance.collection('product').add({
      'name': name,
      'price': price,
      'description': description,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'like': 0,
      'likedBy': []
    }).then((value) => {
      FirebaseFirestore.instance.collection('product').doc(value.id).set({
        'name': name,
        'price': price,
        'description': description,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'time' : Timestamp.now(),
        'docId': value.id,
        'like': 0,
        'datetime': FieldValue.serverTimestamp(),
        'likedBy' : []
      })
    });
  }


  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 13.0)),
              onPressed: () {
                Navigator.pushNamed(context, '/first');
              }),
          actions: <Widget>[
            TextButton(
                child: Text('Save',
                    style: TextStyle(color: Colors.white, fontSize: 15.0)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    this._formKey.currentState!.save();
                    // print(this.description);
                    addProductInfo(this.name, this.price, this.description);
                    uploadFile(_image!.path.toString(), this.name);
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                        builder: (context) => HomePage(),)
                    );
                  }
                }),
          ],
        ),
        body: Form(
          key: this._formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 120.0),
              SizedBox(height: 120.0),
              FutureBuilder(
                future: downloadURLExample(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      return Center(child: _image == null ? Image.network(downloadURL) : Image.file(_image!));
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: getImage,
                      icon: Icon(
                        Icons.photo_camera,
                        size: 30.0,
                      ))
                ],
              ),
              TextFormField(
                onSaved: (val) {
                  setState(() {
                    this.name=val!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  labelText: 'Product Name',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please Enter Product Name';
                  }
                  return null;
                },
              ),
              TextFormField(
                onSaved: (val) {
                  setState(() {
                    this.price=val!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  labelText: 'Price',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please Enter Price Name';
                  }
                  return null;
                },
              ),
              TextFormField(
                onSaved: (val) {
                  setState(() {
                    this.description=val!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  labelText: 'Description',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please Enter Description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ));
  }
}

class ProductInfo {
  ProductInfo({required this.name, required this.price, required this.description, required this.userId, required this.docId, required this.like, required this.likedBy});

  final String name;
  final String price;
  final String description;
  final String userId;
  final String docId;
  final int like;
  final List<String> likedBy;
}