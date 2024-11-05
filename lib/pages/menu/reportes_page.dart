import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/menu/api_servicio.dart';
import 'package:homecoming/pages/menu/tipo_reporte.dart'; // Importar el enum
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Para web
import 'package:universal_html/html.dart' as html;

// Para móvil
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ReportesPage extends StatefulWidget {
  @override
  _ReportesPageState createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  dynamic _reporteData;
  String _tituloReporte = 'Reporte';
  TipoReporte _tipoReporteSeleccionado = TipoReporte.general;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
        backgroundColor: Colors.green[200],
      ),
      drawer: MenuWidget(usuario: Usuario.vacio()),
      backgroundColor: Colors.green[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Botones de tipos de reportes
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildReportButton('Reporte General', TipoReporte.general),
                  SizedBox(width: 10),
                  _buildReportButton('Mascotas Perdidas', TipoReporte.mascotasPerdidas),
                  SizedBox(width: 10),
                  _buildReportButton('Mascotas Encontradas', TipoReporte.mascotasEncontradas),
                  SizedBox(width: 10),
                  _buildReportButton('Adopciones', TipoReporte.adopciones),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Selectores de fecha
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48, // Altura fija para evitar el desbordamiento
                    child: TextButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          locale: const Locale('es', 'ES'), // Agregar esta línea para español
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                textTheme: TextTheme(
                                  bodyLarge: TextStyle(fontSize: 14.0),
                                  bodyMedium: TextStyle(fontSize: 14.0),
                                  titleMedium: TextStyle(fontSize: 14.0),
                                ),
                                dialogTheme: DialogTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(textScaleFactor: 0.85),
                                child: child!,
                              ),
                            );
                          },
                        );
                        if (selectedDate != null) {
                          // Validar que la fecha de inicio no sea posterior a la fecha final
                          if (_endDate != null && selectedDate.isAfter(_endDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('La fecha de inicio no puede ser posterior a la fecha final'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _startDate = selectedDate;
                            _actualizarTitulo();
                            _obtenerReporte();
                          });
                        }
                      },
                      child: Text(
                        _startDate == null
                            ? 'Fecha de Inicio'
                            : DateFormat('yyyy-MM-dd').format(_startDate!),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 48, // Altura fija para evitar el desbordamiento
                    child: TextButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        locale: const Locale('es', 'ES'), // Agregar esta línea para español
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              textTheme: TextTheme(
                                bodyLarge: TextStyle(fontSize: 14.0),
                                bodyMedium: TextStyle(fontSize: 14.0),
                                titleMedium: TextStyle(fontSize: 14.0),
                              ),
                              dialogTheme: DialogTheme(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(textScaleFactor: 0.85),
                              child: child!,
                            ),
                          );
                        },
                      );
                        if (selectedDate != null) {
                          setState(() {
                            _endDate = selectedDate;
                            _actualizarTitulo();
                            _obtenerReporte();
                          });
                        }
                      },
                      child: Text(
                        _endDate == null
                            ? 'Fecha Final'
                            : DateFormat('yyyy-MM-dd').format(_endDate!),
                        style: TextStyle(color: Colors.black),
                      ),
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
              child: _buildReporteContent(),
            ),
          ],
        ),
      ),
    );
  }
  String toUpperCase(dynamic value) {
    if (value == null) return '';
    return value.toString().toUpperCase();
  }

  Widget _buildReportButton(String title, TipoReporte tipo) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _tipoReporteSeleccionado == tipo ? Colors.green : Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {
        setState(() {
          _tipoReporteSeleccionado = tipo;
          _obtenerReporte();
        });
      },
      child: Text(title),
    );
  }

  Widget _buildReporteContent() {
    if (_startDate == null || _endDate == null) {
      return Center(child: Text('Seleccione fechas para generar el reporte'));
    }

    if (_reporteData == null) {
      return Center(child: CircularProgressIndicator());
    }

    switch (_tipoReporteSeleccionado) {
      case TipoReporte.general:
        return _buildReporteGeneral();
      case TipoReporte.mascotasPerdidas:
        return _buildReporteMascotasPerdidas();
      case TipoReporte.mascotasEncontradas:
        return _buildReporteMascotasEncontradas();
      case TipoReporte.adopciones:
        return _buildReporteAdopciones();
    }
  }

  Widget _buildReporteGeneral() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.green[100]),
                  dataRowColor: WidgetStateProperty.all(Colors.white),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'DESCRIPCIÓN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CANTIDAD',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('MASCOTAS PERDIDAS')),
                      DataCell(Text('${_reporteData['mascotas_perdidas'] ?? 0}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('MASCOTAS ENCONTRADAS')),
                      DataCell(Text('${_reporteData['mascotas_encontradas'] ?? 0}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('MASCOTAS EN ADOPCIÓN')),
                      DataCell(Text('${_reporteData['mascotas_adopcion'] ?? 0}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('USUARIOS ADMINISTRADORES')),
                      DataCell(Text('${_reporteData['usuarios_administradores'] ?? 0}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('USUARIOS PROPIETARIOS')),
                      DataCell(Text('${_reporteData['usuarios_propietarios'] ?? 0}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('USUARIOS REFUGIOS')),
                      DataCell(Text('${_reporteData['usuarios_refugios'] ?? 0}')),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildDownloadButton(),
      ],
    );
  }

  Widget _buildReporteMascotasPerdidas() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.green[100]),
                        dataRowColor: WidgetStateProperty.all(Colors.white),
                        columnSpacing: 20.0, // Reduced spacing between columns
                        columns: const [
                          DataColumn(
                              label: Text('MASCOTA',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('ESPECIE',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('RAZA',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('FECHA',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('PROPIETARIO',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('CONTACTO',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: (_reporteData['mascotas'] as List).map<DataRow>((mascota) {
                          return DataRow(cells: [
                            DataCell(Text(toUpperCase(mascota['nombre']),
                                style: const TextStyle(fontSize: 13))),
                            DataCell(Text(toUpperCase(mascota['especie']),
                                style: const TextStyle(fontSize: 13))),
                            DataCell(Text(toUpperCase(mascota['raza']),
                                style: const TextStyle(fontSize: 13))),
                            DataCell(Text(
                                toUpperCase(DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(mascota['fecha_perdida']))),
                                style: const TextStyle(fontSize: 13))),
                            DataCell(Text(
                                toUpperCase(
                                    '${mascota['nombre_propietario']} ${mascota['primerApellido']}'),
                                style: const TextStyle(fontSize: 13))),
                            DataCell(Text(toUpperCase(mascota['telefono']),
                                style: const TextStyle(fontSize: 13))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        _buildDownloadButton(),
      ],
    );
  }

  Widget _buildReporteMascotasEncontradas() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.green[100]),
                        dataRowColor: WidgetStateProperty.all(Colors.white),
                        columnSpacing: 20.0,
                        columns: const [
                          DataColumn(
                              label: Text('MASCOTA',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('ESPECIE',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('RAZA',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('REPORTADO POR',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('CONTACTO',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: (_reporteData['mascotas'] as List? ?? [])
                            .map<DataRow>((mascota) {
                          return DataRow(cells: [
                            DataCell(Text(toUpperCase(mascota['nombre']),
                                style: const TextStyle(fontSize: 13))),
                            DataCell(Text(toUpperCase(mascota['especie']),
                                style: const TextStyle(fontSize: 13))),
                            DataCell(Text(toUpperCase(mascota['raza']),
                                style: const TextStyle(fontSize: 13))),
                            DataCell(Text(
                                toUpperCase(
                                    '${mascota['nombre_encontrador']} ${mascota['primerApellido']}'),
                                style: const TextStyle(fontSize: 13))),
                            DataCell(Text(toUpperCase(mascota['telefono']),
                                style: const TextStyle(fontSize: 13))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        _buildDownloadButton(),
      ],
    );
  }

  Widget _buildReporteAdopciones() {
  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.green[100]),
                      dataRowColor: WidgetStateProperty.all(Colors.white),
                      columnSpacing: 20.0,
                      columns: const [
                        DataColumn(
                            label: Text('REFUGIO',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('MASCOTA',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('ESPECIE',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('UBICACIÓN',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('CONTACTO',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: (_reporteData['adopciones'] as List).map<DataRow>((adopcion) {
                        return DataRow(cells: [
                          DataCell(Text(toUpperCase(adopcion['nombreRefugio']),
                              style: const TextStyle(fontSize: 13))),
                          DataCell(Text(toUpperCase(adopcion['nombre_mascota']),
                              style: const TextStyle(fontSize: 13))),
                          DataCell(Text(toUpperCase(adopcion['especie']),
                              style: const TextStyle(fontSize: 13))),
                          DataCell(Text(toUpperCase(adopcion['ubicacionRefugio']),
                              style: const TextStyle(fontSize: 13))),
                          DataCell(Text(toUpperCase(adopcion['telefonoRefugio']),
                              style: const TextStyle(fontSize: 13))),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      _buildDownloadButton(),
    ],
  );
}

  Widget _buildDownloadButton() {
    // Si no es web, retornamos un contenedor vacío
    if (!kIsWeb) {
      return const SizedBox.shrink(); // No muestra nada en móvil
    }

    // Solo mostramos el botón en web
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton.icon(
        onPressed: () => _generarPDF(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[400],
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(Icons.download),
        label: const Text(
          'Descargar PDF',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _actualizarTitulo() {
    if (_startDate != null && _endDate != null) {
      final startDateString = DateFormat('dd-MM-yyyy').format(_startDate!);
      final endDateString = DateFormat('dd-MM-yyyy').format(_endDate!);
      _tituloReporte = 'Reporte ${_getTipoReporteTitle()} del $startDateString al $endDateString';
    }
  }

  String _getTipoReporteTitle() {
    switch (_tipoReporteSeleccionado) {
      case TipoReporte.general:
        return 'General';
      case TipoReporte.mascotasPerdidas:
        return 'de Mascotas Perdidas';
      case TipoReporte.mascotasEncontradas:
        return 'de Mascotas Encontradas';
      case TipoReporte.adopciones:
        return 'de Adopciones';
    }
  }

  void _obtenerReporte() async {
    if (_startDate == null || _endDate == null) return;

    setState(() {
      _reporteData = null;
    });

    try {
      final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
      final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);
      /*print('Obteniendo reporte:');
      print('Fecha inicio: $startDateStr');
      print('Fecha fin: $endDateStr');
      print('Tipo reporte: $_tipoReporteSeleccionado');*/

      final data = await fetchReporte(
        startDate: startDateStr,
        endDate: endDateStr,
        tipoReporte: _tipoReporteSeleccionado,
      );

      setState(() {
        switch (_tipoReporteSeleccionado) {
          case TipoReporte.general:
            _reporteData = {
              'mascotas_perdidas': data['mascotas_perdidas'],
              'mascotas_encontradas': data['mascotas_encontradas'],
              'mascotas_adopcion': data['mascotas_adopcion'],
              'usuarios_administradores': data['usuarios_administradores'],
              'usuarios_propietarios': data['usuarios_propietarios'],
              'usuarios_refugios': data['usuarios_refugios'],
            };
            break;

          case TipoReporte.mascotasPerdidas:
            _reporteData = {
              'mascotas': data['mascotas'],
            };
            break;

          case TipoReporte.mascotasEncontradas:
            _reporteData = {
              'mascotas': data['mascotas'],
            };
            break;

          case TipoReporte.adopciones:
            _reporteData = {
              'adopciones': data['adopciones'],
            };
            break;
        }
      });

    } catch (e) {
      print('Error detallado al obtener reporte:');
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar el reporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    _actualizarTitulo();
}
Future<pw.Font> loadFont() async {
  final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  return pw.Font.ttf(fontData);
}

// Método actualizado para soportar web y móvil
Future<void> _generarPDF() async {
  try {
    final pdf = pw.Document();
    final font = await loadFont();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: font,
        ),
        build: (context) {
          List<pw.Widget> widgets = [];
          
          // Add title in uppercase
          widgets.add(
            pw.Header(
              level: 0,
              child: pw.Text(
                _tituloReporte.toUpperCase(), // Título en mayúsculas
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          );
        
          widgets.add(pw.SizedBox(height: 20));
          // Add content based on report type
          switch (_tipoReporteSeleccionado) {
            case TipoReporte.general:
              widgets.addAll(_generateGeneralReportPDF());
              break;
            case TipoReporte.mascotasPerdidas:
              widgets.addAll(_generateLostPetsReportPDF());
              break;
            case TipoReporte.mascotasEncontradas:
              widgets.addAll(_generateFoundPetsReportPDF());
              break;
            case TipoReporte.adopciones:
              widgets.addAll(_generateAdoptionsReportPDF());
              break;
          }

          return widgets;
        },
      ),
    );

    final fileName = 'Reporte_${_getTipoReporteTitle()}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
    final bytes = await pdf.save();

    // Manejar la descarga según la plataforma
    if (kIsWeb) {
      // Versión Web
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      // Versión Móvil
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      // Abrir el archivo con el visor predeterminado
      await OpenFile.open(filePath);
    }

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF generado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print('Error al generar PDF: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al generar el PDF: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  // Los métodos helper permanecen casi iguales, solo necesitan ajustar el estilo de la tabla
  List<pw.Widget> _generateGeneralReportPDF() {
    List<pw.Widget> widgets = [];
    
    final List<List<String>> tableData = [
      ['MÉTRICA', 'CANTIDAD'],
      ['MASCOTAS PERDIDAS', '${_reporteData['mascotas_perdidas'] ?? 0}'],
      ['MASCOTAS ENCONTRADAS', '${_reporteData['mascotas_encontradas'] ?? 0}'],
      ['MASCOTAS EN ADOPCIÓN', '${_reporteData['mascotas_adopcion'] ?? 0}'],
      ['USUARIOS ADMINISTRADORES', '${_reporteData['usuarios_administradores'] ?? 0}'],
      ['USUARIOS PROPIETARIOS', '${_reporteData['usuarios_propietarios'] ?? 0}'],
      ['USUARIOS REFUGIOS', '${_reporteData['usuarios_refugios'] ?? 0}'],
    ];

    widgets.add(
      pw.TableHelper.fromTextArray(
        context: null,
        data: tableData,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: pw.BoxDecoration(
          color: PdfColors.grey300,
        ),
        cellHeight: 30,
        cellAlignment: pw.Alignment.center,
        cellStyle: pw.TextStyle(fontSize: 10),
      ),
    );

    return widgets;
  }


  List<pw.Widget> _generateLostPetsReportPDF() {
    List<pw.Widget> widgets = [];
    
    final data = (_reporteData['mascotas'] as List);
    final List<List<String>> tableData = [
      ['MASCOTA', 'ESPECIE', 'RAZA', 'FECHA PÉRDIDA', 'PROPIETARIO', 'CONTACTO'],
      ...data.map((mascota) => [
        toUpperCase(mascota['nombre']),
        toUpperCase(mascota['especie']),
        toUpperCase(mascota['raza']),
        toUpperCase(DateFormat('yyyy-MM-dd').format(DateTime.parse(mascota['fecha_perdida']))),
        toUpperCase('${mascota['nombre_propietario']} ${mascota['primerApellido']}'),
        toUpperCase(mascota['telefono']),
      ]),
    ];

    widgets.add(
      pw.TableHelper.fromTextArray(
        context: null,
        data: tableData,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: pw.BoxDecoration(
          color: PdfColors.grey300,
        ),
        cellHeight: 30,
        cellAlignment: pw.Alignment.center,
        cellStyle: pw.TextStyle(fontSize: 10),
      ),
    );

    return widgets;
  }

  List<pw.Widget> _generateFoundPetsReportPDF() {
    List<pw.Widget> widgets = [];
    
    final data = (_reporteData['mascotas'] as List? ?? []);
    final List<List<String>> tableData = [
      ['MASCOTA', 'ESPECIE', 'RAZA', 'REPORTADO POR', 'CONTACTO'],
      ...data.map((mascota) => [
        toUpperCase(mascota['nombre']),
        toUpperCase(mascota['especie']),
        toUpperCase(mascota['raza']),
        toUpperCase('${mascota['nombre_encontrador']} ${mascota['primerApellido']}'),
        toUpperCase(mascota['telefono']),
      ]),
    ];

    widgets.add(
      pw.TableHelper.fromTextArray(
        context: null,
        data: tableData,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: pw.BoxDecoration(
          color: PdfColors.grey300,
        ),
        cellHeight: 30,
        cellAlignment: pw.Alignment.center,
        cellStyle: pw.TextStyle(fontSize: 10),
      ),
    );

    return widgets;
  }

List<pw.Widget> _generateAdoptionsReportPDF() {
  List<pw.Widget> widgets = [];
  
  final data = (_reporteData['adopciones'] as List);
  final List<List<String>> tableData = [
    ['REFUGIO', 'MASCOTA', 'ESPECIE', 'UBICACIÓN', 'CONTACTO'],
    ...data.map((adopcion) => [
      toUpperCase(adopcion['nombreRefugio']),
      toUpperCase(adopcion['nombre_mascota']),
      toUpperCase(adopcion['especie']),
      toUpperCase(adopcion['ubicacionRefugio']),
      toUpperCase(adopcion['telefonoRefugio']),
    ]),
  ];

  widgets.add(
    pw.TableHelper.fromTextArray(
      context: null,
      data: tableData,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellHeight: 30,
      cellAlignment: pw.Alignment.center,
      cellStyle: pw.TextStyle(fontSize: 10),
    ),
  );

  return widgets;
}

}