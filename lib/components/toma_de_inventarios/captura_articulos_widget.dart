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
import '../scan_event_widget.dart';

class CapturaArticulosWidget extends StatefulWidget {
  final user usuario;
  final int toma;
  final List<detallesTomaInventario> detallesTomas;
  final int conteo;
  const CapturaArticulosWidget(
      {Key key, this.usuario, this.toma, this.detallesTomas, this.conteo})
      : super(key: key);

  @override
  _CapturaArticulosWidgetState createState() => _CapturaArticulosWidgetState();
}

class _CapturaArticulosWidgetState extends State<CapturaArticulosWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController articuloController, cantidadController;
  CarouselController carruselController = CarouselController();
  int carruselIndex = 0;
  String cDetalles = "";
  bool buscando = false;
  double cantidadTotal = 0.0;
  Map<int, double> cantidadesTemporales = {}; // Guardar cantidades modificadas

  @override
  void dispose() {
    super.dispose();
  }

  List<TextEditingController> cantidadControllers = [];

  @override
  void initState() {
    super.initState();
    articuloController = TextEditingController();
    cantidadControllers = widget.detallesTomas
        .map((articulo) => TextEditingController(text: '0'))
        .toList();
  }

  _actualizarArticulo() {
    final articulo = widget.detallesTomas[carruselIndex];
    double cantidadModificada =
        double.parse(cantidadControllers[carruselIndex].text);
    cantidadesTemporales[articulo.clave_articulo] = cantidadModificada;
    articulo.cantidad += cantidadModificada;
    cantidadControllers[carruselIndex].text = '0';
  }

  _aumentaCantidad() {
    setState(() {
      double count = double.parse(cantidadControllers[carruselIndex].text);
      count += 1.0;
      cantidadControllers[carruselIndex].text = count.toStringAsFixed(2);
    });
  }

  _disminuyeCantidad() {
    if (cantidadControllers[carruselIndex].text.isNotEmpty) {
      double count = double.parse(cantidadControllers[carruselIndex].text);
      if (count > 0) {
        setState(() {
          count -= 1.0;
          cantidadControllers[carruselIndex].text = count.toStringAsFixed(2);
        });
      }
    }
  }

  _guardarCapturaDeArticulos(bool regresar) async {
    String cDetallesConteo1 = "";
    String cDetallesConteo2 = "";

    widget.detallesTomas.forEach((articulo) {
      double contador = double.parse(
          cantidadControllers[widget.detallesTomas.indexOf(articulo)].text);
      articulo.cantidad += contador;

      if (widget.conteo == 1) {
        cDetallesConteo1 += articulo.clave_articulo.toString() + "|";
        cDetallesConteo1 += articulo.cantidad.toString() + "|";
        cDetallesConteo1 += articulo.cantidad_mal_estado.toString() + "|";
        cDetallesConteo1 += articulo.piezas.toString() + "|";
        cDetallesConteo1 += articulo.piezas_mal_estado.toString() + "Ç";
      } else if (widget.conteo == 2) {
        cDetallesConteo2 += articulo.clave_articulo.toString() + "|";
        cDetallesConteo2 += articulo.cantidad.toString() + "|";
        cDetallesConteo2 += articulo.cantidad_mal_estado.toString() + "|";
        cDetallesConteo2 += articulo.piezas.toString() + "|";
        cDetallesConteo2 += articulo.piezas_mal_estado.toString() + "Ç";
      }
    });

    setState(() {
      cantidadControllers.forEach((controller) => controller.text = '0');
    });

    if (widget.conteo == 1) {
      DatabaseProvider.guardaTomaInventario(widget.toma, widget.conteo,
              widget.usuario.usuario, cDetallesConteo1)
          .then((value) {
        if (value) {
          if (regresar) {
            Navigator.pop(
                context, true); // Solo regresa si el parámetro es verdadero
          }
        } else {
          MensajesProvider.mensaje(context, 'Ocurrió un error');
        }
      }).onError((error, stackTrace) {
        MensajesProvider.mensajeExtendido(context, "Error", error.toString());
      });
    } else if (widget.conteo == 2) {
      DatabaseProvider.guardaTomaInventario(widget.toma, widget.conteo,
              widget.usuario.usuario, cDetallesConteo2)
          .then((value) {
        if (value) {
          if (regresar) {
            Navigator.pop(
                context, true); // Solo regresa si el parámetro es verdadero
          }
        } else {
          MensajesProvider.mensaje(context, 'Ocurrió un error');
        }
      }).onError((error, stackTrace) {
        MensajesProvider.mensajeExtendido(context, "Error", error.toString());
      });
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
          String busqueda = articuloController.value.text.trim().toUpperCase();
          if (articulo.clave_articulo.toString().contains(busqueda) ||
              articulo.articulo.toUpperCase().trim().contains(busqueda) ||
              articulo.clave_anterior.toUpperCase().trim().contains(busqueda) ||
              articulo.nombre_articulo
                  .toUpperCase()
                  .trim()
                  .contains(busqueda)) {
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

  _leerCodigoBarras() async {
    await Permission.camera.request();

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

    if (barcode != null) {
      widget.detallesTomas
        ..forEach((articulo) {
          if (articulo.clave_articulo.toString().contains(barcode) ||
              articulo.articulo.toUpperCase().contains(barcode) ||
              articulo.clave_anterior.toUpperCase().contains(barcode)) {
            setState(() {
              int count = int.parse(cantidadControllers[index].text);
              cantidadControllers[index].text = (count + 1).toString();
              cantidadTotal += 1;
            });

            carruselController.jumpToPage(index);
            encontrado = true;
          }
          index++;
        });

      if (!encontrado) {
        Fluttertoast.showToast(
          msg: "El artículo no existe en la Toma de Inventario",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Busqueda cancelada."),
      ));
    }
  }

  _openBusquedaDeArticulos() {
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
                    "Conteo: ${widget.conteo}",
                    style: GoogleFonts.getFont('Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color.fromARGB(255, 78, 76, 76)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Desliza hacia los lados para navegar entre los artículos o busca un articulo mediante el cuadro de texto.",
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 13, color: Color.fromARGB(255, 78, 76, 76)),
                  ),
                  SizedBox(height: 10),
                ])),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextFormField(
                      onChanged: (value) {
                        _busqueda();
                      },
                      controller: articuloController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un nombre o clave de artículo aquí',
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.orange),
                        filled: true,
                        fillColor: Color(0xFFF4F4F4),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 100,
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
                      style: GoogleFonts.getFont(
                        'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                      padding: EdgeInsetsDirectional.fromSTEB(15, 15, 15, 0),
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.detallesTomas.length,
                      itemBuilder: (context, listViewIndex) {
                        final i = widget.detallesTomas[listViewIndex];
                        if (buscando) {
                          if (i.busqueda) {
                            return InkWell(
                              onTap: () {
                                carruselController.jumpToPage(listViewIndex);
                                articuloController.text = "";
                                _busqueda();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i.articulo.trim(),
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.getFont('Poppins',
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  Text(
                                    i.nombre_articulo.trim(),
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.getFont('Poppins',
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ),
                            );
                          } else {
                            return Column();
                          }
                        } else {
                          return Column();
                        }
                      }),
                  SizedBox(height: 20),
                  CarouselSlider(
                    carouselController: carruselController,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.5,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          carruselIndex = index;
                          _actualizarArticulo();
                        });
                      },
                    ),
                    items: widget.detallesTomas.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              padding: EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(i.articulo,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                  SizedBox(height: 5),
                                  Text(i.nombre_articulo,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[600],
                                      )),
                                  SizedBox(height: 20),
                                  Text(
                                    "Último registro: ${widget.detallesTomas[carruselIndex].cantidad}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FloatingActionButton(
                                        onPressed: () {
                                          _disminuyeCantidad();
                                        },
                                        child: Icon(Icons.remove),
                                        backgroundColor: Color(0xFFF57C00),
                                      ),
                                      SizedBox(width: 20),
                                      Container(
                                        width: 113,
                                        child: TextFormField(
                                          controller: cantidadControllers[
                                              carruselIndex],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'^\d*\.?\d{0,2}')), // Permite números con hasta dos decimales
                                          ],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8),
                                          ),
                                          textAlign: TextAlign.center,
                                          readOnly: false,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      FloatingActionButton(
                                        onPressed: () {
                                          _aumentaCantidad();
                                        },
                                        child: Icon(Icons.add),
                                        backgroundColor: Color(0xFFF57C00),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Cantidad total: ",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                "${(widget.detallesTomas[carruselIndex].cantidad + double.parse(cantidadControllers[carruselIndex].text))} ${widget.detallesTomas[carruselIndex].nombre_unidad}",
                                            style: TextStyle(
                                              color: Colors.green[600],
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
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
      floatingActionButton: Stack(
        children: [
          // Botón de "Guardado Instantáneo" pegado a la izquierda
          Positioned(
            left: 40, // Ajusta el valor para que quede casi pegado al borde
            bottom: 20, // Mantener en la parte inferior
            child: FloatingActionButton(
              heroTag: "guardaInstantaneo",
              onPressed: () {
                _guardarCapturaDeArticulos(false); // false para no regresar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Guardado instantáneo realizado."),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: Color.fromARGB(255, 243, 124, 33),
              tooltip: "Guardar instantáneo",
              child: const Icon(Icons.save_alt),
            ),
          ),

          // Botones del lado derecho (Leer código de barras y Guardar y regresar)
          Positioned(
            right: 10, // Pegado a la derecha
            bottom: 20, // Mantener en la parte inferior
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Botón de "Leer código de barras"
                FloatingActionButton(
                  heroTag: "leeArticulo",
                  onPressed: () {
                    _leerCodigoBarras();
                  },
                  backgroundColor: Color.fromARGB(255, 243, 124, 33),
                  tooltip: "Leer código de barras",
                  child: const Icon(FontAwesomeIcons.barcode),
                ),
                SizedBox(height: 20), // Espaciado entre los botones
                // Botón de "Guardar y regresar"
                FloatingActionButton(
                  heroTag: "guardaCaptura",
                  onPressed: () {
                    _guardarCapturaDeArticulos(true); // true para regresar
                  },
                  backgroundColor: Color.fromARGB(255, 243, 124, 33),
                  tooltip: "Guardar y regresar",
                  child: const Icon(Icons.save),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Mantener los botones principales a la derecha
    );
  }
}
