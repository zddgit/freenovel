import 'package:flutter/material.dart';
import 'package:freenovel/page/BookLibrary.dart';
import 'package:freenovel/page/MySelf.dart';
import 'package:freenovel/page/Talk.dart';
import 'package:freenovel/page/Bookshelf.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首页
class Home extends StatefulWidget {
  @override
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  int _currentIndex = 1;
  SharedPreferences prefs;

  @override
  initState() {
    super.initState();
    initDataBase();
  }
  initDataBase() async {
    prefs = await SharedPreferences.getInstance();
    String database = prefs.getString("database");
    if(database==null){
      String databaseName = "novels";
      int version = 1;
      SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
      List<String> ddls = new List();
      //TODO 数据库设计
      ddls.add("CREATE TABLE IF NOT EXISTS `novel` (id INTEGER PRIMARY KEY, name TEXT,author TEXT, introduction TEXT, cover TEXT)");
      ddls.add("CREATE TABLE IF NOT EXISTS `chapter` (novelId INTEGER,chapterId INTEGER, title TEXT, content TEXT, primary key (novelId,chapterId))");
      await sqfLiteHelper.ddl(databaseName, ddls, version);
      prefs.setString("database", databaseName);
      print("生成数据库$databaseName");
    }
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
      case 2:

        /// 动弹
        return Talk();
      case 3:

        /// 我的
        return MySelf();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _changBodyWidget(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              border:
                  BorderDirectional(top: BorderSide(color: Colors.grey[300]))),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  title: Text("书架"),
                  activeIcon: Icon(Icons.add_box),
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance),
                  title: Text("书库"),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.find_in_page),
                  title: Text("发现"),
                  activeIcon: Icon(Icons.find_in_page),
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  title: Text("我的"),
                  activeIcon: Icon(Icons.account_circle),
                  backgroundColor: Colors.blue),
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
      ),
    );
  }
}
