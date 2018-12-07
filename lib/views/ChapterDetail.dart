import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/views/CoustomSlider.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:freenovel/util/NovelSqlHelper.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:freenovel/views/TitleDetail.dart';
import 'package:loadmore/loadmore.dart';

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
  int currentReadChapterId;
  String currentTitle="";

  /// 目录章节标题
  List<Chapter> titles = [];
  /// 当前正在读的章节
  ListQueue<Chapter> readChapters;
  /// 滚动控制
  ScrollController scrollController;
  /// 目录看到的索引
  int index = 0;
  /// 移动的距离
  double offset=0;
  /// 是否在书架中存在
  bool isExist = false;
  SqfLiteHelper sqfLiteHelper;
  /// loadMore小部件是否加载下一章
  bool isFinish  = true;

  int fontsize = Global.fontsize;

  ChapterDetailState(this.novel);

  updateFontSize(){
    Global.fontsize = fontsize;
    Global.prefs.setInt("fontsize", fontsize);
    Tools.updateUI(this);
  }

  void showSetFontSizeSlider(){
    showDialog(
      context: context,
      builder: (context)=> Dialog(
        child: Container(
          height: 20.0,
          child: CoustomSlider(this),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    sqfLiteHelper = new SqfLiteHelper();
    novelId = novel["id"];
    // 判断当前看的书是不是在书架里面
    bool flag = false;
    Global.shelfNovels.forEach((item){
      if(novelId == item["id"]){
        flag = true;
      }
    });
    if(flag){
      currentReadChapterId = novel["readChapterId"];
      offset = novel["readPosition"]==null?0:double.parse(novel["readPosition"].toString());
    }
    scrollController = ScrollController();
    scrollController.addListener(slideListen);
    readChapters = ListQueue<Chapter>();
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
    /// 退出阅读页面的时候保存阅读信息
    Global.shelfNovels.forEach((item) {
      if (item["id"] == novelId) {
        item["readChapterId"] = currentReadChapterId;
        item["readPosition"] = offset.toInt();
      }
    });
    sqfLiteHelper.update( NovelSqlHelper.databaseName, NovelSqlHelper.updateReadChapterIdByNovelId, [currentReadChapterId,offset.toInt(), novelId]);
  }

  /// 判断此小说是否加入书架
  void init() async {
    if(offset==0||currentReadChapterId==null){
      await initOffSetAndReaderchapterId();
    }
    List list = await sqfLiteHelper.query( NovelSqlHelper.databaseName, NovelSqlHelper.queryNovelByNovelId,[novelId]);
    if(list.length==0){
      isExist = false;
    }else{
      isExist = true;
    }
    await getNovel();
    getTitles();
    Duration duration = new Duration(milliseconds: 100);
    new Future.delayed(duration,()=>scrollController.jumpTo(offset));
  }

  initOffSetAndReaderchapterId() async {
    List list = await sqfLiteHelper.query( NovelSqlHelper.databaseName, NovelSqlHelper.queryReadPositionByNovelId,[novelId]);
    if(list.length==1){
      offset = double.parse(list.elementAt(0)["readPosition"].toString());
      currentReadChapterId = int.parse(list.elementAt(0)["readChapterId"].toString());
      novel["readChapterId"] = currentReadChapterId;
    }
  }

  getNovel() async {
    readChapters.addLast(Chapter(currentReadChapterId??1, novelId, ""));
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
        if (item['chapterId'] == (novel["readChapterId"]??1) ) {
          index = i;
          currentTitle = item["title"];
          currentReadChapterId = item["chapterId"];
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
        if (item['chapterId'] == (novel["readChapterId"]??1)) {
          index = i;
          currentTitle = item["title"];
          currentReadChapterId = item["chapterId"];
        }
        Chapter chapter = Chapter(item['chapterId'], item['novelId'], item['title']);
        chapter.globalKey = new GlobalKey();
        titles.add(chapter);
      }
    }
//    Tools.updateUI(this);
  }

  @override
  Widget build(BuildContext context) {

    currentTitle = currentTitle==null?"":currentTitle;
    return WillPopScope(
      onWillPop: (){
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
                      List args = [];
                      args.add(novel["id"]);
                      args.add(novel["name"]);
                      args.add(novel["author"]);
                      args.add(novel["introduction"]);
                      novel["recentReadTime"] = Tools.now();
                      args.add(novel["recentReadTime"]);
                      novel["readChapterId"] = currentReadChapterId;
                      args.add(novel["readChapterId"]);
                      novel["readPosition"] = offset.toInt();
                      args.add(novel["readPosition"]);
                      Global.shelfNovels.add(novel);
                      sqfLiteHelper.insert(NovelSqlHelper.databaseName, NovelSqlHelper.saveNovel, args);
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
      child: Scaffold(
//          appBar: PreferredSize(
//            preferredSize: Size.fromHeight(40.0),
//            child: AppBar(
//            leading: IconButton(
//                icon: Icon(Icons.arrow_back),
//                onPressed:(){
//                  Navigator.of(context).pop();
//                }),
//            title: Center(child: Text(currentTitle,style: TextStyle(color: Colors.black26,fontSize: 16.0),)),
//            actions: <Widget>[
//              IconButton(icon: Icon(Icons.settings), onPressed:showSetFontSizeSlider)
//            ],
//          ),),
          backgroundColor: Colors.teal[100],
          drawer: TitleDetail(this),
          body: Builder(builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                Container(
                  height: Global.screenTop,
                  color: Colors.black26,
                  child: Center(
                    child: Text(currentTitle),
                  ),
                ),
                Expanded(
                  child: LoadMore(
                    isFinish: isFinish,
                    onLoadMore: loadMoreChapter,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: readChapters == null ? 0 : readChapters.length,
                      itemBuilder: _chapterContentitemBuilder,
                    ),
                  ),
                )

              ],
            );

          })),
    );
  }

  Future<bool> loadMoreChapter() async{
    if(index<titles.length){
      index++;
      Chapter ch = titles[index];
      readChapters.addLast(ch);
      isFinish = true;
      await getNovelDetail(ch);
    }
    await Future.delayed(Duration(milliseconds: 100));
    return true;
  }

  /// 滑动检测
  slideListen() {
    offset = scrollController.offset;
    updateCurrentTitle();
    // 当读到最后一章得时候进行加载
    double threshold = scrollController.position.maxScrollExtent - offset;
    if(threshold == 0 && index < titles.length){
      // 此标志位是用来判断是否加载下一章的
      isFinish = false;
      Tools.updateUI(this);
    }else{
      isFinish = true;
    }
  }
  void updateCurrentTitle(){
    //根据更新滑动来判断当前看到那里
    double sum = 0;
    String title;
    for(int i=0;i<readChapters.length;i++){
      Chapter item = readChapters.elementAt(i);
      if(item.height!=null){
        sum = sum + item.height;
        if(sum+Global.screenTop>Global.screenHeight+offset){
          if(i==0){
            currentReadChapterId = item.chapterId;
            title = item.title;
            break;
          }else{
            currentReadChapterId = item.chapterId;
            title = item.title;
            offset = (Global.screenHeight+offset)-(sum+Global.screenTop-item.height);
          }
          break;
        }

      }
    }
    if(title != currentTitle && title!=null){
        currentTitle = title;
        Tools.updateUI(this);
    }

  }

  /// 网络获取章节内容
  Future<void> getNovelDetail(Chapter ch,{fn}) async {
    List list = await sqfLiteHelper.query(NovelSqlHelper.databaseName, NovelSqlHelper.queryChapterByChapterIdAndNovel,[ch.novelId,ch.chapterId]);
    if(list.length==1 && list.elementAt(0)["content"] !=null){
      ch.content = list.elementAt(0)["content"];
      ch.title = list.elementAt(0)["title"];
    }else{
      String content = await HttpUtil.get(NovelAPI.getNovelDetail(ch.novelId, ch.chapterId ?? 1));
      var result = json.decode(content);
      ch.content = result["content_str"];
      ch.title = result["title"];
      if(isExist){
        sqfLiteHelper.insert(NovelSqlHelper.databaseName, NovelSqlHelper.saveChapter,[ch.novelId,ch.chapterId,ch.title,ch.content]);
      }
    }
    currentTitle = ch.title;
    currentReadChapterId = ch.chapterId;
    Tools.updateUI(this, fn: fn);
  }

  /// 章节内容
  Widget _chapterContentitemBuilder(BuildContext context, int index) {
    Chapter chapter = readChapters.elementAt(index);
    if(chapter.globalKey==null){
      chapter.globalKey = new GlobalKey();
    }
    Duration duration = new Duration(milliseconds: 1000);
    new Future.delayed(duration,(){
        chapter.height = chapter.globalKey.currentContext.size.height;
    });
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Text((chapter.title ?? "") + "\n    " + (chapter.content ?? ""),
        style: TextStyle(letterSpacing: 1.0, height: 1.2, fontSize: fontsize.toDouble()),
        key: chapter.globalKey,),
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
    String contentStr = content.substring(0,10);
    return 'Chapter{chapterId: $chapterId, novelId: $novelId, title: $title, content: $contentStr, globalKey: $globalKey, height: $height}';
  }


}

