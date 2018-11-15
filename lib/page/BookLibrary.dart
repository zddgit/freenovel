import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/common/CommonSearchBarDelegate.dart';
import 'package:freenovel/common/Tools.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelResource.dart';

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
  List<Tab> tabs = Global.tabs;
  List<Widget> pages = Global.pages;
  TabController _controller;
  CommonSearchBarDelegate commonSearchBarDelegate;

  @override
  void initState() {
    super.initState();
    queryName = "";
    commonSearchBarDelegate = new CommonSearchBarDelegate(query);
    _controller = TabController(length: tabs.length, vsync: this);
    getRecommendNovels();
  }



  getRecommendNovels() async {
    String top10 = await HttpUtil.get(NovelAPI.getRecommentNovelsTop10());
    showNovels = json.decode(top10);

  }

  getSearchNovels(String name) async {
    String searchNovels = await HttpUtil.get(NovelAPI.getNovelsByNameOrAuthor(name));
    showNovels = json.decode(searchNovels);
    Tools.updateUI(this);
  }

  Widget query(query) {
    if (!query.isEmpty) {
      getSearchNovels(query);
    }
    return Tools.listViewBuilder(showNovels,onLongPress:Tools.addToShelf);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('搜书名'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () => showSearch(
                    context: context, delegate: commonSearchBarDelegate)),
          ],
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: tabs,
            isScrollable: true,
            controller: _controller,
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: pages,
        )
    );
  }


}

class LibraryPage extends StatefulWidget {
  int _tagid;

  LibraryPage(this._tagid);

  @override
  LibraryPageState createState() {
    return LibraryPageState(_tagid);
  }
}

class LibraryPageState extends State<LibraryPage> {
  int _tagid;
  List showNovels = [];
  int currentPage = 1;
  bool isload = true;

  /// 滚动控制
  ScrollController scrollController;

  LibraryPageState(this._tagid);

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    loadShowNovels(_tagid,currentPage);
  }

  loadShowNovels(int tagid,int page) async {
      String novels = await HttpUtil.get(NovelAPI.getNovelsByTag(tagid,page));
      List result  = json.decode(novels);
      if(result.length<10){
        isload = false;
      }
      showNovels.addAll(result);
      Tools.updateUI(this);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: onVerticalDragDown,
      child: Tools.listViewBuilder(showNovels,onLongPress:Tools.addToShelf,controller: scrollController),
    );
  }
  onVerticalDragDown(DragDownDetails _) {
    // 这里指定快划到最后150像素的时候，进行加载
    double threshold = scrollController.position.maxScrollExtent - scrollController.offset;
    if (isload && threshold < 100) {
      currentPage = currentPage+1;
      loadShowNovels(_tagid,currentPage);
    } else if(threshold < 10) {
      Fluttertoast.showToast(
          msg: "没有更多了",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 2,
          bgcolor: "#777777",
          textcolor: '#ffffff');
    }
  }
}
