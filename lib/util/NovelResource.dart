class NovelAPI{
  static final String baseURI = "Http://192.168.1.194:8080/";

  /// 获取小说目录
  static String getTitles(int novelId)=>baseURI+"getChapters/$novelId";
  /// 获取小说具体章节
  static String getNovelDetail(int novelId,int chapterId)=>baseURI+"getNovelDetail/$novelId/$chapterId";
  /// 获取小说信息
  static String getNovel(int novelId)=>baseURI+"getNovel/$novelId";
  /// 获取小说封面
  static String getImage(int novelId)=>baseURI+"getImage/$novelId.jpg";

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