class articulosComprometidos {
  int folio;
  String tipo;
  String fecha_texto;
  String promesa_texto;
  String jefe;
  String estado_actual;
  String nombre_color;
  String informacion_surtido;
  double cantidad;

  articulosComprometidos({
    this.folio,
    this.tipo,
    this.fecha_texto,
    this.promesa_texto,
    this.jefe,
    this.estado_actual,
    this.nombre_color,
    this.informacion_surtido,
    this.cantidad
  });

  factory articulosComprometidos.fromJson(Map<String, dynamic> json) {
    return articulosComprometidos(
      folio: json['folio'] as int,
      tipo: json['tipo'] as String,
      fecha_texto: json['fecha_texto'] as String,
      promesa_texto: json['promesa_texto'] as String,
      jefe: json['jefe'] as String,
      estado_actual: json['estado_actual'] as String,
      nombre_color: json['nombre_color'] as String,
      informacion_surtido: json['informacion_surtido'] as String,
      cantidad: double.parse(json['cantidad'].toString()),
    );
  }
}