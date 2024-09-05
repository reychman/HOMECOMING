import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/menu/reporte.dart';
import 'package:homecoming/pages/menu/api_servicio.dart';
import 'package:pdf/pdf.dart';
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
  String _tituloReporte = 'Reporte';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
        backgroundColor: Colors.green[200],
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
                        _updateTitle();
                        _autoFetchReport();
                      });
                    },
                    child: Text(
                      _startDate == null
                          ? 'Seleccionar Fecha de Inicio'
                          : DateFormat('yyyy-MM-dd').format(_startDate!),
                      style: TextStyle(color: Colors.black),
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
                        _updateTitle();
                        _autoFetchReport();
                      });
                    },
                    child: Text(
                      _endDate == null
                          ? 'Seleccionar Fecha Final'
                          : DateFormat('yyyy-MM-dd').format(_endDate!),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              _tituloReporte,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
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
                    return Center(child: Text('Seleccione una fecha inicial y una fecha final para generar el reporte.'));
                  }

                  final reporte = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DataTable(
                        columns: [
                          DataColumn(
                              label: Text(
                            'N°',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]),
                          )),
                          DataColumn(
                              label: Text(
                            'Descripción',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]),
                          )),
                          DataColumn(
                              label: Text(
                            'Cantidad',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]),
                          )),
                        ],
                        rows: [
                          DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return Colors.green[50]; // Fondo verde claro para filas impares
                              },
                            ),
                            cells: [
                              DataCell(Text('1')),
                              DataCell(Text('Mascotas Perdidas')),
                              DataCell(Text(reporte.mascotasPerdidas.toString())),
                            ],
                          ),
                          DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return Colors.white; // Fondo blanco para filas pares
                              },
                            ),
                            cells: [
                              DataCell(Text('2')),
                              DataCell(Text('Mascotas Encontradas')),
                              DataCell(Text(reporte.mascotasEncontradas.toString())),
                            ],
                          ),
                          DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return Colors.green[50];
                              },
                            ),
                            cells: [
                              DataCell(Text('3')),
                              DataCell(Text('Usuarios Administradores')),
                              DataCell(Text(reporte.usuariosAdministradores.toString())),
                            ],
                          ),
                          DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return Colors.white;
                              },
                            ),
                            cells: [
                              DataCell(Text('4')),
                              DataCell(Text('Usuarios Propietarios')),
                              DataCell(Text(reporte.usuariosPropietarios.toString())),
                            ],
                          ),
                          DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return Colors.green[50];
                              },
                            ),
                            cells: [
                              DataCell(Text('5')),
                              DataCell(Text('Usuarios Refugios')),
                              DataCell(Text(reporte.usuariosRefugios.toString())),
                            ],
                          ),
                        ],
                        border: TableBorder.all(color: Colors.green[800]!),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final pdf = await _generatePdf(reporte);
                            final pdfBytes = await pdf.save();
                            final blob = html.Blob([pdfBytes], 'application/pdf');
                            final fileName = _generateFileName();
                            final url = html.Url.createObjectUrlFromBlob(blob);
                            html.AnchorElement(href: url)
                              ..setAttribute('download', fileName)
                              ..click();
                            html.Url.revokeObjectUrl(url);
                          } catch (e) {
                            print('Error generando PDF: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                        ),
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

  void _updateTitle() {
    if (_startDate != null && _endDate != null) {
      final startDateString = DateFormat('dd-MM-yyyy').format(_startDate!);
      final endDateString = DateFormat('dd-MM-yyyy').format(_endDate!);
      _tituloReporte = 'Reporte del $startDateString al $endDateString';
    } else {
      _tituloReporte = 'Reporte';
    }
  }

  void _autoFetchReport() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _futureReporte = fetchReporte(
          startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
          endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
        );
      });
    }
  }

  String _generateFileName() {
    if (_startDate != null && _endDate != null) {
      final startDateString = DateFormat('yyyyMMdd').format(_startDate!);
      final endDateString = DateFormat('yyyyMMdd').format(_endDate!);
      return 'Reporte${startDateString}_${endDateString}.pdf';
    }
    return 'Reporte.pdf';
  }

  Future<pw.Document> _generatePdf(Reporte reporte) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  _tituloReporte,
                  style: pw.TextStyle(font: boldFont, fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColor.fromHex('#BDBDBD')),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FFFFFF')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('N°', style: pw.TextStyle(font: boldFont)),
                      ),
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
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E8F5E9')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('1', style: pw.TextStyle(font: font)),
                      ),
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
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FFFFFF')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('2', style: pw.TextStyle(font: font)),
                      ),
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
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E8F5E9')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('3', style: pw.TextStyle(font: font)),
                      ),
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
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FFFFFF')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('4', style: pw.TextStyle(font: font)),
                      ),
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
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E8F5E9')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('5', style: pw.TextStyle(font: font)),
                      ),
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
