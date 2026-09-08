class AccessRecord {
  final String usuario;
  final DateTime fechaHora;
  final bool exitoso;

  const AccessRecord({
    required this.usuario,
    required this.fechaHora,
    required this.exitoso,
  });

  String obtenerResultado() {
    if (exitoso == true) {
      return 'AUTORIZADO';
    } else {
      return 'RECHAZADO';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'fechaHora': fechaHora.toIso8601String(),
      'resultado': obtenerResultado(),
    };
  }

  factory AccessRecord.fromJson(Map<String, dynamic> json) {
  String resultado = json['resultado'];

  if (resultado != 'AUTORIZADO' && resultado != 'RECHAZADO') {
    throw FormatException(
      'El resultado debe ser AUTORIZADO o RECHAZADO',
    );
  }

  bool exitoso = resultado == 'AUTORIZADO';

  return AccessRecord(
    usuario: json['usuario'],
    fechaHora: DateTime.parse(json['fechaHora']),
    exitoso: exitoso,
  );
}
}