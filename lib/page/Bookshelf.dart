import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/NovelSqlHelper.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:freenovel/util/Tools.dart';


class Bookshelf extends StatefulWidget {
  @override
  BookshelfState createState() {
    return BookshelfState();
  }
}

class BookshelfState extends State<Bookshelf> {
  Color updateColor = Colors.deepOrangeAccent;
  String updateMessage = "提醒更新";


  @override
  void initState() {
    super.initState();
    initNovels();
  }


  initNovels() async {
    if(Global.shelfNovels.length==0){
      SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
      List result = await sqfLiteHelper.query(NovelSqlHelper.databaseName,NovelSqlHelper.queryRecentReadNovel);
      result.forEach((item){
        Map map = new Map();
        item.keys.forEach((key){
          map[key] = item[key];
        });
        Global.shelfNovels.add(map);
      });
      //更新
      Tools.updateUI(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = new DateTime.now();
    if(Global.updateTime==now.day){
      updateColor = Colors.blueGrey;
      updateMessage = "更新完成^_^";
    }
    Widget widget;
    if(Global.shelfNovels.length==0){
      widget = Center(child: Text("你还没有添加小说"),);
    }else{
      widget = Tools.listViewBuilder(Global.shelfNovels,onLongPress:_showDelDialog,onTap: Tools.openChapterDetail);
    }
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("书架"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child:widget,
          ),
          FlatButton(
            child: Center(child: Text(updateMessage, style: TextStyle(color: Colors.white),)),
            color: updateColor,
            onPressed: () {
              DateTime now = new DateTime.now();
              if(Global.updateTime!=now.day){
                Global.updateTime =now.day;
                Global.prefs.setInt("updateTime", now.day);
                Fluttertoast.showToast(
                    msg: "请稍后，正在更新，😝😝😝",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 1,
                    backgroundColor:Colors.black,
                    textColor: Colors.white70
                );
                Future.delayed(new Duration(seconds: 1),(){
                  Fluttertoast.showToast(
                      msg: "更新完成！！！请查看目录",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor:Colors.black,
                      textColor: Colors.white70
                  );
                  updateColor = Colors.blueGrey;
                  updateMessage = "更新过了😝😝😝";
                  Tools.updateUI(this);
                });
              }
            },)
        ],
      ),
    );
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
                sqfLiteHelper.del(NovelSqlHelper.databaseName, NovelSqlHelper.delChapterByNovelId,[novels[index]["id"]]);
                Global.shelfNovels.removeAt(index);
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

