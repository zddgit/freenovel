import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
import 'package:freenovel/util/NovelSqlHelper.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:freenovel/views/oldpage/ChapterDetail.dart';
import 'package:loadmore/loadmore.dart';

class TitleDetail extends StatefulWidget {
  final ChapterDetailState chapterDetailState;
  TitleDetail(this.chapterDetailState,{Key key}): super(key: key);

  @override
  TitleDetailState createState() {
    return TitleDetailState(chapterDetailState);
  }

}
class TitleDetailState extends State<TitleDetail> {
  ChapterDetailState chapterDetailState;
  ScrollController titleScrollController;
  /// 目录章节标题
  List<Chapter> titles=[];
  bool isFinish = false;
  TitleDetailState(this.chapterDetailState);



  @override
  void initState() {
    super.initState();
    titleScrollController = ScrollController();
    titleScrollController.addListener((){
      if(titles.length!=chapterDetailState.titles.length){
        titles = chapterDetailState.titles;
        Tools.updateUI(this,fn:(){ titleScrollController.jumpTo(28.0*(chapterDetailState.index));
        });
      }
    });
    titles = chapterDetailState.titles;
    int i = (chapterDetailState.index-1<0)?0:chapterDetailState.index-1;
    titles = titles.sublist(i);
    Duration duration = new Duration(milliseconds: 100);
    new Future.delayed(duration,(){
      if(i!=0){
        titleScrollController.jumpTo(28.0);
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top; //状态栏的高度
    return Container(
        width: 250,
        color: Colors.grey,
        child: Container(
          margin: EdgeInsets.only(top: statusBarHeight, bottom: 10.0),
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                    child: Text( "目录", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0), ),
                ),
                IconButton(icon: Icon(Icons.settings), onPressed:chapterDetailState.showSetFontSizeSlider)
              ],),
              Expanded(
                child: LoadMore(
                  isFinish: isFinish,
                  onLoadMore:loadMoreTitle,
                  child: ListView.builder(
                      controller: titleScrollController,
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: titles == null ? 0 : titles.length,
                      itemBuilder: _chapterTitleItemBuilder
                  ),
                ),
              )
            ],
          ),
        )

    );
  }
  Future<bool> loadMoreTitle() async{
    isFinish = true;
    await loadRemainTitle(chapterDetailState.novelId,chapterDetailState.titles.length);
    await Future.delayed(Duration(milliseconds: 100));
    return true;
  }
  Widget _chapterTitleItemBuilder(BuildContext context, int index) {
    Chapter chapter = titles[index];
    TextStyle textStyle = TextStyle(letterSpacing: 1.0, height: 1.2);
    if(chapter.chapterId == chapterDetailState.titles[chapterDetailState.index].chapterId){
      textStyle = TextStyle(letterSpacing: 1.0, height: 1.2,color: Colors.redAccent);
    }
    return Padding(
      padding: const EdgeInsets.only(right: 10.0,top: 8.0),
      child: Container(
          height: 20.0,
          decoration: BoxDecoration( border: Border(bottom: BorderSide(color: Colors.blueGrey))),
          child: GestureDetector(
              onTap: () {
                chapterDetailState.index = index;
                chapterDetailState.readChapters.clear();
                chapterDetailState.readChapters.addFirst(chapter);
                chapterDetailState.scrollController.jumpTo(2.0);
                chapterDetailState.getNovelDetail(chapter);
                Navigator.of(context).pop();
              },
              child: Text(chapter.title, style: textStyle,overflow: TextOverflow.ellipsis,)),),

    );
  }

  loadRemainTitle(int novelId, int length) async {
    String titlesJsonStr = await HttpUtil.get(NovelAPI.getTitles(novelId,limit: length));
    List list = json.decode(titlesJsonStr);
    if(list.length==50){
      isFinish = false;
    }
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < list.length; i++) {
      var item = list[i];
      Chapter chapter = Chapter(item['chapterId'], item['novelId'], item['title']);
      chapter.globalKey = new GlobalKey();
      chapterDetailState.titles.add(chapter);
      sb.write("(");
      sb.write("${item['novelId']},");
      sb.write("${item['chapterId']},");
      sb.write("'${item['title']}'");
      sb.write("),");
    }
    Tools.updateUI(this);
    SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
    if(chapterDetailState.isExist){
      String values = sb.toString();
      values = values.substring(0, values.length - 1);
      sqfLiteHelper.insert(NovelSqlHelper.databaseName, NovelSqlHelper.batchSaveChapter+values);
      sqfLiteHelper.update(NovelSqlHelper.databaseName, NovelSqlHelper.updateUpdateTimeByNovelId, [Tools.now(), novelId]);
    }
  }

}