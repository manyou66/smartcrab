import 'package:cloud_firestore/cloud_firestore.dart';

class CrabModel {
  //Field
  String weight;
  String enterdate;

  //Method
  CrabModel(
    this.enterdate,
    this.weight,
  );

  CrabModel.fromMap(Map<dynamic, dynamic> map) {
    enterdate = map['datetime'];
    weight = map['weight'];
  }
}
