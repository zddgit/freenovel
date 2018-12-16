import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/page/login.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:freenovel/util/Tools.dart';

///我的
class MySelf extends StatefulWidget {
  @override
  MySelfState createState() {
    return MySelfState();
  }
}

class MySelfState extends State<MySelf> {

  List setting = [];
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          elevation: 0.0,
          title: Center(child: Text("个人中心"),),),),
      body: Center(
        child: Column(children: <Widget>[
          Container(
            height: 80.0,
            color: Colors.blue,
            child: Row(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Tools.pushPage(context, Login());
                  },
                  textColor: Colors.white,
                  child: Text("点击登录",style: TextStyle(fontSize: 20.0),),),
                Expanded(
                  child: Container(),),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    decoration:BoxDecoration(color: Colors.white70,borderRadius:BorderRadius.circular(30.0)),
                    height: 60.0,
                    child: Image.asset("images/icon_logo.png"),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: setting.length,
              itemBuilder: _itemBulider),)
        ],),
      ),
    );
  }

  Widget _itemBulider(BuildContext context, int index) {
    var item = setting[index];
    return Column(children: <Widget>[
          Card(
            margin: EdgeInsets.all(0.0),
            elevation: 0.0,
            child: ListTile(
                leading: Text(item["name"]),
                trailing: item["id"]!=16?IconButton(onPressed:()=>setPage(item),icon: Icon(Icons.keyboard_arrow_right)):Container(child: Text("1.0"),margin: EdgeInsets.only(right: 12.0),)
            ),
          ),
          Divider(color: Colors.grey, height: 1.0,),
    ],);
  }

  Future<void> initSetting() async {
    String sets = await HttpUtil.get(NovelAPI.getSetting());
    setting = json.decode(sets);
    Tools.updateUI(this);
  }

  void setPage(item) {
    print(item);
  }
}
