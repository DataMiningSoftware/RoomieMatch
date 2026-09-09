import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ChatDBService {
  static final ChatDBService _instance = ChatDBService._internal();
  static Database? _database;

  factory ChatDBService() {
    return _instance;
  }

  ChatDBService._internal();

  /// Getter to lazily initialize and return the database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database file and opens it.
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'chat.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Creates the 'chat' table when the database is first created.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat(
        user_id VARCHAR(36) NOT NULL,
        chat_user_id VARCHAR(36) NOT NULL,
        first_name VARCHAR(100),
        latest_time LONGINT NOT NULL,
        PRIMARY KEY (user_id, chat_user_id)
      )
    ''');
  }

  /// Inserts a new chat relationship into the database.
  Future<int> insertChat(String userId, String chatUserid, String firstName, int latestTime) async {
    Database db = await database;
    return await db.insert(
      'chat',
      {'user_id': userId, 'chat_user_id': chatUserid, 'first_name': firstName, 'latest_time': latestTime},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all chats associated with a specific user ID, ordered by latest time.
  Future<List<Map<String, dynamic>>> getChatsByUserId(String userId) async {
    Database db = await database;
    return await db.query(
      'chat',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'latest_time DESC',
    );
  }

  // // Delete a message by ID
  // Future<int> deleteMessage(int id) async {
  //   Database db = await database;
  //   return await db.delete(
  //     'messages',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }
}