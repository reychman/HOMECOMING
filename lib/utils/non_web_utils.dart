import 'dart:typed_data';
import 'package:printing/printing.dart';

void descargarPdfWeb(List<int> pdfBytes, String fileName) async {
  // Convertimos List<int> a Uint8List
  final Uint8List uint8listBytes = Uint8List.fromList(pdfBytes);

  // Usamos Printing.sharePdf para compartir el PDF
  await Printing.sharePdf(bytes: uint8listBytes, filename: fileName);
}
