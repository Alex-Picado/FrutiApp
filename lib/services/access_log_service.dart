import 'dart:convert';

import '../models/access_record.dart';

class AccessLogService {
  final List<AccessRecord> _records = [];

  List<AccessRecord> get records => List.unmodifiable(_records);

  void add(AccessRecord record) => _records.add(record);

  void clear() => _records.clear();

  String exportJson({Iterable<AccessRecord>? records}) {
    final data = (records ?? _records).map((record) => record.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void importJson(String source) {
    try {
      final decoded = jsonDecode(source);

      if (decoded is! List) {
        throw const FormatException('El JSON debe contener una lista');
      }

      final loaded = decoded
          .map(
            (item) => AccessRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      _records
        ..clear()
        ..addAll(loaded);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException(
        'Cada registro debe contener usuario, fechaHora y exitoso válidos',
      );
    }
  }
}