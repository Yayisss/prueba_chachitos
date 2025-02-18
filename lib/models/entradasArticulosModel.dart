class entradasArticulos {
  int entrada;
  String persona_confirmo;
  String nombre_proveedor;
  String cFecha;
  double costo_entrada;

  entradasArticulos(
      {this.entrada,
      this.persona_confirmo,
      this.nombre_proveedor,
      this.cFecha,
      this.costo_entrada});

  factory entradasArticulos.fromJson(Map<String, dynamic> json) {
    return entradasArticulos(
        entrada: json['entrada'] as int,
        persona_confirmo: json['persona_confirmo'] as String,
        nombre_proveedor: json['nombre_proveedor'] as String,
        cFecha: json['cFecha'] as String,
        costo_entrada: double.parse(json['costo_entrada'].toString()));
  }
}
