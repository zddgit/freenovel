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
      Novel(1, "images/3773s.jpg", "三寸人间", "耳根",
          "星空古剑，万族进化，缥缈道院，谁与争锋天下万物，神兵不朽，宇宙苍穹，太虚称尊青木年华，悠悠牧之", null),
      Novel(2, "images/4772s.jpg", "圣墟", "辰东", "在破败中崛起，在寂灭中复苏", null),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: Text("书架")),
      body: ListView.builder(
          itemCount: novels == null ? 0 : novels.length,
          itemBuilder: _itemBuilder),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Novel novel = novels[index];

    void _open(int chapterIndex) {
      Navigator.of(context).push(new PageRouteBuilder(pageBuilder:
          (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
        return new Detail(chapterIndex);
      }, transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
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

    void _showDialog() {
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

    return Card(
      child: ListTile(
        leading: Image.asset(
          novel.imageUrl,
          height: 50.0,
          width: 50.0,
        ),
        title: Text(novel.name),
        subtitle: Text(novel.author),
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
              overflow: TextOverflow.ellipsis,
            ))),
        onTap: () => _open(novel.id),
        onLongPress: _showDialog,
      ),
    );
  }
}

class Novel {
  final int _id;
  final String _imageUrl;
  final String _name;
  final String _author;
  final String _introduction;
  final DateTime _recentReadTime;

  Novel(this._id, this._imageUrl, this._name, this._author, this._introduction,
      this._recentReadTime);

  int get id => _id;

  String get imageUrl => _imageUrl;

  String get name => _name;

  String get author => _author;

  String get introduction => _introduction;

  DateTime get recentReadTime => _recentReadTime;
}
