import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HttpUtil {
  static final Dio dio = new Dio()..interceptors.add(CookieManager(CookieJar()));
  static final Options options = new Options(connectTimeout: 5000,receiveTimeout: 5000,followRedirects: true);

  static Future<String> get(String url,{int retry=0,Map data}) async {
    if(retry>=3){
      Fluttertoast.showToast(
          msg: "网络错误",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor:Colors.black,
          textColor: Colors.white70
      );
      return null;
    }
    print("get请求："+url);
    String result;
    try{
      Response response=await dio.get(url,queryParameters: data,options: options);
      if(response.statusCode == 200) {
        result = json.encode(response.data);
      }else{
        await Future.delayed(Duration(seconds: 1));
        result = await get(url,data: data,retry: (retry+1));
      }
    }catch(e){
      await Future.delayed(Duration(seconds: 1));
      result = await get(url,data: data,retry: (retry+1));
    }
    return result;
  }
  static Future<String> post(String url,{int retry=0,Map data}) async {
    if(retry>=3){
      Fluttertoast.showToast(
          msg: "网络错误",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor:Colors.black,
          textColor: Colors.white70
      );
      return null;
    }
    print("post请求："+url);
    String result;
    try{
      Response response=await dio.post(url,data: data,options: options);
      if(response.statusCode == 200) {
          result = json.encode(response.data);
      }else{
        await Future.delayed(Duration(seconds: 1));
        result = await post(url,data: data,retry: (retry+1));
      }
    }catch(e){
      await Future.delayed(Duration(seconds: 1));
      result = await post(url,data: data,retry: (retry+1));
    }
     return result;
  }
  static download(String url,String savePath) async{
    print("download请求：$url");
    await dio.download(url, savePath);
  }

}

