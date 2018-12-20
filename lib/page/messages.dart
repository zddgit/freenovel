import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/EncryptUtil.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
import 'package:freenovel/util/Tools.dart';
class Messages extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MessageState();
  }

}
class MessageState extends State<Messages>{
  var currentPanelIndex=-1;//设置-1默认全部闭合
  var messages=List();
  int index = 0;


  @override
  void initState() {
    super.initState();
    initMessages();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("我的私信"),),
      body: SingleChildScrollView(
        child:ExpansionPanelList(
          expansionCallback: (panelIndex,isExpanded){
            if(!isExpanded){
              messages[panelIndex]["read"]=1;
              Global.user["messages"] = null;
            }
            currentPanelIndex=(currentPanelIndex!=panelIndex?panelIndex:-1);
            Tools.updateUI(this);
          },
          children: _bulidListExpansionPanel(),
        ),
      ),
    );
  }
  List<ExpansionPanel> _bulidListExpansionPanel(){
    List<ExpansionPanel> list = [];
    for(int i=0;i<messages.length;i++){
      list.add(_messagebuilder(i,currentPanelIndex));
    }
    return list;
  }
  ExpansionPanel  _messagebuilder(int i,int currentPanelIndex) {
    var item = messages[i];
    String title = item["feedback"]??"";
    String body = item["reply"]??"";
    return new ExpansionPanel(
      headerBuilder: (context,isExpanded){
        return ListTile(
          leading: item["read"]==1?Icon(Icons.drafts):Icon(Icons.markunread),
          title:  Text(title,overflow: TextOverflow.ellipsis,),
        );
      },
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(body),
      ),
      isExpanded: currentPanelIndex==i,
    );
  }

  void initMessages() async{
    int userid = Global.user["id"];
    String result = await HttpUtil.get(NovelAPI.getMessages(EncryptUtil.encryptStr(userid.toString(), userid.toString()), userid));
    var map = json.decode(result);
    messages = map["data"];
    Tools.updateUI(this);
  }
}