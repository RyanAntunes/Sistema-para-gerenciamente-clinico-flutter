import 'package:flutter/material.dart';
class SuaImagem extends StatefulWidget {
   final String caminhoArquivo;

   const SuaImagem( {required this.caminhoArquivo});
   //Passando um construtor para state full, obrigatoriamente
   //devemos colocar uma "marcador" (key) e o parametro do
   //construtor
  @override
  _SuaImagemState createState() => _SuaImagemState();
}

class _SuaImagemState extends State<SuaImagem> {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.caminhoArquivo,
      //Pegamos atraves do objeto widget
      filterQuality: FilterQuality.high,
      //Qualidade foto
      fit: BoxFit.cover,
      //Ajusta conforme o tamanho tela
      //height: 130,
      //width: 130,
      scale: 50,
      colorBlendMode: BlendMode.darken,
    );
  }
}
