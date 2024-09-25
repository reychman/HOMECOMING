import 'dart:html' as html;
import 'dart:typed_data';

void descargarPdfWeb(List<int> pdfBytes, String fileName) {
  // Convertimos List<int> a Uint8List
  final Uint8List uint8listBytes = Uint8List.fromList(pdfBytes);

  // Creamos el Blob para el archivo PDF
  final blob = html.Blob([uint8listBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // Usamos AnchorElement directamente sin asignarlo a una variable
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  // Revocamos la URL para liberar memoria
  html.Url.revokeObjectUrl(url);
}
