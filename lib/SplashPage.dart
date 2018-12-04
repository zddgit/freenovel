import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/NovelSqlHelper.dart';
import 'package:freenovel/home.dart';
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

  @override
  Widget build(BuildContext context) {
    double left = MediaQuery.of(context).size.width * 0.75;
    return new Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Stack(children: <Widget>[
                    Center(child: Image.asset("images/icon_logo.png"),),
                    Padding(
                      padding: EdgeInsets.only(left: left, top: 60.0),
                      child: GestureDetector(
                        onTap: (){
                          goToHomePage();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5.0))),
                            padding: const EdgeInsets.only(left: 12.0, top: 8.0, right: 12.0, bottom: 8.0),
                            child: Text("跳过$seconds")),),
                    )
                  ],),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "免费阅读",
              style: TextStyle(fontSize: 40.0,fontWeight: FontWeight.w100,color: Colors.blue),
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
  }

//  void countDown() {
//    //设置倒计时三秒后执行跳转方法
//    var duration = new Duration(seconds: 5);
//    new Future.delayed(duration, goToHomePage);
//  }

  void goToHomePage() {
    timer.cancel();
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => new Home()),
            (Route<dynamic> rout) => false);
  }
}
