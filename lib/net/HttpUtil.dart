import 'package:dio/dio.dart';

class HttpUtil {
  static final Dio dio = new Dio();

  static Future<T> get<T>(String url,{data}) async {
    T result;
    Response<T> response=await dio.get<T>(url,data: data);
    if(response.statusCode == 200) {
      result = response.data;
    } else {
      //result = "Network Error\nHttp status ${response.statusCode}";
      result = null;
    }
    return result;
  }
  static Future<String> post(String url,{data}) async {
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
