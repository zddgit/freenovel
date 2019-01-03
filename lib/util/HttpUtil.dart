import 'dart:convert';

import 'package:dio/dio.dart';

class HttpUtil {
  static final Dio dio = new Dio();
  static final Options options = new Options(connectTimeout: 3000,receiveTimeout: 3000);

  static Future<String> get(String url,{Map data}) async {
    print("get请求："+url);
    String result;
    try{
      Response response=await dio.get(url,data: data,options: options);
      if(response.statusCode == 200) {
        result = json.encode(response.data);
      }else{
        await Future.delayed(Duration(seconds: 1));
        result = await get(url,data: data);
      }
    }catch(e){
      await Future.delayed(Duration(seconds: 1));
      result = await get(url,data: data);
    }
    return result;
  }
  static Future<String> post(String url,{Map data}) async {
    print("post请求："+url);
    String result;
    try{
      Response response=await dio.post(url,data: data,options: options);
      if(response.statusCode == 200) {
          result = json.encode(response.data);
      }else{
        await Future.delayed(Duration(seconds: 1));
        result = await post(url,data: data);
      }
    }catch(e){
      await Future.delayed(Duration(seconds: 1));
      result = await post(url,data: data);
    }
     return result;
  }
  static download(String url,String savePath) async{
    print("download请求：$url");
    await dio.download(url, savePath);
  }

}

