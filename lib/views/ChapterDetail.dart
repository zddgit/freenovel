import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/common/NovelSqlHelper.dart';
import 'package:freenovel/common/Tools.dart';
import 'package:freenovel/page/Bookshelf.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/LimitQueue.dart';
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
  int novelId;
  int currentChapterId;
  final Map novel;
  /// 目录章节标题
  List<Chapter> titles = [];


  /// 当前正在读的章节
  LimitQueue<Chapter> readChapters;
  /// 滚动控制
  ScrollController scrollController;

  bool hide = true;


  ChapterDetailState(this.novel);

  @override
  void initState() {
    print("init");
    super.initState();
    novelId = novel["id"];
    currentChapterId = novel["readChapterId"];
    scrollController = ScrollController();
    readChapters = LimitQueue(5);
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
    sqfLiteHelper.update(
        NovelSqlHelper.databaseName,
        NovelSqlHelper.updateReadChapterIdByNovelId,
        [currentChapterId, novelId]);
    super.dispose();
  }


  getNovel() async {
    await getTitles();
    currentChapterId = currentChapterId??titles[0].chapterId;
    readChapters.addLast(Chapter(currentChapterId, novelId, ""));
    getNovelDetail(readChapters.elementAt(0));
  }

  getTitles() async {
    SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
    List list = await sqfLiteHelper.query(NovelSqlHelper.databaseName, NovelSqlHelper.queryChaptersByNovelId, [novelId]);
    if (list == null || list.length == 0) {
      String titlesJsonStr = await HttpUtil.get(NovelAPI.getTitles(novelId));
      list = json.decode(titlesJsonStr);
      StringBuffer sb = new StringBuffer();
      list.forEach((item) {
        titles.add(Chapter(item['chapterId'], item['novelId'], item['title']));
        sb.write("(");
        sb.write("${item['novelId']},");
        sb.write("${item['chapterId']},");
        sb.write("'${item['title']}'");
        sb.write("),");
      });
      String values = sb.toString();
      values = values.substring(0, values.length - 1);
      sqfLiteHelper.insert(NovelSqlHelper.databaseName, "insert into chapter (novelId,chapterId,title) values $values");
      sqfLiteHelper.update(NovelSqlHelper.databaseName, NovelSqlHelper.updateUpdateTimeByNovelId, [Tools.now(), novelId]);
    } else {
      list.forEach((item) {
        titles.add(Chapter(item['chapterId'], item['novelId'], item['title']));
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal[100],
        drawer: TitleDetail(this),
        body: Builder(builder: (BuildContext context) {
          return RefreshIndicator(
                 onRefresh: onRefresh,
                 child: Stack(
                  children: <Widget>[
                    Container(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: readChapters == null ? 0 : readChapters.getLength(),
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
                              padding: EdgeInsets.only( top: MediaQuery.of(context).padding.top, left: 8.0),
                              alignment: Alignment.centerLeft,
                              icon: Icon(
                                Icons.keyboard_backspace,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                print(scrollController.position.maxScrollExtent);
                                print(scrollController.offset);
                                Navigator.of(context).pop();
                              }),
                        ]),
                      ),
                    )
                  ],
                ),
              );
        }));
  }

  Future<void> onRefresh() {
    currentChapterId = readChapters.elementAt(0).chapterId;
    if (currentChapterId != titles[0].chapterId) {
      currentChapterId--;
      Chapter ch = Chapter(currentChapterId, novelId, titles[currentChapterId - 1].title);
      readChapters.addFirst(ch);
      return getNovelDetail(ch);
    } else {
      return Future(() {
        Fluttertoast.showToast(
            msg: "已经是第一章了",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 2,
            bgcolor: "#777777",
            textcolor: '#ffffff');
      });
    }
  }

  loadNextChapter() {
    // 当读到最后一章得时候进行加载
    // 这里指定快划到最后150像素的时候，进行加载
    double threshold = scrollController.position.maxScrollExtent - scrollController.offset;
    if (threshold < 100 && currentChapterId < titles.length ) {
      Chapter ch = Chapter( currentChapterId + 1, novelId, titles[currentChapterId].title);
      readChapters.addLast(ch);
      getNovelDetail(ch);
    } else if (currentChapterId == titles.length && threshold < 50) {
      Fluttertoast.showToast(
          msg: "已经最后一章了",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 2,
          bgcolor: "#777777",
          textcolor: '#ffffff');
    }
  }

  /// 网络获取章节内容
  Future<void> getNovelDetail(Chapter ch) async {
    String content = await HttpUtil.get(NovelAPI.getNovelDetail(ch.novelId, ch.chapterId ?? 1));
    var result = json.decode(content);
    ch.content = result["content_str"];
    ch.title = result["title"];
    Tools.updateUI(this);
  }

  /// 章节内容
  Widget _chapterContentitemBuilder(BuildContext context, int index) {
    Chapter chapter = readChapters.elementAt(index);
    return GestureDetector(
//      onVerticalDragUpdate: (DragUpdateDetails detail){
//        scrollController.jumpTo(scrollController.offset-detail.delta.dy);
//      },
      onPanDown: (_){
        loadNextChapter();
        currentChapterId = chapter.chapterId;
      },
      onTap: (){
        hide =true;
        Tools.updateUI(this);
      },
      onLongPress: () {
        hide = false;
        Tools.updateUI(this);
      },
      child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(chapter.title + "\n    " + chapter.content,
          style: TextStyle(letterSpacing: 1.0, height: 1.2)),
    ),);
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

  Chapter(this.chapterId, this.novelId, this.title, {this.content = ""});

  @override
  String toString() {
    return 'Chapter{chapterId: $chapterId, novelId: $novelId, title: $title}';
  }
}
