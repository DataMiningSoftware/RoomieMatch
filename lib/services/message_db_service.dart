import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class MessageDBService {
  static final MessageDBService _instance = MessageDBService._internal();
  static Database? _database;

  factory MessageDBService() {
    return _instance;
  }

  MessageDBService._internal();

  // Returns the database instance, initializing it if needed
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initializes the SQLite database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'messages.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Creates the messages table when the database is first created
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages(
        sender_user_id VARCHAR(36) NOT NULL,
        recipient_user_id VARCHAR(36) NOT NULL,
        plain_text TEXT NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
        PRIMARY KEY (sender_user_id, recipient_user_id, timestamp)
      )
    ''');
  }

  // Inserts a new message into the database
  Future<int> insertMessage(String senderUserId, String recipientUserId, String plainText, String timestamp) async {
    Database db = await database;
    return await db.insert(
      'messages',
      {'sender_user_id': senderUserId, 'recipient_user_id': recipientUserId, 'plain_text': plainText, 'timestamp': timestamp},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieves all messages between two users (both directions)
  Future<List<Map<String, dynamic>>> getMessagesByUserId(String currUserId, String chatUserId) async {
    Database db = await database;
    return await db.query(
      'messages',
      where: '(sender_user_id = ? AND recipient_user_id = ?) OR (sender_user_id = ? AND recipient_user_id = ?)',
      whereArgs: [currUserId, chatUserId, chatUserId, currUserId],
      orderBy: 'timestamp ASC',
    );
  }

  // Deletes a message by ID (Note: This assumes there's an `id` column in the table, which is not defined in your schema)
  Future<int> deleteMessage(int id) async {
    Database db = await database;
    return await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}