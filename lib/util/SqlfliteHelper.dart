import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;

class SqfLiteHelper {

  static sqflite.Database db;

  Future<String> _creatDB(String dbName, bool isdel) async {
    var databasesPath = await sqflite.getDatabasesPath();
    String _path = path.join(databasesPath, "$dbName.db");
    if (await new Directory(path.dirname(_path)).exists()) {
      if (isdel) {
        /// db已经存在,删除创建新的
        await sqflite.deleteDatabase(_path);
      } else {
        /// db已经存在
      }
    }
    return _path;
  }



  Future<sqflite.Database> _getDB(String dbName, {bool isdel = false}) async {
    String dbpath = await _creatDB(dbName, isdel);
    db = await sqflite.openDatabase(dbpath);
    return db;
  }

  Future<int> insert(String dbName, String sql, [List args]) async {
    if(db==null){
      db = await _getDB(dbName);
    }
    int id = await db.rawInsert(sql, args);
    return id;
  }

  Future<List<Map<String, dynamic>>> query(String dbName, String sql,
      [List args]) async {
    if(db==null){
      db = await _getDB(dbName);
    }
    List<Map<String, dynamic>> list = await db.rawQuery(sql, args);
    return list;
  }

  Future<int> update(String dbName, String sql, [List args]) async {
    if(db==null){
      db = await _getDB(dbName);
    }
    int i = await db.rawUpdate(sql, args);
    return i;
  }

  Future<int> del(String dbName, String sql, [List args]) async {
    if(db==null){
      db = await _getDB(dbName);
    }
    int i = await db.rawDelete(sql, args);
    return i;
  }
  void dataBaseClose(){
    db.close();
    db = null;
  }

  ddl(String dbName, List<String> sqls, int version) async {
    sqflite.Database db = await _getDB(dbName);
    db.setVersion(version);
    for (String sql in sqls) {
      db.execute(sql);
    }
  }

  delDataBases(String dbName) async {
    String databasesPath = await sqflite.getDatabasesPath();
    String _path = path.join(databasesPath, "$dbName.db");
    if (await new Directory(path.dirname(_path)).exists()) {
      await sqflite.deleteDatabase(_path);
    }
  }
}
