import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartcrab/models/crab_models.dart';

class Letcrabdetail extends StatefulWidget {
  @override
  _LetcrabdetailState createState() => _LetcrabdetailState();
}

class _LetcrabdetailState extends State<Letcrabdetail> {
  //Field
  List<CrabModel> crabModels = List();

  void initState() {
    super.initState();
    readAllData();
  }

  Future<void> readAllData() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    CollectionReference collectionReference =
        firebaseFirestore.collection('letcrab');
    await collectionReference.snapshots().listen((response) {
      List<QueryDocumentSnapshot> snapshots = response.docs;
      for (var snapshot in snapshots) {
        print('snapshot = $snapshot');
        print('weight = ${snapshot.data()["weight"]}');
        print('date = ${snapshot.data()["datetime"]}');
        //Timestamp t =  snapshot.data()["datetime"];
        // DateTime d = t.toDate();
        // String dd, m, y;
        // dd = d.day.toString();
        // m = d.month.toString();
        // y = d.year.toString();

        // print('day ==> $dd');
        // print('month ==> $m');
        // print('year ==> $y');
        CrabModel crabModel = CrabModel.fromMap(snapshot.data());

        setState(() {
          crabModels.add(crabModel);
        });
        String str = crabModels[0].enterdate;
        print('weight ===> $str');
      }
    });
  }

  Widget showDate(int index) {
    return Text(crabModels[index].enterdate);
  }

  Widget showWeight(int index) {
    return Text(crabModels[index].weight.toString());
  }

  Widget showText(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.width * 0.5,
      child: Row(
        children: [
          showDate(index),
          showWeight(index),
        ],
      ),
    );
  }

  Widget showListView(int index) {
    return Column(
      children: [showText(index)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: crabModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return showListView(index);
        },
      ),
    );
  }
}
