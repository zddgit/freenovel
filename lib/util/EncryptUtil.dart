import 'dart:convert';

import 'dart:math';

///  加解密
class EncryptUtil {
  static  String key = "freeNovel@zdd";
  static int gene = 0xDB6;
  static String encryptInt(int src){
    int _src = src ^ gene;
    String _ret;
    if(_src < 0 ){
      _src = -_src;
      _ret = "0";
    }else{
      _ret = String.fromCharCode(97 + Random().nextInt(25));
    }
    _src = _src+_ret.codeUnits.first;
    return _src.toRadixString(16)+_ret;
  }

  static int decryptInt(String src){
    String _f =  src.substring(src.length - 1 );
    int _src = int.parse(src.substring(0,src.length-1),radix: 16);
    _src = _src-_f.codeUnits.first;
    if("0"==_f){
      _src = -_src;
    }
    return _src ^ gene;
  }

  static String encryptStr(String source) {
    List<int> strbyte = utf8.encode(source);
    List<int> keybyte = utf8.encode(key);
    List<int> bt = [0, 0];
    String retstr = "";
    for (int i = 0, j = 0; i < strbyte.length; i++) {
      int ret = strbyte[i] ^ keybyte[j];
      bt[0] = (65 + (ret / 26).floor());
      bt[1] = (65 + ret % 26);
      String s = utf8.decode(bt);
      retstr += s;
      if (j == keybyte.length - 1) {
        j = 0;
      }else{
        j++;
      }
    }
    return retstr;
  }

  static String decryptStr(String source) {
    List<int> strbyte = utf8.encode(source);
    List<int> keybyte = utf8.encode(key);
    String mstr = "";
    List<int> bt = [0, 0];
    List<int> retbt = [0];
    for (int i = 0; i < strbyte.length / 2; i++) {
      bt[0] = (strbyte[2 * i] - 65) * 26;
      bt[1] = (strbyte[2 * i + 1] - 65);
      retbt[0] = bt[0] + bt[1];
      String s = utf8.decode(retbt);
      mstr += s;
    }

    strbyte = utf8.encode(mstr);
    String retstr = "";
    for (int i = 0, j = 0; i < strbyte.length; i++) {
      retbt[0] = strbyte[i] ^ keybyte[j];
      String s = utf8.decode(retbt);
      retstr += s;
      if (j == keybyte.length - 1) {
        j = 0;
      }else{
        j++;
      }
    }
    return retstr;
  }
}
  void main(){
    print(EncryptUtil.encryptInt(100000));
    print(EncryptUtil.decryptInt("18b80c"));
  }


