import 'dart:convert';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/tipo_reporte.dart'; // Importar el enum
import 'package:http/http.dart' as http;

  Future<dynamic> fetchReporte({
  required String startDate,
  required String endDate,
  required TipoReporte tipoReporte,
}) async {
  final String tipoReporteStr = tipoReporte.toString().split('.').last;
  
  String url = 'http://$serverIP/homecoming/homecomingbd_v2/reportes.php'
    '?start_date=$startDate'
    '&end_date=$endDate'
    '&tipo_reporte=$tipoReporteStr';

  try {
    final response = await http.get(Uri.parse(url));
    /*print('URL de la petición: $url'); // Para depuración
    print('Respuesta del servidor: ${response.body}'); // Para depuración*/

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['error'] != null) {
        throw Exception(jsonResponse['error']);
      }
      
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      } else {
        throw Exception('Respuesta no exitosa del servidor');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error en la petición: $e');
  }
}