import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/LimitQueue.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 文章主体页面
class ChapterDetail extends StatefulWidget {
  final int novelId;
  final int recentChapterId;

  ChapterDetail(this.recentChapterId, this.novelId);

  @override
  _ChapterDetailState createState() {
    return _ChapterDetailState(novelId, recentChapterId);
  }
}

class _ChapterDetailState extends State<ChapterDetail> {
  /// 当前所读小说的id和章节id
  final int novelId;
  int currentChapterId;

  /// 目录章节标题
  List<Chapter> titles;

  /// 当前正在读的章节
  LimitQueue<Chapter> readChapters;

  /// 滚动控制
  ScrollController scrollController;

  SharedPreferences prefs;

  /// 控制是不是点击目录产生的跳转
  bool onclick=false;


  _ChapterDetailState(this.novelId, this.currentChapterId);

  updateUI({fn}) {
    setState(() {
      if (fn != null) fn();
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    readChapters = LimitQueue(5);
    // TODO: 初始化从网络读取章节目录
    getTitles();
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    super.dispose();

    /// 退出阅读页面的时候保存阅读信息
    String key = NovelStatus.getReadStatusPrefsKey(novelId);
//    Map map = {};
//    map["currentChapterId"] = currentChapterId;
//    prefs.setString(key, json.encode(map));
    prefs.setInt(key, currentChapterId);

  }

  void getTitles() async {
    String titlesJsonStr = await HttpUtil.get(NovelAPI.getTitles(novelId));
    List list = json.decode(titlesJsonStr);
    if (titles == null) titles = [];
    list.forEach((item) {
      titles.add(Chapter(item['chapterId'], item['novelId'], "第${item['chapterId']}章 " + item['title']));
    });
    readChapters.addLast( titles.elementAt(currentChapterId == null ? 0 : currentChapterId - 1));
    getNovelDetail(readChapters.elementAt(0));
    updateUI();
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top; //状态栏的高度
//    var bodyHeight = MediaQuery.of(context).size.height;//屏幕高度
//    var bodyWidth = MediaQuery.of(context).size.width;//屏幕高度
    return Scaffold(
        backgroundColor: Colors.teal[100],
        drawer: Container(
          color: Colors.grey,
          width: 200.0,
          child: Container(
            margin: EdgeInsets.only(top: statusBarHeight, bottom: 10.0),
            child: Column(
              children: <Widget>[
                Text( "目录", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0), ),
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: titles == null ? 0 : titles.length,
                      itemBuilder: _chapterTitleItemBuilder),
                )
              ],
            ),
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return GestureDetector(
              onVerticalDragDown: (_) {
                onclick = false;
                // 当读到最后一章得时候进行加载
                // 这里指定快划到最后150像素的时候，进行加载
                if (scrollController.position.maxScrollExtent - scrollController.offset < 150 && currentChapterId < titles.length) {
                  Chapter ch = Chapter(currentChapterId + 1, novelId, titles[currentChapterId].title);
                  readChapters.addLast(ch);
                  getNovelDetail(ch);
                  currentChapterId++;
                } else if (currentChapterId == titles.length && scrollController.position.maxScrollExtent - scrollController.offset < 50) {
                  Fluttertoast.showToast(
                      msg: "已经最后一章了",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 2,
                      bgcolor: "#777777",
                      textcolor: '#ffffff');
                }
              },
              child: RefreshIndicator(
                onRefresh: () {
                  if(onclick){
                    return Future(() { });
                  }
                  currentChapterId = readChapters.elementAt(0).chapterId;
                  if (currentChapterId >= 2) {
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
                },
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: readChapters == null ? 0 : readChapters.getLength(),
                  itemBuilder: _chapterContentitemBuilder,
                ),
              ));
        }));
  }

  /// 网络获取章节内容
  Future<void> getNovelDetail(Chapter ch) async {
    String content = await HttpUtil.get(NovelAPI.getNovelDetail(ch.novelId, ch.chapterId));
    ch.content = content;
    updateUI();
  }

  /// 章节内容
  Widget _chapterContentitemBuilder(BuildContext context, int index) {
    Chapter chapter = readChapters.elementAt(index);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(chapter.title + "\n    " + chapter.content,
          style: TextStyle(letterSpacing: 1.0, height: 1.2)),
    );
  }

  /// 目录
  Widget _chapterTitleItemBuilder(BuildContext context, int index) {
    Chapter chapter = titles[index];
    return GestureDetector(
      onTap: () {
        onclick = true;
        currentChapterId = index + 1;
        readChapters.clear();
        readChapters.addFirst(chapter);
        print(readChapters.getLength());
        scrollController.jumpTo(0.0);
        getNovelDetail(chapter);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.blueGrey))),
            child: Text(chapter.title,
                style: TextStyle(letterSpacing: 1.0, height: 1.2))),
      ),
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
  final String title;

  /// 章节内容
  String content;

  Chapter(this.chapterId, this.novelId, this.title, {this.content = ""});

  @override
  String toString() {
    return 'Chapter{chapterId: $chapterId, novelId: $novelId, title: $title}';
  }
}
