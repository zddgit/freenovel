import 'package:freenovel/Global.dart';

class NovelAPI{
  static final String baseURI = "http://47.105.67.114:8080/";
//  static final String baseURI = "Http://192.168.1.194:8080/";
//  static final String baseURI = "Http://172.18.210.1:8080/";

  /// 获取小说目录
  static String getTitles(int novelId,{int limit =0})=>baseURI+"getChapters/$novelId/$limit";
  /// 获取小说具体章节
  static String getNovelDetail(int novelId,int chapterId)=>baseURI+"getNovelDetail/$novelId/$chapterId";
  /// 获取小说信息
  static String getNovel(int novelId)=>baseURI+"getNovel/$novelId";
  /// 获取小说封面
  static String getImage(int novelId)=>baseURI+"getImage/$novelId.jpg";
  /// 推荐小说列表top10
  static String getRecommentNovelsTop10()=>baseURI+"getRecommentNovelsTop10";
  /// 搜索小说通过名字或者作者
  static String getNovelsByNameOrAuthor(String keyword,int page)=>baseURI+"getNovelsByNameOrAuthor?keyword=$keyword&page=$page";
  /// 获取小说所有类别
  static String getTags()=>baseURI+"getDicByType?type=tag";
  /// 根据类别获取小说
  static String getNovelsByTag(int tagId,int page)=>baseURI+"getNovelsByTag?tagId=$tagId&page=$page";


}
class NovelStatus{

  //书架列表（长字符串如1,2） 小说id集合
  static String bookshelfPrefsKey = "bookshelf";
  static String _novelInfo="novelInfo_";
  static String _readStatus = "readStatus_";

  ///单个小说信息(json结构)
  static String getReadStatusPrefsKey(int novelId)=>_readStatus+novelId.toString();
  ///阅读状态(阅读到第几章int)
  static String getNovelInfoPrefsKey(int novelId)=>_novelInfo+novelId.toString();
}