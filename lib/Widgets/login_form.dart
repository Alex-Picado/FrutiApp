import 'package:flutter/material.dart';
import '../home_page.dart';
import '../models/access_record.dart';
import '../services/access_log_service.dart';

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
  String mensaje = '';

  bool _recordarme = false;

  //separador

  void validarAcceso() {
  final usuario = usuarioController.text.trim();
  final password = passwordController.text;

  final exitoso = usuario == 'admin' && password == '1234';

  logService.add(
    AccessRecord(
      usuario: usuario,
      fechaHora: DateTime.now(),
      exitoso: exitoso,
    ),
  );

  if (exitoso) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          logService: logService,
        ),
      ),
    );
  } else {
    setState(() {
      mensaje = 'Usuario o contraseña incorrectos';
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
              if (value == null || value.isEmpty) {
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            obscureText: true,
            validator: (value) {
              //if (value == null || value.length < 6) {
              // return 'La contraseña debe tener al menos 6 caracteres';
              //}
              if (value == null || value.isEmpty) {
                return 'Por favor ingrrese su contraseña';
              }
              return null;
            },
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Checkbox(
                value: _recordarme,
                onChanged: (value) {
                  setState(() {
                    if (value == null) {
                      _recordarme = false;
                    } else {
                      _recordarme = value;
                    }
                  });
                },
              ),
              const Text('Recordarme'),
            ],
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                validarAcceso();
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
