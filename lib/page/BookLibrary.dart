import 'dart:convert';

import 'package:flutter/material.dart';
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

  LibraryPageState(this._tagid);

  @override
  void initState() {
    super.initState();
    initShowNovels();
  }

  initShowNovels() async {
      String novels = await HttpUtil.get(NovelAPI.getNovelsByTag(_tagid));
      showNovels = json.decode(novels);
      Tools.updateUI(this);
  }

  @override
  Widget build(BuildContext context) {
    return Tools.listViewBuilder(showNovels,onLongPress:Tools.addToShelf);
  }
}
