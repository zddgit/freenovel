import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelResource.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:path/path.dart';
class CoustomCacheImage extends StatefulWidget{
  final int novelId;

  CoustomCacheImage(this.novelId);

  @override
  State<StatefulWidget> createState() {
    return CoustomCacheImageState(novelId);
  }

}
class CoustomCacheImageState extends State<CoustomCacheImage>{
  final int novelId;
  Widget child;

  CoustomCacheImageState(this.novelId);

  @override
  void initState() {
    super.initState();
    child = Center(child: Text("封面"),);
    initChild();
  }


  @override
  void dispose() {
    super.dispose();
    child = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: child,);

  }

  initChild() async {
    String imgpath = join(Global.cacheImgPath, "$novelId.jpg");
    if (!(await File(imgpath).exists())) {
        await HttpUtil.download(NovelAPI.getImage(novelId), imgpath);
    }
    child = Image.file(File(imgpath),fit: BoxFit.cover,);
    Tools.updateUI(this);

  }


}