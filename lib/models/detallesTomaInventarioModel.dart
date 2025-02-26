import 'package:flutter/material.dart';

class detallesTomaInventario {
  int clave_articulo;
  int cantidadGuardada;
  int conteo;
  String clave_anterior;
  String articulo;
  String nombre_articulo;
  String nombre_ubicacion;
  String nombre_unidad;
  String nombre_unidad_alterna;
  double cantidad;
  double cantidad_mal_estado;
  double piezas;
  double piezas_mal_estado;
  double cantidad_comprometida;
  bool busqueda;
  double cantidadTotal;

  TextEditingController cantidadController;

  detallesTomaInventario({
    this.clave_articulo,
    this.clave_anterior,
    this.articulo,
    this.conteo,
    this.nombre_articulo,
    this.nombre_ubicacion,
    this.nombre_unidad,
    this.nombre_unidad_alterna,
    this.cantidad = 0,
    this.cantidad_mal_estado = 0,
    this.piezas = 0,
    this.piezas_mal_estado = 0,
    this.cantidad_comprometida = 0,
    this.busqueda = true,
    this.cantidadTotal = 0,
    this.cantidadGuardada = 0
  }) {
    cantidadController = TextEditingController(text: cantidad.toString());
  }

  factory detallesTomaInventario.fromJson(Map<String, dynamic> json) {
    return detallesTomaInventario(
      clave_articulo: json['clave_articulo'] as int,
      clave_anterior: json['clave_anterior'] as String,
      articulo: json['articulo'] as String,
      conteo: json['conteo'] as int,
      nombre_articulo: json['nombre_articulo'] as String,
      nombre_ubicacion: json['nombre_ubicacion'] as String,
      nombre_unidad: json['nombre_unidad'] as String,
      nombre_unidad_alterna: json['nombre_unidad_alterna'] as String,
      cantidad: double.tryParse(json['cantidad'].toString()) ?? 0.0,
      cantidad_mal_estado:
          double.tryParse(json['cantidad_mal_estado'].toString()) ?? 0.0,
      piezas: double.tryParse(json['piezas'].toString()) ?? 0.0,
      piezas_mal_estado:
          double.tryParse(json['piezas_mal_estado'].toString()) ?? 0.0,
      cantidad_comprometida:
          double.tryParse(json['cantidad_comprometida'].toString()) ?? 0.0,
      busqueda: true,
      cantidadTotal: double.tryParse(json['cantidadTotal'].toString()) ?? 0.0
    )..cantidadController =
        TextEditingController(text: json['cantidad'].toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'clave_articulo': clave_articulo,
      'clave_anterior': clave_anterior,
      'articulo': articulo,
      'conteo': conteo,
      'nombre_articulo': nombre_articulo,
      'nombre_ubicacion': nombre_ubicacion,
      'nombre_unidad': nombre_unidad,
      'nombre_unidad_alterna': nombre_unidad_alterna,
      'cantidad': cantidad,
      'cantidad_mal_estado': cantidad_mal_estado,
      'piezas': piezas,
      'piezas_mal_estado': piezas_mal_estado,
      'cantidad_comprometida': cantidad_comprometida,
      'busqueda': busqueda,
      'cantidadTotal': cantidadTotal
    };
  }

  void calcularCantidadTotal() {
    this.cantidadTotal = this.cantidad;
  }
}
