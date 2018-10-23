class NovelAPI{
  final String baseURI = "Http://192.168.1.194:8080/";

  /// 获取小说目录
  String getSimpleNovels(int novelId)=>baseURI+"getChapters/$novelId";
  /// 获取小说具体章节
  String getNovelDetail(int novelId,int chapterId)=>baseURI+"getNovelDetail/$novelId/$chapterId";
  /// 获取小说信息
  String getNovel(int novelId)=>baseURI+"getNovel/$novelId";
  /// 获取小说封面
  String getImage(int novelId)=>baseURI+"getImage/$novelId.jpg";





}
