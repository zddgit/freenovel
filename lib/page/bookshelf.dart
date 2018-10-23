import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freenovel/views/ChapterDetail.dart';

class Bookshelf extends StatefulWidget {
  @override
  _BookshelfState createState() {
    return _BookshelfState();
  }
}

class _BookshelfState extends State<Bookshelf> {
  List<Novel> novels;

  @override
  void initState() {
    super.initState();
    //TODO 初始化读过的小说,本地文件读取
    novels = <Novel>[
        Novel(1, "三寸人间", "耳根",imageUrl:"images/3773s.jpg",introduction:"星空古剑，万族进化，缥缈道院，谁与争锋天下万物，神兵不朽，宇宙苍穹，太虚称尊青木年华，悠悠牧之"),
        Novel(2, "圣墟", "辰东",imageUrl:"images/4772s.jpg",introduction:"在破败中崛起，在寂灭中复苏"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(backgroundColor: Colors.blue, title: Text("书架"),centerTitle: true,),
      body: ListView.builder(
          itemCount: novels == null ? 0 : novels.length,
          itemBuilder: _itemBuilder),
    );
  }

  /// 打开章节详情页
  void _open(int chapterIndex) {
    Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return new ChapterDetail(chapterIndex);},
        transitionsBuilder: (BuildContext context, Animation<double> animation,Animation<double> secondaryAnimation, Widget child) {
          return new FadeTransition(
            opacity: animation,
            child: new SlideTransition(
              position: new Tween<Offset>(
                begin: Offset(1.0, 0.0),
                end: Offset(0.0, 0.0),
              ).animate(animation),
              child: child,
            ),
          );
        }));
  }
  /// 长按删除
  void _showDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('你想删除吗？'),
          actions: <Widget>[
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                print("删除了$index");
                Navigator.of(context).pop();
                setState(() {
                  novels.removeAt(index);
                });
              },
            ),
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  /// 书架具体元素构建
  Widget _itemBuilder(BuildContext context, int index) {
    Novel novel = novels[index];
    return Card(
      color: Colors.black12,
      child: Container(
        padding: EdgeInsets.only(top: 15.0),
        height: 100.0,
        child: ListTile(
          leading: Image.asset(
            novel.imageUrl,
            height: 80.0,
            //width: 50.0,
          ),
          title: Text(novel.name),
          subtitle: Text(novel.author),
          trailing: Container(
              width: 150.0,
              height: 80.0,
              child: Center(
                  child: Text(
                novel.introduction,
                style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ))),
          onTap: () => _open(novel.id),
          onLongPress: ()=>_showDialog(index),
        ),
      ),
    );
  }
}

class Novel {
  /// 小说id
  final int id;
  /// 小说封面
  final String imageUrl;
  /// 小说名称
  final String name;
  /// 小说作者
  final String author;
  /// 小说简介
  final String introduction;
  /// 最近阅读时间
  final int recentUpdateTime;


  Novel(this.id, this.name, this.author,{this.imageUrl,  this.introduction, this.recentUpdateTime});
}
