// medicos.dart
import 'package:flutter/material.dart';
import 'bd/db_medicos_helper.dart';
import 'widgets/widgetsInput.dart';
import 'widgets/botoes.dart';
import 'widgets/meutexto.dart';

class MedicosPage extends StatefulWidget {
  const MedicosPage({super.key});

  @override
  State<MedicosPage> createState() => _MedicosPageState();
}

class _MedicosPageState extends State<MedicosPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController especialidadeController = TextEditingController();

  List<Map<String, dynamic>> medicos = [];
  String status = "";

  @override
  void initState() {
    super.initState();
    carregarMedicos();
  }

  void carregarMedicos() async {
    final data = await DBMedicosHelper.getMedicos();
    setState(() {
      medicos = data;
    });
  }

  void cadastrarMedico() async {
    final nome = nomeController.text.trim();
    final esp = especialidadeController.text.trim();

    if (nome.isEmpty || esp.isEmpty) {
      setState(() {
        status = "Preencha todos os campos.";
      });
      return;
    }

    await DBMedicosHelper.insertMedico(nome, esp);

    setState(() {
      status = "Médico cadastrado com sucesso.";
    });

    nomeController.clear();
    especialidadeController.clear();

    carregarMedicos();
  }

  void excluirMedico(int id) async {
    await DBMedicosHelper.deleteMedico(id);
    carregarMedicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Médicos")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            InputTextos("Nome", "Nome do médico", controller: nomeController),
            const SizedBox(height: 16),
            InputTextos("Especialidade", "Ex: Cardiologista", controller: especialidadeController),
            const SizedBox(height: 24),
            Botoes("Cadastrar Médico", onPressed: cadastrarMedico),
            const SizedBox(height: 24),
            if (status.isNotEmpty) MeuTexto(status, Colors.teal, 16),
            const SizedBox(height: 24),
            MeuTexto("Médicos cadastrados:", Colors.black, 18),
            ...medicos.map((medico) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text("Nome: ${medico['nome']}"),
                subtitle: Text("Especialidade: ${medico['especialidade']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => excluirMedico(medico['id']),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
