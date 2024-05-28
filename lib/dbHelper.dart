import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mynotes/Models/NoteModel.dart';

class DatabaseConnectionHandler {
  static Database? database;
  static const String tablename = 'notes';

  Future<Database> get DB async {
    if (database != null) return database!;
    database = await _initializingDatabase();
    return database!;
  }

  Future<Database> _initializingDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'app.db');
    final response = await openDatabase(databasePath, version: 1,
        onCreate: (db, version) async {
      await db.execute(
          '''CREATE TABLE $tablename(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
          noteName Text, 
          noteDescription Text)''');
    });
    return response;
  }

  Future<int> insertData(NoteModel data) async {
    final db = await DB;
    var Data = {
      'noteName': data.noteName,
      'noteDescription': data.noteDescription
    };
    var query = db.insert(tablename, Data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return query;
  }

  Future<List<NoteModel>> getData() async {
    final db = await DB;
    var query = await db.query(tablename, orderBy: "id");
    List<NoteModel> notes = [];
    
    query.forEach((value) {
      notes.add(NoteModel(
          id: value['id'] as int,
          noteName: value['noteName'] as String,
          noteDescription: value['noteDescription'] as String));
    });
    return notes;
  }

  Future<int> deleteData(int id) async {
    final db = await DB;
    var query = db.delete(tablename, where: "id = ?", whereArgs: [id]);
    return query;
  }

  Future<int> updateData(NoteModel data) async {
    final db = await DB;
    var Data = {
      'id': data.id,
      'noteName': data.noteName,
      'noteDescription': data.noteDescription
    };
    var query =
        db.update(tablename, Data, where: "id = ?", whereArgs: [data.id]);
    return query;
  }
}
