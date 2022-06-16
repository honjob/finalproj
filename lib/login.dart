// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

//import 'package:Shrine/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutterfire_ui/auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

 class UserModel {
  // 사용자 기본정보

   late String userName; // 사용자 이름(닉네임)
   late String profileImageUrl; // 사용자 프로필사진
   late String uid; // 현재 사용자(로그인한)
//    public String pushToken;

}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initState() {
    super.initState();
    _handleSignOut();
  }

  Future<GoogleSignInAccount?> googleLogin() async =>
      await GoogleSignIn().signIn();

  Future<void> _handleSignIn() async {
    final GoogleSignInAccount googleUser = (await _googleSignIn.signIn())!;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user!;
    print("signed in " + user.displayName!);

  }


  Future<void> _handleSignOut() => FirebaseAuth.instance.signOut();


  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();

    } catch (e) {
      print(e);
    }
  }


  Widget _buildBody() {
    // ignore: unnecessary_null_comparison
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      children: <Widget>[
        SizedBox(height: 80.0),
        Column(
          children: <Widget>[
            SizedBox(height: 16.0),
          ],
        ),
        SizedBox(height: 120.0),
        // ignore: deprecated_member_use
        RaisedButton(
          child: Text('GOOGLE'),
          onPressed: () {
            _handleSignIn().then((value) {
              setState(() {
                FirebaseFirestore.instance.collection('user').add({
                  'email':FirebaseAuth.instance.currentUser!.email,
                  'name': FirebaseAuth.instance.currentUser!.displayName,
                  'uid': FirebaseAuth.instance.currentUser!.uid,
                },);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              });
            });
          },
        ),
        // ignore: deprecated_member_use
        RaisedButton(
          child: Text('EMAIL'),
          onPressed: () {
            _signInAnonymously().then((value) {
              setState(() {
                FirebaseFirestore.instance.collection('user').add({
                  'uid': FirebaseAuth.instance.currentUser!.uid,
                },);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              });
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
}
