import 'package:dio/dio.dart';
import 'dart:convert';

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

}
void main() async {
  var str = await HttpUtil.get("http://192.168.1.194:8080/getChapters/1");
  print(str);

}
