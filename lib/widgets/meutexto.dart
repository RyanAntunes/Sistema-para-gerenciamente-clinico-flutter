import 'package:flutter/material.dart';
class MeuTexto extends StatelessWidget {
  String texto="";
  double tamanhoFonte=12;
  Color cor=Colors.cyan ;
  MeuTexto(this.texto,  this.cor, this.tamanhoFonte,);


  @override

  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
          backgroundColor: cor,
          fontSize: tamanhoFonte,
          color: Colors.lightGreen
      ),
    );
    ;
  }
}
