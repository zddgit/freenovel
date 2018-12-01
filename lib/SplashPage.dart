import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/NovelSqlHelper.dart';
import 'package:freenovel/home.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';

class SplashPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new SplashPageState();
  }

}
class SplashPageState extends State<SplashPage>{



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(child: Text("闪屏页"),),
    );
  }

  @override
  void initState() {
    super.initState();
    Global.init(initDataBase);
    //开启倒计时
    countDown();
  }
  initDataBase() async {
    String database = Global.prefs.getString("database");
    if(database==null){
      int version = 1;
      SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
      List<String> ddls = new List();
      ddls.add(NovelSqlHelper.novelTableDDL);
      ddls.add(NovelSqlHelper.chapterTableDDL);
      await sqfLiteHelper.ddl(NovelSqlHelper.databaseName, ddls, version);
      Global.prefs.setString("database", NovelSqlHelper.databaseName);
      print("生成数据库${NovelSqlHelper.databaseName}");
    }
  }

  void countDown() {
    //设置倒计时三秒后执行跳转方法
    var duration = new Duration(seconds: 3);
    new Future.delayed(duration, goToHomePage);
  }
  void goToHomePage(){
    Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (context)=>new Home()), (Route<dynamic> rout)=>false);
  }

}