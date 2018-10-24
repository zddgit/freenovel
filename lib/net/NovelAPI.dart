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

  //书架列表
  static String bookshelfData = "bookshelf";
  //阅读状态
  static String readStatus = "readStatus";





}
