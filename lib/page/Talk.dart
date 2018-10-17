import 'package:flutter/material.dart';

///书库
class Talk extends StatefulWidget {
  @override
  TalkState createState() {
    return TalkState();
  }
}

class TalkState extends State<Talk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text("讨论广场"),
    );
  }
}
