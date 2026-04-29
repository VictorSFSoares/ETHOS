import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'ethos_users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profiles(
            email TEXT PRIMARY KEY,
            name TEXT,
            avatar_path TEXT
          )
        ''');
      },
    );
  }

  // Cria um perfil vazio assim que o utilizador se regista
  Future<void> createInitialProfile(String email, String name) async {
    final db = await database;
    await db.insert(
      'profiles',
      {'email': email, 'name': name, 'avatar_path': ''},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Map<String, dynamic>?> getProfile(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> updateProfile(
      String email, String name, String avatarPath) async {
    final db = await database;
    await db.update(
      'profiles',
      {'name': name, 'avatar_path': avatarPath},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}
