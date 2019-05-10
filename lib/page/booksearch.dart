import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:loadmore/loadmore.dart';

class BookSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookSearchState();
  }
}

class BookSearchState extends State<BookSearch> {
  String query;

  List novels=[];
  ScrollController scrollController = new ScrollController();

  List searchNovels = [];
  ScrollController searchScrollController = new ScrollController();
  bool isFinish = false;
  bool isSearch = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: TextField(
          decoration: InputDecoration(hintText: "输入书名、作者关键词"),
          onChanged: (query) {
            this.query = query;
          },
          onSubmitted: (query) {
            loadSearchNovel();
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                loadSearchNovel();
              })
        ],
      ),
      body: isSearch?getSearch():getDefaultNew(),
    );
  }
  Widget getDefaultNew(){
    return Container(child: Center(child: Text("还未开始搜索"),),);
  }
  Widget getDefault(){
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Row(
              children: <Widget>[
                Text(
                  "大家都再搜",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
              ],
            ),
          ),
          getRecommend(),
          getRecommend(),
          Divider(color: Colors.grey),
          Container(
            padding: const EdgeInsets.only(left: 16.0, top: 0.0),
            child: Row(
              children: <Widget>[
                Text(
                  "热门阅读",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),

              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LoadMore(
                isFinish: isFinish,
                onLoadMore: loadMoreNovel,
                child: Tools.listViewBuilder(
                    novels,
                    controller: scrollController,
                    onTap: Tools.openChapterDetail),
              ),
            ),
          )

        ],
      ),
    );
  }
  Widget getSearch(){
    if(searchNovels.length==0){
      return Container(child: Center(child: Text("无搜索结果,请修改关键字或者到我的->反馈，按照\n#书名_作者#\n格式反馈给开发者，会尽快上线你喜欢的小说"),),);
    }else{
      return Tools.listViewBuilder(
          searchNovels,
          controller: searchScrollController,
          onTap: Tools.openChapterDetail);
    }
  }
  Widget getRecommend(){
    List<Widget> list = new List();
    for(var i = 0;i<3;i++){
      Widget recommend = Container();
      if(i==0){
        recommend = Container(
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(topLeft:Radius.circular(5.0))),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text("新",style: TextStyle(color: Colors.white,fontSize: 12.0),),
          ),
        );
      }
      if(i==1){
        recommend = Container(
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(topLeft:Radius.circular(5.0))),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text("热",style: TextStyle(color: Colors.white,fontSize: 12.0),),
          ),
        );
      }
      list.add(Expanded(
        child: Container(
          margin: EdgeInsets.only(top: 10.0,left: 10.0,right: 10),
          decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.black38),
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 4.0, bottom: 4.0),
                child: GestureDetector(
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: "哈哈，这本书还不能点击",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                        backgroundColor:Colors.black,
                        textColor: Colors.white70
                    );
                  },
                  child: Text("点我,点我"),),
              ),
              recommend
            ],
          ),
        ),
      ));
    }

    return Row(children: list,);
  }

  Future<bool> loadMoreNovel() async {
    await initNovels();
    await new Future.delayed(new Duration(milliseconds: 100));
    return true;
  }

   initNovels() async{
    String result = await HttpUtil.get(NovelAPI.getRecommentNovelsTop10());
    List list = json.decode(result);
    if(list.length<10){
      isFinish = true;
    }
    novels.addAll(list);
    Tools.updateUI(this);
  }

  loadSearchNovel() async{
    isSearch = true;
    searchNovels.clear();
    String result = await HttpUtil.get(NovelAPI.getNovelsByNameOrAuthor(query, 1));
    List list = json.decode(result);
    searchNovels.addAll(list);
    Tools.updateUI(this);
  }
}
