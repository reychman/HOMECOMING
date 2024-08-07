import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/mascota.dart';

class InfoMascotasPage extends StatelessWidget {
  final Mascota mascota;

  InfoMascotasPage({required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mascota.nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mascota.foto.isNotEmpty)
              Image.network(mascota.foto, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(
              mascota.nombre,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${mascota.especie} - ${mascota.raza}',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 8),
            Text(
              'Sexo: ${mascota.sexo}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Fecha Perdida: ${mascota.fechaPerdida}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Lugar Perdida: ${mascota.lugarPerdida}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Estado: ${mascota.estado}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Descripción: ${mascota.descripcion}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
