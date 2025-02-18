class articulos {
  int clave_articulo;
  String clave_anterior;
  String articulo;
  String nombre_articulo;
  String nombre_ubicacion;
  String nombre_unidad;
  String nombre_unidad_alterna;
  String ultima_venta;
  String surtio_ultima_venta;
  String ultima_toma;
  String ultimo_traspaso;
  double cantidad_comprometida;
  double disponible;
  double ex_total;
  double tasa_IVA;
  int ubicacion;

  articulos(
      {this.clave_articulo,
      this.clave_anterior,
      this.articulo,
      this.nombre_articulo,
      this.nombre_ubicacion,
      this.nombre_unidad,
      this.nombre_unidad_alterna,
      this.ultima_venta,
      this.surtio_ultima_venta,
      this.ultima_toma,
      this.ultimo_traspaso,
      this.cantidad_comprometida,
      this.disponible,
      this.ex_total,
      this.tasa_IVA,
      this.ubicacion});

  factory articulos.fromJson(Map<String, dynamic> json) {
    var jsonIVA = json['tasa_IVA'];
    double iva = 0;
    if (jsonIVA != null) iva = double.parse(json['tasa_IVA'].toString());

    return articulos(
        clave_articulo: json['clave_articulo'] as int,
        clave_anterior: json['clave_anterior'] as String,
        articulo: json['articulo'] as String,
        nombre_articulo: json['nombre_articulo'] as String,
        nombre_ubicacion: json['nombre_ubicacion'] as String,
        nombre_unidad: json['nombre_unidad'] as String,
        nombre_unidad_alterna: json['nombre_unidad_alterna'] as String,
        ultima_venta: json['ultima_venta'] as String,
        surtio_ultima_venta: json['surtio_ultima_venta'] as String,
        ultima_toma: json['ultima_toma'] as String,
        ultimo_traspaso: json['ultimo_traspaso'] as String,
        cantidad_comprometida:
            double.parse(json['cantidad_comprometida'].toString()),
        disponible: double.parse(json['disponible'].toString()),
        ex_total: double.parse(json['ex_total'].toString()),
        tasa_IVA: iva,
        ubicacion: json['ubicacion'] as int);
  }
}
