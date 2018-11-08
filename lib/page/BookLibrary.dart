import 'package:flutter/material.dart';
import 'package:freenovel/common/CommonSearchBarDelegate.dart';
import 'package:freenovel/page/Bookshelf.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:freenovel/util/SqlfliteHelper.dart';

///书库
class BookLibrary extends StatefulWidget {
  @override
  BookLibraryState createState() {
    return BookLibraryState();
  }
}

class BookLibraryState extends State<BookLibrary> {
  String queryName;

  List<Novel> novels;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜书名'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () => showSearch(context: context, delegate: CommonSearchBarDelegate((query){
                if(query.isEmpty){
                  //TODO 从网络获取最热小说(带本地缓存)
                  novels = <Novel>[
                    Novel(1, "a三寸人间", "耳根",introduction:"星空古剑，万族进化，缥缈道院，谁与争锋天下万物，神兵不朽，宇宙苍穹，太虚称尊青木年华，悠悠牧之"),
                    Novel(2, "b圣墟", "辰东",introduction:"在破败中崛起，在寂灭中复苏"),
                  ];
                }else{
                  //TODO 从网络获取匹配的小说(带本地缓存)
                  novels = <Novel>[
                    Novel(1, "c三寸人间", "耳根",introduction:"星空古剑，万族进化，缥缈道院，谁与争锋天下万物，神兵不朽，宇宙苍穹，太虚称尊青木年华，悠悠牧之"),
                    Novel(2, "d圣墟", "辰东",introduction:"在破败中崛起，在寂灭中复苏"),
                  ];
                  novels = novels.where((input) => input.name.startsWith(query)).toList();
                }
                return ListView.builder(
                    itemCount: novels.length,
                    itemBuilder: _itemBuilder
                );
              }))
          ),
        ],
        centerTitle: true,
      ),
      body: Center(child: RaisedButton(
        color: Colors.blueGrey,
        onPressed: () async {
          SqfLiteHelper sqfLiteHelper = new SqfLiteHelper();
          List<String> sqls = List();
          sqls.add("DROP TABLE IF EXISTS `Test`;CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
          sqls.add("CREATE TABLE IF NOT EXISTS `student` (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
          await sqfLiteHelper.delDataBases("novels");
          //await sqfLiteHelper.ddl("novels", sqls,1);

        },
        child: Text("书库"),)),
    );
  }

  @override
  void initState() {
    super.initState();
    queryName = "";
  }
  Widget _itemBuilder(BuildContext context, int index) {
    Novel novel = novels[index];
    return Card(
      child: ListTile(
        leading: Image.asset(
          NovelAPI.getImage(novel.id),
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
        onTap: () {},
      ),
    );
  }

}
