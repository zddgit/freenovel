import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freenovel/page/BookLibrary.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef InitFn = void Function();
class Global{
  /// 书库类别标签
  static List<Tab> tabs = [];
  /// 书库类别标签对用的页面
  static List<LibraryPage> pages = [];
  /// 书库标签对应的novels
  static Map<int,List> map = new Map();
  /// 书库标签对应的刷到第几页了
  static Map<int,int> currentPages = new Map();
  /// 默认字体大小
  static int fontsize = 18;
  /// 屏幕的高度
  static double screenHeight;
  /// 屏幕顶部状态栏的高度
  static double screenTop;

  /// 书架小说列表
  static List shelfNovels=[];

  static SharedPreferences prefs;

  static String cacheImgPath;

  static void init(InitFn fn) async{
    prefs = await SharedPreferences.getInstance();
    Directory tempDir = await getTemporaryDirectory();
    cacheImgPath = tempDir.path;
    fn();
    /// 首先初始化tabs
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


}