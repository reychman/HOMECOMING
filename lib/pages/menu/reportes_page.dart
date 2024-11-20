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
import 'package:syncfusion_flutter_charts/charts.dart';
// Para web
import 'package:universal_html/html.dart' as html;

// Para móvil
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ReportesPage extends StatefulWidget {
  @override
  _ReportesPageState createState() => _ReportesPageState();
}
// Helper class for chart data
class _ChartData {
  final String category;
  final int value;
  
  _ChartData(this.category, this.value);
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
            if (_reporteData != null) _buildChartSection(),
          
            Expanded(
              child: _buildReporteContent(),
            ),
          ],
        ),
      ),
    );
  }
  
Widget _buildChartSection() {
  final chartData = _generateChartData();
  final List<Color> barColors = [
    Color.fromARGB(255, 139, 225, 236),  // Cian
    Color.fromARGB(255, 183, 239, 185),  // Verde
    Color.fromARGB(255, 113, 177, 228),  // Azul
    Color.fromARGB(255, 223, 199, 127),  // Amarillo
    Color.fromARGB(255, 221, 115, 151),  // Rosa
    Color.fromARGB(255, 166, 100, 177),  // Morado
    Color.fromARGB(255, 245, 167, 143),  // Naranja
    Color.fromARGB(255, 208, 163, 146),  // Marrón
  ];
  return LayoutBuilder(
    builder: (context, constraints) {
      bool isMobile = !kIsWeb && (constraints.maxWidth < 600);
      
      if (isMobile) {
        return SizedBox(
          height: 250,
          child: SfCircularChart(
            title: ChartTitle(text: 'Resumen de ${_getTipoReporteTitle()}'),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap
            ),
            series: <CircularSeries>[
              PieSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.category,
                yValueMapper: (_ChartData data, _) => data.value,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  // Usar labelFormatter para personalizar el formato de la etiqueta
                  builder: (dynamic data, dynamic point, dynamic series,
                      int pointIndex, int seriesIndex) {
                    return Text(
                      '${data.category}: ${data.value}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
                enableTooltip: true,
                explode: true,
                explodeIndex: -1,
              )
            ],
          ),
        );
      } else {
        return SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            title: ChartTitle(text: 'Resumen de ${_getTipoReporteTitle()}'),
            legend: Legend(isVisible: true),
            series: <CartesianSeries>[
              ColumnSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.category,
                yValueMapper: (_ChartData data, _) => data.value,
                name: 'Cantidad',
                // Usar pointColorMapper para asignar colores diferentes a cada barra
                pointColorMapper: (_ChartData data, int? index) => 
                    barColors[index! % barColors.length],
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.top,
                ),
              )
            ],
          ),
        );
      }
    },
  );
}

  List<_ChartData> _generateChartData() {
  List<_ChartData> chartData = [];
  
  if (_reporteData != null) {
    switch (_tipoReporteSeleccionado) {
      case TipoReporte.general:
        chartData = [
          _ChartData('Mascotas Perdidas', _reporteData['mascotas_perdidas'] ?? 0),
          _ChartData('Mascotas Encontradas', _reporteData['mascotas_encontradas'] ?? 0),
          _ChartData('Mascotas en Adopción', _reporteData['mascotas_adopcion'] ?? 0),
        ];
        break;
      
      case TipoReporte.mascotasPerdidas:
        Map<String, int> speciesCounts = {};
        for (var mascota in (_reporteData['mascotas'] as List)) {
          String especie = mascota['especie'].toString().toUpperCase();
          speciesCounts[especie] = (speciesCounts[especie] ?? 0) + 1;
        }
        chartData = speciesCounts.entries
            .map((entry) => _ChartData(entry.key, entry.value))
            .toList();
        break;
      
      case TipoReporte.mascotasEncontradas:
        Map<String, int> speciesCounts = {};
        for (var mascota in (_reporteData['mascotas'] as List)) {
          String especie = mascota['especie'].toString().toUpperCase();
          speciesCounts[especie] = (speciesCounts[especie] ?? 0) + 1;
        }
        chartData = speciesCounts.entries
            .map((entry) => _ChartData(entry.key, entry.value))
            .toList();
        break;
      
      case TipoReporte.adopciones:
        Map<String, int> speciesCounts = {};
        for (var adopcion in (_reporteData['adopciones'] as List)) {
          String especie = adopcion['especie'].toString().toUpperCase();
          speciesCounts[especie] = (speciesCounts[especie] ?? 0) + 1;
        }
        chartData = speciesCounts.entries
            .map((entry) => _ChartData(entry.key, entry.value))
            .toList();
        break;
    }
  }
  
  return chartData;
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
      _tituloReporte = 'Reporte ${_getTipoReporteTitle()}';
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

Future<pw.MemoryImage?> loadLogoImage() async {
  try {
    final logoData = await rootBundle.load('assets/imagenes/logo.png');
    return pw.MemoryImage(logoData.buffer.asUint8List());
  } catch (e) {
    print('Error loading logo: $e');
    return null;
  }
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
      final logo = await loadLogoImage();
      final generationDateTime = DateTime.now();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: font,
          ),
          build: (context) {
            List<pw.Widget> widgets = [];
            
            // Header with logo, title, and generation date
            widgets.add(
              pw.Row(
                children: [
                  // Logo on the far left
                  if (logo != null) 
                    pw.Image(logo, width: 100, height: 100),
                  
                  // Title right next to the logo
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 10), // Desplaza 20 unidades a la derecha
                    child: pw.Text(
                      _tituloReporte.toUpperCase(), 
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Generation date and date range on the right
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Fecha de Generación:\n${DateFormat('yyyy-MM-dd HH:mm:ss').format(generationDateTime)}', 
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Periodo del Reporte:\n${DateFormat('dd-MM-yyyy').format(_startDate!)} al ${DateFormat('dd-MM-yyyy').format(_endDate!)}',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                    ],
                  ),
                ],
              )
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
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, 
          color: PdfColors.white
        ),
        headerDecoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF4CAF50),
        ),
        cellHeight: 30,
        cellAlignment: pw.Alignment.center,
        cellStyle: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.black
        ),
        border: pw.TableBorder(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 1),
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 1),
          left: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 0.5),
          right: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 0.5),
          horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xFF81C784), width: 0.5),
          verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xFF81C784), width: 0.5),
        ),
        cellDecoration: (index, data, rowNum) {
          // Skip decoration for header row
          if (index == 0) return pw.BoxDecoration();
          
          return pw.BoxDecoration(
            color: index % 2 == 0 
              ? PdfColors.green50  // Use predefined light green
              : PdfColors.white
          );
        },
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
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, 
          color: PdfColors.white
        ),
        headerDecoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF4CAF50),
        ),
        cellHeight: 30,
        cellAlignment: pw.Alignment.center,
        cellStyle: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.black
        ),
        border: pw.TableBorder(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 1),
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 1),
          left: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 0.5),
          right: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 0.5),
          horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xFF81C784), width: 0.5),
          verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xFF81C784), width: 0.5),
        ),
        cellDecoration: (index, data, rowNum) {
          // Skip decoration for header row
          if (index == 0) return pw.BoxDecoration();
          
          return pw.BoxDecoration(
            color: index % 2 == 0 
              ? PdfColors.green50  // Use predefined light green
              : PdfColors.white
          );
        },
      ),
    );

    return widgets;
  }

  List<pw.Widget> _generateFoundPetsReportPDF() {
    List<pw.Widget> widgets = [];
    final PdfColor _pdfPrimaryColor = PdfColor.fromInt(0xFF4CAF50); // Main green
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
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, 
          color: PdfColors.white
        ),
        headerDecoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF4CAF50),
        ),
        cellHeight: 30,
        cellAlignment: pw.Alignment.center,
        cellStyle: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.black
        ),
        border: pw.TableBorder(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 1),
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 1),
          left: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 0.5),
          right: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 0.5),
          horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xFF81C784), width: 0.5),
          verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xFF81C784), width: 0.5),
        ),
        cellDecoration: (index, data, rowNum) {
          // Skip decoration for header row
          if (index == 0) return pw.BoxDecoration();
          
          return pw.BoxDecoration(
            color: index % 2 == 0 
              ? PdfColors.green50  // Use predefined light green
              : PdfColors.white
          );
        },
      ),
    );

    // Optional: Add a summary or additional information
    if (data.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 10));
      widgets.add(pw.Text(
        'Total de Mascotas Encontradas: ${data.length}',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: _pdfPrimaryColor,
        ),
      ));
    }

    return widgets;
  }

  List<pw.Widget> _generateAdoptionsReportPDF() {
    List<pw.Widget> widgets = [];
    final PdfColor _pdfPrimaryColor = PdfColor.fromInt(0xFF4CAF50); // Main green
    
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
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, 
          color: PdfColors.white
        ),
        headerDecoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF4CAF50),
        ),
        cellHeight: 30,
        cellAlignment: pw.Alignment.center,
        cellStyle: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.black
        ),
        border: pw.TableBorder(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 1),
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 1),
          left: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 0.5),
          right: pw.BorderSide(color: PdfColor.fromInt(0xFF4CAF50), width: 0.5),
          horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xFF81C784), width: 0.5),
          verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xFF81C784), width: 0.5),
        ),
        cellDecoration: (index, data, rowNum) {
          // Skip decoration for header row
          if (index == 0) return pw.BoxDecoration();
          
          return pw.BoxDecoration(
            color: index % 2 == 0 
              ? PdfColors.green50  // Use predefined light green
              : PdfColors.white
          );
        },
      ),
    );

    // Optional: Add a summary or additional information
    if (data.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 10));
      widgets.add(pw.Text(
        'Total de Adopciones: ${data.length}',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: _pdfPrimaryColor,
        ),
      ));
    }

    return widgets;
  }

}