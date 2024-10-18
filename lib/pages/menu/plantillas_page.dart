import 'package:flutter/material.dart';

class PlantillasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plantillas de Se Busca'),
        backgroundColor: Colors.green[200],
      ),
      body: Center(
        child: Text('Aquí van las plantillas de Se Busca'),
        // Aquí puedes implementar la lógica para mostrar o descargar las plantillas
      ),
    );
  }
}
