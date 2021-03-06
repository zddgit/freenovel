import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:freenovel/views/ChapterDetailPageImp.dart';



class TitleDetailImp extends StatefulWidget {
  final int novelId;
  final int chapterId;
  final ChapterDetailPageImpState chapterDetailPageImpState;


  TitleDetailImp(this.novelId,this.chapterId,this.chapterDetailPageImpState);

  @override
  State<StatefulWidget> createState() {
    return TitleDetailStateImp(novelId,chapterId,chapterDetailPageImpState);
  }
}

class TitleDetailStateImp extends State<TitleDetailImp> {
  final int novelId;
  final int chapterId;
  final ChapterDetailPageImpState chapterDetailPageImpState;
  List<Chapter> titles = [];
  ScrollController scrollController = new ScrollController();
  TitleDetailStateImp(this.novelId,this.chapterId,this.chapterDetailPageImpState);

  @override
  void initState() {
    super.initState();
    getTitle();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if(titles.length==0){
      body =  ListView(
        controller: scrollController,
        children: <Widget>[
          Center(child: Image.asset("images/loading.gif"))
      ],);
    }else{
      body = DraggableScrollbar.arrows(
        labelTextBuilder: (double offset) => Text("${offset ~/ 50}"),
        controller: scrollController,
        backgroundColor: Colors.grey,
        child: ListView.builder(
          controller: scrollController,
          itemBuilder: (BuildContext ctx, int index) {
            Chapter chapter = titles[index];
            return Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]))),
              child: GestureDetector(
                  child: Padding(padding: EdgeInsets.fromLTRB(8, 15, 0, 10), child: Text(chapter.title, overflow: TextOverflow.ellipsis),),
                  onTap: () {
                    Navigator.of(context).pop(); //弹出目录页
                    Navigator.of(context).pop(); //弹出模态页
                    chapterDetailPageImpState.loadeChapter(chapter.novelId, chapter.chapterId, 2);
                  }),
              height: 50,
            );
          },
          itemCount: titles.length,),
      );
    }
    return new Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();//弹出目录页
              Navigator.of(context).pop();//弹出模态页
            }),
        title: Text("目录"),
      ),
      body: body,
    );
  }

  void getTitle() async{
    await Global.saveTitle(novelId, titles,this,fn:(){
      Future.delayed(Duration(milliseconds: 50),(){
        scrollController.jumpTo((chapterId-1)*50.toDouble());
      });
    });
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
    String contentStr = content.substring(0,10);
    return 'Chapter{chapterId: $chapterId, novelId: $novelId, title: $title, content: $contentStr}';
  }


}