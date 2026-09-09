import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/auth_box_helper.dart';

class MessageKeyDBService {
  static final MessageKeyDBService _instance = MessageKeyDBService._internal();
  static Database? _database;

  factory MessageKeyDBService() {
    return _instance;
  }

  MessageKeyDBService._internal();

  // Returns the database instance, initializing it if needed
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initializes the SQLite database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'messagesKey.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Creates the table when the database is first created
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messagesKey(
        user_id VARCHAR(36) NOT NULL,
        key_id INT NOT NULL,
        private_key TEXT NOT NULL,
        init_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
        PRIMARY KEY (user_id, key_id)
      )
    ''');
  }

  // Inserts a new message key pair into the database
  Future<int> insertMessageKey(int keyId, String privateKey) async {
    Database db = await database;
    String userId = AuthBoxHelper.getUserId();

    return await db.insert(
      'messagesKey',
      {'user_id': userId, 'key_id': keyId, 'private_key': privateKey},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieves a specific private key by key ID and user ID
  Future<List<Map<String, dynamic>>> getMessagesPrivateKeyById(int keyId) async {
    Database db = await database;
    String userId = AuthBoxHelper.getUserId();

    return await db.query(
      'messagesKey',
      where: 'user_id = ? AND key_id = ?',
      whereArgs: [userId, keyId],
      orderBy: 'init_timestamp ASC',
    );
  }

  // Retrieves the latest stored message keys for the current user
  Future<List<Map<String, dynamic>>> getLatestMessagesKey() async {
    Database db = await database;
    String userId = AuthBoxHelper.getUserId();

    return await db.query(
      'messagesKey',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'init_timestamp DESC',
    );
  }

  // Deletes a message key entry based on the user ID
  Future<int> deleteMessage(int id) async {
    Database db = await database;
    return await db.delete(
      'messagesKey',
      where: 'user_id = ?',
      whereArgs: [id],
    );
  }
}