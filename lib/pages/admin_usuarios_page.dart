import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/modificar_usuario_pague.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminUsuariosPage extends StatefulWidget {
  @override
  _AdminUsuariosPageState createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await http.get(Uri.parse(
        'http://$serverIP/homecoming/homecomingbd_v2/lista_usuarios.php'));

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      return List<Map<String, dynamic>>.from(users);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _deleteUser(int userId) async {
  final url = Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/eliminar_usuario.php');
  final response = await http.post(
    url,
    body: {
      'id': userId.toString(),
    },
  );

  if (response.statusCode == 200) {
    // Manejar la respuesta del servidor
    Map<String, dynamic> data = json.decode(response.body);
    if (data.containsKey('success')) {
      // Éxito: Usuario eliminado correctamente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['success']),
          duration: Duration(seconds: 2),
        ),
      );
      // Actualizar la lista de usuarios después de la eliminación
      setState(() {
        // Aquí puedes recargar la lista de usuarios si es necesario
      });
    } else if (data.containsKey('error')) {
      // Error: No se pudo eliminar el usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['error']),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } else {
    // Handle error
    print('Error al eliminar usuario: ${response.statusCode}');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Usuarios'),
      ),
      drawer: MenuWidget(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final users = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20, // Ajusta el espacio entre columnas
                columns: [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('Primer Apellido')),
                  DataColumn(label: Text('Segundo Apellido')),
                  DataColumn(label: Text('Teléfono')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Tipo Usuario')),
                  DataColumn(label: Text('Modificar')),
                  DataColumn(label: Text('Eliminar')),
                ],
                rows: List<DataRow>.generate(
                  users.length,
                  (index) {
                    final user = users[index];
                    return DataRow(
                      cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(user['nombre'])),
                        DataCell(Text(user['primerApellido'])),
                        DataCell(Text(user['segundoApellido'])),
                        DataCell(Text(user['telefono'])),
                        DataCell(Text(user['email'])),
                        DataCell(Text(user['tipo_usuario'])),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ModificarUsuarioPage(user: user),
                              ));
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.amber),
                            ),
                            child: Text('Modificar'),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Eliminar Usuario'),
                                    content: Text(
                                        '¿Está seguro de querer eliminar al usuario?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Cancelar'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Aceptar'),
                                        onPressed: () {
                                        Navigator.of(context).pop();
                                          _deleteUser(int.parse(user['id'].toString()));
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.red),
                            ),
                            child: Text('Eliminar'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
