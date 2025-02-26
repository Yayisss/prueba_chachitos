class tomasInventario {
  int total_articulos;
  String fecha_registro;
  String estado_actual;
  int conteo;
  String conjunto;

  tomasInventario(
      {this.total_articulos,
      this.fecha_registro,
      this.estado_actual,
      this.conteo,
      this.conjunto});

  factory tomasInventario.fromJson(Map<String, dynamic> json) {
    return tomasInventario(
        total_articulos: json['total_articulos'] as int,
        fecha_registro: json['fecha_registro'] as String,
        conteo: json['conteo'] as int,
        estado_actual: json['estado_actual_conteos'] as String,
        conjunto: json['conjunto'] as String);
  }
}
