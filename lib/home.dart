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

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'detail.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class LoginProvider with ChangeNotifier{
  String Title = Name;

}

class _HomePageState extends State<HomePage> {
  final orderList = ['Asc', 'Desc'];
  var selectedOrder = 'Asc';
  bool isDesc = false;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String downloadURL = "";

  Stream<QuerySnapshot> currentStream = FirebaseFirestore.instance
      .collection('product')
      .orderBy('price', descending: false)
      .snapshots();

  Future<String> url(String name) async {
    downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(name)
        .getDownloadURL();
    // Within your widgets:
    return 'https://' + downloadURL;
  }

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

  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Colors.accents.map((color) {
                return Container(height: 112, color: color);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.person_rounded,
            semanticLabel: 'profile',
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        title: Text("알바몬"),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(
          //     Icons.add,
          //     semanticLabel: 'filter',
          //   ),
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/add');
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          // DropdownButton(
          //   value: selectedOrder,
          //   items: orderList.map((value) {
          //     return DropdownMenuItem(value: value, child: Text(value));
          //   }).toList(),
          //   onChanged: (value) {
          //     setState(() {
          //       selectedOrder = value.toString();
          //       if (selectedOrder == 'Desc') {
          //         currentStream = FirebaseFirestore.instance
          //             .collection('product')
          //             .orderBy('price', descending: true)
          //             .snapshots();
          //       } else {
          //         currentStream = FirebaseFirestore.instance
          //             .collection('product')
          //             .orderBy('price', descending: false)
          //             .snapshots();
          //       }
          //     });
          //   },
          // ),
          buildFloatingSearchBar(),
          // Flexible(
          //   child: StreamBuilder<QuerySnapshot>(
          //       stream: currentStream,
          //       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //         if (snapshot.hasError) return new Text('${snapshot.error}');
          //         switch (snapshot.connectionState) {
          //           case ConnectionState.none:
          //           case ConnectionState.waiting:
          //             return Center(child: CircularProgressIndicator());
          //           default:
          //             return Center(
          //               child:
          //                   OrientationBuilder(builder: (context, orientation) {
          //                 return GridView.count(
          //                   crossAxisCount:
          //                       MediaQuery.of(context).orientation ==
          //                               Orientation.portrait
          //                           ? 2
          //                           : 3,
          //                   // padding: EdgeInsets.all(10),
          //                   childAspectRatio: 7.0 / 8.0,
          //                   children:
          //                       snapshot.data!.docs.map((DocumentSnapshot doc) {
          //                     return Card(
          //                       clipBehavior: Clip.antiAlias,
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: <Widget>[
          //                           AspectRatio(
          //                             aspectRatio: 18 / 11,
          //                             child: FutureBuilder(
          //                               future: url(doc['name']),
          //                               builder: (context,
          //                                   AsyncSnapshot<String> snapshot) {
          //                                 return Container(
          //                                   child: Image.network(downloadURL),
          //                                 );
          //                               },
          //                             ),
          //                           ),
          //                           Expanded(
          //                             child: Padding(
          //                               padding: EdgeInsets.fromLTRB(
          //                                   16.0, 12.0, 16.0, 8.0),
          //                               child: Column(
          //                                 crossAxisAlignment:
          //                                     CrossAxisAlignment.start,
          //                                 children: <Widget>[
          //                                   Text(
          //                                     doc['name'],
          //                                     maxLines: 1,
          //                                   ),
          //                                   SizedBox(height: 8.0),
          //                                   Text(
          //                                     doc['price'] + '원',
          //                                   ),
          //                                   TextButton(
          //                                       onPressed: () {
          //                                         Navigator.push(
          //                                           context,
          //                                           MaterialPageRoute(
          //                                             builder: (context) =>
          //                                                 DetailPage(
          //                                               docID: doc.id,
          //                                             ),
          //                                             settings: RouteSettings(
          //                                               arguments: doc.id,
          //                                             ),
          //                                           ),
          //                                         );
          //                                       },
          //                                       child: Text("more"))
          //                                 ],
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     );
          //                   }).toList(),
          //                 );
          //               }),
          //             );
          //         }
          //       }),
          // ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
