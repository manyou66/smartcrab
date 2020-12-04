import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smartcrab/dialogs/mydialog.dart';
import 'package:smartcrab/screens/authen.dart';
import 'package:smartcrab/widget/showdetail.dart';
import 'package:smartcrab/widget/showrelease.dart';
import 'package:smartcrab/widget/showtemp.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  Map<dynamic, dynamic> iotmap;
  int crabInt;
  String crabString = 'หยุดปล่อยปู';
  String nameLogin = "", uidString;
  FirebaseAuth firebaseAuthMyService = FirebaseAuth.instance;
  DateTime _dateTime;
  String weight;
  final formkey = GlobalKey<FormState>(); //Store email and password data
  final scaffoldKey = GlobalKey<ScaffoldState>(); //store all screen
  String showdate = "เลือกวันที่";
  String login = '...';
  Widget currentWidget = Showdetail();

  @override
  void initState() {
    super.initState();
    getValueFromFirebase();
  }

  Widget showListTemp() {
    return ListTile(
      title: Text(
        'แสดงอุณหภูมิ',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Icon(
        Icons.wb_sunny,
        size: 35.0,
        color: Colors.green[300],
      ),
      onTap: () {
        setState(() {
          currentWidget = Showtemp();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget showListDetail() {
    return ListTile(
      leading: Icon(
        Icons.details,
        size: 35.0,
        color: Colors.yellow[400],
      ),
      title: Text(
        'รายละเอียดการปล่อย',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        setState(() {
          currentWidget = Showdetail();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget showListRelease() {
    return ListTile(
      leading: Icon(
        Icons.touch_app,
        size: 35.0,
        color: Colors.pink[300],
      ),
      title: Text(
        'ปล่อยปู',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        setState(() {
          currentWidget = Showrelease();
        });
        Navigator.of(context).pop();
      },
    );
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
        children: [
          showHead(),
          showListRelease(),
          showListTemp(),
          showListDetail(),
        ],
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
    
    return Scaffold(
      drawer: showDrawer(),
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('แอพพลิเคชันปล่อยปูอัจฉริยะ'),
        actions: [
          signOutButton(),
        ],
      ),
      body: currentWidget,
    );
  }
}
