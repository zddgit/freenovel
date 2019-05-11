import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
import 'package:freenovel/util/NovelSqlHelper.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:freenovel/util/Tools.dart';


// 左右滑动翻页
class ChapterDetailPageImp extends StatefulWidget{
 final Map novel;
 ChapterDetailPageImp(this.novel);
  @override
  State<StatefulWidget> createState() {
    return ChapterDetailPageImpState(novel);
  }

}
class ChapterDetailPageImpState extends State<ChapterDetailPageImp>{
  /// 当前所读小说的id和章节id
  final Map novel;
  int novelId;
  int currentReadChapterId = 1;
//  String title="";
  /// 当前章节第几页
  int page=0;
  /// 是否在书架中存在
  bool isExist = false;
  /// 总的页面内容
  List<String> totalPages = [];
  /// 当前看到第几页
  int currentIndex=0;
  /// 每一章占有多少页,标题
  Map chapterIdAndTitlePages = new HashMap();
 
  /// 页面内容
  List<String> pages = [];
  /// 页面字体大小
  int fontSize = 20;
  /// 页面左右两边总间距
  int padding = 20;
  


  SqfLiteHelper sqfLiteHelper;
  ChapterDetailPageImpState(this.novel);

  @override
  void initState() {
    super.initState();
    //隐藏状态栏
    SystemChrome.setEnabledSystemUIOverlays([]);
    sqfLiteHelper = new SqfLiteHelper();
    novelId = novel["id"];
    // 判断当前看的书是不是在书架里面
    Global.shelfNovels.forEach((item){
      if(novelId == item["id"]){
        isExist = true;
      }
    });
    if(isExist){
      currentReadChapterId = novel["readChapterId"];
      page = novel["readPosition"]==null?0:int.parse(novel["readPosition"].toString());
      currentIndex = page;
    }
    loadeChapter(novelId,currentReadChapterId,0);
  }
  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    if(isExist){ //这里代表书架和数据库都要保存
      List args = [];
      args.add(novel["id"]);
      args.add(novel["name"]);
      args.add(novel["author"]);
      args.add(novel["introduction"]);
      novel["recentReadTime"] = Tools.now();
      args.add(novel["recentReadTime"]);
      novel["readChapterId"] = currentReadChapterId;
      args.add(novel["readChapterId"]);
      novel["readPosition"] = page;
      args.add(novel["readPosition"]);
      isExist = false;//进来以后，重新设置为false,防止书架重复添加
      Global.shelfNovels.forEach((item){
        if(novelId == item["id"]){
          isExist = true;
        }
      });
      if(!isExist){//这里代表书架不存在要保存书架
        Global.shelfNovels.add(novel);
      }
      sqfLiteHelper.insert(NovelSqlHelper.databaseName, NovelSqlHelper.saveNovel, args);
    }
  }
  @override
  Widget build(BuildContext context) {
    Map info = chapterIdAndTitlePages[currentReadChapterId];
    if(pages.length==0){
      //默认返回加载中的图片
      return new Scaffold(
        body: Container(
          child: Center(child: Image.asset("images/loading.gif"),),
        ),
      );
    }
    //当章节加载出来以后，使用下面的组件
    return WillPopScope(
      onWillPop:(){
        if(!isExist){
          return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('你想加入书架吗？'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('确定'),
                    onPressed: () {
                      isExist = true;
                      Navigator.of(context).pop(true);
                    },
                  ),
                  FlatButton(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
        }else{
          return Future.value(true);
        }
      },
      child: new Scaffold(
        backgroundColor: Colors.teal[100],
        body: new Swiper(
          key: new GlobalKey(),// new一个key，保证每一次build生成的都是新的小组件
          index: currentIndex,
          loop: false,
          itemBuilder: (BuildContext context, int index) {
            Widget txt = Text( totalPages[index], style: TextStyle(fontSize: 20, height: 1.1),);
            return Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(info["title"] + ":" + index.toString()),
                  ),
                  Expanded(child: txt,),
                ],
              ),
            );
          },
          itemCount: totalPages.length,
          onIndexChanged: (index){
            currentIndex = index;
            Map info = computeCurrentReadChapterIdAndPage();
            int currentChapterId =info["currentChapterId"];
            page = info["page"];
            if(currentReadChapterId != currentChapterId){
              currentReadChapterId = currentChapterId;
              Tools.updateUI(this);
            }
            if(index==(totalPages.length-1)){
              // 加载下一章
              loadeChapter(novelId,currentReadChapterId+1,1);
            }
            if(index==0){
              // 加载上一章
              loadeChapter(novelId,currentReadChapterId-1,-1);
            }
          },
        ),
      ),
    );
  }
// 加载章节内容
  void loadeChapter(int novelId, int chapterId,int type) async {
    Map info = new HashMap();
    List chapterDetail = await sqfLiteHelper.query(NovelSqlHelper.databaseName, NovelSqlHelper.queryChapterByChapterIdAndNovel,[novelId,chapterId]);
    if (chapterDetail.length==1 && chapterDetail.elementAt(0)["content"] !=null){
      /// 说明手机数据库有数据
      pages = Global.initPage(Global.screenWidth, Global.screenHeight, padding, fontSize, chapterDetail.elementAt(0)["content"]);
      info["title"] = chapterDetail.elementAt(0)["title"];
    }else{
      /// 手机数据库没有数据,从网络获取
      String content = await HttpUtil.get(NovelAPI.getNovelDetail(novelId, chapterId));
      var result = json.decode(content);
      content = result["content_str"];
      String title = result["title"];
      /// 判断需不需要保存到数据库
      if(isExist){
        sqfLiteHelper.insert(NovelSqlHelper.databaseName, NovelSqlHelper.saveChapter,[novelId,chapterId,title,content]);
      }
      pages = Global.initPage(Global.screenWidth, Global.screenHeight, padding, fontSize, content);
      info["title"] = title;
    }
    info["length"] = pages.length;
    chapterIdAndTitlePages[chapterId] = info;
    if(type==0){//初始化
      totalPages.addAll(pages);
    }
    if(type==-1){//加载上一章，头插
      totalPages.insertAll(0, pages);
      currentIndex = pages.length;
    }
    if(type==1){//加载下一张，尾插
      currentIndex = totalPages.length-1;
      totalPages.addAll(pages);
    }
    Tools.updateUI(this);
  }
  /// 计算当前处于那个章节
  Map computeCurrentReadChapterIdAndPage() {
    Map map = new HashMap();
    var keys = chapterIdAndTitlePages.keys;
    int length = 0;
    bool flag = false;
    for(int i=0;i<keys.length;i++){
        var key = keys.toList()[i];
        length = length + chapterIdAndTitlePages[key]["length"];
        if(length > currentIndex){
          map["currentChapterId"] = key;
          if(flag){
            map["page"] = currentIndex-(length-chapterIdAndTitlePages[key]["length"]);
          }else{
            map["page"] = currentIndex;
          }
          break;
        }
        flag = true;
    }
    return map;
  }




}