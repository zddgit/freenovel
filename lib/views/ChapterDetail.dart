import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 文章主体页面
class ChapterDetail extends StatefulWidget {
  final int id;

  ChapterDetail(this.id);

  @override
  _ChapterDetailState createState() {
    return _ChapterDetailState(id);
  }
}

class _ChapterDetailState extends State<ChapterDetail> {
  final int id;
  List<Chapter> chapters;

  _ChapterDetailState(this.id);

  int currentIndex;

  @override
  void initState() {
    // TODO: 初始化从缓存读取
    super.initState();
    chapters = <Chapter>[
      Chapter(
          1,
          id,
          "大漠孤烟直，长河落日圆。一望无垠的大漠，空旷而高远，壮阔而雄浑，当红日西坠，地平线尽头一片殷红，磅礴中亦有种苍凉感。"
          "上古的烽烟早已在岁月中逝去，黄河古道虽然几经变迁，但依旧在。"
          "楚风一个人在旅行，很疲惫，他躺在黄沙上，看着血色的夕阳，不知道还要多久才能离开这片大漠。"
          "数日前他毕业了，同时也跟校园中的女神说再见，或许见不到了吧，毕竟他曾被委婉的告知，从此天各一方，该分手了。"
          "离开学院后，他便出来旅行。落日很红，挂在大漠的尽头，在空旷中有一种宁静的美。楚风坐起来喝了一些水，感觉精力恢复了不少，他的身体属于修长强健那一类型，体质非常好，疲惫渐消退。"
          "站起来眺望，他觉得快要离开大漠了，再走一段路程或许就会见到牧民的帐篷，他决定继续前行。"
          "一路西进，他在大漠中留下一串很长、很远的脚印。无声无息，竟起雾了，这在沙漠中非常罕见。"
          "楚风惊讶，而这雾竟然是蓝色的，在这深秋季节给人一种凉意。不知不觉间，雾霭渐重，蓝色缭绕，朦朦胧胧，笼罩了这片沙漠。"
          "大漠尽头，落日都显得有些诡异了，渐渐化成一轮蓝日，有种魔性的美，而火云也被染成了蓝色。",
          "第1章"),
      Chapter(
          1,
          id,
          "大漠孤烟直，长河落日圆。一望无垠的大漠，空旷而高远，壮阔而雄浑，当红日西坠，地平线尽头一片殷红，磅礴中亦有种苍凉感。"
          "上古的烽烟早已在岁月中逝去，黄河古道虽然几经变迁，但依旧在。",
          "第2章")
    ];
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;//状态栏的高度
//    var bodyHeight = MediaQuery.of(context).size.height;//屏幕高度
//    var bodyWidth = MediaQuery.of(context).size.width;//屏幕高度
    return Scaffold(
        backgroundColor: Colors.teal[100],
        drawer: Container(
          color: Colors.grey,
          width: 200.0,
          child: Container(
            margin: EdgeInsets.only(top: statusBarHeight,bottom: 10.0),
            child: Column(
              children: <Widget>[
                Text("目录",style: TextStyle(fontWeight: FontWeight.bold,fontSize:20.0),),
                Expanded(child: ListView.builder(
                    padding:EdgeInsets.only(top: 10.0),
                    itemCount: chapters == null ? 0 : chapters.length,
                    itemBuilder: _chapterTitleItemBuilder),)
              ],
            ),
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return GestureDetector(
            onLongPress: () {
              // TODO 长按设置
              print("onLongPress");
              //Scaffold.of(context).openDrawer();
            },
            onVerticalDragDown: (_) {
              if (currentIndex == chapters.length - 1) {
                Fluttertoast.showToast(
                    msg: "加载中……",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 2,
                    bgcolor: "#777777",
                    textcolor: '#ffffff');
                setState(() {
                  chapters.add(Chapter(
                      1,
                      2,
                      "大漠孤烟直，长河落日圆。一望无垠的大漠，空旷而高远，壮阔而雄浑，当红日西坠，地平线尽头一片殷红，磅礴中亦有种苍凉感。",
                      "第" + chapters.length.toString() + "章"));
                });
              }
            },
            child: ListView.builder(
              itemCount: chapters == null ? 0 : chapters.length,
              itemBuilder: _chapterContentitemBuilder,
            ),
          );
        }));
  }

  Widget _chapterContentitemBuilder(BuildContext context, int index) {
    currentIndex = index;
    Chapter chapter = chapters[index];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(chapter.title + "\n    " + chapter.content,
          style: TextStyle(letterSpacing: 1.0, height: 1.2)),
    );
  }
  Widget _chapterTitleItemBuilder(BuildContext context, int index) {
    currentIndex = index;
    Chapter chapter = chapters[index];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration:BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blueGrey))),
          child: Text(chapter.title, style: TextStyle(letterSpacing: 1.0, height: 1.2))),
    );
  }
}

/// 章节内容
class Chapter {
  final int chapterId;
  final int novelId;
  final String content;
  final String title;

  Chapter(this.chapterId, this.novelId, this.content, this.title);
}
