import 'package:flutter/material.dart';
import 'bd/db_medicos_helper.dart';
import 'bd/db_consultas_helper.dart';
import 'bd/db_pacientes_helper.dart';
import 'widgets/widgetsInput.dart';
import 'widgets/botoes.dart';
import 'widgets/meutexto.dart';

class TelaEdicao extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> dados;
  final VoidCallback onAtualizado;

  const TelaEdicao({
    super.key,
    required this.tipo,
    required this.dados,
    required this.onAtualizado,
  });

  @override
  State<TelaEdicao> createState() => _TelaEdicaoState();
}

class _TelaEdicaoState extends State<TelaEdicao> {
  final TextEditingController campo1 = TextEditingController();
  final TextEditingController campo2 = TextEditingController();
  final TextEditingController campo3 = TextEditingController();

  String status = "";

  @override
  void initState() {
    super.initState();

    // Pré-carrega os valores com base no tipo
    if (widget.tipo == "paciente") {
      campo1.text = widget.dados['nome'];
      campo2.text = widget.dados['telefone'];
      campo3.text = widget.dados['email'];
    } else if (widget.tipo == "medico") {
      campo1.text = widget.dados['nome'];
      campo2.text = widget.dados['especialidade'];
    } else if (widget.tipo == "consulta") {
      campo1.text = widget.dados['paciente'];
      campo2.text = widget.dados['medico'];
      campo3.text = widget.dados['dataHora'];
    }
  }

  Future<void> salvar() async {
    final id = widget.dados['id'];

    if (widget.tipo == "paciente") {
      await DBPacientesHelper.updatePaciente(id, campo1.text, campo2.text, campo3.text);
    } else if (widget.tipo == "medico") {
      await DBMedicosHelper.updateMedico(id, campo1.text, campo2.text);
    } else if (widget.tipo == "consulta") {
      await DBConsultasHelper.updateConsulta(id, campo1.text, campo2.text, campo3.text);
    }

    setState(() {
      status = "Atualizado com sucesso!";
    });

    widget.onAtualizado();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String titulo;
    List<Widget> campos = [];

    if (widget.tipo == "paciente") {
      titulo = "Editar Paciente";
      campos = [
        InputTextos("Nome", "", controller: campo1),
        const SizedBox(height: 16),
        InputTextos("Telefone", "", controller: campo2),
        const SizedBox(height: 16),
        InputTextos("Email", "", controller: campo3),
      ];
    } else if (widget.tipo == "medico") {
      titulo = "Editar Médico";
      campos = [
        InputTextos("Nome", "", controller: campo1),
        const SizedBox(height: 16),
        InputTextos("Especialidade", "", controller: campo2),
      ];
    } else {
      titulo = "Editar Consulta";
      campos = [
        InputTextos("Paciente", "", controller: campo1),
        const SizedBox(height: 16),
        InputTextos("Médico", "", controller: campo2),
        const SizedBox(height: 16),
        InputTextos("Data/Hora", "", controller: campo3),
      ];
    }

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ...campos,
            const SizedBox(height: 24),
            Botoes("Salvar Alterações", onPressed: salvar),
            if (status.isNotEmpty) ...[
              const SizedBox(height: 24),
              MeuTexto(status, Colors.green, 16),
            ]
          ],
        ),
      ),
    );
  }
}
