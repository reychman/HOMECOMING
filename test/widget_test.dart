import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homecoming/main.dart';

void main() {
  testWidgets('Login page widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verificar que el widget de inicio de sesión se muestra correctamente.
    expect(find.text('Inicio de Sesión'), findsOneWidget);
    expect(find.text('Usuario o contraseña incorrecto'), findsNothing);

    // Simular la entrada de datos y prueba del inicio de sesión
    await tester.enterText(find.byKey(Key('usernameField')), 'testuser');
    await tester.enterText(find.byKey(Key('passwordField')), 'testpassword');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verificar que se navega correctamente a la página de administrador o usuarios
    expect(find.text('Inicio de Sesión'), findsNothing);
    expect(find.text('Usuario o contraseña incorrecto'), findsNothing);
  });
}
