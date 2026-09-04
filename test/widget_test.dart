import 'package:flutter_test/flutter_test.dart';
import 'package:frutiapp_web/main.dart';

void main() {
  testWidgets('el login muestra sus controles principales', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('FrutiApp'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Recordarme'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
