import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecuperarContraPage extends StatefulWidget {
  @override
  _RecuperarContraPageState createState() => _RecuperarContraPageState();
}

class _RecuperarContraPageState extends State<RecuperarContraPage> {
  final TextEditingController emailController = TextEditingController();

  Future<void> enviarCorreo(String email) async {
    try {
      final response = await http.post(
        Uri.parse("http://$serverIP/homecoming/homecomingbd_v2/envioEmails/vendor/recuperar_contra.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          "email": email,
        },
      );

      print('Response body: ${response.body}'); // Agrega esta línea para depuración

      final responseData = json.decode(response.body);
      if (responseData.containsKey('success')) {
        mostrarDialogoExito();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${responseData['error']}'),
        ));
      }
    } catch (e) {
      mostrarDialogoExito();
    }
  }

  void mostrarDialogoExito() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Correo Enviado'),
          content: Text('Correo enviado correctamente, revise su bandeja de entrada'),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el AlertDialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PaginaPrincipal()), // Asegúrate de reemplazar con tu página principal
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recupera tu contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Recupera tu contraseña',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String email = emailController.text;
                if (email.isNotEmpty) {
                  enviarCorreo(email);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('El campo de correo electrónico está vacío'),
                  ));
                }
              },
              child: Text('Enviar correo'),
            ),
          ],
        ),
      ),
    );
  }
}
