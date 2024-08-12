import 'package:flutter/material.dart';
import 'package:homecoming/pages/login/modificar_usuario_pague.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/usuario.dart';

class AdminUsuariosPage extends StatefulWidget {
  @override
  _AdminUsuariosPageState createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {

  Future<void> _deleteUser(Usuario usuario) async {
    final result = await usuario.deleteUsuario(); // Llama al método deleteUsuario
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario eliminado correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
      // Actualizar la lista de usuarios después de la eliminación
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar usuario'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  Usuario? usuario;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Usuarios'),
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
      body: FutureBuilder<List<Usuario>>(
        future: Usuario.fetchUsuarios(),
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
                        DataCell(Text(user.nombre)),
                        DataCell(Text(user.primerApellido)),
                        DataCell(Text(user.segundoApellido)),
                        DataCell(Text(user.telefono)),
                        DataCell(Text(user.email)),
                        DataCell(Text(user.tipoUsuario)),
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
                                          _deleteUser(user);
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
