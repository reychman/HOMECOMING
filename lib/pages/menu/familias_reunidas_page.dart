import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';

class FamiliasReunidasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Familias reunidas'),
      ),
      drawer: MenuWidget(),
      body: Center(
        child: Text('Contenido de Familias reunidas'),
      ),
    );
  }
}
