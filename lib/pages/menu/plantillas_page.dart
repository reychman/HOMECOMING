import 'package:flutter/material.dart';// Para obtener imágenes desde assets, si es necesario.
import 'package:homecoming/pages/mascota.dart';
import 'dart:async'; // Para operaciones asíncronas
import 'dart:io'; // Para guardar el PDF
import 'package:pdf/pdf.dart'; // La librería pdf
import 'package:pdf/widgets.dart' as pw; // Widgets para PDF
import 'package:path_provider/path_provider.dart'; // Para obtener la ruta del directorio

class PlantillasPage extends StatefulWidget {
  final Mascota mascota;

  PlantillasPage({required this.mascota});

  @override
  _PlantillasPageState createState() => _PlantillasPageState();
}

class _PlantillasPageState extends State<PlantillasPage> {
  bool _isGenerating = false; // Para controlar el estado de la generación

  Future<void> _generateAndDownloadPDF() async {
    setState(() {
      _isGenerating = true; // Mostramos el indicador de carga
    });

    try {
      // Crear un documento PDF
      final pdf = pw.Document();

      // Agregar una página al documento con la plantilla
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${widget.mascota.especie.toUpperCase()} PERDIDO',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Nombre: ${widget.mascota.nombre}'),
                pw.Text('Raza: ${widget.mascota.raza}'),
                pw.Text('Sexo: ${widget.mascota.sexo}'),
                pw.Text('Fecha perdida: ${widget.mascota.fechaPerdida}'),
                pw.Text('Lugar perdido: ${widget.mascota.lugarPerdida}'),
                pw.Text('Descripción: ${widget.mascota.descripcion}'),
                pw.SizedBox(height: 10),
                pw.Text('Contacto: ${widget.mascota.telefonoDueno}'),
                // Puedes agregar más contenido según la plantilla que quieras generar
              ],
            );
          },
        ),
      );

      // Guardar el PDF en un archivo
      final outputDir = await getTemporaryDirectory(); // Obtener el directorio temporal
      final file = File('${outputDir.path}/plantilla_${widget.mascota.nombre}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Mostrar un mensaje de éxito y abrir el archivo PDF
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plantilla generada correctamente.')));

      // Aquí puedes abrir el archivo o compartirlo
      // Por ejemplo, usar la librería 'open_file' para abrir el PDF
      // OpenFile.open(file.path);

    } catch (e) {
      // Si ocurre un error, lo manejamos
      print('Error al generar el PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar la plantilla.')));
    } finally {
      setState(() {
        _isGenerating = false; // Ocultamos el indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plantilla de Se Busca'),
        backgroundColor: Colors.green[200],
      ),
      body: Center(
        child: _isGenerating
            ? CircularProgressIndicator() // Mostrar indicador de carga si se está generando el PDF
            : ElevatedButton(
                onPressed: _generateAndDownloadPDF,
                child: Text('Generar y Descargar Plantilla'),
              ),
      ),
    );
  }
}
