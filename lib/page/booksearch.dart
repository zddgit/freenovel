import 'package:flutter/material.dart';

class BookSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookSearchState();
  }
}

class BookSearchState extends State<BookSearch> {
  String query;

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
          decoration: InputDecoration(hintText: "输入书名、作者或者关键词"),
          onChanged: (query) {
            this.query = query;
          },
          onSubmitted: (query) {
            print(query);
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
//                Navigator.of(context).pop();
              })
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 16.0, top: 12.0),
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
//            Container(color: Colors.blueGrey[200],height: 4.0,margin: EdgeInsets.only(top: 10.0),),
            Container(
              padding: const EdgeInsets.only(left: 16.0, top: 12.0),
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
            )

          ],
        ),
      ),
    );
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
          margin: EdgeInsets.only(top: 20.0,left: 10.0,right: 10),
          decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.black38),
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 4.0, bottom: 4.0),
                child: Text("绝世主神"),
              ),
              recommend
            ],
          ),
        ),
      ));
    }

    return Row(children: list,);
  }
}
