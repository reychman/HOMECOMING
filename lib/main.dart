import 'package:flutter/material.dart';
import 'package:homecoming/pages/admin_usuarios_page.dart';
import 'package:homecoming/pages/login/perfil_usuario_page.dart';
import 'package:homecoming/pages/mascotas_perdidas_page.dart';
import 'package:homecoming/pages/menu/familias_reunidas_page.dart';
import 'package:homecoming/pages/menu/home_page.dart';
import 'package:homecoming/pages/menu/mapa_busquedas_page.dart';
import 'package:homecoming/pages/menu/reportes_page.dart';
import 'package:homecoming/pages/menu/preguntas_frecuentes_page.dart';
import 'package:homecoming/pages/menu/quienes_somos_page.dart';
import 'package:homecoming/pages/login/iniciar_sesion_page.dart';
import 'package:homecoming/pages/login/crear_usuario_page.dart';
import 'package:homecoming/pages/usuario_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Homecoming',
      theme: ThemeData(
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 96.0, fontWeight: FontWeight.bold),
        ),
      ),
      // Agregamos soporte para localización
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Definimos los idiomas soportados
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés
      ],
      // Establecemos el idioma por defecto
      locale: const Locale('es', 'ES'),
      home: CheckLoginStatus(),
      routes: <String, WidgetBuilder>{
        '/inicio': (BuildContext context) => PaginaPrincipal(),
        '/quienes_somos': (BuildContext context) => QuienesSomosPage(),
        '/preguntas_frecuentes': (BuildContext context) => PreguntasFrecuentesPage(),
        '/mapa_busquedas': (BuildContext context) => MapaBusquedasPage(),
        '/familias_reunidas': (BuildContext context) => FamiliasReunidasPage(),
        '/reportes': (BuildContext context) => ReportesPage(),
        '/iniciar_sesion': (BuildContext context) => IniciarSesionPage(),
        '/CrearUsuario': (BuildContext context) => CrearUsuarioPage(),
        '/MascotasPerdidas': (BuildContext context) => MascotasPerdidas(),
        '/perfilUsuario': (BuildContext context) => PerfilUsuario(),
        '/admin_usuarios': (BuildContext context) => AdminUsuarios(),
      },
    );
  }
}

class CheckLoginStatus extends StatefulWidget {
  @override
  _CheckLoginStatusState createState() => _CheckLoginStatusState();
}

class _CheckLoginStatusState extends State<CheckLoginStatus> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    String? storedPassword = prefs.getString('password');

    if (storedUsername != null && storedPassword != null) {
      // Si las credenciales están guardadas, intentamos el login
      bool loginSuccess = await _login(storedUsername, storedPassword);
      if (loginSuccess) {
        setState(() {
          isLoggedIn = true;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _login(String username, String password) async {
    // Simulamos el método de login. Debes reemplazar esta parte con tu lógica real de login.
    // Supongamos que el login fue exitoso:
    await Future.delayed(Duration(seconds: 1));
    return true; // Devuelve true si el login fue exitoso.
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return isLoggedIn ? PaginaPrincipal() : PaginaPrincipal();
    }
  }
}