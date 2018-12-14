import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
//          Global.prefs.remove("database");
//          SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
//          sqfLiteHelper.delDataBases("novels");
          Fluttertoast.showToast(
              msg: "哈哈，这里还没有实现",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor:Colors.black,
              textColor: Colors.white70
          );

        },
      )),
    );
  }
}
