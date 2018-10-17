import 'package:flutter/material.dart';

///我的
class MySelf extends StatefulWidget {
  @override
  MySelfState createState() {
    return MySelfState();
  }
}

class MySelfState extends State<MySelf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text("我的"),
    );
  }
}
