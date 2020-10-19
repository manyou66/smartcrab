import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_web/flutter_native_web.dart';
import 'package:smartcrab/screens/authen.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  Map<dynamic, dynamic> iotmap;
  int crabInt;
  String crabString = 'Stop Crab';
  String temp_inside = 'https://thingspeak.com/channels/662286/charts/2?bgcolor=%23ffffff&color=%23d62020&dynamic=true&results=60&type=line';
  WebController webController;
  String nameLogin = "", uidString;
  FirebaseAuth firebaseAuthMyService = FirebaseAuth.instance;

  void onWebCreatedTempInside(webController) {
    this.webController = webController;
    this.webController.loadUrl(temp_inside);
    this.webController.onPageStarted.listen((url) => print("Loading $url"));
    this
        .webController
        .onPageFinished
        .listen((url) => print("Finished loading $url"));
  }

  @override
  void initState() {
    super.initState();
    getValueFromFirebase();
  }

  void getValueFromFirebase() async {
    DatabaseReference databaseReference =
        await firebaseDatabase.reference().once().then((objValue) {
      iotmap = objValue.value;
      setState(() {
        crabInt = iotmap['Crab'];
        print('Crab = $crabInt');
      });
    });
  }

  void editFirebase(String nodeString, int value) async {
    print('node ==> $nodeString');
    iotmap['$nodeString'] = value;
    await firebaseDatabase.reference().set(iotmap).then((objValue) {
      print('$nodeString Success');
      getValueFromFirebase();
    }).catchError((objValue) {
      String error = objValue.message;
      print('error ==> $error');
    });
  }

  Widget button() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 50.0),
        child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: () {
            if (crabInt == 1) {
              crabString = 'Stop Crab';
              editFirebase('Crab', 0);
            } else {
              crabString = 'Open Crab';
              editFirebase('Crab', 1);
            }
          },
          color: Colors.orange[500],
          child: Text(
            crabString,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget signOutButton() {
    return IconButton(
      icon: Icon(Icons.exit_to_app),
      tooltip: 'Sign Out',
      onPressed: () {
        signOut2();
      },
    );
  }

  void signOut() async {
    await firebaseAuthMyService.signOut().then((objValue) {
      print('Exit');
      exit(0);
    });
  }

  Future<void> signOut2() async {
    await firebaseAuthMyService.signOut().then((response) {
      MaterialPageRoute materialPageRoute =
          MaterialPageRoute(builder: (BuildContext context) {
        return Authen();
      });
      Navigator.of(context).pushAndRemoveUntil(materialPageRoute,
          (Route<dynamic> route) {
        return false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterNativeWeb flutterWebViewTempInside = new FlutterNativeWeb(
      onWebCreated: onWebCreatedTempInside,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        Factory<OneSequenceGestureRecognizer>(
          () => TapGestureRecognizer(),
        ),
      ].toSet(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Release Crab'),
        actions: [
          signOutButton(),
        ],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 30.0, right: 10.0, left: 10.0),
                child: flutterWebViewTempInside,
                height: 300.0,
                width: 500.0,
              )
            ],
          ),
          button(),
        ],
      ),
    );
  }
}
