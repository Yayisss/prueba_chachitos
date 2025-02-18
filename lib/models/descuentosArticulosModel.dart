class descuentosArticulos {
  double descuento;
  String nombre_linea;

  descuentosArticulos({
    this.descuento,
    this.nombre_linea
  });

  factory descuentosArticulos.fromJson(Map<String, dynamic> json) {
    return descuentosArticulos(
        descuento: double.parse(json['descuento'].toString()),
        nombre_linea: json['nombre_linea'] as String
    );
  }
}