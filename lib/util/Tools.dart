//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freenovel/views/ChapterDetail.dart';
import 'package:freenovel/views/CoustomCacheImage.dart';

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
                  border: Border.all(width: 1.0, color: Colors.black38),
                  borderRadius: BorderRadius.all(Radius.circular(2.0))),
              child: CoustomCacheImage(novel["id"]),
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
                  maxLines: 3,
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
    if(state.mounted){
      state.setState(() {
        if (fn != null) fn();
      });
    }
  }

  /// 打开章节详情页
  static void openChapterDetail(int index,List novels,BuildContext context) {
    var novel = novels[index];
    pushPage(context, new ChapterDetail(novel));
  }

  static void pushPage(BuildContext context,var page){
    Navigator.of(context).push(
        new PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) { return page;},
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
  static String nowString(){
    DateTime dt = DateTime.now();
    return "${dt.year}-${dt.month}-${dt.day}";
  }
  /// 打开详情
  static void openToDetail(int index, List showNovels, BuildContext context) {}

  static String verifyAccountType(String account){
    String type;
    if(new RegExp('^[A-Za-z0-9\\u4e00-\\u9fa5]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+\$').hasMatch(account)){
      type = "email";
    }
    if(new RegExp('^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$').hasMatch(account)){
      type = "mobile";
    }
    return type;
  }
}
