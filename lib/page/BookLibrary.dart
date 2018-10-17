import 'package:flutter/material.dart';
import 'package:freenovel/page/bookshelf.dart';

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
              onPressed: () => showSearch(context: context, delegate: SearchBarDelegate())
          ),
        ],
      ),
      body: Center(child: Text("书库")),
    );
  }

  @override
  void initState() {
    super.initState();
    queryName = "";
  }

}

class SearchBarDelegate extends SearchDelegate<String> {
  List<Novel> novels;


  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = "")];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      child: Card(
        color: Colors.redAccent,
        child: Center(
          child: Text(query),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query.isEmpty){
      //TODO 从网络获取最热小说(带本地缓存)
      novels = <Novel>[
        Novel(1, "images/3773s.jpg", "a武动乾坤", "耳根",
            "星空古剑，万族进化，缥缈道院，谁与争锋天下万物，神兵不朽，宇宙苍穹，太虚称尊青木年华，悠悠牧之", null),
        Novel(2, "images/4772s.jpg", "b凡人修仙传", "辰东", "在破败中崛起，在寂灭中复苏", null),
      ];
    }else{
      //TODO 从网络获取匹配的小说(带本地缓存)
      novels = <Novel>[
        Novel(1, "images/3773s.jpg", "c三寸人间", "耳根",
            "星空古剑，万族进化，缥缈道院，谁与争锋天下万物，神兵不朽，宇宙苍穹，太虚称尊青木年华，悠悠牧之", null),
        Novel(2, "images/4772s.jpg", "d圣墟", "辰东", "在破败中崛起，在寂灭中复苏", null),
      ];
    novels = novels.where((input) => input.name.startsWith(query)).toList();
    }


    return ListView.builder(
        itemCount: novels.length,
        itemBuilder: _itemBuilder
    );
  }
  Widget _itemBuilder(BuildContext context, int index) {
    Novel novel = novels[index];
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
        onTap: () {},
      ),
    );
  }
}
