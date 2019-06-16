import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/page/booksearch.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:loadmore/loadmore.dart';

///书库
class BookLibrary extends StatefulWidget {
  @override
  BookLibraryState createState() {
    return BookLibraryState();
  }
}

class BookLibraryState extends State<BookLibrary>
    with SingleTickerProviderStateMixin {
  String queryName;
  List showNovels = [];
  TabController _controller;

  /// 滚动控制
  ScrollController scrollController;
  bool isload = true;

  @override
  void initState() {
    super.initState();
    queryName = "";
    scrollController = ScrollController();
    if(Global.tabs.length==0){
      initTabs();
    }
    _controller = TabController(length: Global.tabs.length, vsync: this);
  }
  void initTabs() async{
   await Global.initTabs();
   _controller = TabController(length: Global.tabs.length, vsync: this);
   Tools.updateUI(this);
  }

  getSearchNovels(String name, {page = 1}) async {
    String searchNovels =
        await HttpUtil.get(NovelAPI.getNovelsByNameOrAuthor(name, page));
    showNovels = json.decode(searchNovels);
    if (showNovels.length < 10) {
      isload = false;
    }
    Tools.updateUI(this);
  }

  @override
  Widget build(BuildContext context) {
    Widget tabBar = Container(),tabBarView = Container();
    if(Global.tabs.length>0){
      tabBar= TabBar(
        indicatorColor: Colors.white,
        tabs: Global.tabs,
        isScrollable: true,
        controller: _controller,
      );
      tabBarView =  TabBarView(
        controller: _controller,
        children: Global.pages,
      );

    }
    return Scaffold(
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            Tools.pushPage(context, new BookSearch());
          },
          child: new Icon(Icons.search),
        ),
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: tabBar,
          ),
        ),
        body:tabBarView);
  }
}

class LibraryPage extends StatefulWidget {
  final int _tagid;

  LibraryPage(this._tagid);

  @override
  LibraryPageState createState() {
    return LibraryPageState(_tagid);
  }
}

class LibraryPageState extends State<LibraryPage>
    with AutomaticKeepAliveClientMixin {
  int _tagid;
  int currentPage = 1;

  bool isFinish = false;

  /// 滚动控制
  ScrollController scrollController;

  LibraryPageState(this._tagid);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    if (Global.currentPages[_tagid] == 1 && Global.map[_tagid].length == 0) {
      loadShowNovels(_tagid, currentPage);
    }
  }

  loadShowNovels(int tagid, int page) async {
    String novels = await HttpUtil.get(NovelAPI.getNovelsByTag(tagid, page));
    List result = json.decode(novels);
    if (result.length ==10) {
      isFinish = false;
    }
    Global.map[_tagid].addAll(result);
    Global.currentPages[_tagid] = page;
    Tools.updateUI(this);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LoadMore(
        isFinish: isFinish,
        onLoadMore: loadMoreNovel,
        child: Tools.listViewBuilder(Global.map[_tagid],
            controller: scrollController, onTap: Tools.openChapterDetail),
      ),
    );
  }
  Future<bool> loadMoreNovel() async{
    if(!isFinish){
      currentPage++;
      isFinish = true;
      await loadShowNovels(_tagid, currentPage);
    }
    await Future.delayed(Duration(milliseconds: 100));
    return true;
  }
}
