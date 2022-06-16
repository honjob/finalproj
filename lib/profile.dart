import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

String Uid = FirebaseAuth.instance.currentUser!.uid.toString();
String Email = FirebaseAuth.instance.currentUser!.email.toString();
String Name = FirebaseAuth.instance.currentUser!.displayName.toString();
String Message = FirebaseFirestore.instance.collection('user').doc('status_message').snapshots() as String;



class _ProfileState extends State<Profile> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String downloadURL = "";


  Future<String> downloadURLExample() async {
    downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('logo.png')
        .getDownloadURL();
    // Within your widgets:
    return 'https://' + downloadURL;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              semanticLabel: 'logout',
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FirebaseAuth.instance.currentUser!.email != null
          ? Center(
              child: Column(
                children: [
                  Image(
                      image: NetworkImage(
                    FirebaseAuth.instance.currentUser!.photoURL.toString(),
                  )),
                  Text(
                    Uid,
                  ),
                  Text(
                    Email,
                  ),
                  Text(
                    Name
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("HyunSeung Lee"),
                  Text("I promise to take the test honestly before GOD"),
                  TextButton(
                    child:Text('edit'),
                    onPressed: (){

                    },
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                children: [
                  FutureBuilder(
                    future: downloadURLExample(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return Image.network(
                        downloadURL,
                        height: 300,
                        width: 600,
                        scale: 0.5,
                      );
                    },
                  ),
                  Text(Uid),
                  Text("Anonymous"),
                  SizedBox(
                    height: 20,
                  ),
                  Text("HyunSeung Lee"),
                  Text("I promise to take the test honestly before GOD"),
                  TextButton(
                      child:Text('edit'),
                      onPressed: (){

                      },
                  ),
                ],
              ),
            ),
    );
  }
}
