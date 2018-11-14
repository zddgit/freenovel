import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freenovel/page/BookLibrary.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef InitFn = void Function();
class Global{
  static List<Tab> tabs = [];
  static List<LibraryPage> pages = [];
  static SharedPreferences prefs;
  static void init(InitFn fn) async{
    prefs = await SharedPreferences.getInstance();
    /// 首先初始化tabs
    String tags = await HttpUtil.get(NovelAPI.getTags());
    List list = json.decode(tags);
    for (var i = 0; i < list.length; i++) {
      var item = list[i];
      tabs.add(Tab(text: item["name"]));
      pages.add(LibraryPage(item["id"]));
    }
    fn();
  }


}