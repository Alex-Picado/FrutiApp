import 'dart:convert';

import 'access_log_page.dart';
import 'services/access_log_service.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Producto {
  const Producto({required this.id, required this.nombre});
  final int id;
  final String nombre;
  int get precio => id * 100;
  factory Producto.fromJson(Map<String, dynamic> json) =>
      Producto(id: json['id'] as int, nombre: json['title'] as String);
}

Future<List<Producto>> cargarProductos() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/posts'),
  );
  if (response.statusCode != 200) {
    throw Exception('No se pudo cargar la información');
  }

  final datos = jsonDecode(response.body) as List<dynamic>;
  return datos
      .map((dato) => Producto.fromJson(dato as Map<String, dynamic>))
      .toList();
}

class HomePage extends StatefulWidget {
  final AccessLogService logService;

  const HomePage({super.key, required this.logService});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<Producto>> _productos = cargarProductos();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('FrutiApp - Catálogo'),
      actions: [
        IconButton(
          tooltip: 'Bitácora de accesos',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccessLogPage(logService: widget.logService),
            ),
          ),
          icon: const Icon(Icons.fact_check),
        ),
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: FutureBuilder<List<Producto>>(
      future: _productos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudo cargar la información.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }
        final productos = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${producto.id}')),
                title: Text(producto.nombre),
                subtitle: Text('Precio: ${producto.precio} colones'),
              ),
            );
          },
        );
      },
    ),
  );
}
