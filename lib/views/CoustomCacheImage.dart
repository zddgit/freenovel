import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freenovel/Global.dart';
import 'package:freenovel/util/HttpUtil.dart';
import 'package:freenovel/util/NovelAPI.dart';
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
      File file = File(imgpath);
      Image image = Image.file(file,fit: BoxFit.cover,width: 80,height: 100,);
      // 此方法主要是用来在图片加载失败以后，添加默认小部件
      ImageStream stream = image.image.resolve(ImageConfiguration.empty);
      stream.addListener((_,__){//成功回调
          child = image;
          Tools.updateUI(this);
      }, onError: (dynamic exception, StackTrace stackTrace) {//失败回调
          child = Center(child: Text("封面"),);
          Tools.updateUI(this);
      });

  }


}