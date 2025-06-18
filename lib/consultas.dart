import 'package:flutter/material.dart';
import 'widgets/widgetsInput.dart';
import 'widgets/botoes.dart';
import 'widgets/meutexto.dart';
import 'bd/db_consultas_helper.dart';
import 'bd/db_pacientes_helper.dart';
import 'bd/db_medicos_helper.dart';


class ConsultasPage extends StatefulWidget {
  const ConsultasPage({super.key});

  @override
  State<ConsultasPage> createState() => _ConsultasPageState();
}

class _ConsultasPageState extends State<ConsultasPage> {
  final TextEditingController pacienteController = TextEditingController();
  final TextEditingController medicoController = TextEditingController();
  final TextEditingController dataHoraController = TextEditingController();

  List<Map<String, dynamic>> consultas = [];
  String status = "";

  @override
  void initState() {
    super.initState();
    carregarConsultas();
  }

  void carregarConsultas() async {
    final data = await DBConsultasHelper.getConsultas();
    setState(() {
      consultas = data;
    });
  }

  void agendarConsulta() async {
    final paciente = pacienteController.text.trim();
    final medico = medicoController.text.trim();
    final dataHora = dataHoraController.text.trim();

    if (paciente.isEmpty || medico.isEmpty || dataHora.isEmpty) {
      setState(() {
        status = "Preencha todos os campos.";
      });
      return;
    }

    // Validação se médico e paciente existem
    final pacientes = await DBPacientesHelper.getPacientes();
    final medicos = await DBMedicosHelper.getMedicos();

    final pacienteExiste = pacientes.any((p) => p['nome'].toLowerCase() == paciente.toLowerCase());
    final medicoExiste = medicos.any((m) => m['nome'].toLowerCase() == medico.toLowerCase());

    if (!pacienteExiste) {
      setState(() {
        status = "Paciente não encontrado.";
      });
      return;
    }

    if (!medicoExiste) {
      setState(() {
        status = "Médico não encontrado.";
      });
      return;
    }

    await DBConsultasHelper.insertConsulta(paciente, medico, dataHora);

    setState(() {
      status = "Consulta agendada com sucesso.";
    });

    pacienteController.clear();
    medicoController.clear();
    dataHoraController.clear();

    carregarConsultas();
  }

  void excluirConsulta(int id) async {
    await DBConsultasHelper.deleteConsulta(id);
    carregarConsultas();
  }

  Future<void> selecionarDataHora() async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (data != null) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (hora != null) {
        final dtFormatada = "${data.day.toString().padLeft(2, '0')}/"
            "${data.month.toString().padLeft(2, '0')}/"
            "${data.year} às "
            "${hora.hour.toString().padLeft(2, '0')}:"
            "${hora.minute.toString().padLeft(2, '0')}";

        setState(() {
          dataHoraController.text = dtFormatada;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agendamento de Consultas")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            InputTextos("Paciente", "Nome do paciente", controller: pacienteController),
            const SizedBox(height: 16),
            InputTextos("Médico", "Nome do médico", controller: medicoController),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: selecionarDataHora,
              child: AbsorbPointer(
                child: TextField(
                  controller: dataHoraController,
                  decoration: const InputDecoration(
                    labelText: "Data e Hora",
                    hintText: "Toque para escolher",
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Botoes("Agendar Consulta", onPressed: agendarConsulta),
            const SizedBox(height: 24),
            if (status.isNotEmpty) MeuTexto(status, Colors.teal, 16),
            const SizedBox(height: 24),
            MeuTexto("Consultas agendadas:", Colors.black, 18),
            const SizedBox(height: 12),
            ...consultas.map((consulta) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text("Paciente: ${consulta['paciente']}"),
                subtitle: Text("Médico: ${consulta['medico']}\nData/Hora: ${consulta['dataHora']}"),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => excluirConsulta(consulta['id']),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
