import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartcrab/models/crab_models.dart';

class Showdetail extends StatefulWidget {
  @override
  _ShowdetailState createState() => _ShowdetailState();
}

class _ShowdetailState extends State<Showdetail> {
 //Field
  List<CrabModel> crabModels = List();
  String date, weight;
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
        weight = snapshot.data()["weight"];
        date = snapshot.data()["datetime"];
        print('weight = $weight');
        print('date = $date');
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
    //return Text(crabModels[index].enterdate);
  }

  Widget showWeight(int index) {
     return Text(crabModels[index].weight.toString());
   // return Text('$weight');
  }

  Widget showText(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.width * 0.5,
      child: Row(
        children: <Widget>[
          showDate(index),
           showWeight(index),
        ],
      ),
    );
  }

  Widget showListView(int index) {
    return Column(
      children: <Widget>[showText(index)],
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