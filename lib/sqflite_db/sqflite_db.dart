import 'dart:io';

import 'package:nurebo/sqflite_db/model/note.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDB {
  static final SqfliteDB instance = SqfliteDB._init();
  static Database? _database;

  SqfliteDB._init();

  Future<Database?> get database async {
    // if (_database == null)
    //   _database = await initDB('kadingira.db');
    _database ??= await initDB('kadingira.db');

    return _database;
  }

  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // Directory directory = await getApplicationDocumentsDirectory();
    // String path = 'todos.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await createTableNotes(db, version);
        await createTableDateNotification(db, version);
        await createTableNotification(db, version);
        await createTableAppointmentNotification(db, version);
        await createTableFriendshipNotification(db, version);
      }
    );
  }

  Future createTableNotes(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    try{
      await db.execute(
          '''CREATE TABLE $tableNotes ( 
              ${NoteFields.id} $idType, 
              ${NoteFields.isImportant} $boolType,
              ${NoteFields.number} $integerType,
              ${NoteFields.title} $textType,
              ${NoteFields.description} $textType,
              ${NoteFields.time} $textType
            )'''
      );
    } on Exception catch (e) {
      // //print(e);
      return null;
    }
  }

  Future createTableNotes1(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    // try{
      await db.execute(
          '''CREATE TABLE $tableNotes ( 
              ${NoteFields.id} $idType, 
              ${NoteFields.isImportant} $boolType,
              ${NoteFields.number} $integerType,
              ${NoteFields.time} $textType
            )'''
      );
    // } on Exception catch (e) {
    //   //print(e);
    //   return null;
    // }
  }

  // Future createTableNotification(Database db, int version) async {
  //   await db.execute(
  //   '''CREATE TABLE notification (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       type INT(3) NOT NULL,
  //       user_id VARCHAR(36) NOT NULL,
  //       single_event_id VARCHAR(36),
  //       single_event_begin_at TEXT,
  //       booking_id VARCHAR(36),
  //       booking_begin_at TEXT
  //     )'''
  //   );
  // }

  Future createTableDateNotification(Database db, int version) async {
    await db.execute(
        '''CREATE TABLE booking_notification (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id VARCHAR(36),
        prestazione_id VARCHAR(36) NOT NULL,
        sender_id VARCHAR(36) NOT NULL,
        sent_at TEXT,
        sender_username TEXT,
        sender_name TEXT,
        business_name TEXT,
        prestazione_title TEXT,
        prestazione_image TEXT,
        price DOUBLE
      )'''
    );
  }


  Future createTableNotification(Database db, int version) async {
    //item_category_id può essere un ID di una prestazione o di un event
    //item_id può essere un ID di un booking o di un ticket
    //type può essere un codice per stabilire il tipo di notifica (se social o di un acquisto
    // o cancellazione e chi la invia e se è in tiket o un booking oppure un evento o una prestazione)
    await db.execute(
      '''CREATE TABLE notification (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER,
        sender_id VARCHAR(36) NOT NULL,
        sender_name TEXT,
        receiver_id VARCHAR(36) NOT NULL,
        receiver_name TEXT,
        item_category_id TEXT,
        item_id VARCHAR(36),
        item_price DOUBLE,
        item_begin_at TEXT,
        item_title TEXT,
        item_image TEXT,
        created_at TEXT
      )'''
    );

    // await db.execute(
    //     '''CREATE TABLE notification (
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     type INTEGER,
    //     senderId VARCHAR(36) NOT NULL,
    //     senderName TEXT,
    //     receiverId VARCHAR(36) NOT NULL,
    //     receiverName TEXT,
    //     itemCategoryId TEXT,
    //     itemId VARCHAR(36),
    //     itemPrice DOUBLE,
    //     itemBeginAt TEXT,
    //     itemTitle TEXT,
    //     itemImage TEXT,
    //     createdAt TEXT
    //   )'''
    // );
  }

  Future createTableAppointmentNotification(Database db, int version) async {
    await db.execute(
        '''CREATE TABLE appointment_notification (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          booking_id VARCHAR(36),
          booking_price DOUBLE,
          booking_begin_at TEXT,
          is_canceled INTEGER,
          user_id VARCHAR(36) NOT NULL,
          business_id VARCHAR(36) NOT NULL,
          business_name TEXT,
          prestazione_id VARCHAR(36) NOT NULL,
          prestazione_title TEXT,
          prestazione_image TEXT,
          sent_at TEXT
        )'''
    );
  }

  Future createTableFriendshipNotification(Database db, int version) async {
    await db.execute(
        '''CREATE TABLE friendship_notification (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          status INTEGER,
          user_id VARCHAR(36) NOT NULL,
          recipient_id VARCHAR(36) NOT NULL,
          user_name TEXT,
          user_username TEXT,
          user_image TEXT,
          status_at TEXT,
          sent_at TEXT
        )'''
    );
  }

  Future rawInsert(String table, List arguments) async {
    final db = (await instance.database)!;

    final result = await db.rawInsert(
      table,
      arguments
    );
    return result;
  }

  Future dropTable(String table) async {
    final db = (await instance.database)!;
    // try{
      await db.execute(
        "DROP TABLE IF EXISTS $table",
      );
    // } on Exception catch (e) {
    //   //print(e);
    //   return null;
    // }
  }

  Future insert(String table, Map values) async {
    final db = (await instance.database)!;

    // Map<String, dynamic> values = {
    //   DatabaseHelper.columnName : 'Bob',
    //   DatabaseHelper.columnAge  : 23
    // };
    // try{
      final result = await db.insert(
          table,
          values as Map<String, Object?>
      );
      return result;
    // } on Exception catch (e) {
    //   //print(e);
    //   return null;
    // }
  }

  Future query(String table, {String? where, List? whereArgs, String? orderBy}) async {
    final db = (await instance.database)!;

    // try{
      final result = await db.query(
        table,
        // columns: ,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy
      );
      // return result;
      // return result.map((json) => Note.fromJson(json)).toList();
      return result./*map((json) => {
        '_id': json[NoteFields.id] as int,
        'isImportant': json[NoteFields.isImportant] == 1,
        'number': json[NoteFields.number] as int,
        'title': json[NoteFields.title] as String,
        'description': json[NoteFields.description] as String,
        'createdTime': DateTime.parse(json[NoteFields.time] as String),
      }).*/toList();
    // } on Exception catch (e) {
    //   //print(e);
    //   return null;
    // }
  }

  Future rawQuery(String query, List whereArgs) async {
    final db = (await instance.database)!;

    final result = await db.rawQuery(
        query,
        whereArgs,
    );
    return result;
  }

  Future<int> delete(String table, {String? where, List? whereArgs}) async {
    final db = (await instance.database)!;

    // try {
      final result = await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      return result;
    // } on Exception catch (e) {
    //   //print(e);
    //   return null;
    // }
  }

  Future close() async {
    final db = (await instance.database)!;
    db.close();
  }

}
