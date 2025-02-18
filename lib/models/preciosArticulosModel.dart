class preciosArticulos {
  double precio1;
  double precio2;

  preciosArticulos({
    this.precio1,
    this.precio2
  });

  factory preciosArticulos.fromJson(Map<String, dynamic> json) {
    return preciosArticulos(
        precio1: double.parse(json['precio1'].toString()),
        precio2: double.parse(json['precio2'].toString())
    );
  }
}