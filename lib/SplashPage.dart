import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/home.dart';
import 'package:freenovel/util/NovelSqlHelper.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:freenovel/util/Tools.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {
  int seconds = 5;
  Timer timer;
  int fontsize = 10;


  @override
  Widget build(BuildContext context) {
    Global.screenHeight = MediaQuery.of(context).size.height;
    Global.screenWidth = MediaQuery.of(context).size.width;
    Global.screenTop = MediaQuery.of(context).padding.top;
    double left = MediaQuery.of(context).size.width * 0.65;
    Global.pageType = 2;
    return new Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 1,child: Container(),),
          Expanded(
            flex: 7,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Stack(children: <Widget>[
                    Center(child: Image.asset("images/icon_logo.png"),),
                    Padding(
                      padding: EdgeInsets.only(left: left),
                      child: FlatButton(
                        onPressed:goToHomePage,
                        color: Colors.black26,
                        child: Text("$seconds秒跳过"),
                      ),

                    )
                  ],),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              "地瓜阅读",
              style: TextStyle(fontSize: 40.0,fontWeight: FontWeight.w100,color: Color.fromRGBO(51, 181, 229, 1.0)),
            ),),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    Global.init(initDataBase);
    //开启倒计时
    timer = Timer.periodic(new Duration(seconds: 1), (_) {
      --seconds;
      if(seconds ==0){
        goToHomePage();
      }
      Tools.updateUI(this);
    });
  }


  initDataBase() async {
    String database = Global.prefs.getString("database");
    if (database == null) {
      int version = 1;
      SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
      List<String> ddls = new List();
      ddls.add(NovelSqlHelper.novelTableDDL);
      ddls.add(NovelSqlHelper.chapterTableDDL);
      sqfLiteHelper.ddl(NovelSqlHelper.databaseName, ddls, version);
      Global.prefs.setString("database", NovelSqlHelper.databaseName);
      print("生成数据库${NovelSqlHelper.databaseName}");
    }
    int fontsize = Global.prefs.getInt("fontsize");
    if(fontsize!=null){
      Global.fontSize = fontsize.toDouble();
    }
  }

  void goToHomePage() {
    timer.cancel();
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => new Home()),
            (Route<dynamic> rout) => false);
  }
}

