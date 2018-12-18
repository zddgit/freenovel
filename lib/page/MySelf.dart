import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/page/login.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
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
  Widget build(BuildContext context) {
    if(Global.setting.length==0){
      initSetting();
    }else{
      setting = List()..addAll(Global.setting);
      if(Global.user!=null){
        setting.add({"id":0,"name":"退出登录"});
      }
    }
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
                  child: Text(Global.user==null?"点击登录":Global.user["nick"],style: TextStyle(fontSize: 20.0),),),
                Expanded(
                  child: Container(),),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    decoration:BoxDecoration(color: Colors.white70,borderRadius:BorderRadius.circular(30.0)),
                    height: 60.0,
                    child: Image.asset(Global.user==null?"images/offline.png":"images/online.png"),
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
    if(item["id"]!=0){
      return Column(children: <Widget>[
            Card(
              margin: EdgeInsets.all(0.0),
              elevation: 0.0,
              child: GestureDetector(
                onTap: (){
                  print(item);
                },
                child: ListTile(
                leading: Text(item["name"]),
                trailing: settingBuild(item),
              ),),
            ),
            Divider(color: Colors.grey, height: 1.0,),
      ],);
    }else{
      return Column(children: <Widget>[
        Card(
          color: Colors.red,
          elevation:2.0,
          margin: EdgeInsets.all(0.0),
          child: GestureDetector(
            onTap: (){
              setCallBack(item["id"]);
            },
            child: ListTile(
              title: Center(child: Text(item["name"],style: TextStyle(color: Colors.white),)),
            ),),
        ),
        Divider(color: Colors.grey, height: 1.0,),
      ],);
    }
  }

  Future<void> initSetting() async {
    String sets = await HttpUtil.get(NovelAPI.getSetting());
    setting = json.decode(sets);
    Global.setting = List()..addAll(setting);
    if(Global.user!=null){
      setting.add({"id":0,"name":"退出登录"});
    }
    Tools.updateUI(this);
  }

  Widget settingBuild(item) {
    switch(item["id"]){
        // TODO 获取我的账户
      case 11:
        return Container(child: Text("300.0 金豆"),margin: EdgeInsets.only(right: 12.0),);
        break;
        //签到
      case 12:
        int info = Random().nextInt(10);
        if(info>5){
          return Container(child: Image.asset("images/signIn.png"),margin: EdgeInsets.only(right: 12.0),);
        }else{
          return Container(child: Image.asset("images/signedIn.png"),margin: EdgeInsets.only(right: 12.0),);
        }
        break;
        // TODO 我的私信
      case 13:
        int info = Random().nextInt(10);
        if(info==0){
          return Container();
        }else{
          return Container(
            width: 20,
            height: 20,
            decoration:BoxDecoration(color: Colors.red,borderRadius:BorderRadius.all(Radius.circular(10.0))),
            child: Center(child: Text(info.toString(),style: TextStyle(color: Colors.white),),),margin: EdgeInsets.only(right: 12.0),);
        }
        break;
        //当前版本
      case 16:
        return Container(child: Text("1.0"),margin: EdgeInsets.only(right: 12.0),);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void setCallBack(id) {
    switch (id){
      case 0:
        Global.user = null;
        Global.prefs.remove("account");
        setting.removeLast();
        Tools.updateUI(this);
        break;
      default:
        print(id);
    }

  }
}
