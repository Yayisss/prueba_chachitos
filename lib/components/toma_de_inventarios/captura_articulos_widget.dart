import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i_p_s_mant/backend/database_connect.dart';
import 'package:i_p_s_mant/components/busqueda_de_articulos/busqueda_de_articulo_widget.dart';
import 'package:i_p_s_mant/models/detallesTomaInventarioModel.dart';
import 'package:i_p_s_mant/models/userModel.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../backend/mensajes.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../flutter_flow/flutter_flow_util.dart';
import '../scan_event_widget.dart';

class CapturaArticulosWidget extends StatefulWidget {
  final user usuario;
  final int toma;
  final List<detallesTomaInventario> detallesTomas;
  const CapturaArticulosWidget(
      {Key key, this.usuario, this.toma, this.detallesTomas})
      : super(key: key);

  @override
  _CapturaArticulosWidgetState createState() => _CapturaArticulosWidgetState();
}

class _CapturaArticulosWidgetState extends State<CapturaArticulosWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController articuloController, cantidadController;
  CarouselController carruselController = CarouselController();
  int carruselIndex = 0;
  String cDetalles = "";
  bool buscando = false;

  double cantidadGuardadaAnterior = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    articuloController = TextEditingController();
    cantidadController = TextEditingController();
    cantidadController.text = NumberFormat("#,###,###")
        .format(widget.detallesTomas[carruselIndex].cantidad);

    // Restablecer la cantidad de cada artículo a 0 al volver a la toma
    widget.detallesTomas.forEach((articulo) {
      articulo.cantidad = 0; // Restablecer la cantidad a 0
    });

    cantidadController.text = NumberFormat("#,###,###")
        .format(widget.detallesTomas[carruselIndex].cantidad);
  }

  _aumentaCantidad() async {
    if (cantidadController.value.text.isEmpty) {
      this.cantidadController.text = "1";
    } else {
      this.cantidadController.text =
          (int.parse(this.cantidadController.text) + 1).toString();
    }
    widget.detallesTomas[carruselIndex].cantidad =
        double.parse(this.cantidadController.text);
  }

  _disminuyeCantidad() async {
    if (cantidadController.value.text.isNotEmpty) {
      if (int.parse(this.cantidadController.text) != 0) {
        this.cantidadController.text =
            (int.parse(this.cantidadController.text) - 1).toString();
        widget.detallesTomas[carruselIndex].cantidad =
            double.parse(this.cantidadController.text);
      }
    }
  }

  _busqueda() {
    if (articuloController.value.text.isNotEmpty) {
      if (articuloController.value.text == "") {
        buscando = false;
        widget.detallesTomas.forEach((articulo) {
          setState(() {
            articulo.busqueda = true;
          });
        });
      } else {
        buscando = true;
        widget.detallesTomas.forEach((articulo) {
          String busqueda = articuloController.value.text.toUpperCase();
          if (articulo.clave_articulo.toString().contains(busqueda) ||
              articulo.articulo.toUpperCase().contains(busqueda) ||
              articulo.clave_anterior.toUpperCase().contains(busqueda) ||
              articulo.nombre_articulo.toUpperCase().contains(busqueda)) {
            setState(() {
              articulo.busqueda = true;
            });
          } else {
            setState(() {
              articulo.busqueda = false;
            });
          }
        });
      }
    } else {
      buscando = false;
      widget.detallesTomas.forEach((articulo) {
        setState(() {
          articulo.busqueda = true;
        });
      });
    }
  }

  _guardarCapturaDeArticulos() async {
    widget.detallesTomas.forEach((articulo) {
      // Actualizamos el último registro y la cantidad total
      articulo.ultimo_registro = articulo
          .cantidad; // Guardamos la cantidad registrada como último registro
      articulo.cantidad_total = (articulo.ultimo_registro +
          articulo
              .cantidad); // Sumamos el último registro con la nueva cantidad

      cDetalles += articulo.clave_articulo.toString() + "|";
      cDetalles += articulo.cantidad.toInt().toString() + "|";
      cDetalles += articulo.cantidad_mal_estado.toInt().toString() + "|";
      cDetalles += articulo.piezas.toInt().toString() + "|";
      cDetalles += articulo.piezas_mal_estado.toInt().toString() + "Ç";
    });

    // Guardamos la toma en la base de datos
    DatabaseProvider.guardaTomaInventario(
            widget.toma, widget.usuario.usuario, cDetalles)
        .then((value) {
      if (value) {
        Navigator.pop(context, true);
      } else {
        MensajesProvider.mensaje(context, 'Ocurrió un error');
      }
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      MensajesProvider.mensajeExtendido(context, "Error", error.toString());
    });
  }

  _leerCodigoBarras() async {
    // Solicitar permiso para la cámara
    await Permission.camera.request();

    // Iniciar la lectura del código de barras
    var barcode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanEventWidget(
          usuario: widget.usuario,
        ),
      ),
    );

    int index = 0;
    bool encontrado = false;

    // Verificamos si el código de barras no es nulo
    if (barcode != null) {
      widget.detallesTomas.forEach((articulo) {
        // Compara el código de barras escaneado con los datos de los artículos
        if (articulo.clave_articulo.toString().contains(barcode) ||
            articulo.articulo.toUpperCase().contains(barcode) ||
            articulo.clave_anterior.toUpperCase().contains(barcode)) {
          // Artículo encontrado, actualizamos la cantidad
          setState(() {
            // Aumenta la cantidad en 1, o puedes modificarlo según sea necesario
            articulo.cantidad += 1;
            // Refleja la actualización en el controlador de cantidad
            cantidadController.text =
                NumberFormat("#,###,###").format(articulo.cantidad);
          });

          // Cambia al carrusel de ese artículo
          carruselController.jumpToPage(index);
          encontrado = true;
        }
        index++;
      });

      // Si no se encuentra el artículo, mostramos un mensaje
      if (!encontrado) {
        Fluttertoast.showToast(
          msg: "El artículo no existe en la Toma de Inventario",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } else {
      // Si la lectura fue cancelada, mostramos un mensaje
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Busqueda cancelada."),
      ));
    }
  }

  _openBusquedaDeArticulos() {
    print(widget.detallesTomas[carruselIndex].articulo);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BusquedaDeArticuloWidget(
                  usuario: widget.usuario,
                  cArticulo: widget.detallesTomas[carruselIndex].articulo,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 243, 124, 33),
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 35,
            ),
            tooltip: 'Volver',
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Captura de Artículos",
            style: GoogleFonts.getFont('Poppins',
                fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
          ),
          actions: [
            PopupMenuButton(
                tooltip: 'Opciones',
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [Text("Ver artículo")],
                      ),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 1) {
                    //Ver articulo
                    _openBusquedaDeArticulos();
                  }
                }),
          ],
          centerTitle: true,
        ),
        backgroundColor: FlutterFlowTheme.of(context).background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(15, 15, 15, 0),
                  child: Column(children: [
                    Text(
                      "Desliza hacia los lados para navegar entre los artículos o busca un articulo mediante el cuadro de texto.",
                      style: GoogleFonts.getFont('Poppins',
                          fontSize: 13, color: Color.fromARGB(255, 78, 76, 76)),
                    ),
                    SizedBox(height: 10),
                  ])),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    // Barra de búsqueda ajustada
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5), // Margen horizontal
                      child: TextFormField(
                        onChanged: (value) {
                          _busqueda();
                        },
                        controller: articuloController,
                        decoration: InputDecoration(
                          hintText:
                              'Escribe un nombre o clave de artículo aquí',
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.orange),
                          filled: true,
                          fillColor: Color(0xFFF4F4F4), // Color de fondo claro
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFF57C00),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // List ade resultados
                    ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 1),
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: widget.detallesTomas.length,
                        itemBuilder: (context, listViewIndex) {
                          final i = widget.detallesTomas[listViewIndex];
                          if (buscando && i.busqueda) {
                            return InkWell(
                              onTap: () {
                                carruselController.jumpToPage(listViewIndex);
                                articuloController.text = "";
                                _busqueda();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(i.articulo,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text(i.nombre_articulo,
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Container();
                        }),

                    SizedBox(height: 20),

                    CarouselSlider(
                      carouselController: carruselController,
                      options: CarouselOptions(
                        height: 400.0,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            carruselIndex = index;
                            cantidadController.text = NumberFormat("#,###,###")
                                .format(widget
                                    .detallesTomas[carruselIndex].cantidad);
                          });
                        },
                      ),
                      items: widget.detallesTomas.map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10)
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(i.articulo,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text(i.nombre_articulo,
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey)),
                                    SizedBox(height: 20),

                                    // Mostrar la unidad seguida de "totes"
                                    Text(
                                      "${i.nombre_unidad}",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    SizedBox(height: 10),

                                    // Contenedor para los botones de aumento y disminución
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        FloatingActionButton(
                                          onPressed: () {
                                            _disminuyeCantidad(); // Cambié esto para pasar el artículo
                                          },
                                          child: Icon(Icons.remove),
                                          backgroundColor: Color(0xFFF57C00),
                                        ),
                                        Container(
                                          width: 80,
                                          child: TextFormField(
                                            onChanged: (value) {
                                              widget
                                                      .detallesTomas[carruselIndex]
                                                      .cantidad =
                                                  double.parse(this
                                                      .cantidadController
                                                      .text);
                                            },
                                            controller: cantidadController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        FloatingActionButton(
                                          onPressed: () {
                                            _aumentaCantidad(); // Cambié esto también para pasar el artículo
                                          },
                                          child: Icon(Icons.add),
                                          backgroundColor: Color(0xFFF57C00),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Text(
                                      "Último registro: ${(i.ultimo_registro ?? 0).toInt()} ${i.nombre_unidad}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600]),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Existencia Total: ${(i.cantidad_total ?? 0).toInt()} ${i.nombre_unidad}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                  ],
                ),
              )
            ]),
          ),
        ),
        floatingActionButton: Align(
          alignment: Alignment
              .topRight, // Alinea los botones en la esquina superior derecha
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment:
                CrossAxisAlignment.end, // Alinea los botones a la derecha
            children: [
              // Botón "Leer Artículo"
              FloatingActionButton(
                heroTag: "leeArticulo",
                onPressed: () {
                  _leerCodigoBarras();
                },
                backgroundColor: Color.fromARGB(255, 243, 124, 33),
                tooltip: "Leer código de barras",
                child: const Icon(FontAwesomeIcons.barcode),
              ),
              SizedBox(height: 10), // Espacio entre los botones
              // Botón "Guardar"
              FloatingActionButton(
                heroTag: "guardaCaptura",
                onPressed: () {
                  _guardarCapturaDeArticulos();
                },
                backgroundColor: Color.fromARGB(255, 243, 124, 33),
                tooltip: "Guardar",
                child: const Icon(Icons.save),
              ),
            ],
          ),
        ));
  }
}
