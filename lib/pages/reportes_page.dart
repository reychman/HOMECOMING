import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/reporte.dart';
import 'package:homecoming/pages/menu/api_servicio.dart'; // Asegúrate de importar la función de servicio
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class ReportesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
      ),
      drawer: MenuWidget(usuario: Usuario.vacio()), 
      body: FutureBuilder<Reporte>(
        future: fetchReporte(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar el reporte: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No hay datos disponibles'));
          }

          final reporte = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reporte del Mes', style: Theme.of(context).textTheme.headlineLarge),
                SizedBox(height: 16),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Descripción')),
                    DataColumn(label: Text('Cantidad')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Mascotas Perdidas')),
                      DataCell(Text(reporte.mascotasPerdidas.toString())),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Mascotas Encontradas')),
                      DataCell(Text(reporte.mascotasEncontradas.toString())),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Usuarios Administradores')),
                      DataCell(Text(reporte.usuariosAdministradores.toString())),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Usuarios Propietarios')),
                      DataCell(Text(reporte.usuariosPropietarios.toString())),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Usuarios Refugios')),
                      DataCell(Text(reporte.usuariosRefugios.toString())),
                    ]),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _generatePdf(reporte);
                      final file = await _localFile;
                      OpenFile.open(file.path);
                    } catch (e) {
                      print('Error generando PDF: $e');
                    }
                  },
                  child: Text('Descargar PDF'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _generatePdf(Reporte reporte) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Tipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Mascotas Perdidas'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('${reporte.mascotasPerdidas}'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Mascotas Encontradas'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('${reporte.mascotasEncontradas}'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Usuarios Administradores'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('${reporte.usuariosAdministradores}'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Usuarios Propietarios'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('${reporte.usuariosPropietarios}'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Usuarios Refugios'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('${reporte.usuariosRefugios}'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final outputFile = await _localFile;
    await outputFile.writeAsBytes(await pdf.save());
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/reporte.pdf');
  }
}
