import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freenovel/common/NovelSqlHelper.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';

typedef onTapFn = void Function(int index,List novels,BuildContext context);
typedef onLongPressFn = void Function(int index,List novels,BuildContext context);

class Tools {
  static ListView listViewBuilder(var showNovels,{onTapFn onTap,onLongPressFn onLongPress}) {
    return ListView.builder(
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
                height: 50.0,
                child: Center(
                    child: Text(
                  novel["introduction"],
                  style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ))),
            onTap: () {
              if (onTap != null) {
                onTap(index,showNovels,context);
              }
            },
            onLongPress: (){
              if(onLongPress!=null){
                onLongPress(index,showNovels,context);
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
  static void addToShelf(int index,List showNovels,BuildContext context){
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
                args.add(showNovels[index]["id"]);
                args.add(showNovels[index]["name"]);
                args.add(showNovels[index]["author"]);
                args.add(showNovels[index]["introduction"]);
                args.add(DateTime.now().millisecondsSinceEpoch~/1000);
                sqfLiteHelper.insert(NovelSqlHelper.databaseName, NovelSqlHelper.saveNovel,args);
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
  /// 打开详情
  static void openToDetail(int index,List showNovels,BuildContext context){

  }
}
