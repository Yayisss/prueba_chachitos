class sucursales {
  String sucursal;
  String nombre_sucursal;

  sucursales({this.sucursal, this.nombre_sucursal});

  factory sucursales.fromJson(Map<String, dynamic> json) {
    return sucursales(
        sucursal: json['sucursal'] as String,
        nombre_sucursal: json['nombre_sucursal'] as String);
  }
}
