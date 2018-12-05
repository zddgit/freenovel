import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/page/booksearch.dart';
import 'package:freenovel/util/Tools.dart';
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
  TabController _controller;
  /// 滚动控制
  ScrollController scrollController;
  bool isload = true;

  @override
  void initState() {
    super.initState();
    queryName = "";
    scrollController = ScrollController();
    _controller = TabController(length: Global.tabs.length, vsync: this);
  }



  getSearchNovels(String name,{page=1}) async {
    String searchNovels = await HttpUtil.get(NovelAPI.getNovelsByNameOrAuthor(name,page));
    showNovels = json.decode(searchNovels);
    if(showNovels.length<10){
      isload = false;
    }
    Tools.updateUI(this);
  }




  @override
  Widget build(BuildContext context) {
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
            child: TabBar(
              indicatorColor: Colors.white,
              tabs: Global.tabs,
              isScrollable: true,
              controller: _controller,
            ),
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: Global.pages,
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

class LibraryPageState extends State<LibraryPage> with AutomaticKeepAliveClientMixin {
  int _tagid;
  int currentPage = 1;
  bool isload = true;

  /// 滚动控制
  ScrollController scrollController;

  LibraryPageState(this._tagid);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    if(Global.currentPages[_tagid]==1 && Global.map[_tagid].length==0){
      loadShowNovels(_tagid,currentPage);
    }
  }

  loadShowNovels(int tagid,int page) async {
      String novels = await HttpUtil.get(NovelAPI.getNovelsByTag(tagid,page));
      List result  = json.decode(novels);
      if(result.length<10){
        isload = false;
      }
      Global.map[_tagid].addAll(result);
      Global.currentPages[_tagid] = page;
      Tools.updateUI(this);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: onVerticalDragDown,
      child: Tools.listViewBuilder(Global.map[_tagid],controller: scrollController,onTap: Tools.openChapterDetail),
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
