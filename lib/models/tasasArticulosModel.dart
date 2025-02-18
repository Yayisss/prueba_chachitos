class tasasArticulos {
  String tipo_IEPS;
  double tasa_IEPS;
  int es_tasa_cero;

  tasasArticulos({
    this.tipo_IEPS,
    this.tasa_IEPS,
    this.es_tasa_cero
  });

  factory tasasArticulos.fromJson(Map<String, dynamic> json) {
    return tasasArticulos(
        tipo_IEPS: json['tipo_IEPS'] as String,
        tasa_IEPS: double.parse(json['tasa_IEPS'].toString()),
        es_tasa_cero: json['es_tasa_cero'] as int
    );
  }
}