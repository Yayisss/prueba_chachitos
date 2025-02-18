class permisoSucursal{
  int puede_cambiar_sucursal;
  String sucursal;

  permisoSucursal({
    this.puede_cambiar_sucursal,
    this.sucursal
  });

  factory permisoSucursal.fromJson(Map<String, dynamic> json) {
    return permisoSucursal(
        puede_cambiar_sucursal: json['puede_cambiar_sucursal'] as int,
        sucursal: json['sucursal'] as String
    );
  }
}