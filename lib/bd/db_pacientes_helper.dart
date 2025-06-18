import 'db_helper.dart';

class DBPacientesHelper {
  static Future<void> insertPaciente(String nome, String telefone, String email) async {
    final dbClient = await DBHelper.db;
    await dbClient.insert('pacientes', {
      'nome': nome,
      'telefone': telefone,
      'email': email,
    });
  }

  static Future<List<Map<String, dynamic>>> getPacientes() async {
    final dbClient = await DBHelper.db;
    return dbClient.query('pacientes');
  }

  static Future<void> deletePaciente(int id) async {
    final dbClient = await DBHelper.db;
    await dbClient.delete('pacientes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updatePaciente(int id, String nome, String telefone, String email) async {
    final dbClient = await DBHelper.db;
    await dbClient.update(
      'pacientes',
      {'nome': nome, 'telefone': telefone, 'email': email},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  static Future<Map<String, dynamic>?> buscarPacientePorNome(String nome) async {
    final dbClient = await DBHelper.db;
    final resultado = await dbClient.query(
      'pacientes',
      where: 'nome = ?',
      whereArgs: [nome],
      limit: 1,
    );
    if (resultado.isNotEmpty) {
      return resultado.first;
    }
    return null;
  }

}
