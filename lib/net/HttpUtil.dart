import 'package:dio/dio.dart';

class HttpUtil {
  static final Dio dio = new Dio();

  static Future<String> get(String url,{Map data}) async {
    String result;
    Response<String> response=await dio.get(url,data: data);
    if(response.statusCode == 200) {
      result = response.data;
    } else {
      result = "Network Error\nHttp status ${response.statusCode}";
      //result = null;
    }
    return result;
  }
  static Future<String> post(String url,{Map data}) async {
    String result;
    Response<String> response=await dio.post(url,data: data);
    if(response.statusCode == 200) {
      result = response.data;
    } else {
      result = "Network Error\nHttp status ${response.statusCode}";
    }
    return result;
  }

}
void main() async {
  var str = await HttpUtil.get("http://www.baidu.com");
  print(str.runtimeType);
}
