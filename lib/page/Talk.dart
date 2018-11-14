import 'package:flutter/material.dart';

///动弹广场
class Talk extends StatefulWidget {
  @override
  TalkState createState() {
    return TalkState();
  }
}

class TalkState extends State<Talk> with SingleTickerProviderStateMixin {
  TabController _controller;
  List<Tab> tabs;

  @override
  void initState() {
    super.initState();
    tabs = <Tab>[
      Tab(
        text: "动弹",
      ),
      Tab(
        child: Text("热门"),
      ),
    ];
    _controller = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          indicatorColor: Colors.white,
          tabs: tabs,
          isScrollable: false,
          controller: _controller,
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [TalkPage("talk"), TalkPage("hotTalk")],
      ),
    );
  }
}

class TalkPage extends StatefulWidget {
  final String type;

  TalkPage(this.type);

  @override
  TalkPageState createState() {
    return TalkPageState(type);
  }
}

class TalkPageState extends State<TalkPage> {
  final String type;

  TalkPageState(this.type);

  List<TalkMessage> talks;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child:
          ListView.builder(itemCount: talks.length, itemBuilder: _itemBuilder),
      onRefresh: () {},
    );
  }

  @override
  void initState() {
    super.initState();
    if (type == "talk") {
      //TODO 网络获取最新talk(带缓存)
      talks = [TalkMessage("我的第一条talk", 1), TalkMessage("我的第二条talk", 2)];
    } else if (type == "hotTalk") {
      //TODO 网络获取热门talk(带缓存)
      talks = [TalkMessage("我的第三条talk", 1), TalkMessage("我的第四条talk", 2)];
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    TalkMessage talkMessage = talks[index];
    return Card(
      child: ListTile(
        leading: talkMessage.pic ??
            CircleAvatar(backgroundImage: AssetImage(
              "images/4772s.jpg"
             ),),
        title: Text(talkMessage.content ?? ""),
        subtitle: Text(talkMessage.name ?? ""),
        onTap: () {},
      ),
    );
  }
}



class TalkMessage {
  String pic; // talk 发布者头像
  String name; //talk 发布者昵称
  String content; // talk 具体内容
  int id; //talk id
  int publishId; //talk 发布者id
  List<int> welcome; // 点赞人id
  int type;

  TalkMessage(this.content, this.publishId,
      {this.id, this.pic, this.name, this.welcome, this.type = 0});

  @override
  String toString() {
    return 'TalkMessage{pic: $pic, name: $name, content: $content, id: $id, publishId: $publishId, welcome: $welcome, type: $type}';
  }
}
