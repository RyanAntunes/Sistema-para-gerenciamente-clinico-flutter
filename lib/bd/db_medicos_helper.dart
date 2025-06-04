import 'db_helper.dart';

class DBMedicosHelper {
  static Future<void> insertMedico(String nome, String especialidade) async {
    final dbClient = await DBHelper.db;
    await dbClient.insert('medicos', {
      'nome': nome,
      'especialidade': especialidade,
    });
  }

  static Future<List<Map<String, dynamic>>> getMedicos() async {
    final dbClient = await DBHelper.db;
    return dbClient.query('medicos');
  }

  static Future<void> deleteMedico(int id) async {
    final dbClient = await DBHelper.db;
    await dbClient.delete('medicos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateMedico(int id, String nome, String especialidade) async {
    final dbClient = await DBHelper.db;
    await dbClient.update(
      'medicos',
      {'nome': nome, 'especialidade': especialidade},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
