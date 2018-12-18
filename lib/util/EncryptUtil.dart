import 'dart:convert';

///  加解密
class EncryptUtil {
  static String encryptStr(String source, String key) {
    List<int> strbyte = utf8.encode(source);
    List<int> keybyte = utf8.encode(key);
    List<int> bt = [0, 0];
    String retstr = "";
    for (int i = 0, j = 0; i < strbyte.length; i++, j++) {
      int ret = strbyte[i] ^ keybyte[j];
      bt[0] = (65 + (ret / 26).floor());
      bt[1] = (65 + ret % 26);
      String s = utf8.decode(bt);
      retstr += s;
      if (j == keybyte.length - 1) {
        j = 0;
      }
    }
    return retstr;
  }

  static String decryptStr(String source, String key) {
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
    for (int i = 0, j = 0; i < strbyte.length; i++, j++) {
      retbt[0] = strbyte[i] ^ keybyte[j];
      String s = utf8.decode(retbt);
      retstr += s;
      if (j == keybyte.length - 1) {
        j = 0;
      }
    }
    return retstr;
  }
}

void main() {
  print(EncryptUtil.encryptStr("9fe90b293feb641f7f4a8739c6d843d4954dac61", "com"));
  print(EncryptUtil.decryptStr("DMAJAIDIDPANDRDIDQAJAIANDNDNDOAJDMAJDLAODHDKDQDIAODLAJDJDLDOAJDNDGDMDLALAMAMDNDQ", "com"));
}
