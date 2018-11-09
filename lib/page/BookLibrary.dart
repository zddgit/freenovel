import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freenovel/common/CommonSearchBarDelegate.dart';
import 'package:freenovel/page/Bookshelf.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';
import 'package:cached_network_image/cached_network_image.dart';

///书库
class BookLibrary extends StatefulWidget {
  @override
  BookLibraryState createState() {
    return BookLibraryState();
  }
}

class BookLibraryState extends State<BookLibrary> {
  String queryName;

  List<Novel> novels = [];
  List<Novel> top10Novels = [];
  List<Novel> showNovels = [];
  CommonSearchBarDelegate commonSearchBarDelegate;

  @override
  void initState() {
    super.initState();
    queryName = "";
    commonSearchBarDelegate = new CommonSearchBarDelegate(query);
    getRecommendNovels();
  }

  updateUI({fn}) {
    setState(() {
      if (fn != null) fn();
    });
  }

  getRecommendNovels() async {
    String top10 = await HttpUtil.get(NovelAPI.getRecommentNovelsTop10());
    List list = json.decode(top10);
    list.forEach((item) {
      top10Novels.add(Novel(item["id"], item["name"], item["author"],
          introduction: item["introduction"], cover: item["cover"]));
    });
  }

  getSearchNovels(String name) async {
    String searchNovels = await HttpUtil.get(NovelAPI.getNovelsByNameOrAuthor(name));
    List list = json.decode(searchNovels);
    showNovels = [];
    list.forEach((item) {
      showNovels.add(Novel(item["id"], item["name"], item["author"],
          introduction: item["introduction"], cover: item["cover"]));
    });
    updateUI(fn: (){
      print(showNovels);
    });
  }

  Widget query(query){
    if (query.isEmpty) {
      showNovels = top10Novels;
    } else {
      getSearchNovels(query);
    }
    return ListView.builder(
        itemCount: showNovels.length,
        itemBuilder: _itemBuilder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜书名'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () => showSearch( context: context, delegate: commonSearchBarDelegate)),
        ],
        centerTitle: true,
      ),
      body: Center(
          child: RaisedButton(
            color: Colors.blueGrey,
            onPressed: () async {
              SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
              List<String> sqls = List();
              sqls.add(
                  "DROP TABLE IF EXISTS `Test`;CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
              sqls.add(
                  "CREATE TABLE IF NOT EXISTS `student` (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
              await sqfLiteHelper.delDataBases("novels");
              //await sqfLiteHelper.ddl("novels", sqls,1);
            },
            child: Text("书库"),
          )),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Novel novel = showNovels[index];
    return Card(
      child: ListTile(
        leading: Container(
          width: 50.0,
          height: 55.0,
          decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: Colors.black38),
              borderRadius:BorderRadius.all(Radius.circular(2.0))),
          child: new CachedNetworkImage(
            imageUrl: NovelAPI.getImage(novel.id),
            placeholder: new CircularProgressIndicator(),
            errorWidget: Container(
                color: Colors.blueGrey,
                child: Center(child: Text(novel.name.substring(0, 1))),
            ),
            width: 50.0,
            height: 55.0,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(novel.name),
        subtitle : Text(novel.author),
        trailing: Container(
            width: 150.0,
            height: 50.0,
            child: Center(
                child: Text(
                  novel.introduction,
                  style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  maxLines: 3,
                  overflow: TextOverflow
                      .ellipsis,
                ))),
//        onTap: () {
//          print("dianji$index");
//        } ,
      )
      ,
    );
  }
}
