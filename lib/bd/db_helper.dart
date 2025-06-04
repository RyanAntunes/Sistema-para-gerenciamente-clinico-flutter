import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'clinica.db');

    return await openDatabase(
      path,
      version: 4, // ⚠️ aumente sempre que fizer alterações de estrutura
      onCreate: (db, version) async {
        await _criarTabelas(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _criarTabelas(db);
      },
    );
  }

  static Future<void> _criarTabelas(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        especialidade TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS consultas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente TEXT,
        medico TEXT,
        dataHora TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pacientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        telefone TEXT,
        email TEXT
      )
    ''');
  }
}
