import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:http/http.dart' as http;

class EditarPublicacionPage extends StatefulWidget {
  final Map<String, dynamic> publicacion;

  EditarPublicacionPage({required this.publicacion});

  @override
  _EditarPublicacionPageState createState() => _EditarPublicacionPageState();
}

class _EditarPublicacionPageState extends State<EditarPublicacionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.publicacion['nombre']);
    _descripcionController = TextEditingController(text: widget.publicacion['descripcion']);
  }

  Future<void> _editarPublicacion() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/editar_publicacion.php'),
        body: {
          'id': widget.publicacion['id'].toString(),
          'nombre': _nombreController.text,
          'descripcion': _descripcionController.text,
        },
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publicación actualizada correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la publicación')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Publicación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la Mascota'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editarPublicacion,
                child: Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
