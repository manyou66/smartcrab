import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_web/flutter_native_web.dart';

class Showtemp extends StatefulWidget {
  @override
  _ShowtempState createState() => _ShowtempState();
}

class _ShowtempState extends State<Showtemp> {
  String temp_inside =
      'https://thingspeak.com/channels/1223309/charts/1?bgcolor=%23ffffff&color=%23d62020&dynamic=true&results=60&type=line&update=15';
  WebController webController;

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
  Widget build(BuildContext context) {
    FlutterNativeWeb flutterWebViewTempInside = new FlutterNativeWeb(
      onWebCreated: onWebCreatedTempInside,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        Factory<OneSequenceGestureRecognizer>(
          () => TapGestureRecognizer(),
        ),
      ].toSet(),
    );
    return Column(
      children: [
        Text(
          'ค่าอุณหภูมิ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 20.0, right: 10.0, left: 5.0),
          child: flutterWebViewTempInside,
          height: 300.0,
          width: 500.0,
        ),
      ],
    );
  }
}
