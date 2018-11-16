import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';

///我的
class MySelf extends StatefulWidget {
  @override
  MySelfState createState() {
    return MySelfState();
  }
}

class MySelfState extends State<MySelf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: RaisedButton(
        child: Text("我的"),
        onPressed: (){
          Global.prefs.remove("database");
          SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
          sqfLiteHelper.delDataBases("novels");
        },
      )),
    );
  }
}
