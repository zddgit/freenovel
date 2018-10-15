import 'package:flutter/material.dart';
class Bookshelf extends StatefulWidget{
  @override
  _BookshelfState createState() {
    return _BookshelfState();
  }

}
class _BookshelfState extends State<Bookshelf>{
  List<Novel> novels;
  @override
  void initState() {
    super.initState();
    //TODO 初始化读过的小说,本地文件读取
    novels = <Novel>[
      Novel("images/3773s.jpg","三寸人间","耳根","星空古剑，万族进化，缥缈道院，谁与争锋天下万物，神兵不朽，宇宙苍穹，太虚称尊青木年华，悠悠牧之……",null),
      Novel("images/4772s.jpg","圣墟","辰东","在破败中崛起，在寂灭中复苏",null),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: novels==null?0:novels.length,
        itemBuilder: _itemBuilder
    );
  }


  Widget _itemBuilder(BuildContext context, int index) {
    Novel novel = novels[index];
    return Card(
      child: ListTile(
          leading: Image.asset(novel._imageUrl,height: 50.0,width: 50.0,),
          title: Text(novel._name),
          subtitle: Text(novel._author),
          trailing:Container(
              width: 150.0,
              height: 50.0,
              child: Center(
                  child: Text(
                    novel._introduction,
                    style:TextStyle(fontSize: 10.0,fontWeight:FontWeight.bold,color: Colors.grey),
                  )
              )
          ),
        onTap: (){
          print("点击了$index");
          //TODO 打开小说
        },
        onLongPress: (){

            showDialog(
                context: context,
                barrierDismissible: false,
                builder:(context){
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


        },
      ),
    );
  }
}
class Novel{
  final String _imageUrl;
  final String _name;
  final String _author;
  final String _introduction;
  final DateTime _recentReadTime;

  Novel(this._imageUrl, this._name, this._author, this._introduction,this._recentReadTime);

}