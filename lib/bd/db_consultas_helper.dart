// db_consultas_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'db_helper.dart';

class DBConsultasHelper {
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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS consultas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            paciente TEXT,
            medico TEXT,
            dataHora TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS consultas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              paciente TEXT,
              medico TEXT,
              dataHora TEXT
            )
          ''');
        }
      },
    );
  }

  static Future<void> insertConsulta(String paciente, String medico, String dataHora) async {
    final dbClient = await db;
    await dbClient.insert('consultas', {
      'paciente': paciente,
      'medico': medico,
      'dataHora': dataHora,
    });
  }

  static Future<List<Map<String, dynamic>>> getConsultas() async {
    final dbClient = await db;
    return dbClient.query('consultas');
  }

  static Future<void> deleteConsulta(int id) async {
    final dbClient = await db;
    await dbClient.delete('consultas', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateConsulta(int id, String paciente, String medico, String dataHora) async {
    final dbClient = await DBHelper.db;
    await dbClient.update(
      'consultas',
      {
        'paciente': paciente,
        'medico': medico,
        'dataHora': dataHora,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
