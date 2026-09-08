import 'package:flutter/material.dart';

import '../home_page.dart';
import '../models/access_record.dart';
import '../services/access_log_service.dart';
import '../services/preferences_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();

  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();
  final logService = AccessLogService();
  final preferencesService = PreferencesService();

  String mensaje = '';

  bool _recordarme = false;
  bool _ocultarPassword = true;
  //separador

  @override
  void initState() {
    super.initState();
    cargarUsuarioRecordado();
  }

  Future<void> cargarUsuarioRecordado() async {
    final usuario = await preferencesService.cargarUsuario();

    if (mounted == false) {
      return;
    }

    setState(() {
      usuarioController.text = usuario;

      if (usuario.isNotEmpty) {
        _recordarme = true;
      } else {
        _recordarme = false;
      }
    });
  }

  IconData obtenerIconoPassword() {
    if (_ocultarPassword == true) {
      return Icons.visibility;
    } else {
      return Icons.visibility_off;
    }
  }

  Future<void> validarAcceso() async {
    final usuario = usuarioController.text.trim();
    final password = passwordController.text;

    await preferencesService.guardarUsuario(usuario, _recordarme);

    if (mounted == false) {
      return;
    }

    final exitoso = usuario == 'admin' && password == '1234';

    logService.add(
      AccessRecord(
        usuario: usuario,
        fechaHora: DateTime.now(),
        exitoso: exitoso,
      ),
    );

    if (exitoso == true) {
      setState(() {
        mensaje = '';
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Acceso autorizado'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 8),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return HomePage(logService: logService);
          },
        ),
      );
    } else {
      setState(() {
        mensaje = 'Acceso rechazado: usuario o contraseña incorrectos';
      });
    }
  }

  //separador

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: usuarioController,

            decoration: InputDecoration(
              labelText: 'Usuario',
              //labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            //validator: (value) {
            //if (value == null || value.isEmpty) {
            //return 'Ingrese el correo';
            //}

            //if (!value.contains('@') || !value.contains('.')) {
            //return 'Correo no válido';
            //}

            //return null;
            //},
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingrese el usuario';
              }

              return null;
            },
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',

              prefixIcon: Icon(Icons.lock),

              suffixIcon: IconButton(
                tooltip: 'Mostrar u ocultar contraseña',
                icon: Icon(obtenerIconoPassword()),
                onPressed: () {
                  if (_ocultarPassword == true) {
                    setState(() {
                      _ocultarPassword = false;
                    });
                  } else {
                    setState(() {
                      _ocultarPassword = true;
                    });
                  }
                },
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            obscureText: _ocultarPassword,

            validator: (value) {
              //if (value == null || value.length < 6) {
              //  return 'La contraseña debe tener al menos 6 caracteres';
              //}

              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su contraseña';
              }

              return null;
            },
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Checkbox(
                value: _recordarme,
                onChanged: (value) async {
                  setState(() {
                    if (value == null) {
                      _recordarme = false;
                    } else {
                      _recordarme = value;
                    }
                  });

                  if (_recordarme == false) {
                    await preferencesService.guardarUsuario('', false);
                  }
                },
              ),
              const Text('Recordarme'),
            ],
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await validarAcceso();
              }
            },
            child: const Text('Ingresar'),
          ),

          if (mensaje.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
