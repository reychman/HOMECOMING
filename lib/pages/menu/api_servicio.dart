// api_service.dart
import 'dart:convert';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/reporte.dart';
import 'package:http/http.dart' as http;

Future<Reporte> fetchReporte() async {
  final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/reportes.php'));

  if (response.statusCode == 200) {
    return Reporte.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load report');
  }
}
