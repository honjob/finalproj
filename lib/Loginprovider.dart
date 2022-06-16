import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'detail.dart';
import 'package:provider/provider.dart';

class LoginProvider extends ChangeNotifier{
  late String _title;
  String get title => _title;

  Google(){
    _title = Name;
    notifyListeners();
  }

  Anonymous(){
    _title = "Guest";
    notifyListeners();
  }

}