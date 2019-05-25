import 'package:freenovel/util/EncryptUtil.dart';

class NovelAPI{
  static final String baseURI = "http://4s.net579.com:23641/";
//  static final String baseURI = "http://47.105.67.114:8080/";
//  static final String baseURI = "http://192.168.1.150:8080/";
//  static final String baseURI = "Http://192.168.2.111:80/";
//  static final String baseURI = "Http://172.18.210.1:8080/";

  /// 获取小说目录
  static String getTitles(int novelId,{int limit =0}){
    String nid= EncryptUtil.encryptInt(novelId);
    return baseURI+"getChapters/$nid/$limit";
  }
  /// 获取小说具体章节
  static String getNovelDetail(int novelId,int chapterId){
    String nid= EncryptUtil.encryptInt(novelId);
    String cid= EncryptUtil.encryptInt(chapterId);
    return baseURI+"getNovelDetail/$nid/$cid";
  }

  /// 获取小说信息
  static String getNovel(int novelId)=>baseURI+"getNovel/$novelId";
  /// 获取小说封面
  static String getImage(int novelId){
    String nid= EncryptUtil.encryptInt(novelId);
    return baseURI+"getImage/$nid.jpg";
  }
  /// 推荐小说列表top10
  static String getRecommentNovelsTop10()=>baseURI+"getRecommentNovelsTop10";
  /// 搜索小说通过名字或者作者
  static String getNovelsByNameOrAuthor(String keyword,int page)=>baseURI+"getNovelsByNameOrAuthor?keyword=$keyword&page=$page";
  /// 获取小说所有类别
  static String getTags()=>baseURI+"getDicByType?type=tag&status=0";
  static String getSetting()=>baseURI+"getDicByType?type=setting&status=0";
  /// 根据类别获取小说
  static String getNovelsByTag(int tagId,int page)=>baseURI+"getNovelsByTag?tagId=$tagId&page=$page";

  /// 登录或注册
  static String loginOrRegister(String type,String account,String pwd)=>baseURI+"loginOrRegister?type=$type&account=$account&pwd=$pwd";
  /// 签到
  static String signIn(int id,int goldenBean,String verify)=>baseURI+"signIn?id=$id&goldenBean=$goldenBean&verify=$verify";
  /// 获取私信
  static String getMessages(String verify,int userid)=>baseURI+"getMessages?userid=$userid&verify=$verify";
  /// 标记已读
  static String markRead(int messageId,String verify)=>baseURI+"markRead?messageId=$messageId&verify=$verify";
  /// 建议反馈
  static String feedback(String feedback,String userId,String verify)=>baseURI+"feedback?feedback=$feedback&userId=$userId&verify=$verify";

  static String checkVersion()=>baseURI+"getVersion";
  static String autoUpdate()=>baseURI+"autoUpdate";


}
