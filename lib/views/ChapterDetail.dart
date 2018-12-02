import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/NovelSqlHelper.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:freenovel/views/TitleDetail.dart';

/// 文章主体页面
class ChapterDetail extends StatefulWidget {
  final Map novel;

  ChapterDetail(this.novel);

  @override
  ChapterDetailState createState() {
    return ChapterDetailState(novel);
  }
}

class ChapterDetailState extends State<ChapterDetail> {
  /// 当前所读小说的id和章节id
  final Map novel;
  int novelId;

  /// 目录章节标题
  List<Chapter> titles = [];

  /// 当前正在读的章节
  ListQueue<Chapter> readChapters;

  /// 滚动控制
  ScrollController scrollController;
  bool hide = true;
  int index = 0;

  /// 移动的距离
  double offset=0;
  /// 屏幕的高度
  double screenHeight=0;
  /// 屏幕顶部状态栏的高度
  double screenTop=0;
  bool isExist = false;
  SqfLiteHelper sqfLiteHelper;




  ChapterDetailState(this.novel);

  @override
  void initState() {
    super.initState();
    sqfLiteHelper = new SqfLiteHelper();
    novelId = novel["id"];
    scrollController = ScrollController();
    scrollController.addListener(loadChapter);
    readChapters = ListQueue<Chapter>();
    offset = novel["readPosition"]==null?0:double.parse(novel["readPosition"].toString());
    init();
  }

  @override
  void dispose() {
    super.dispose();
    if(isExist){
      saveNovel();
    }
  }
  /// 退出保存信息
  void saveNovel(){
    /// 此处退出的时候计算阅读位置
    double sum = 0;
    for(int i=0;i<readChapters.length;i++){
      Chapter item = readChapters.elementAt(i);
      if(item.height!=null){
        sum = sum + item.height;
        if(sum+screenTop>screenHeight+offset){
          if(i==0){
            break;
          }else{
            offset = (screenHeight+offset)-(sum+screenTop-item.height);
          }
          break;
        }

      }
    }
    /// 退出阅读页面的时候保存阅读信息
    Global.shelfNovels.forEach((item) {
      if (item["id"] == novelId) {
        item["readChapterId"] = titles[index].chapterId;
        item["readPosition"] = offset.toInt();
      }
    });

    sqfLiteHelper.update( NovelSqlHelper.databaseName, NovelSqlHelper.updateReadChapterIdByNovelId, [titles[index].chapterId,offset.toInt(), novelId]);
  }

  /// 判断此小说是否加入书架
  void init() async {
    await getTitles();
    getNovel();
    List list = await sqfLiteHelper.query( NovelSqlHelper.databaseName, NovelSqlHelper.queryNovelByNovelId,[novelId]);
    if(list.length==0){
      isExist = false;
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
                  isExist = true;
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
    }else{
      isExist = true;
    }
  }

  getNovel() async {
    readChapters.addLast(titles[index]);
    getNovelDetail(readChapters.elementAt(0));
  }

  getTitles() async {
    List list = await sqfLiteHelper.query(NovelSqlHelper.databaseName,NovelSqlHelper.queryChaptersByNovelId, [novelId]);
    if (list == null || list.length == 0) {
      String titlesJsonStr = await HttpUtil.get(NovelAPI.getTitles(novelId));
      list = json.decode(titlesJsonStr);
      StringBuffer sb = new StringBuffer();
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        if (item['chapterId'] == novel["readChapterId"]) {
          index = i;
        }
        Chapter chapter = Chapter(item['chapterId'], item['novelId'], item['title']);
        chapter.globalKey = new GlobalKey();
        titles.add(chapter);
        sb.write("(");
        sb.write("${item['novelId']},");
        sb.write("${item['chapterId']},");
        sb.write("'${item['title']}'");
        sb.write("),");
      }

      String values = sb.toString();
      values = values.substring(0, values.length - 1);
      sqfLiteHelper.insert(NovelSqlHelper.databaseName, NovelSqlHelper.batchSaveChapter+values);
      sqfLiteHelper.update(NovelSqlHelper.databaseName, NovelSqlHelper.updateUpdateTimeByNovelId, [Tools.now(), novelId]);
    } else {
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        if (item['chapterId'] == novel["readChapterId"]) {
          index = i;
        }
        Chapter chapter = Chapter(item['chapterId'], item['novelId'], item['title']);
        chapter.globalKey = new GlobalKey();
        titles.add(chapter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenTop = MediaQuery.of(context).padding.top;
    return Scaffold(
        backgroundColor: Colors.teal[100],
        drawer: TitleDetail(this),
        body: Builder(builder: (BuildContext context) {
          return Stack(
            children: <Widget>[
              Container(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: readChapters == null ? 0 : readChapters.length,
                  itemBuilder: _chapterContentitemBuilder,
                ),
              ),
              Offstage(
                offstage: hide,
                child: Container(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                  height: 60.0,
                  child: Row(children: <Widget>[
                    IconButton(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8.0),
                        alignment: Alignment.centerLeft,
                        icon: Icon( Icons.keyboard_backspace, color: Colors.white,),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ]),
                ),
              )
            ],
          );
        }));
  }



  loadChapter() {
    offset = scrollController.offset;
    // 当读到最后一章得时候进行加载
    double threshold = scrollController.position.maxScrollExtent - offset;
    if (threshold == 0 && index < titles.length) {
      index++;
      Chapter ch = titles[index];
      readChapters.addLast(ch);
      getNovelDetail(ch);
    }else if(scrollController.offset==0 && index > 0){
      Fluttertoast.showToast(
          msg: "加载中。。。。",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIos: 1,
          bgcolor: "#777777",
          textcolor: '#ffffff');
      index--;
      Chapter ch = titles[index];
      fn(){
        var duration = new Duration(milliseconds: 80);
        new Future.delayed(duration, () {
          scrollController.animateTo(ch.globalKey.currentContext.size.height, duration: new Duration(milliseconds: 100), curve: Curves.decelerate);
        });
      }
      readChapters.addFirst(ch);
      getNovelDetail(ch,fn: fn);
    }else if(scrollController.offset==0 && index == 0){
      Fluttertoast.showToast(
          msg: "已经是第一章了",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 2,
          bgcolor: "#777777",
          textcolor: '#ffffff');
    } else if (index == titles.length) {
      Fluttertoast.showToast(
          msg: "已经最后一章了",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          bgcolor: "#777777",
          textcolor: '#ffffff');
    }
  }

  /// 网络获取章节内容
  Future<void> getNovelDetail(Chapter ch,{fn}) async {
    List list = await sqfLiteHelper.query(NovelSqlHelper.databaseName, NovelSqlHelper.queryChapterByChapterIdAndNovel,[ch.novelId, ch.chapterId ?? 1]);
    if(list.length==1 && list.elementAt(0)["content"] !=null){
      ch.content = list.elementAt(0)["content"];
      ch.title = list.elementAt(0)["title"];
    }else{
      String content = await HttpUtil.get(NovelAPI.getNovelDetail(ch.novelId, ch.chapterId ?? 1));
      var result = json.decode(content);
      ch.content = result["content_str"];
      ch.title = result["title"];
      sqfLiteHelper.insert(NovelSqlHelper.databaseName, NovelSqlHelper.saveChapter,[ch.novelId,ch.chapterId,ch.title,ch.content]);
    }
    scrollController.jumpTo(offset);
    Tools.updateUI(this, fn: fn);
  }

  /// 章节内容
  Widget _chapterContentitemBuilder(BuildContext context, int index) {
    Chapter chapter = readChapters.elementAt(index);
    GlobalKey globalKey = new GlobalKey();
    chapter.globalKey = globalKey;
    Duration duration = new Duration(milliseconds: 200);
    new Future.delayed(duration,(){
      chapter.height = globalKey.currentContext.size.height;
    });
    return FlatButton(
      key: globalKey,
      padding: EdgeInsets.only(left: 4.0),
      splashColor: Colors.teal[100],
      highlightColor: Colors.teal[100],
      onPressed: () {
        hide = !hide;
        Tools.updateUI(this);
      },
      child: Text(chapter.title + "\n    " + chapter.content,
          style: TextStyle(letterSpacing: 1.0, height: 1.2, fontSize: 18)),
    );
  }


}

/// 章节内容
class Chapter {
  /// 章节id
  final int chapterId;

  /// 小说id
  final int novelId;

  /// 章节标题
  String title;

  /// 章节内容
  String content;

  GlobalKey globalKey;

  double height;

  Chapter(this.chapterId, this.novelId, this.title, {this.content = ""});

  @override
  String toString() {
    return 'Chapter{chapterId: $chapterId, novelId: $novelId, title: $title, content: $content, globalKey: $globalKey, height: $height}';
  }


}
