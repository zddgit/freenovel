import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freenovel/common/NovelSqlHelper.dart';
import 'package:freenovel/common/Tools.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:freenovel/views/ChapterDetail.dart';

class Bookshelf extends StatefulWidget {
  @override
  BookshelfState createState() {
    return BookshelfState();
  }
}

class BookshelfState extends State<Bookshelf> {
  /// 书架
  List novels = [];
  /// 保存阅读信息
  Map readMap = {};


  @override
  void initState() {
    print("initState");
    super.initState();
    //TODO 初始化读过的小说,本地数据库读取
    initNovels();
  }


  initNovels() async {
    SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
    List result = await sqfLiteHelper.query(NovelSqlHelper.databaseName,NovelSqlHelper.queryRecentReadNovel);
    novels.addAll(result);
    //更新
    Tools.updateUI(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("书架"),
        centerTitle: true,
      ),
      body: Tools.listViewBuilder(novels,onLongPress:_showDelDialog,onTap: _open),
    );
  }

  /// 打开章节详情页
  void _open(int index,List novels,BuildContext context) {
    var novel = novels[index];
    Navigator.of(context).push(
        new PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) { return new ChapterDetail(readMap[novel["id"]]??novel["readChapterId"],novel["id"],this);},
            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      return new FadeTransition(
        opacity: animation,
        child: new SlideTransition(
          position: new Tween<Offset>(
            begin: Offset(1.0, 0.0),
            end: Offset(0.0, 0.0),
          ).animate(animation),
          child: child,
        ),
      );
    }));
  }

  /// 长按删除
  void _showDelDialog(int index,List novels,BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('你想删除吗？'),
          actions: <Widget>[
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
                SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
                sqfLiteHelper.del(NovelSqlHelper.databaseName, NovelSqlHelper.delNovelById,[novels[index]["id"]]);
                this.novels.removeAt(index);
                Tools.updateUI(this);
              },
            ),
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}

