import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'json_downloader.dart';
import 'models/access_record.dart';
import 'services/access_log_service.dart';

class AccessLogPage extends StatefulWidget {
  final AccessLogService logService;

  const AccessLogPage({super.key, required this.logService});

  @override
  State<AccessLogPage> createState() => _AccessLogPageState();
}

class _AccessLogPageState extends State<AccessLogPage> {
  _LogFilter _filter = _LogFilter.todos;

  List<AccessRecord> get _visibleRecords {
    final records = widget.logService.records;
    if (_filter == _LogFilter.exitosos) {
      return records.where((record) => record.exitoso).toList();
    }
    if (_filter == _LogFilter.fallidos) {
      return records.where((record) => !record.exitoso).toList();
    }
    return records;
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _exportarBitacora() {
    descargarJson(widget.logService.exportJson(records: _visibleRecords));
    _mostrarMensaje('Bitácora exportada correctamente.');
  }

  Future<void> _importarBitacora() async {
    const typeGroup = XTypeGroup(
      label: 'JSON',
      extensions: ['json'],
      mimeTypes: ['application/json'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    try {
      final contenido = await file.readAsString();
      widget.logService.importJson(contenido);
      if (!mounted) return;
      setState(() {});
      _mostrarMensaje('Bitácora importada correctamente.');
    } on FormatException catch (error) {
      _mostrarMensaje('Importación incorrecta: JSON inválido: ${error.message}');
    } catch (_) {
      _mostrarMensaje('Importación incorrecta: no se pudo leer el archivo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _visibleRecords;
    final allRecords = widget.logService.records;
    final successful = allRecords.where((record) => record.exitoso).length;
    final successRate = allRecords.isEmpty
        ? 0
        : (successful / allRecords.length * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora de accesos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Total: ${allRecords.length}')),
              Chip(label: Text('Exitosos: $successful')),
              Chip(label: Text('Tasa: $successRate%')),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<_LogFilter>(
            segments: const [
              ButtonSegment(value: _LogFilter.todos, label: Text('Todos')),
              ButtonSegment(
                value: _LogFilter.exitosos,
                label: Text('Exitosos'),
              ),
              ButtonSegment(
                value: _LogFilter.fallidos,
                label: Text('Fallidos'),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (selection) {
              setState(() => _filter = selection.first);
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: records.isEmpty ? null : _exportarBitacora,
                icon: const Icon(Icons.download),
                label: const Text('Exportar JSON'),
              ),
              OutlinedButton.icon(
                onPressed: _importarBitacora,
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar JSON'),
              ),
              TextButton.icon(
                onPressed: allRecords.isEmpty
                    ? null
                    : () => setState(widget.logService.clear),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Limpiar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No hay registros para mostrar.')),
            )
          else
            ...records.reversed.map(
              (record) => ListTile(
                leading: Icon(
                  record.exitoso ? Icons.check_circle : Icons.cancel,
                  color: record.exitoso ? Colors.green : Colors.red,
                ),
                title: Text(
                  record.usuario.isEmpty ? '(sin usuario)' : record.usuario,
                ),
                subtitle: Text(record.fechaHora.toLocal().toString()),
                trailing: Text(record.exitoso ? 'OK' : 'FALLÓ'),
              ),
            ),
        ],
      ),
    );
  }
}

enum _LogFilter { todos, exitosos, fallidos }