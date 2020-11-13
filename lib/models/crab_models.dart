import 'package:cloud_firestore/cloud_firestore.dart';

class CrabModel {
  //Field
  int weight;
  String enterdate;

  //Method
  CrabModel(this.enterdate, this.weight);

  CrabModel.fromMap(Map<String, dynamic> map) {
    enterdate = map['datetime'];
    weight = map['weight'];
  }
}
