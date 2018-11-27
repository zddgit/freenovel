import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/common/NovelSqlHelper.dart';
import 'package:freenovel/common/Tools.dart';
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

  int currentChapterId;

  /// 目录章节标题
  List<Chapter> titles = [];

  /// 当前正在读的章节

  ListQueue<Chapter> readChapters;

  /// 滚动控制
  ScrollController scrollController;
  bool hide = true;
  int index = 0;



  ChapterDetailState(this.novel);

  @override
  void initState() {
    super.initState();
    novelId = novel["id"];
    currentChapterId = novel["readChapterId"];
    scrollController = ScrollController();
    scrollController.addListener(loadChapter);
    readChapters = ListQueue<Chapter>();
    getNovel();
  }

  @override
  void dispose() {
    /// 退出阅读页面的时候保存阅读信息
    Global.shelfNovels.forEach((item) {
      if (item["id"] == novelId) {
        item["readChapterId"] = currentChapterId;
      }
    });
    SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
    sqfLiteHelper.update( NovelSqlHelper.databaseName, NovelSqlHelper.updateReadChapterIdByNovelId, [currentChapterId, novelId]);
    super.dispose();
  }

  getNovel() async {
    await getTitles();
    currentChapterId = titles[index].chapterId;
    readChapters.addLast(titles[index]);
    getNovelDetail(readChapters.elementAt(0));
  }

  getTitles() async {
    SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
    List list = await sqfLiteHelper.query(NovelSqlHelper.databaseName,
        NovelSqlHelper.queryChaptersByNovelId, [novelId]);
    if (list == null || list.length == 0) {
      String titlesJsonStr = await HttpUtil.get(NovelAPI.getTitles(novelId));
      list = json.decode(titlesJsonStr);
      StringBuffer sb = new StringBuffer();
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        if (item['chapterId'] == currentChapterId) {
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
      sqfLiteHelper.insert(NovelSqlHelper.databaseName, "insert into chapter (novelId,chapterId,title) values $values");
      sqfLiteHelper.update(NovelSqlHelper.databaseName, NovelSqlHelper.updateUpdateTimeByNovelId, [Tools.now(), novelId]);
    } else {
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        if (item['chapterId'] == currentChapterId) {
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
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top, left: 8.0),
                        alignment: Alignment.centerLeft,
                        icon: Icon(
                          Icons.keyboard_backspace,
                          color: Colors.white,
                        ),
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
    // 当读到最后一章得时候进行加载
    double threshold = scrollController.position.maxScrollExtent - scrollController.offset;
    if (threshold == 0 && currentChapterId < titles[titles.length - 1].chapterId) {
      index--;
      Chapter ch = titles[index];
      currentChapterId = currentChapterId + 1;
      readChapters.addLast(ch);
      getNovelDetail(ch);
    }else if(scrollController.offset==0 && currentChapterId > titles[0].chapterId){
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
        var duration = new Duration(milliseconds: 100);
        new Future.delayed(duration, () {
          scrollController.jumpTo(ch.globalKey.currentContext.size.height);
        });
      }
      currentChapterId = currentChapterId - 1;
      readChapters.addFirst(ch);

      getNovelDetail(ch,fn: fn);
    }else if(scrollController.offset==0 && currentChapterId == titles[0].chapterId){
      Fluttertoast.showToast(
          msg: "已经是第一章了",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 2,
          bgcolor: "#777777",
          textcolor: '#ffffff');
    } else if (currentChapterId == titles[titles.length - 1].chapterId) {
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
    String content = await HttpUtil.get(NovelAPI.getNovelDetail(ch.novelId, ch.chapterId ?? 1));
    var result = json.decode(content);
    ch.content = result["content_str"];
    ch.title = result["title"];
    Tools.updateUI(this, fn: fn);
  }

  /// 章节内容
  Widget _chapterContentitemBuilder(BuildContext context, int index) {
    Chapter chapter = readChapters.elementAt(index);
    GlobalKey globalKey = new GlobalKey();
    chapter.globalKey = globalKey;
    return FlatButton(
      key: globalKey,
      padding: EdgeInsets.only(left: 4.0),
      splashColor: Colors.teal[100],
      highlightColor: Colors.teal[100],
      onPressed: () {
        hide = !hide;
        print(globalKey.currentContext.size);
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

  Chapter(this.chapterId, this.novelId, this.title, {this.content = ""});


  @override
  String toString() {
    return 'Chapter{chapterId: $chapterId, novelId: $novelId, title: $title}';
  }
}
