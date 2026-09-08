import 'package:shared_preferences/shared_preferences.dart';
// por si da error use este comando en la terminal: flutter pub add shared_preferences
class PreferencesService {
  final preferencias = SharedPreferencesAsync();

  Future<void> guardarUsuario(String usuario, bool recordar) async {
    if (recordar == true) {
      await preferencias.setString('usuarioRecordado', usuario);
      await preferencias.setBool('recordarUsuario', true);
    } else {
      await preferencias.remove('usuarioRecordado');
      await preferencias.setBool('recordarUsuario', false);
    }
  }

  Future<String> cargarUsuario() async {
    final recordar = await preferencias.getBool('recordarUsuario');

    if (recordar == true) {
      final usuario = await preferencias.getString('usuarioRecordado');

      if (usuario != null) {
        return usuario;
      }
    }

    return '';
  }
}
