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
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ads/ads.dart';

import 'TitleDetailImp.dart';


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
  /// 当前章节第几页
  int page=0;
  /// 是否在书架中存在
  bool isExist = false;
  /// 总的页面内容
  List<String> totalPages=[];
  /// 当前看到第几页
  int currentIndex=0;
  /// 每一章占有多少页,标题
  Map chapterIdAndTitlePages = new HashMap();
 
  /// 页面内容
  List<String> pages = [];

  /// 加载中的上下文引用
  BuildContext loadingCtx;



  


  SqfLiteHelper sqfLiteHelper;
  ChapterDetailPageImpState(this.novel);

  @override
  void initState() {
    super.initState();
    initAd();
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
  // 初始化广告
  void initAd() {
      Ads.init("ca-app-pub-4020538078469336");
  }
  @override
  void dispose() {
    super.dispose();
    Ads.dispose();
//    myInterstitial.dispose();
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
          item["readPosition"]= page;
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
    return Scaffold(
      backgroundColor: Global.bgColor,
      body: WillPopScope(
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
                        sqfLiteHelper.update(NovelSqlHelper.databaseName, NovelSqlHelper.delChapterByNovelId,[novelId]);
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
        child: new Swiper(
          key: new GlobalKey(),// new一个key，保证每一次build生成的都是新的小组件
          index: currentIndex,
          loop: false,
          onTap: (index){
            showModalBottomSheet(context: context,builder: (BuildContext context) {
              return Container(
                height: 100,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  onTap: (index) {
                    if(index == 0) back();
                    if(index==1) titleSetting();
                    if(index==2) themeSetting();
                    if(index ==3) fontSizeSetting();
                  },
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.arrow_back),
                      title: Text("返回"),
                      activeIcon: Icon(Icons.arrow_back),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.list),
                        title: Text("目录"),
                        activeIcon: Icon(Icons.list),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.wb_sunny),
                        title: Text("日间"),
                        activeIcon: Icon(Icons.brightness_2),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.text_format),
                        title: Text("设置"),
                        activeIcon: Icon(Icons.text_format),
                        ),
                  ],),
              );
            });
          },
          itemBuilder: (BuildContext context, int index) {
            Widget txt = AutoSizeText( totalPages[index], style: TextStyle(fontSize: Global.fontSize, height: 1.1,color: Global.fontColor),);
            return Container(
              padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(info["title"],overflow: TextOverflow.ellipsis,),
                    height: Global.top,
                  ),
                  Expanded(child: txt,),
                ],
              ),
            );
          },
          itemCount: totalPages.length,
          onIndexChanged: (index){
            currentIndex = index;
            // 实时计算当前所处于那页
            Map info = computeCurrentReadChapterIdAndPage();
            int currentChapterId =info["currentChapterId"];
            page = info["page"];
            // 当章节是奇数的时候展示广告
            if(page==0 && currentChapterId%2==1){
              Ads.showFullScreenAd();
            }
            // 获取正确的当前章节以后修改全局变量
            if(currentReadChapterId != currentChapterId){
              currentReadChapterId = currentChapterId;
              Tools.updateUI(this);
            }
            if(index==(totalPages.length-1)){
              showLoading();
              // 加载下一章
              loadeChapter(novelId,currentReadChapterId+1,1,fn:cancleLoading);
            }
            if(index==0){
              // 加载上一章
              if((currentReadChapterId-1)>0){
                showLoading();
                loadeChapter(novelId,currentReadChapterId-1,-1,fn:cancleLoading);
              }
            }
          },
        ),
      ),
    );
  }
// 加载章节内容
  void loadeChapter(int novelId, int chapterId,int type,{fn}) async {
    Map info = new HashMap();
    List chapterDetail = await sqfLiteHelper.query(NovelSqlHelper.databaseName, NovelSqlHelper.queryChapterByChapterIdAndNovel,[novelId,chapterId]);
    if (chapterDetail.length==1 && chapterDetail.elementAt(0)["content"] !=null){
      /// 说明手机数据库有数据
      pages = Global.initPage(Global.screenWidth, Global.screenHeight-Global.top, Global.padding, Global.fontSize, chapterDetail.elementAt(0)["content"]);
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
      pages = Global.initPage(Global.screenWidth, Global.screenHeight, Global.padding, Global.fontSize, content);
      info["title"] = title;
    }
    info["length"] = pages.length;
    if(type==0){//初始化
      totalPages.addAll(pages);
      // 向前多加载一章
      if(chapterId>1 && page==0){
        loadeChapter(novelId, chapterId-1, -1);
      }
      //向后多加载一章
      if(page==(totalPages.length-1)){
        loadeChapter(novelId, chapterId+1, 1);
      }
    }
    if(type==2){//目录页面打开的
      totalPages = [];
      page = 0;
      currentIndex = 0;
      currentReadChapterId = chapterId;
      chapterIdAndTitlePages= new HashMap();
      totalPages.addAll(pages);
      // 向前多加载一章
      if(chapterId>1){
        loadeChapter(novelId, chapterId-1, -1);
      }
    }
    if(type==-1){//加载上一章，头插
      currentIndex = page+pages.length;
      totalPages.insertAll(0, pages);
    }
    if(type==1){//加载下一张，尾插
      currentIndex = totalPages.length-1;
      totalPages.addAll(pages);
    }
    chapterIdAndTitlePages[chapterId] = info;
    if(fn != null){
      fn();
    }
    Tools.updateUI(this);
  }
  /// 计算当前处于那个章节
  Map computeCurrentReadChapterIdAndPage() {
    Map map = new HashMap();
    var keys = chapterIdAndTitlePages.keys;
    int length = 0;
    bool flag = false;
    List klist = keys.toList();
    klist.sort();
    for(int i=0;i<klist.length;i++){
        var key = klist[i];
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
  /// 字体设置
  void fontSizeSetting() {
    showModalBottomSheet(context: context,builder: (BuildContext context){
      return Container(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: FlatButton(child: Text("Aa-",style: TextStyle(color: Colors.white),),onPressed: (){
                Global.switchFontSize(this,-1);
              },color: Colors.blue,),
            ),
            Expanded(child: Center(child: Text("字体大小设置"),),flex: 1,),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FlatButton(child: Text("Aa+",style: TextStyle(color: Colors.white),),onPressed: (){
                Global.switchFontSize(this,1);
              },color: Colors.blue,),
            )
          ],
        ),
        height: 100,
      );
    });
  }
  /// 阅读页面主题设置
  void themeSetting() {
    Global.switchTheme(this);
  }
  /// 目录页面跳转
  void titleSetting() {
      Tools.pushPage(context,TitleDetailImp(this.novelId,this.currentReadChapterId,this));
  }
  /// 退出详情页
  void back() {
    Navigator.of(context).pop();//弹出模态页
    if(!isExist){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text('你想加入书架吗？'),
            actions: <Widget>[
              FlatButton(
                child: Text('确定'),
                onPressed: () {
                  isExist = true;
                  Navigator.of(ctx).pop(); //弹出AlertDialog
                  Navigator.of(context).pop(); //弹出详情页
                },
              ),
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  sqfLiteHelper.update(NovelSqlHelper.databaseName, NovelSqlHelper.delChapterByNovelId,[novelId]);
                  Navigator.of(ctx).pop(); //弹出AlertDialog
                  Navigator.of(context).pop(); //弹出详情页
                },
              ),
            ],
          );
        },
      );
    }else{
      Navigator.of(context).pop(); //弹出详情页
    }
  }
  /// 显示加载中。。。
  void showLoading() {
    showDialog(context: context,builder: (context){
      loadingCtx = context;
      return Image.asset("images/loading.gif");
    });
  }
  /// 取消加载中...
 void cancleLoading(){
    Navigator.of(loadingCtx).pop();
    loadingCtx = null;
 }




}