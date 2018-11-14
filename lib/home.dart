import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/common/NovelSqlHelper.dart';
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
  int _currentIndex = 0;

  @override
  initState() {
    super.initState();
    Global.init(initDataBase);
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
