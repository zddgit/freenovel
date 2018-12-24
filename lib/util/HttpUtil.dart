import 'dart:convert';

import 'package:dio/dio.dart';

class HttpUtil {
  static final Dio dio = new Dio();

  static Future<String> get(String url,{Map data}) async {
    print("get请求："+url);
    String result;
    Response response=await dio.get(url,data: data);
    if(response.statusCode == 200) {
        result = json.encode(response.data);
    } else {
      result = "Network Error\nHttp status ${response.statusCode}";
      //result = null;
    }
    return result;
  }
  static Future<String> post(String url,{Map data}) async {
    print("post请求："+url);
    String result;
    Response response=await dio.post(url,data: data);
    if(response.statusCode == 200) {
        result = json.encode(response.data);
    } else {
      result = "Network Error\nHttp status ${response.statusCode}";
    }
    return result;
  }
  static download(String url,String savePath) async{
    print("download请求：$url");
    await dio.download(url, savePath);
  }

}

