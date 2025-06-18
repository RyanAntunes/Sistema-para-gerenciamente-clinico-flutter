import 'package:flutter/material.dart';
import 'widgets/widgetsInput.dart';
import 'widgets/botoes.dart';
import 'widgets/meutexto.dart';
import 'bd/db_pacientes_helper.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  List<Map<String, dynamic>> pacientes = [];
  String status = "";

  @override
  void initState() {
    super.initState();
    carregarPacientes();
  }

  void carregarPacientes() async {
    final data = await DBPacientesHelper.getPacientes();
    setState(() {
      pacientes = data;
    });
  }

  void cadastrarPaciente() async {
    final nome = nomeController.text.trim();
    final telefone = telefoneController.text.trim();
    final email = emailController.text.trim();

    if (nome.isEmpty || telefone.isEmpty || email.isEmpty) {
      setState(() {
        status = "Preencha todos os campos.";
      });
      return;
    }

    try {
      await DBPacientesHelper.insertPaciente(nome, telefone, email);
      setState(() {
        status = "Paciente cadastrado com sucesso.";
      });

      nomeController.clear();
      telefoneController.clear();
      emailController.clear();

      carregarPacientes();
    } catch (e) {
      setState(() {
        status = "Erro ao salvar paciente: $e";
      });
    }
  }

  void excluirPaciente(int id) async {
    await DBPacientesHelper.deletePaciente(id);
    carregarPacientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Pacientes")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            InputTextos("Nome", "Digite o nome completo", controller: nomeController),
            const SizedBox(height: 16),
            InputTextos("Telefone", "Digite o telefone com DDD", controller: telefoneController),
            const SizedBox(height: 16),
            InputTextos("Email", "Digite o email", controller: emailController),
            const SizedBox(height: 24),
            Botoes("Cadastrar Paciente", onPressed: cadastrarPaciente),
            const SizedBox(height: 24),
            if (status.isNotEmpty) MeuTexto(status, Colors.teal, 16),
            const SizedBox(height: 24),
            MeuTexto("Pacientes cadastrados:", Colors.black, 18),
            const SizedBox(height: 12),
            ...pacientes.map((paciente) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(paciente['nome']),
                subtitle: Text("Tel: ${paciente['telefone']} | Email: ${paciente['email']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => excluirPaciente(paciente['id']),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
