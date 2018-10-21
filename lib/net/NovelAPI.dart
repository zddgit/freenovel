class NovelAPI{
  final String baseURI = "Http://localhost:8080/";

  /// 获取目录
  String getSimpleNovels(int novelId)=>baseURI+"getNovels/simple/$novelId";
  /// 获取具体章节
  String getNovel(int novelId,int chapterId)=>baseURI+"getNovels/$novelId/$chapterId";





}
