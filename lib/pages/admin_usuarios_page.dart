import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/modificar_usuario_pague.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Administración de Usuarios'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => cargarUsuarios('propietario'),
                child: Text('Ver Propietarios'),
              ),
              ElevatedButton(
                onPressed: () => cargarUsuarios('administrador'),
                child: Text('Ver Administradores'),
              ),
              ElevatedButton(
                onPressed: () => cargarRefugios(),
                child: Text('Ver Refugios'),
              ),
            ],
          ),
          Expanded(
            child: tipoVistaActual == 'refugio' 
              ? _construirVistasRefugios()
              : _construirTablaUsuarios(),
          ),
        ],
      ),
    );
  }
  Widget _construirVistasRefugios() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text('Refugios Activos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          _construirTablaRefugios(refugiosActivos, true),
          SizedBox(height: 20),
          Text('Refugios Pendientes de Aprobación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          _construirTablaRefugios(refugiosInactivos, false),
          SizedBox(height: 20),
          Text('Refugios Rechazados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          _construirTablaRefugios(refugiosRechazados, false, esRechazado: true),
        ],
      ),
    );
  }
  Widget _construirTablaUsuarios() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Primer Apellido')),
          DataColumn(label: Text('Segundo Apellido')),
          DataColumn(label: Text('Teléfono')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Tipo Usuario')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: usuarios.asMap().entries.map((entry) {
          int idx = entry.key;
          Usuario usuario = entry.value;
          return DataRow(cells: [
            DataCell(Text((idx + 1).toString())),
            DataCell(Text(usuario.nombre)),
            DataCell(Text(usuario.primerApellido)),
            DataCell(Text(usuario.segundoApellido)),
            DataCell(Text(usuario.telefono)),
            DataCell(Text(usuario.email)),
            DataCell(Text(usuario.tipoUsuario)),
            DataCell(Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editarUsuario(usuario),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _confirmarEliminacion(usuario),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _construirTablaRefugios(List<Usuario> refugios, bool esActivo, {bool esRechazado = false}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Primer Apellido')),
          DataColumn(label: Text('Segundo Apellido')),
          DataColumn(label: Text('Teléfono')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Tipo Usuario')),
          DataColumn(label: Text('Nombre Refugio')),
          DataColumn(label: Text('Email Refugio')),
          DataColumn(label: Text('Ubicación Refugio')),
          DataColumn(label: Text('Teléfono Refugio')),
          if (!esRechazado) DataColumn(label: Text('Acciones')),
        ],
        rows: refugios.asMap().entries.map((entry) {
          int idx = entry.key;
          Usuario refugio = entry.value;
          return DataRow(cells: [
            DataCell(Text((idx + 1).toString())),
            DataCell(Text(refugio.nombre)),
            DataCell(Text(refugio.primerApellido)),
            DataCell(Text(refugio.segundoApellido)),
            DataCell(Text(refugio.telefono)),
            DataCell(Text(refugio.email)),
            DataCell(Text(refugio.tipoUsuario)),
            DataCell(Text(refugio.nombreRefugio ?? '')),
            DataCell(Text(refugio.emailRefugio ?? '')),
            DataCell(Text(refugio.ubicacionRefugio ?? '')),
            DataCell(Text(refugio.telefonoRefugio ?? '')),
            if (!esRechazado) DataCell(Row(
              children: esActivo
                ? [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editarUsuario(refugio),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmarEliminacion(refugio),
                    ),
                  ]
                : [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () => _aprobarRefugio(refugio),
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () => _rechazarRefugio(refugio),
                    ),
                  ],
            )),
          ]);
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
      _mostrarMensaje('Refugio aprobado con éxito');
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
      _mostrarMensaje('Refugio rechazado con éxito');
      _actualizarListas();
    } else {
      _mostrarMensaje('Error al rechazar refugio: ${result['message']}', esError: true);
    }
  } catch (e) {
    _mostrarMensaje('Error inesperado: ${e.toString()}', esError: true);
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

