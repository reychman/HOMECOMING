import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecoming/pages/admin_page.dart';
import 'package:homecoming/pages/admin_usuarios_page.dart';
import 'package:homecoming/pages/menu/perfil_usuario_page.dart';
import 'package:homecoming/pages/propietario_page.dart';
import 'package:homecoming/pages/refugio_page.dart';
import 'package:homecoming/pages/mascotas_perdidas_page.dart';
import 'package:homecoming/pages/menu/familias_reunidas_page.dart';
import 'package:homecoming/pages/menu/home_page.dart';
import 'package:homecoming/pages/menu/mapa_busquedas_page.dart';
import 'package:homecoming/pages/menu/planes_page.dart';
import 'package:homecoming/pages/menu/preguntas_frecuentes_page.dart';
import 'package:homecoming/pages/menu/quienes_somos_page.dart';
import 'package:homecoming/pages/login/iniciar_sesion_page.dart';
import 'package:homecoming/pages/login/crear_usuario_page.dart';
import 'package:homecoming/pages/login/recuperar_contra_page.dart';
import 'package:homecoming/pages/menu/usuario_provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UsuarioProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UsuarioProvider(),
      child: MaterialApp(
      debugShowCheckedModeBanner: false, //quitar el texto debug
      title: 'Homecoming',
      home: PaginaPrincipal(), // Temporary home for debugging
      initialRoute: '/inicio',
      routes: <String, WidgetBuilder>{
        '/inicio': (BuildContext context) => PaginaPrincipal(),
        '/quienes_somos': (BuildContext context) => QuienesSomosPage(),
        '/preguntas_frecuentes': (BuildContext context) => PreguntasFrecuentesPage(),
        '/mapa_busquedas': (BuildContext context) => MapaBusquedasPage(),
        '/familias_reunidas': (BuildContext context) => FamiliasReunidasPage(),
        '/planes': (BuildContext context) => PlanesPage(),
        '/iniciar_sesion': (BuildContext context) => IniciarSesionPage(),
        '/CrearUsuario': (BuildContext context) => CrearUsuarioPage(),
        '/RecuperarContra': (BuildContext context) => RecuperarContraPage(),
        '/MascotasPerdidas': (BuildContext context) => MascotasPerdidas(),
        '/administrador': (BuildContext context) => Administrador(),
        '/propietario': (BuildContext context) => Propietario(),
        '/refugio': (BuildContext context) => Refugio(),
        '/perfilUsuario': (BuildContext context) => PerfilUsuario(),
        '/admin_usuarios': (BuildContext context) => AdminUsuariosPage(),
      },
    )
  );
  }
}