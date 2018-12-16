import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelResource.dart';
class Login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }

}
class LoginState extends State<Login> with TickerProviderStateMixin {
  final TextEditingController accountcontroller = TextEditingController();
  final TextEditingController pwdcontroller = TextEditingController();
  var ctx;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed:()=>Navigator.of(context).pop()),
        title: Text("账号密码登录"),
      ),
      body: Column(children: <Widget>[
        Expanded(child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30,right: 30,left: 30),
            child: TextField(
              controller: accountcontroller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  labelText: '邮箱',
                  icon: Icon(Icons.email),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15,right: 30,left: 30),
            child: TextField(
              controller: pwdcontroller,
              keyboardType: TextInputType.text,
              obscureText:true,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  labelText: '密码',
                  icon: Icon(Icons.lock),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30,top: 10),
            child: Row(children: <Widget>[
              Expanded(child: Container(),),
              Text("忘记密码")
            ],),
          ),
          FlatButton(child: Text("登录/注册",style: TextStyle(color: Colors.white),),color: Colors.blue,onPressed: showLogin,)
        ],),),
        Row(children: <Widget>[
          Expanded(child: Container(child: FlatButton(child: Image.asset("images/wx.png"), onPressed: ()=>openWx(),),height: 30.0,),flex: 1,),
          Expanded(child: Container(child: FlatButton(child: Image.asset("images/wb.png"), onPressed: ()=>openWb(),),height: 30.0,),flex: 1,),
          Expanded(child: Container(child: FlatButton(child: Image.asset("images/QQ.png"), onPressed: ()=>openQQ(),),height: 30.0,),flex: 1,),
        ],),
        Padding(
          padding: const EdgeInsets.only(top: 8.0,bottom: 15.0),
          child: Text("点击登录代表同意此软件的 使用协议 和 隐私政策",style: TextStyle(color: Colors.grey,fontSize: 12.0),),
        )
      ],),
    );
  }

  openWx() {}

  openWb() {}

  openQQ() {}



  showLogin() {
    String account = accountcontroller.text.trim();
    String pwd = pwdcontroller.text.trim();
    if(account==""||pwd==""){
      Fluttertoast.showToast(
          msg: "请填写完成信息",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 3,
          backgroundColor:Colors.red,
          textColor: Colors.white70
      );
      return;
    }
    longin(account,pwd);
    showDialog(context: context,builder: (context){
      ctx = context;
      return Image.asset("images/loading.gif");
    });
  }
  longin(account,pwd) async {
    String type;
    if(new RegExp('^[A-Za-z0-9\\u4e00-\\u9fa5]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+\$').hasMatch(account)){
        type = "email";
    }
    if(new RegExp('^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$').hasMatch(account)){
      type = "mobile";
    }
    var bytes = utf8.encode(pwd);
    Digest digest = sha1.convert(bytes);
    String result = await HttpUtil.post(NovelAPI.loginOrRegister(type, account, digest.toString()));
    var r =json.decode(result);
    Fluttertoast.showToast(
        msg: r["message"],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3,
        backgroundColor:Colors.black,
        textColor: Colors.white70
    );
    Navigator.of(ctx).pop();
  }

}
