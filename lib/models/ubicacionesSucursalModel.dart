class ubicacionesSucursal {
  int ubicacion;
  String nombre_ubicacion;

  ubicacionesSucursal({
    this.ubicacion,
    this.nombre_ubicacion
  });

  factory ubicacionesSucursal.fromJson(Map<String, dynamic> json) {
    return ubicacionesSucursal(
        ubicacion: json['ubicacion'] as int,
        nombre_ubicacion: json['nombre_ubicacion'] as String
    );
  }
}