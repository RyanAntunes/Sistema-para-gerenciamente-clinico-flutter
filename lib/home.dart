
import 'package:flutter/material.dart';
import 'pacientes.dart';
import 'medicos.dart';
import 'consultas.dart';
import 'pagina_consulta.dart';
import 'widgets/botoes.dart';
import 'widgets/meutexto.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clínica Médica")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MeuTexto("Bem-vindo à Clínica Médica", Colors.teal, 20),
              const SizedBox(height: 40),
              Botoes("Gerenciar Pacientes", onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PacientesPage()));
              }),
              const SizedBox(height: 20),
              Botoes("Gerenciar Médicos", onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicosPage()));
              }),
              const SizedBox(height: 20),
              Botoes("Agendar Consultas", onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultasPage()));
              }),
              const SizedBox(height: 20),
              Botoes("Consultar Registros", onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PaginaConsulta()));
              }),
            ],
          ),
        ),
      ),
    );
  }
}
