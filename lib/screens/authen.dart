import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartcrab/screens/my_service.dart';

class Authen extends StatefulWidget {
  @override
  _AuthenState createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  // Explcit
  double amount = 150.0;
  double size = 250.0;
  String emailString, passwordString;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final formkey = GlobalKey<FormState>(); //Store email and password data
  final scaffoldKey = GlobalKey<ScaffoldState>(); //store all screen

  bool checkSpace(String value) {
    // check space input from email and password
    bool result = false;
    if (value.length == 0) {
      // have space
      result = true;
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    checkStatus(context);
  }
    void checkStatus(BuildContext context) async {
    final User user = await firebaseAuth.currentUser;
    //final uid = user.uid;//Stay login firebase have value
    if (user != null) {
      //  Move to MyService
      moveToMyService(context);
    }
  }


  Widget showLogo() {
    return Container(
      width: amount,
      height: amount,
      child: Image.asset(
        'images/logo.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget showName() {
    return Container(
      child: Text(
        'Smart Crab',
        style: TextStyle(
          fontSize: 50.0,
          color: Colors.orange[800],
          fontWeight: FontWeight.bold,
          fontFamily: 'FC Galaxy Regular',
        ),
      ),
    );
  }

  Widget emailTextFormFeild() {
    return Container(
      width: size,
      child: TextFormField(
        style: TextStyle(
          color: Colors.orange[600],
        ),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            icon: Icon(
              Icons.email,
              size: 40.0,
              color: Colors.orange[600],
            ),
            labelText: 'User:',
            labelStyle: TextStyle(
              color: Colors.orange[600],
            ),
            hintText: 'abcd@email.com'),
        validator: (String emailvalue) {
          if (checkSpace(emailvalue)) {
            return 'Please Type in Email';
          }
          if (!(emailvalue.contains('@')) && (emailvalue.contains('.'))) {
          return 'Wrong Email Format you@abcd.com';
        }

        },
        onSaved: (String value) {
          emailString = value.trim();
        },
      ),
    );
  }

  Widget passwordText() {
    return Container(
      width: size,
      child: TextFormField(
        obscureText: true,
        style: TextStyle(
          color: Colors.orange[600],
        ),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            icon: Icon(
              Icons.lock,
              size: 40.0,
              color: Colors.orange[600],
            ),
            labelText: 'Password:',
            labelStyle: TextStyle(
              color: Colors.orange[600],
            ),
            hintText: 'More 6 Charactor'),
        validator: (String pwdvalue) {
          if (checkSpace(pwdvalue)) {
            return 'Password Empty';
          }
          if (pwdvalue.length < 6) {
          return 'More than 6 ';
        }

        },
        onSaved: (String value) {
          passwordString = value.trim();
        },
      ),
    );
  }

  void moveToMyService(BuildContext context) {
    var myServiceRoute =
        MaterialPageRoute(builder: (BuildContext context) => MyService());
    Navigator.of(context)
        .pushAndRemoveUntil(myServiceRoute, (Route<dynamic> route) => false);
  }

  void checkAuthen(BuildContext context) async {
    await firebaseAuth
        .signInWithEmailAndPassword(
            email: emailString, password: passwordString)
        .then((objValue) {
      moveToMyService(context);
      // print('data OK');
    }).catchError((objValue) {
      String error = objValue.message;
      print('error => $error');
    });
  }

  Widget signInButton(BuildContext context) {
    return Expanded(
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: () {
          if (formkey.currentState.validate()) {
            formkey.currentState.save();
            checkAuthen(context);
          }
        },
        color: Colors.orange[500],
        child: Text(
          'Sign In',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Container(
        alignment: Alignment(0, -1),
        padding: EdgeInsets.only(top: 70.0),
        child: Form(
          key: formkey,
          child: Column(
            children: <Widget>[
              showLogo(),
              showName(),
              emailTextFormFeild(),
              passwordText(),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                alignment: Alignment.center,
                width: 100,
                child: Row(
                  children: <Widget>[
                    signInButton(context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
