import 'dart:convert';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/reporte.dart';
import 'package:http/http.dart' as http;

Future<Reporte> fetchReporte({String? startDate, String? endDate}) async {
  // Prepara la URL base
  String url = 'http://$serverIP/homecoming/homecomingbd_v2/reportes.php';

  // Añadir parámetros de fecha si están definidos
  if (startDate != null && endDate != null) {
    url += '?start_date=$startDate&end_date=$endDate';
  }

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return Reporte.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('No se pudo cargar el informe');
  }
}
