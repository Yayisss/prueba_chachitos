class user {
  int sucursal;
  int sucursal_almacen;
  int usuario;
  int es_supervisor;
  String nombre_persona;
  String nombre_cliente;
  String cumpleanos;
  String mensaje;
  int status;
  int exito;

  user({
    this.sucursal,
    this.sucursal_almacen,
    this.usuario,
    this.es_supervisor,
    this.nombre_persona,
    this.nombre_cliente,
    this.cumpleanos,
    this.mensaje,
    this.status,
    this.exito
  });

  factory user.fromJson(Map<String, dynamic> json) {
    return user(
      sucursal: json['sucursal'] as int,
      sucursal_almacen: json['sucursal_almacen'] as int,
      usuario: json['usuario'] as int,
      es_supervisor: json['es_supervisor'] as int,
      nombre_persona: json['nombre_persona'] as String,
      nombre_cliente: json['nombre_cliente'] as String,
      mensaje: json['mensaje'] as String,
      status: json['status'] as int,
      exito: json['exito'] as int,
    );
  }
}
