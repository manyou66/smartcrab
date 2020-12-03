import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_web/flutter_native_web.dart';
import 'package:smartcrab/dialogs/mydialog.dart';
import 'package:smartcrab/screens/authen.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  Map<dynamic, dynamic> iotmap;
  int crabInt;
  String crabString = 'หยุดปล่อยปู';
  String temp_inside =
      'https://thingspeak.com/channels/662286/charts/2?bgcolor=%23ffffff&color=%23d62020&dynamic=true&results=60&type=line';
  WebController webController;
  String nameLogin = "", uidString;
  FirebaseAuth firebaseAuthMyService = FirebaseAuth.instance;
  DateTime _dateTime;
  String weight;
  final formkey = GlobalKey<FormState>(); //Store email and password data
  final scaffoldKey = GlobalKey<ScaffoldState>(); //store all screen
  String showdate = "เลือกวันที่";
  String login = '...';

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

  Future<void> findDisplayName() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    
  }

  Widget showAppName() {
    return Text(
      'แอพพลิเคชันปล่อยปู',
      style: TextStyle(
        color: Colors.blue[700],
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
      ),
    );
  }

  Widget showLogin() {
    return Text('Login by $login');
  }

  Widget showLogo() {
    return Container(
      width: 80.0,
      height: 80.0,
      child: Image.asset('images/logo.png'),
    );
  }

  Widget showHead() {
    return DrawerHeader(
      child: Column(
        children: [
          showLogo(),
          showAppName(),
          SizedBox(
            height: 7.0,
          ),
          showLogin(),
        ],
      ),
    );
  }

  Widget showDrawer() {
    return Drawer(
      child: ListView(
        children: [showHead()],
      ),
    );
  }

  Future<void> additemFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    Map<String, dynamic> map = Map();
    map['datetime'] = showdate;
    map['weight'] = weight;
    await firebaseFirestore.collection('letcrab').add(map).then((value) {
      print('Insert Success');
      normalDialog(context, 'แจ้งเตือน',
          'ส่งค่าวันที่ $showdate น้ำหนักปู $weight กก.เรียบร้อยครับ');
    }).catchError((var response) {
      print('response = $response');
      String title = response.code;
      String message = response.message;
      print('title = $title, message = $message');
      normalDialog(context, title, message);
    });
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

  Widget weightcrab() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            icon: Icon(
              Icons.add,
              color: Colors.blue[700],
              size: 20.0,
            ),
            labelText: 'น้ำหนักปู',
            labelStyle: TextStyle(color: Colors.blue[700]),
            helperText: 'น้ำหนักเป็น กิโลกรัม',
            helperStyle: TextStyle(color: Colors.blue[300]),
          ),
          validator: (String value) {
            if (value.length == 0) {
              return 'กรุณาใส่น้ำหนักปูครับ';
            }
          },
          onSaved: (String value) {
            weight = value.trim();
          },
        ),
      ),
    );
  }

  Widget uploadButton(BuildContext context) {
    return Expanded(
      child: Container(
        child: IconButton(
            icon: Icon(Icons.cloud_upload),
            iconSize: 35.0,
            onPressed: () {
              if (formkey.currentState.validate()) {
                formkey.currentState.save();
                additemFirestore();
              }
            }),
      ),
    );
  }

  Widget date() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 20.0),
        child: RaisedButton(
          child: Text(showdate),
          onPressed: () {
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2050),
            ).then((date) {
              setState(() {
                _dateTime = date;
                showdate = _dateTime.day.toString() +
                    "/" +
                    _dateTime.month.toString() +
                    "/" +
                    _dateTime.year.toString();
                print('date ===> $showdate');
              });
            });
          },
        ),
      ),
    );
  }

  Widget button() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 20.0),
        child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: () {
            if (crabInt == 1) {
              crabString = 'หยุดปล่อยปู';
              editFirebase('Crab', 0);
              normalDialog(context, 'แจ้งเตือน', 'ขอบคุณที่ปล่อยปูครับ');
            } else {
              crabString = 'ปล่อยปู';
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
      drawer: showDrawer(),
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('แอพพลิเคชันปล่อยปูอัจฉริยะ'),
        actions: [
          signOutButton(),
        ],
      ),
      body: Container(
        child: Form(
          key: formkey,
          child: ListView(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 20.0, right: 10.0, left: 5.0),
                    child: flutterWebViewTempInside,
                    height: 300.0,
                    width: 500.0,
                  )
                ],
              ),
              button(),
              Row(
                children: [
                  date(),
                  weightcrab(),
                ],
              ),
              Row(
                children: [
                  uploadButton(context),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0, right: 10.0, left: 5.0),
                child: flutterWebViewTempInside,
                height: 300.0,
                width: 500.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
