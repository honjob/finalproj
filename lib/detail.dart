import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'edit.dart';

class DetailPage extends StatefulWidget {
  final String docID;

  DetailPage({Key? key, required this.docID}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    CollectionReference Product =
        FirebaseFirestore.instance.collection('product');

    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;
    String downloadURL = "";
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    Future<String> url(String string) async {
      downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(string)
          .getDownloadURL();
      // Within your widgets:
      return 'https://'+downloadURL;
    }

    return FutureBuilder<DocumentSnapshot>(
        future: Product.doc(widget.docID).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return new Text('${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              int numLike = snapshot.data!['like'];
              List<String> likedPeople = List.from(snapshot.data!['likedBy']);

              return MaterialApp(
                home: Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: Center(
                        child: Text('DetailPage'),
                      ),
                      actions: FirebaseAuth.instance.currentUser!.uid ==
                              snapshot.data!['userId']
                          ? <Widget>[
                              IconButton(
                                icon: Icon(
                                  Icons.create,
                                  semanticLabel: 'filter',
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          edit(
                                            docID: widget.docID,
                                          ),
                                      settings: RouteSettings(
                                        arguments: widget.docID,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  semanticLabel: 'filter',
                                ),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('product')
                                      .doc(widget.docID)
                                      .delete();
                                  firebase_storage.FirebaseStorage.instance
                                      .ref(snapshot.data!['name'])
                                      .delete();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ]
                          : <Widget>[]),
                  body: ListView(
                    children: [
                      GestureDetector(
                        child: Hero(
                          tag: 'imageHero',
                          child: Material(
                              child: InkWell(
                            onDoubleTap: () {
                              setState(() {
                              });
                            },
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  child: FutureBuilder(
                                    future: url(snapshot.data!['name']),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      return Image.network(
                                        downloadURL,
                                        height: 300,
                                        width: 600,
                                        scale: 0.5,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: Row(
                          children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    snapshot.data!['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30.0,
                                    ),
                                  ),
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        snapshot.data!['price'] + '원',
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 20),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              if (likedPeople.contains(
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid)) {
                                                _scaffoldKey.currentState!
                                                .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'You can only do it once!'),
                                                ));
                                              } else {
                                                setState(() {
                                                  numLike = numLike + 1;
                                                  Product.doc(widget.docID)
                                                      .update({
                                                    'like': numLike,
                                                    'likedBy':
                                                    FieldValue.arrayUnion([
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                    ])
                                                  });
                                                });
                                                _scaffoldKey.currentState!
                                                    .showSnackBar(SnackBar(
                                                  content: Text('I like it!'),
                                                ));
                                              }
                                            },

                                            icon: Icon(
                                              Icons.thumb_up,
                                              size: 30,
                                              color: Colors.red,
                                            ),
                                          ),
                                          Text(
                                            snapshot.data!['like'].toString(),
                                            style: TextStyle(fontSize: 20),
                                          )
                                        ],
                                      )
                                    ]),
                              ],
                            ))
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0, 10.0, 0),
                                    child: Text(snapshot.data!['description'])),
                              ],
                            ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 200,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text("Creator:"),
                              Text(widget.docID),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Modified on: "),
                              Text(DateFormat('yy-MM-dd  kk:mm').format(snapshot.data!['time'].toDate())),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Created on: "),
                              Text(DateFormat('yy-MM-dd  kk:mm').format(snapshot.data!['datetime'].toDate())),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ));
          }
        });
  }
}

class ProductInfo {
  ProductInfo(
      {required this.name,
      required this.price,
      required this.description,
      required this.userId,
      required this.docId});

  final String name;
  final String price;
  final String description;
  final String userId;
  final String docId;
}
