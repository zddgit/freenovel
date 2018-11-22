import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freenovel/common/NovelSqlHelper.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:freenovel/views/ChapterDetail.dart';

typedef onTapFn = void Function(int index, List novels, BuildContext context);
typedef onLongPressFn = void Function(
    int index, List novels, BuildContext context);

class Tools {
  static ListView listViewBuilder(var showNovels, {onTapFn onTap, onLongPressFn onLongPress, ScrollController controller}) {
    return ListView.builder(
      controller: controller,
      itemCount: showNovels.length,
      itemBuilder: (BuildContext context, int index) {
        var novel = showNovels[index];
        return Card(
          color: Colors.white70,
          child: ListTile(
            leading: Container(
              width: 50.0,
              height: 55.0,
              decoration: BoxDecoration(
                  border: Border.all(width: 2.0, color: Colors.black38),
                  borderRadius: BorderRadius.all(Radius.circular(2.0))),
              child: new CachedNetworkImage(
                imageUrl: NovelAPI.getImage(novel["id"]),
                placeholder: new CircularProgressIndicator(),
                errorWidget: Container(
                  color: Colors.blueGrey,
                  child: Center(child: Text(novel["name"].substring(0, 1))),
                ),
                width: 50.0,
                height: 55.0,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(novel["name"]),
            subtitle: Text(novel["author"]),
            trailing: Container(
                width: 150.0,
                height: 55.0,
                child: Center(
                    child: Text(
                  novel["introduction"],
                  style: TextStyle(
//                      letterSpacing: 1.0,
                      height: 1.2,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ))),
            onTap: () {
              if (onTap != null) {
                onTap(index, showNovels, context);
              }
            },
            onLongPress: () {
              if (onLongPress != null) {
                onLongPress(index, showNovels, context);
              }
            },
          ),
        );
      },
    );
  }

  static void updateUI(State state, {fn}) {
    state.setState(() {
      if (fn != null) fn();
    });
  }

  /// 添加到书架
  static void addToShelf(int index, List showNovels, BuildContext context,{var novel}) {
    if(novel==null){
      novel = showNovels[index];
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('你想加入书架吗？'),
          actions: <Widget>[
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
                List args = [];
                args.add(novel["id"]);
                args.add(novel["name"]);
                args.add(novel["author"]);
                args.add(novel["introduction"]);
                args.add(Tools.now());
                sqfLiteHelper.insert(NovelSqlHelper.databaseName, NovelSqlHelper.saveNovel, args);
                Navigator.of(context).pop();
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

  /// 打开章节详情页
  static void openChapterDetail(int index,List novels,BuildContext context) {
    var novel = novels[index];
    Navigator.of(context).push(
        new PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) { return new ChapterDetail(novel);},
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

  static int now(){
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
  /// 打开详情
  static void openToDetail(int index, List showNovels, BuildContext context) {}
}
