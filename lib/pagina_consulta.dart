import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'widgets/botoes.dart';
import 'widgets/meutexto.dart';
import 'bd/db_medicos_helper.dart';
import 'bd/db_consultas_helper.dart';
import 'bd/db_pacientes_helper.dart';

class PaginaConsulta extends StatefulWidget {
  const PaginaConsulta({super.key});

  @override
  State<PaginaConsulta> createState() => _PaginaConsultaState();
}

class _PaginaConsultaState extends State<PaginaConsulta> {
  String tipoSelecionado = "";
  List<Map<String, dynamic>> dados = [];

  void carregarDados(String tipo) async {
    List<Map<String, dynamic>> resultado = [];

    if (tipo == "paciente") {
      resultado = await DBPacientesHelper.getPacientes();
    } else if (tipo == "medico") {
      resultado = await DBMedicosHelper.getMedicos();
    } else if (tipo == "consulta") {
      resultado = await DBConsultasHelper.getConsultas();
    }

    setState(() {
      tipoSelecionado = tipo;
      dados = resultado;
    });
  }

  String formatarDados(Map<String, dynamic> item) {
    if (tipoSelecionado == "paciente") {
      return "Nome: ${item['nome']}\nTelefone: ${item['telefone']}\nEmail: ${item['email']}";
    } else if (tipoSelecionado == "medico") {
      return "Nome: ${item['nome']}\nEspecialidade: ${item['especialidade']}";
    } else if (tipoSelecionado == "consulta") {
      return "Paciente: ${item['paciente']}\nMédico: ${item['medico']}\nData/Hora: ${item['dataHora']}";
    } else {
      return "";
    }
  }

  void exibirDialogoEdicao(BuildContext context, String tipo, Map<String, dynamic> item) {
    final campo1 = TextEditingController();
    final campo2 = TextEditingController();
    final campo3 = TextEditingController();

    if (tipo == "paciente") {
      campo1.text = item['nome'];
      campo2.text = item['telefone'];
      campo3.text = item['email'];
    } else if (tipo == "medico") {
      campo1.text = item['nome'];
      campo2.text = item['especialidade'];
    } else if (tipo == "consulta") {
      campo1.text = item['paciente'];
      campo2.text = item['medico'];
      campo3.text = item['dataHora'];
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Editar ${tipo[0].toUpperCase()}${tipo.substring(1)}"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: campo1, decoration: const InputDecoration(labelText: "Campo 1")),
              const SizedBox(height: 8),
              TextField(controller: campo2, decoration: const InputDecoration(labelText: "Campo 2")),
              if (tipo != "medico") ...[
                const SizedBox(height: 8),
                TextField(controller: campo3, decoration: const InputDecoration(labelText: "Campo 3")),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = item['id'];

              if (tipo == "paciente") {
                await DBPacientesHelper.updatePaciente(id, campo1.text, campo2.text, campo3.text);
              } else if (tipo == "medico") {
                await DBMedicosHelper.updateMedico(id, campo1.text, campo2.text);
              } else if (tipo == "consulta") {
                await DBConsultasHelper.updateConsulta(id, campo1.text, campo2.text, campo3.text);
              }

              carregarDados(tipo);
              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Future<void> enviarMensagemWhatsapp(Map<String, dynamic> consulta) async {
    final pacienteNome = consulta['paciente'];
    final dataHora = consulta['dataHora'];

    final paciente = await DBPacientesHelper.buscarPacientePorNome(pacienteNome);
    if (paciente == null || paciente['telefone'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefone do paciente não encontrado')),
      );
      return;
    }

    String telefone = paciente['telefone'].replaceAll(RegExp(r'[^0-9]'), '');
    if (telefone.startsWith('0')) {
      telefone = telefone.substring(1);
    }

    final texto = Uri.encodeComponent(
      "Olá ${paciente['nome']}, tudo bem? 😊\n"
          "Aqui é da clínica. Passando para lembrar que sua consulta está agendada para:\n"
          "📓 *$dataHora*\n\n"
          "Qualquer dúvida, estamos à disposição!",
    );

    final url = Uri.parse("https://api.whatsapp.com/send?phone=55$telefone&text=$texto");

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir WhatsApp: $e')),
      );
    }
  }

  Future<void> enviarEmailConsulta(Map<String, dynamic> consulta) async {
    final pacienteNome = consulta['paciente'];
    final dataHora = consulta['dataHora'];
    final medico = consulta['medico'];

    final paciente = await DBPacientesHelper.buscarPacientePorNome(pacienteNome);
    if (paciente == null || paciente['email'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email do paciente não encontrado')),
      );
      return;
    }

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
          'to_name': paciente['nome'],
          'email': paciente['email'],
          'dataHora': dataHora,
          'medico': medico,
        },
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email enviado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Consulta de Dados")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            MeuTexto("Escolha o que deseja visualizar:", Colors.black, 18),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Botoes("Pacientes", onPressed: () => carregarDados("paciente")),
                Botoes("Médicos", onPressed: () => carregarDados("medico")),
                Botoes("Consultas", onPressed: () => carregarDados("consulta")),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: dados.isEmpty
                  ? MeuTexto("Nenhum dado encontrado.", Colors.grey, 16)
                  : ListView.builder(
                itemCount: dados.length,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(formatarDados(dados[index])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.teal),
                          onPressed: () => exibirDialogoEdicao(context, tipoSelecionado, dados[index]),
                        ),
                        if (tipoSelecionado == "consulta") ...[
                          IconButton(
                            icon: const Icon(Icons.email, color: Colors.blue),
                            onPressed: () => enviarEmailConsulta(dados[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.message, color: Colors.green),
                            onPressed: () => enviarMensagemWhatsapp(dados[index]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
