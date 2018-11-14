class NovelSqlHelper{
  static String databaseName = "novels";
  static String novelTableDDL = "CREATE TABLE IF NOT EXISTS `novel` (id INTEGER PRIMARY KEY, name TEXT,author TEXT, introduction TEXT, cover TEXT,recentReadTime INTEGER,readChapterId INTEGER)";
  static String chapterTableDDL = "CREATE TABLE IF NOT EXISTS `chapter` (novelId INTEGER,chapterId INTEGER, title TEXT, content TEXT, primary key (novelId,chapterId))";
  static String queryRecentReadNovel = "select id,name,author,introduction,recentReadTime,readChapterId from novel order by recentReadTime desc";
  static String delNovelById = "delete from novel where id = ?";
  static String saveNovel = "insert into novel (id,name,author,introduction,recentReadTime,readChapterId) values (?,?,?,?,?,1)";
  static String updateReadChapterIdByNovelId = "update novel set readChapterId = ? where id = ?";

}