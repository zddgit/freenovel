import 'package:flutter/material.dart';
import 'package:freenovel/common/Tools.dart';
import 'package:freenovel/views/ChapterDetail.dart';

class TitleDetail extends StatefulWidget {
  ChapterDetailState chapterDetailState;
  TitleDetail(this.chapterDetailState);

  @override
  TitleDetailState createState() {
    return TitleDetailState(chapterDetailState);
  }

}
class TitleDetailState extends State<TitleDetail>{
  ChapterDetailState chapterDetailState;
  ScrollController titleScrollController;
  /// 目录章节标题
  List<Chapter> titles=[];
  TitleDetailState(this.chapterDetailState);



  @override
  void initState() {
    super.initState();
    titleScrollController = ScrollController();
    titleScrollController.addListener((){

    });
    titles = chapterDetailState.titles;
    titles = titles.sublist(chapterDetailState.currentChapterId-1);
  }




  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top; //状态栏的高度
    return Container(
        color: Colors.grey,
        width: 200.0,
        child: Container(
          margin: EdgeInsets.only(top: statusBarHeight, bottom: 10.0),
          child: Column(
            children: <Widget>[
              Text( "目录", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0), ),
              Expanded(
                child: GestureDetector(
                  onPanDown: (_){
                    if(titles.length!=chapterDetailState.titles.length){
                      titles = chapterDetailState.titles;
                      Tools.updateUI(this,fn:(){ titleScrollController.jumpTo(28.0*(chapterDetailState.currentChapterId-chapterDetailState.titles[0].chapterId));
                      });
                    }
                  },
                  child: ListView.builder(
                    controller: titleScrollController,
                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: titles == null ? 0 : titles.length,
                    itemBuilder: _chapterTitleItemBuilder),)

              )
            ],
          ),
        )

    );
  }
  Widget _chapterTitleItemBuilder(BuildContext context, int index) {
    Chapter chapter = titles[index];
    TextStyle textStyle = TextStyle(letterSpacing: 1.0, height: 1.2);
    if(chapter.chapterId == chapterDetailState.currentChapterId){
      textStyle = TextStyle(letterSpacing: 1.0, height: 1.2,color: Colors.redAccent);
    }
    return GestureDetector(
      onTap: () {
        chapterDetailState.currentChapterId = chapter.chapterId;
        chapterDetailState.readChapters.clear();
        chapterDetailState.readChapters.addFirst(chapter);
        chapterDetailState.scrollController.jumpTo(0.0);
        chapterDetailState.getNovelDetail(chapter);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0,right: 10.0,top: 8.0),
        child: Container(
            height: 20.0,
            decoration: BoxDecoration( border: Border(bottom: BorderSide(color: Colors.blueGrey))),
            child: Text(chapter.title, style: textStyle,overflow: TextOverflow.ellipsis,)),
      ),
    );
  }

}