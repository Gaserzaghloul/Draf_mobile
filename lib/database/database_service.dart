import 'dart:math';
import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/connected_device.dart';
import '../models/message.dart';
import '../models/resource.dart';
import '../models/activity.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName =
      'beacon_encrypted.db'; // Changed to new encrypted file
  static const int _databaseVersion = 4;
  static const _secureStorage = FlutterSecureStorage();

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    // Get or generate encryption key
    String? encryptionKey = await _secureStorage.read(key: 'db_key');
    if (encryptionKey == null) {
      // Generate a random 32-char key (approx 256 bits entropy)
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(255));
      encryptionKey = base64UrlEncode(values);
      await _secureStorage.write(key: 'db_key', value: encryptionKey);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      password: encryptionKey, // Enable Encryption
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Migration from version 1 to version 4
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Add new columns to users table
      await db.execute('ALTER TABLE users ADD COLUMN sex TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN address TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN emergency_phone1 TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN emergency_phone2 TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN blood_type TEXT');
    }
    if (oldVersion < 3) {
      // Add isProfileComplete column and default existing users to true
      await db.execute(
        'ALTER TABLE users ADD COLUMN isProfileComplete INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (oldVersion < 4) {
      // Add senderName column to messages table
      await db.execute('ALTER TABLE messages ADD COLUMN senderName TEXT');
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        profileImage TEXT,
        sex TEXT,
        address TEXT,
        emergency_phone1 TEXT,
        emergency_phone2 TEXT,
        blood_type TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        isProfileComplete INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create ConnectedDevices table
    await db.execute('''
      CREATE TABLE connected_devices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        deviceId TEXT NOT NULL UNIQUE,
        ipAddress TEXT,
        signalStrength INTEGER NOT NULL,
        lastSeen TEXT NOT NULL,
        isConnected INTEGER NOT NULL DEFAULT 0,
        deviceType TEXT
      )
    ''');

    // Create Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        filePath TEXT,
        fileName TEXT,
        fileSize INTEGER,
        isRead INTEGER NOT NULL DEFAULT 0,
        senderName TEXT,
        FOREIGN KEY (senderId) REFERENCES users (id),
        FOREIGN KEY (receiverId) REFERENCES users (id)
      )
    ''');

    // Create Resources table
    await db.execute('''
      CREATE TABLE resources (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileName TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        ownerId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'available',
        checksum TEXT,
        FOREIGN KEY (ownerId) REFERENCES users (id)
      )
    ''');

    // Create Activities table
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        metadata TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_messages_sender ON messages(senderId)');
    await db.execute(
      'CREATE INDEX idx_messages_receiver ON messages(receiverId)',
    );
    await db.execute(
      'CREATE INDEX idx_messages_timestamp ON messages(timestamp)',
    );
    await db.execute('CREATE INDEX idx_activities_user ON activities(userId)');
    await db.execute(
      'CREATE INDEX idx_activities_timestamp ON activities(timestamp)',
    );
  }

  // User operations
  static Future<String> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap());
    return user.id;
  }

  static Future<User?> getUser(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  static Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ConnectedDevice operations
  static Future<String> insertConnectedDevice(ConnectedDevice device) async {
    final db = await database;
    await db.insert('connected_devices', device.toMap());
    return device.id;
  }

  static Future<List<ConnectedDevice>> getAllConnectedDevices() async {
    final db = await database;
    final maps = await db.query('connected_devices');
    return maps.map((map) => ConnectedDevice.fromMap(map)).toList();
  }

  static Future<int> updateConnectedDevice(ConnectedDevice device) async {
    final db = await database;
    return await db.update(
      'connected_devices',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  static Future<int> deleteConnectedDevice(String id) async {
    final db = await database;
    return await db.delete(
      'connected_devices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Message operations
  static Future<String> insertMessage(Message message) async {
    final db = await database;
    await db.insert('messages', message.toMap());
    return message.id;
  }

  static Future<List<Message>> getMessagesBetweenUsers(
    String userId1,
    String userId2,
  ) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where:
          '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'timestamp ASC',
    );
    return maps.map((map) => Message.fromMap(map)).toList();
  }

  static Future<List<Message>> getAllMessages() async {
    final db = await database;
    final maps = await db.query('messages', orderBy: 'timestamp DESC');
    return maps.map((map) => Message.fromMap(map)).toList();
  }

  static Future<int> updateMessage(Message message) async {
    final db = await database;
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }
}
