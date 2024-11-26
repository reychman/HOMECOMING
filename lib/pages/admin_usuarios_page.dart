import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/modificar_usuario_pague.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminUsuarios extends StatefulWidget {
  @override
  _AdminUsuariosState createState() => _AdminUsuariosState();
}

class _AdminUsuariosState extends State<AdminUsuarios> {
  List<Usuario> usuarios = [];
  List<Usuario> refugiosActivos = [];
  List<Usuario> refugiosInactivos = [];
  List<Usuario> refugiosRechazados = [];
  String tipoVistaActual = '';

@override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    final Usuario usuario = arguments is Usuario ? arguments : Usuario.vacio();
    return Scaffold(
      appBar: AppBar(
        title: Text('ADMINISTRACIÓN DE USUARIOS'),
        backgroundColor: Colors.green[200],
      ),
      drawer: MenuWidget(usuario: usuario),
      backgroundColor: Colors.green[50],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[300],
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => cargarUsuarios('propietario'),
                      child: Text('VER PROPIETARIOS'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[300],
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => cargarUsuarios('administrador'),
                      child: Text('VER ADMINISTRADORES'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[300],
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => cargarRefugios(),
                      child: Text('VER REFUGIOS'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: tipoVistaActual == 'refugio' 
                  ? _construirVistasRefugios()
                  : _construirTablaUsuarios(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirVistasRefugios() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.green[50],
            child: Text(
              'REFUGIOS ACTIVOS', 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _construirTablaRefugios(refugiosActivos, true),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.green[50],
            child: Text(
              'REFUGIOS PENDIENTES DE APROBACIÓN', 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _construirTablaRefugios(refugiosInactivos, false),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.green[50],
            child: Text(
              'REFUGIOS RECHAZADOS', 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _construirTablaRefugios(refugiosRechazados, false, esRechazado: true),
          ),
        ],
      ),
    );
  }

  Widget _construirTablaRefugios(List<Usuario> refugios, bool esActivo, {bool esRechazado = false}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.green[100]),
        columns: [
          DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('NOMBRE COMPLETO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('TELÉFONOS', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('EMAILS', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('TIPO USUARIO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('NOMBRE REFUGIO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('UBICACIÓN REFUGIO', style: TextStyle(fontWeight: FontWeight.bold))),
          if (!esRechazado) DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: refugios.asMap().entries.map((entry) {
          int idx = entry.key;
          Usuario refugio = entry.value;
          // Concatenación de nombre completo
          String nombreCompleto = '${refugio.nombre} ${refugio.primerApellido} ${refugio.segundoApellido}';
          // Concatenación de emails con salto de línea
          String emails = '${refugio.email}\n${refugio.emailRefugio ?? ''}';
          String telefonos = '${refugio.telefono}\n${refugio.telefonoRefugio  ?? ''}';
          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) return Colors.green[50];
                return null;
              },
            ),
            cells: [
              DataCell(Text((idx + 1).toString())),
              DataCell(Text(nombreCompleto.toUpperCase())),
              DataCell(
                Text(
                  telefonos,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  emails,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(Text((refugio.tipoUsuario ?? 'Sin tipo').toUpperCase())),
              DataCell(Text((refugio.nombreRefugio ?? '').toUpperCase())),
              DataCell(Text((refugio.ubicacionRefugio ?? '').toUpperCase())),
              if (!esRechazado)
                DataCell(Row(
                  children: esActivo
                      ? [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _editarUsuario(refugio),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarEliminacion(refugio),
                          ),
                        ]
                      : [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () => _aprobarRefugio(refugio),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _rechazarRefugio(refugio),
                          ),
                        ],
                )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _construirTablaUsuarios() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.green[100]),
        columns: [
          DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('NOMBRE COMPLETO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('TELÉFONO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('EMAIL', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('TIPO USUARIO', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: usuarios.asMap().entries.map((entry) {
          Usuario usuario = entry.value;
          String nombreCompleto = '${usuario.nombre} ${usuario.primerApellido} ${usuario.segundoApellido}';
          int idx = entry.key;
          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) return Colors.green[50];
                return null;
              },
            ),
            cells: [
              DataCell(Text((idx + 1).toString())),
              DataCell(Text(nombreCompleto.toUpperCase())),
              DataCell(Text(usuario.telefono.toUpperCase())),
              DataCell(Text(usuario.email)),
              DataCell(Text((usuario.tipoUsuario ?? 'Sin tipo').toUpperCase())),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.green),
                    onPressed: () => _editarUsuario(usuario),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarEliminacion(usuario),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  void cargarUsuarios(String tipo) async {
    final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/lista_usuarios.php?tipo=$tipo'));
    if (response.statusCode == 200) {
      setState(() {
        usuarios = (json.decode(response.body) as List)
            .map((data) => Usuario.fromJson(data))
            .where((usuario) => usuario.estado == 1)
            .toList();
        tipoVistaActual = tipo;
      });
    }
  }

  void cargarRefugios() async {
    final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/lista_usuarios.php?tipo=refugio'));
    if (response.statusCode == 200) {
      final List<Usuario> todosRefugios = (json.decode(response.body) as List)
          .map((data) => Usuario.fromJson(data))
          .toList();
      
      setState(() {
        refugiosActivos = todosRefugios.where((refugio) => refugio.estado == 1).toList();
        refugiosInactivos = todosRefugios.where((refugio) => refugio.estado == 0).toList();
        refugiosRechazados = todosRefugios.where((refugio) => refugio.estado == 2).toList();
        tipoVistaActual = 'refugio';
      });
    }
  }

  void _editarUsuario(Usuario usuario) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModificarUsuarioPage(user: usuario),
      ),
    );

    if (result == true) {
      await usuario.updateUsuario();
      _mostrarMensaje('Usuario actualizado con éxito');
      _actualizarListas();
    }
  }

  void _confirmarEliminacion(Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Está seguro de que desea eliminar este usuario?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await usuario.deleteUsuario();
                if (success) {
                  _mostrarMensaje('Usuario eliminado con éxito');
                  _actualizarListas();
                } else {
                  _mostrarMensaje('Error al eliminar usuario', esError: true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _aprobarRefugio(Usuario refugio) async {
    try {
      Map<String, dynamic> result = await refugio.cambiarEstadoRefugio(1);
      if (result['success'] == true) {
        // Send approval email
        await enviarCorreo(refugio.email, true);
        print(refugio.email);
        _mostrarMensaje('Refugio aprobado con éxito y notificación enviada');
        _actualizarListas();
      } else {
        _mostrarMensaje('Error al aprobar refugio: ${result['message']}', esError: true);
      }
    } catch (e) {
      _mostrarMensaje('Error inesperado: ${e.toString()}', esError: true);
    }
  }

  void _rechazarRefugio(Usuario refugio) async {
    try {
      Map<String, dynamic> result = await refugio.cambiarEstadoRefugio(2);
      if (result['success'] == true) {
        // Send rejection email
        await enviarCorreo(refugio.email, false);
        _mostrarMensaje('Refugio rechazado con éxito y notificación enviada');
        _actualizarListas();
      } else {
        _mostrarMensaje('Error al rechazar refugio: ${result['message']}', esError: true);
      }
    } catch (e) {
      _mostrarMensaje('Error inesperado: ${e.toString()}', esError: true);
    }
  }

  Future<void> enviarCorreo(String email, bool esAprobado) async {
    try {
      final response = await http.post(
        Uri.parse("http://$serverIP/homecoming/homecomingbd_v2/envioEmails/vendor/correoRefugio/correoRefugio.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          "email": email,
          "serverIP": serverIP,
          "esAprobado": esAprobado.toString(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al enviar el correo');
      }
    } catch (e) {
      _mostrarMensaje('Error al enviar la notificación por correo: ${e.toString()}', esError: true);
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _actualizarListas() {
    if (tipoVistaActual == 'refugio') {
      cargarRefugios();
    } else {
      cargarUsuarios(tipoVistaActual);
    }
  }
}