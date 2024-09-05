import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/menu/reporte.dart';
import 'package:homecoming/pages/menu/api_servicio.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:html' as html;
import 'package:intl/intl.dart';

class ReportesPage extends StatefulWidget {
  @override
  _ReportesPageState createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  Future<Reporte>? _futureReporte;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
      ),
      drawer: MenuWidget(usuario: Usuario.vacio()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      setState(() {
                        _startDate = selectedDate;
                      });
                    },
                    child: Text(
                      _startDate == null
                          ? 'Seleccionar Fecha de Inicio'
                          : DateFormat('yyyy-MM-dd').format(_startDate!),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      setState(() {
                        _endDate = selectedDate;
                      });
                    },
                    child: Text(
                      _endDate == null
                          ? 'Seleccionar Fecha Final'
                          : DateFormat('yyyy-MM-dd').format(_endDate!),
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (_startDate != null && _endDate != null) {
                  setState(() {
                    _futureReporte = fetchReporte(
                      startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
                      endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
                    );
                  });
                }
              },
              child: Text('Generar Reporte'),
            ),
            Expanded(
              child: FutureBuilder<Reporte>(
                future: _futureReporte,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar el reporte: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('No hay datos disponibles'));
                  }

                  final reporte = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            final pdf = await _generatePdf(reporte);
                            final pdfBytes = await pdf.save();
                            final blob = html.Blob([pdfBytes], 'application/pdf');
                            final url = html.Url.createObjectUrlFromBlob(blob);
                            html.AnchorElement(href: url)
                              ..setAttribute('download', 'reporte.pdf')
                              ..click();
                            html.Url.revokeObjectUrl(url);
                          } catch (e) {
                            print('Error generando PDF: $e');
                          }
                        },
                        child: Text('Descargar PDF'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Document> _generatePdf(Reporte reporte) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Tipo', style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Cantidad', style: pw.TextStyle(font: boldFont)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Mascotas Perdidas', style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${reporte.mascotasPerdidas}', style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Mascotas Encontradas', style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${reporte.mascotasEncontradas}', style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Usuarios Administradores', style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${reporte.usuariosAdministradores}', style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Usuarios Propietarios', style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${reporte.usuariosPropietarios}', style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Usuarios Refugios', style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${reporte.usuariosRefugios}', style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
