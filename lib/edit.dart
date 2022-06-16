import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

import 'home.dart';

class edit extends StatefulWidget {
  final String docID;

  edit({Key? key, required this.docID}) : super(key: key);

  @override
  _editState createState() => _editState();
}


class _editState extends State<edit> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  String downloadURL = "";

  String name = "";
  String price = "";
  String description = "";

  final _formKey = GlobalKey<FormState>();

  File? _image;
  final picker = ImagePicker();

  Future<void> uploadFile(String filePath, String filename) async {
    File file = File(filePath);

    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(filename)
          .putFile(file);
    } catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> downloadURLExample(String name) async {
    downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(name)
        .getDownloadURL();

    return 'https://'+downloadURL;
  }

  void updateProductInfo(String name, String price, String description) {
    FirebaseFirestore.instance.collection('product').doc(widget.docID).set({
      'name': name,
      'price': price,
      'description': description,
      'time': Timestamp.now()
    });

  }

  @override
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
                    updateProductInfo(this.name, this.price, this.description);
                    FirebaseFirestore.instance
                        .collection('product')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({'datetime': DateTime.now().toString()});
                    FirebaseFirestore.instance
                        .collection('product')
                        .doc(widget.docID)
                        .delete();
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
              Container(
                child:
                  FutureBuilder(
                    future: downloadURLExample(widget.docID),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return CircularProgressIndicator();
                        default:
                          return _image == null ? Image.network(downloadURL) : Image.file(_image!);
                      }
                    },
                  ),
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