import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecuperarContraPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  Future<void> enviarCorreo(String email) async {
    try {
      final response = await http.post(
        Uri.parse("http://$serverIP/homecoming/homecomingbd_v2/envioEmails/vendor"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          "email": email,
        },
      );

      final responseData = json.decode(response.body);
      if (responseData.containsKey('success')) {
        // Mostrar un mensaje de éxito
        print("Correo enviado: ${responseData['success']}");
      } else {
        // Mostrar un mensaje de error
        print("Error: ${responseData['error']}");
      }
    } catch (e) {
      print("Error decoding JSON: $e");
      // Mostrar un mensaje de error
    }
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
                  // Mostrar un mensaje de error si el campo está vacío
                  print("El campo de correo electrónico está vacío");
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
