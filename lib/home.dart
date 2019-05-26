import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/page/BookLibrary.dart';
import 'package:freenovel/page/Bookshelf.dart';
import 'package:freenovel/page/MySelf.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:url_launcher/url_launcher.dart';

/// 首页
class Home extends StatefulWidget {

  @override
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  int _currentIndex = 0;
  int last = 0;

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  /// 各类页面
  Widget _changBodyWidget() {
    switch (_currentIndex) {
      case 0:

        /// 书架
        return Bookshelf();
      case 1:

        /// 书库
        return BookLibrary();
//      case 2:
//
//        /// 动弹
//        return Talk();
      case 2:

        /// 我的
        return MySelf();
      default:
        return null;
    }
  }
  Future<bool> doubleClickBack() {
    int now = Tools.now();
    if (now - last > 3) {
      last = Tools.now();
      Fluttertoast.showToast(
          msg: "再点一次退出阅读器",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 3,
          backgroundColor:Colors.black,
          textColor: Colors.white70
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "地瓜阅读",
      home: WillPopScope(
        onWillPop: doubleClickBack,
        child: Scaffold(
          body: _changBodyWidget(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration( border: BorderDirectional(top: BorderSide(color: Colors.grey[300]))),
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.book),
                    title: Text("书架"),
                    activeIcon: Icon(Icons.book),
                    backgroundColor: Colors.blue),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    title: Text("书库"),
                    activeIcon: Icon(Icons.list),
                    backgroundColor: Colors.blue),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    title: Text("我的"),
                    activeIcon: Icon(Icons.account_circle),
                    backgroundColor: Colors.blue),
//                BottomNavigationBarItem(
//                  icon: Icon(Icons.find_in_page),
//                  title: Text("发现"),
//                  activeIcon: Icon(Icons.find_in_page),
//                  backgroundColor: Colors.blue),
              ],
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              fixedColor: Colors.red,
              iconSize: 24.0,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),)
        ,
    );
  }

  void checkVersion() async{
    DateTime dt = DateTime.now();
    if(Global.user["lastLoginTime"]-Global.user["expireDate"]>0 && dt.hour>1 && dt.hour<5){
      Fluttertoast.showToast(msg: "夜太深了，洗洗睡吧！");
      Future.delayed(Duration(seconds: 1),(){
          SystemNavigator.pop();
      });
    }
    String  version = await HttpUtil.get(NovelAPI.checkVersion());
    version = version.substring(1,version.length-1);
    if(version!=Global.version){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx){
        return AlertDialog(title: Text("检测到有新版本需要更新"),actions: <Widget>[
          FlatButton(onPressed:(){
            autoUpdate();
            Navigator.of(ctx).pop();
          }, child:Text("更新")),
          FlatButton(onPressed: (){
            Timer.periodic(Duration(minutes: 30), (thiz){
              checkVersion();
              thiz.cancel();
            });
            Navigator.of(ctx).pop();
          }, child:Text("稍后提醒")),
        ],);
      });
    }
  }

  void autoUpdate() async{
    var url = NovelAPI.autoUpdate();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: "无法启动浏览器下载",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white70);
    }
  }
}
