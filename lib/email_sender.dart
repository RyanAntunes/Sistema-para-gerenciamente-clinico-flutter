import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailSender {
  static Future<bool> enviarEmail({
    required String nomePaciente,
    required String emailDestino,
    required String dataHora,
  }) async {
    const serviceId = 'service_dy1sxza';
    const templateId = 'template_ks0zks3';
    const publicKey = 'SONHaSa4AbwGuq9pV';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'user_name': nomePaciente,
          'user_email': emailDestino,
          'data_consulta': dataHora,
        }
      }),
    );

    return response.statusCode == 200;
  }
}
