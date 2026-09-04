import 'package:flutter_test/flutter_test.dart';
import 'package:frutiapp_web/models/access_record.dart';
import 'package:frutiapp_web/services/access_log_service.dart';

void main() {
  final fecha = DateTime.utc(2026, 9, 3, 12, 30);

  test('exporta solo los datos permitidos e importa registros', () {
    final service = AccessLogService();
    service.add(
      AccessRecord(usuario: 'admin', fechaHora: fecha, exitoso: true),
    );

    final json = service.exportJson();

    expect(json, contains('"usuario": "admin"'));
    expect(json, contains('"fechaHora": "2026-09-03T12:30:00.000Z"'));
    expect(json, contains('"exitoso": true'));
    expect(json, isNot(contains('password')));
    expect(json, isNot(contains('1234')));

    final imported = AccessLogService()..importJson(json);
    expect(imported.records, hasLength(1));
    expect(imported.records.single.usuario, 'admin');
  });

  test('importar reemplaza los registros actuales', () {
    final service = AccessLogService()
      ..add(AccessRecord(usuario: 'anterior', fechaHora: fecha, exitoso: false));

    service.importJson(
      '[{"usuario":"nuevo","fechaHora":"2026-09-03T12:30:00.000Z","exitoso":true}]',
    );

    expect(service.records, hasLength(1));
    expect(service.records.single.usuario, 'nuevo');
  });

  test('rechaza JSON invalido o con estructura incorrecta', () {
    final service = AccessLogService();

    expect(() => service.importJson('{malformed'), throwsFormatException);
    expect(() => service.importJson('[{"usuario":"sin fecha"}]'),
        throwsFormatException);
  });
}