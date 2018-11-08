import 'dart:io';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path;

class SqfLiteHelper {
  Future<String> _creatDB(String dbName, bool isdel) async {
    var databasesPath = await sqflite.getDatabasesPath();
    String _path = path.join(databasesPath, "$dbName.db");
    if (await new Directory(path.dirname(_path)).exists()) {
      print("$_path");
      if (isdel) {
        print("$dbName.db已经存在,删除创建新的");
        await sqflite.deleteDatabase(_path);
      } else {
        print("$dbName.db已经存在");
      }
    }
    return _path;
  }

  Future<sqflite.Database> _getDB(String dbName, {bool isdel = false}) async {
    String dbpath = await _creatDB(dbName, isdel);
    sqflite.Database db = await sqflite.openDatabase(dbpath);
    return db;
  }

  Future<int> insert(String dbName, String sql, [List args]) async {
    sqflite.Database db = await _getDB(dbName);
    int id = await db.rawInsert(sql, args);
    await db.close();
    return id;
  }

  Future<List<Map<String, dynamic>>> query(String dbName, String sql,
      [List args]) async {
    sqflite.Database db = await _getDB(dbName);
    List<Map<String, dynamic>> list = await db.rawQuery(sql, args);
    await db.close();
    return list;
  }

  Future<int> update(String dbName, String sql, [List args]) async {
    sqflite.Database db = await _getDB(dbName);
    int i = await db.rawUpdate(sql, args);
    await db.close();
    return i;
  }

  Future<int> del(String dbName, String sql, [List args]) async {
    sqflite.Database db = await _getDB(dbName);
    int i = await db.rawDelete(sql, args);
    await db.close();
    return i;
  }

  ddl(String dbName, List<String> sqls, int version) async {
    sqflite.Database db = await _getDB(dbName);
    db.setVersion(version);
    for (String sql in sqls) {
      await db.execute(sql);
    }
    await db.close();
  }

  delDataBases(String dbName) async {
    String databasesPath = await sqflite.getDatabasesPath();
    String _path = path.join(databasesPath, "$dbName.db");
    if (await new Directory(path.dirname(_path)).exists()) {
      await sqflite.deleteDatabase(_path);
    }
  }
}
