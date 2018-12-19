import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/page/login.dart';
import 'package:freenovel/util/EncryptUtil.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:package_info/package_info.dart';

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
                    if(Global.user==null){
                      Tools.pushPage(context, Login());
                    }
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
                  settingOnclick(item);
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
        int golden=0;
        if(Global.user!=null){
          golden = 0;
          golden = Global.user["goldenBean"];
        }
        return Container(child: Text("${golden}.0 金豆"),margin: EdgeInsets.only(right: 12.0),);
        break;
        //签到
      case 12:
        String  day  = Global.prefs.getString("day");
        if(Tools.nowString() == day){
          return Container(child: Image.asset("images/signedIn.png"),margin: EdgeInsets.only(right: 12.0),);
        }else{
          return Container(child: Image.asset("images/signIn.png"),margin: EdgeInsets.only(right: 12.0),);
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
        return Container(child: Text(Global.version),margin: EdgeInsets.only(right: 12.0),);
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

  void settingOnclick(item) {
    switch (item["id"]) {
    // 签到
      case 12:
        signIn();
        break;
    //使用协议
      case 14:
        showDialog(
            context: context,
            builder:(ctx){
              return new Scaffold(
                appBar: AppBar(
                  leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
                  Navigator.of(ctx).pop();
                }),
                title: Text("使用协议"),),
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0,0,8.0,0),
                  child: ListView(children: <Widget>[
                    Text("    在使用本软件前，请你（个人、公司、其他组织）仔细阅读本使用协议如下全部内容以便决定是否继续使用本软件，你的继续使用行为即表示你已经完全理解并接受本使用协议，否则你应当立即"
                        "卸载并删除本软件。同时，本使用协议的内容可能会根据景来服务内容的变化而做出相应的更改，故请你即时予以关注并决定是否继续接受相关更改。"
                        "\n    1、一切移动客户端用户在下载并浏览本软件时均被视为已经仔细阅读本条款并完全同意。凡以任何方式登陆本APP，或直接、间接使用本APP资料者，均被视为自愿接受本网站相关声明和用户服务协议的约束。"
                        "\n    2、本软件转载的内容并不代表本软件的意见及观点，也不意味着本软件赞同其观点或证实其内容的真实性。"
                        "\n    3、本软件转载的文字、图片等资料均来自第三方网站，本软件不会对第三方网站内容做任何实质性的编辑整理修改，本软件不能保证内容真实性、准确性和合法性，是否查看，采用，引用该内容完全由你自行决定并自行担责，本软件不提供任何保证，也不承担任何法律责任。"
                        "\n    4、本软件所转载的文字、图片等资料，如果侵犯了第三方的知识产权或其他权利，本软件建议你直接与第三方网站或相关司法机关联系，需求法律保护，如你认为本软件侵犯了你的合法权益，需要本软件删除内容，你可随时向本软件发出反馈，本软件收到通知以后，会依法处理。"
                        "\n    5、本软件不保证为向用户提供便利而设置的外部链接的准确性和完整性，同时，对于该外部链接指向的不由本软件实际控制的任何网页上的内容，本软件不承担任何责任。"
                        "\n    6、用户明确并同意其使用本软件网络服务所存在的风险将完全由其本人承担；因其使用本软件网络服务而产生的一切后果也由其本人承担，本软件对此不承担任何责任。"
                        "\n    7、除本软件注明之服务条款外，其它因不当使用本APP而导致的任何意外、疏忽、合约毁坏、诽谤、版权或其他知识产权侵犯及其所造成的任何损失，本软件APP概不负责，亦不承担任何法律责任。"
                        "\n    8、对于因不可抗力或因黑客攻击、通讯线路中断等本软件APP不能控制的原因造成的网络服务中断或其他缺陷，导致用户不能正常使用本软件APP，本软件APP不承担任何责任，但将尽力减少因此给用户造成的损失或影响。"
                        "\n    9、本声明未涉及的问题请参见国家有关法律法规，当本声明与国家有关法律法规冲突时，以国家法律法规为准。"
                        "\n    10、本软件相关声明版权及其修改权、更新权和最终解释权均属本软件APP所有\n")
                  ],)
                    ,
                ),
              );
            },);
        break;
      case 15:
        showDialog(context: context, builder: (ctx) {
          return Dialog(child: Container(
            height: 250,
            decoration: BoxDecoration(borderRadius:BorderRadius.circular(8)),
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(),hintText: "留言建议"),
                  maxLines:6,
                ),
                ),
              ),
              FlatButton(onPressed: (){

              }, child: Container(child: Center(child: Text("建议留言提交",style: TextStyle(color: Colors.white),)),width: 100,),color: Colors.blue,)
            ],),
          ),);

        });
        break;
      default:
        break;
    }
  }
   verifyLogin() {
     if(Global.user==null){
       Fluttertoast.showToast(
           msg: "你还未登录",
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.CENTER,
           timeInSecForIos: 3,
           backgroundColor:Colors.red,
           textColor: Colors.white70
       );
       return false;
     }else{
       return true;
     }
   }
   signIn() async {
    // TODO 删除软件，在安装还可以签到。
     if(verifyLogin() && Global.prefs.get("day") != Tools.nowString()){
       int gold = Random().nextInt(300);
       if(gold<50){
         gold = 50;
       }
       String msg = await HttpUtil.get(NovelAPI.signIn(Global.user["id"], Global.user["goldenBean"]+gold, EncryptUtil.encryptInt(Global.user["goldenBean"])));
       var map = json.decode(msg);
       if(map["code"]==0){
         Fluttertoast.showToast(
             msg: "你获得${gold}金豆",
             toastLength: Toast.LENGTH_SHORT,
             gravity: ToastGravity.CENTER,
             timeInSecForIos: 3,
             backgroundColor:Colors.black54,
             textColor: Colors.white70
         );
         Global.user["goldenBean"] = Global.user["goldenBean"]+gold;
         Global.prefs.setString("day",Tools.nowString());
         Tools.updateUI(this);
       }else{
         Fluttertoast.showToast(
             msg: map["message"],
             toastLength: Toast.LENGTH_SHORT,
             gravity: ToastGravity.CENTER,
             timeInSecForIos: 3,
             backgroundColor:Colors.red,
             textColor: Colors.white70
         );
       }
     }

   }
}
