import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:freenovel/page/BookLibrary.dart';
import 'package:freenovel/util/EncryptUtil.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
import 'package:freenovel/util/NovelSqlHelper.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:freenovel/views/ChapterDetailPageImp.dart';
import 'package:freenovel/views/TitleDetailImp.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


typedef InitFn = void Function();
class Global{
  /// 求更标志
  static int updateTime=0;

  /// 书库类别标签
  static List<Tab> tabs = [];
  /// 书库类别标签对用的页面
  static List<LibraryPage> pages = [];
  /// 书库标签对应的novels
  static Map<int,List> map = new Map();
  /// 书库标签对应的刷到第几页了
  static Map<int,int> currentPages = new Map();

  /// 屏幕的高度
  static double screenHeight;
  /// 屏幕顶部状态栏的高度
  static double screenTop;
  /// 屏幕的宽度
  static double screenWidth;
  /// 翻页方式 1：上下 2：左右
  static int pageType = 1;

  /// 书架小说列表
  static List shelfNovels=[];
  /// 我的
  static List setting=[];
  /// 用户信息
  static Map user;

  static SharedPreferences prefs;

  static String cacheImgPath;

  static String version="";

  /// 页面字体大小
  static double fontSize = 20;
  /// 页面左右两边总间距
  static double padding = 20;
  /// 页面顶部标题盖度
  static double top = 24;
  /// 阅读页面背景色
  static Color bgColor = Colors.teal[100];
  /// 阅读页面字体颜色
  static Color fontColor = Colors.black;

  static SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();

 static void switchTheme(State state){
   if(fontColor==Colors.black){
     fontColor = Colors.blueGrey;
     bgColor = Colors.black87;
   }else{
     fontColor = Colors.black;
     bgColor =  Colors.teal[100];
   }
   Tools.updateUI(state);
 }
  static void switchFontSize(ChapterDetailPageImpState state,int size){
    fontSize = fontSize + size;
    // 上一次处于那一章的头
    if(state.page==0){
      state.currentIndex = state.page;
    }else{
      state.currentIndex = state.page-size.abs();
    }
    state.loadeChapter(state.novelId, state.currentReadChapterId, 0);
  }
  static void init(InitFn fn) async{
    prefs = await SharedPreferences.getInstance();
    Directory tempDir = await getTemporaryDirectory();
    cacheImgPath = tempDir.path;
    fn();
    autoLogin();
    initVsersion();
    initTabs();

    Global.updateTime = prefs.getInt("updateTime")??0;
  }
  /// 首先初始化tabs
  static initTabs() async {
    String tags = await HttpUtil.get(NovelAPI.getTags());
    List list = json.decode(tags);
    for (var i = 0; i < list.length; i++) {
      var item = list[i];
      tabs.add(Tab(text: item["name"]));
      int tagid = item["id"];
      pages.add(LibraryPage(tagid));
      map[tagid] = [];
      currentPages[tagid] = 1;
      loadShowNovels(tagid);
    }
  }
  static void loadShowNovels(int tagid,{int page=1}) async {
    String novels = await HttpUtil.get(NovelAPI.getNovelsByTag(tagid,page));
    List result  = json.decode(novels);
    Global.map[tagid].addAll(result);
    Global.currentPages[tagid] = page;
  }
  static void autoLogin() async{
    String account = prefs.getString("account");
    if(account!=null){
      String type = Tools.verifyAccountType(account);
      String pwd = prefs.getString("pwd");
      String digest = EncryptUtil.decryptStr(pwd);
      String result = await HttpUtil.get(NovelAPI.loginOrRegister(type, account, digest));
      user = json.decode(result)["data"];
    }
  }
  static void initVsersion() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
  }

  static List<String> initPage(double width,double height,double padding,double fontSize,String data){
    List<String> pages = new List<String>();
    int lineWordCount = ((width-padding)/fontSize).floor();
    data = data.replaceAll(" ", "");
    data = data.replaceAll("\n", ".");
    RegExp exp = new RegExp(r"(\.+)");
    data = data.replaceAll(exp, "。");
    RegExp exp1 = new RegExp(r"(。+)");
    data = data.replaceAll(exp1, "。");
    List<String> details = data.split("。");
    StringBuffer content = new StringBuffer();
    int total = (height*4/(fontSize*6)).floor()-1;
    int pageLines = 0;
    for(int i = 0;i<details.length;i++){
      String raw = details.elementAt(i).trim();
      String item="";
      if(raw!=""){
        raw = raw + "。";
      }
      if(raw.isNotEmpty){
        item ="\n        "+raw;
      }
      int lines = ((raw.length+2)/lineWordCount).ceil();
      pageLines = pageLines+lines;
      if(pageLines>total){
        int sub = (total-(pageLines-lines))*lineWordCount-2;
        if(sub != -2){
          String line = raw.substring(0,sub>raw.length?raw.length:sub);
          content.write("\n        "+line);
          String page = content.toString();
          if(page.startsWith("\n")){
            page = page.substring(2);
          }
          pages.add(page);
          content = new StringBuffer();
          if (!line.endsWith("。")){
            item = raw.replaceAll(line, "");
            lines = (item.length/lineWordCount).ceil();
            content.write(item);
          }
        }else{
          String page = content.toString();
          if(page.startsWith("\n")){
            page = page.substring(2);
          }
          pages.add(page);
          content = new StringBuffer();
          content.write(item);
        }
        pageLines = lines;
      }else{
        content.write(item);
      }
    }
    String page = content.toString();
    if(page.startsWith("\n")){
      page = page.substring(2);
    }
    pages.add(page);
    return pages;
  }

  static saveTitle(int novelId,List titles,State state,{fn}) async{
    List dbList = await sqfLiteHelper.query(NovelSqlHelper.databaseName,NovelSqlHelper.queryChaptersByNovelId, [novelId]);
    String titlesJsonStr;
    if(dbList!=null && dbList.length!=0 && dbList[dbList.length-1]['chapterId']==dbList.length){//这个判断就是章节在数据库是连续的，不是断断续续的
      if(titles.length==0){
        for (int i = 0; i < dbList.length; i++) {
          var item = dbList[i];
          Chapter chapter = Chapter(item['chapterId'], item['novelId'], item['title']);
          titles.add(chapter);
        }
      }
      titlesJsonStr = await HttpUtil.get(NovelAPI.getTitles(novelId,limit: dbList.length));
    }else{
      titlesJsonStr = await HttpUtil.get(NovelAPI.getTitles(novelId,limit: 0));
    }
    StringBuffer sb = new StringBuffer();
    List list = json.decode(titlesJsonStr);
    if(list!=null && list.length>0){
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        Chapter chapter = Chapter(item['chapterId'], item['novelId'], item['title']);
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
      Tools.updateUI(state);
      if(state.mounted){
        if(fn!=null){
          fn();
        }
        new Future.delayed(new Duration(milliseconds: 1500),(){
          saveTitle(novelId,titles,state);
        });
      }
    }else{
      Tools.updateUI(state);
    }

  }

}