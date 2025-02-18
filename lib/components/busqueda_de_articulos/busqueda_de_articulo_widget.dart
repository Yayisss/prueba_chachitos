import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i_p_s_mant/backend/database_connect.dart';
import 'package:i_p_s_mant/components/busqueda_de_articulos/articulos_comprometidos_widget.dart';
import 'package:i_p_s_mant/components/busqueda_de_articulos/cambio_de_ubicacion_widget.dart';
import 'package:i_p_s_mant/models/articulosModel.dart';
import 'package:i_p_s_mant/models/descuentosArticulosModel.dart';
import 'package:i_p_s_mant/models/entradasArticulosModel.dart';
import 'package:i_p_s_mant/models/userModel.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:string_validator/string_validator.dart';
import '../../backend/mensajes.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../scan_event_widget.dart';

class BusquedaDeArticuloWidget extends StatefulWidget {
  final user usuario;
  final String cArticulo;
  const BusquedaDeArticuloWidget({Key key, this.usuario, this.cArticulo})
      : super(key: key);

  @override
  _BusquedaDeArticuloWidgetState createState() =>
      _BusquedaDeArticuloWidgetState();
}

bool isSearched = false; // Variable para controlar si se ha realizado la búsqueda

class _BusquedaDeArticuloWidgetState extends State<BusquedaDeArticuloWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController claveArticuloController, existenciaController;
  List<articulos> articulo = [];
  List<entradasArticulos> entradas = [];
  String clave_articulo = "";
  String claveAlterna = "";
  String nombre_articulo = "";
  String unidadMedida = "";
  String ultimaVenta = "";
  String surtido = "";
  String ultimoInventario = "";
  String ultimoTraspaso = "";
  String existencias = "";
  String disponible = "";
  String comprometida = "";
  String ultimaEntrada = "";
  String entrada = "";
  String proveedor = "";
  String fechaEntrada = "";
  String costoEntrada = "";
  String personaConfirmo = "";
  String tooltip = "Buscar";
  String imagenBase64 = "";
  String imagenUrl = "";

  Icon icono = Icon(Icons.done);
  Color folioColor = Colors.black;
  bool buscando = false;
  bool buscaImagen = false;
  bool folioEnabled = true;
  bool esChachitos = false;

  @override
  void initState() {
    super.initState();
    claveArticuloController = TextEditingController();
    existenciaController = TextEditingController();
    esChachitos = (widget.usuario.nombre_cliente == "Chachitos");

    if (widget.cArticulo != "") {
      this.claveArticuloController.text = widget.cArticulo;
      _busqueda();
    }
  }

  _busqueda() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (claveArticuloController.value.text.isNotEmpty) {
      setState(() {
        buscando = true;
         isSearched = true; 
      });

      if (esChachitos)
        _consultaArticuloChachitos();
      else
        _consultaArticuloChachitos();
    }
  }

  _cambiarUbicacion() async {
    Navigator.pop(context);
    bool valor = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CambioDeUbicacionWidget(
                usuario: widget.usuario,
                articulo: articulo.first.clave_articulo)));
    if (valor) {
      MensajesProvider.mensaje(context, 'Ubicación actualizada con éxito');
      _busqueda();
    }
  }

  _consultaArticuloChachitos() {
    String busqueda = claveArticuloController.text;

    DatabaseProvider.getArticulo(busqueda, widget.usuario.usuario)
        .then((resultado) {
      setState(() {
        buscando = false;
        try {
          articulo = resultado[0];
          entradas = resultado[1];
          _procesarArticulo(busqueda);
        } catch (e) {
          print("Error al procesar el artículo: $e");
        }
      });
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      MensajesProvider.mensajeExtendido(context, "Error", error.toString());
    });
  }

  _procesarArticulo(String busqueda) {
    if (articulo.isEmpty) {
      _manejarArticuloNoEncontrado(busqueda);
    } else {
      _actualizarInformacionArticulo();
      _consultaImagen();
    }
  }

  _manejarArticuloNoEncontrado(String busqueda) {
    if (busqueda.length == 13) {
      claveArticuloController.text = busqueda.substring(1, busqueda.length);
      _consultaArticuloChachitos();
    } else {
      MensajesProvider.mensaje(context, 'No se encontró el artículo');
    }
  }

  _actualizarInformacionArticulo() {
    folioEnabled = false;
    folioColor = FlutterFlowTheme.of(context).grayLight;
    icono = Icon(Icons.inventory);
    tooltip = "Toma de Inventario";

    // Información básica del artículo
    clave_articulo = "Artículo: ${articulo.first.articulo}";
    claveAlterna = articulo.first.clave_anterior.isNotEmpty
        ? "Clave Alterna: ${articulo.first.clave_anterior}"
        : "";

    // Información adicional
    nombre_articulo = articulo.first.nombre_articulo;
    unidadMedida = "U.M.: ${articulo.first.nombre_unidad}";
    ultimaVenta = "Última Venta: ${articulo.first.ultima_venta}";

    if (articulo.first.surtio_ultima_venta.isNotEmpty) {
      surtido = "Surtido confirmado por: ${articulo.first.surtio_ultima_venta}";
    }

    ultimoInventario = "Última Toma Inventario: ${articulo.first.ultima_toma}";

    if (articulo.first.ultimo_traspaso.isNotEmpty) {
      ultimoTraspaso = "Último Traspaso: ${articulo.first.ultimo_traspaso}";
    }

    // Existencias
    existencias = "Existencias";
    disponible = _formatearExistencia(articulo.first.disponible);
    comprometida = _formatearComprometida(articulo.first.cantidad_comprometida);

    // Si hay existencias comprometidas
    if (articulo.first.cantidad_comprometida != 0) {
      MensajesProvider.mensajeExtendido(context, "Comprometidas",
          "Hay ${articulo.first.cantidad_comprometida.toStringAsFixed(0)} piezas comprometidas");
    }

    // Entradas
    if (entradas.isNotEmpty) {
      ultimaEntrada = "Última Entrada";
      entrada =
          "Entrada: ${NumberFormat("#,###,###").format(entradas.first.entrada)}";
      proveedor = "Proveedor: ${entradas.first.nombre_proveedor}";
      fechaEntrada = "Fecha: ${entradas.first.cFecha}";
      costoEntrada =
          "Costo: ${entradas.first.costo_entrada.toStringAsFixed(2)}";

      if (entradas.first.persona_confirmo.isNotEmpty) {
        personaConfirmo =
            "Persona que confirmó: ${entradas.first.persona_confirmo}";
      }
    }
  }

  _formatearExistencia(double disponible) {
    return "Disponible: ${disponible % 1 == 0 ? disponible.toStringAsFixed(0) : disponible.toString()}";
  }

  _formatearComprometida(double comprometida) {
    return "Comprometida: ${comprometida % 1 == 0 ? comprometida.toStringAsFixed(0) : comprometida.toString()}";
  }

  _consultaImagen() {
    setState(() {
      buscaImagen = true;
    });

    DatabaseProvider.getFotoArticulo(articulo.first.clave_articulo)
        .then((resultado) {
      setState(() {
        buscaImagen = false;

        try {
          String textoBase64 = resultado.first;
          String url = resultado.last;

          if (textoBase64 != null &&
              textoBase64.isNotEmpty &&
              isBase64(textoBase64)) {
            imagenBase64 = textoBase64;
          } else if (url != null && url.isNotEmpty) {
            imagenUrl = url;
          }
        } catch (e) {}
      });
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      MensajesProvider.mensajeExtendido(context, "Error", error.toString());
    });
  }

  _guardarTomaInventario() async {
    if (existenciaController.value.text == "" ||
        int.parse(existenciaController.value.text) == 0) {
      existenciaController.text = "0";
    }
    DatabaseProvider.guardaToma(articulo.first.articulo, widget.usuario.usuario,
            double.parse(existenciaController.text))
        .then((value) {
      Navigator.pop(context);
      if (value == 0) {
        MensajesProvider.mensaje(context, 'Ocurrió un error');
      } else {
        _limpiar();
        MensajesProvider.mensaje(
            context, 'Toma ' + value.toString() + ' registrada con éxito');
      }
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      MensajesProvider.mensajeExtendido(context, "Error", error.toString());
    });
  }

  _leerCodigoBarras() async {
    await Permission.camera.request();
    String codigo;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScanEventWidget(
                  usuario: widget.usuario,
                ))).then((value) {
      setState(() {
        codigo = value;
      });
    });
    if (codigo == null) {
      print('nothing return');
    } else {
      setState(() {
        this.claveArticuloController.text = codigo;
        _busqueda();
      });
    }
  }

  _limpiar() {
    claveArticuloController.clear();
    existenciaController.clear();
    setState(() {
      clave_articulo = "";
      claveAlterna = "";
      nombre_articulo = "";
      unidadMedida = "";
      ultimaVenta = "";
      surtido = "";
      ultimoInventario = "";
      ultimoTraspaso = "";
      existencias = "";
      disponible = "";
      comprometida = "";
      ultimaEntrada = "";
      entrada = "";
      proveedor = "";
      fechaEntrada = "";
      costoEntrada = "";
      personaConfirmo = "";
      imagenBase64 = "";
      imagenUrl = "";
      tooltip = "Buscar";
      icono = Icon(Icons.done);
      folioColor = Colors.black;
      folioEnabled = true;
    });
  }

  _revisaTomaInventario() {
    if (existenciaController.value.text == "" ||
        int.parse(existenciaController.value.text) == 0) {
      _confirmarInventario0(context);
    } else {
      _guardarTomaInventario();
    }
  }

  _verArticulosComprometidos() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ArticulosComprometidosWidget(
                articulo: articulo.first.articulo, usuario: widget.usuario)));
  }

  Future<void> _abrirImagen(
      BuildContext context, String imagen, bool esBase64) async {
    return showModalBottomSheet<void>(
      context: context,
      barrierColor: Color(0xB3000000),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(25),
      )),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: esBase64
                        ? Image.memory(base64Decode(imagen),
                            fit: BoxFit.fitWidth)
                        : ImagenURL(imagen)),
                SizedBox(height: 25),
                ElevatedButton(
                  child: Text(
                    'Aceptar',
                    style: GoogleFonts.getFont('Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget ImagenURL(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.fitWidth,
      placeholder: (context, url) => Image.asset(
          "assets/images/imagenBusqueda.gif",
          width: MediaQuery.of(context).size.width * 0.5,
          fit: BoxFit.fitWidth),
      errorWidget: (context, url, error) =>
          Image.asset("assets/images/nofoto.png", fit: BoxFit.fitWidth),
    );
  }

  _cargarImagen() {
    showDialog(
      barrierColor: Color(0xB3000000),
      context: context,
      builder: (context) {
        return Center(
            child: Image.asset(
          "assets/images/imagenBusqueda.gif",
          width: MediaQuery.of(context).size.width * 0.5,
          fit: BoxFit.fitWidth,
        ));
      },
    );

    DatabaseProvider.getFotoArticulo(articulo.first.clave_articulo)
        .then((resultado) {
      Navigator.of(context).pop();
      setState(() {
        try {
          String textoBase64 = resultado.first;
          String url = resultado.last;

          if (textoBase64 != null &&
              textoBase64.isNotEmpty &&
              isBase64(textoBase64)) {
            _abrirImagen(context, textoBase64, true);
          } else if (url != null && url.isNotEmpty) {
            _abrirImagen(context, url, false);
          } else {
            MensajesProvider.mensaje(
                context, 'Este artículo no tiene fotografía');
          }
        } catch (e) {}
      });
    }).onError((error, stackTrace) {
      Navigator.of(context).pop();
      print(error);
      print(stackTrace);
      MensajesProvider.mensajeExtendido(context, "Error", error.toString());
    });
  }

  Future<bool> _confirmarInventario0(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Estás seguro que quieres guardar existencia 0?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'No',
                style: TextStyle(
                    color: Color.fromARGB(255, 243, 124,
                        33)), // Cambia el color del texto a naranja
              ),
            ),
            TextButton(
              onPressed: () => _guardarTomaInventario(),
              child: Text(
                'Sí',
                style: TextStyle(
                    color: Color.fromARGB(255, 243, 124,
                        33)), // Cambia el color del texto a naranja
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarUbicacion(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Ubicación del artículo'),
            content: Text(articulo.first.nombre_ubicacion.trim()),
            actions: <Widget>[
              TextButton(
                onPressed: () => _cambiarUbicacion(),
                child: Text(
                  'Cambiar ubicación',
                  style: TextStyle(
                    color:
                        Color.fromARGB(255, 243, 124, 33), // Color anaranjado
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color:
                        Color.fromARGB(255, 243, 124, 33), // Color anaranjado
                  ),
                ),
              ),
            ]);
      },
    );
  }

  Future<void> _tomaDeInventario(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(25),
      )),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Toma de Inventario",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.getFont('Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black),
                ),
                SizedBox(height: 18),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20,
                      0), // Reducir los márgenes para no estar tan pegado a los bordes
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Artículo: " + articulo.first.articulo,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.getFont(
                          'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold, // Un poco más destacado
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                          height:
                              12), // Espacio más amplio entre el texto y el campo de texto
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical:
                                8), // Añadir relleno interno para mayor espacio
                        decoration: BoxDecoration(
                          color: Colors
                              .white, // Fondo blanco para el campo de texto
                          borderRadius:
                              BorderRadius.circular(8), // Bordes redondeados
                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black12, // Sombra suave para un efecto de profundidad
                              offset: Offset(0, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: existenciaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Existencia',
                            labelStyle: GoogleFonts.getFont(
                              'Poppins',
                              fontWeight: FontWeight.normal,
                              color: Colors.black54,
                            ),
                            hintText: '0',
                            hintStyle: GoogleFonts.getFont(
                              'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400], // Sutil, más suave
                            ),
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.getFont(
                            'Poppins',
                            fontSize: 16, // Tamaño legible
                            color: Colors
                                .black87, // Color más oscuro para mejor contraste
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                            255, 243, 124, 33), // Color de fondo del botón
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.getFont(
                          'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white, // Color del texto
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                            255, 243, 124, 33), // Color de fondo del botón
                      ),
                      child: Text(
                        'Guardar',
                        style: GoogleFonts.getFont(
                          'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white, // Color del texto
                        ),
                      ),
                      onPressed: () => _revisaTomaInventario(),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
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
            "Búsqueda de Artículo",
            style: GoogleFonts.getFont('Poppins',
                fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.not_listed_location,
                color: Colors.white,
              ),
              iconSize: AppBar().preferredSize.height * .5,
              tooltip: 'Ver ubicación',
              onPressed: () {
                if (claveArticuloController.value.text == "") {
                  MensajesProvider.mensaje(
                      context, 'Busca primero un artículo');
                } else if (clave_articulo == "") {
                  MensajesProvider.mensaje(context,
                      'Pulsa enter en el teclado para buscar el artículo');
                } else {
                  _mostrarUbicacion(context);
                }
              },
            ),
          ],
          centerTitle: true,
          elevation: (clave_articulo == "") ? 0 : 4,
        ),
        backgroundColor: FlutterFlowTheme.of(context).background,
        body: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            (clave_articulo == "")
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 243, 124, 33),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x9B000000),
                          offset: Offset(0.0, 0.0), //(x,y)
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/articulos.png',
                      width: AppBar().preferredSize.height * 1.8,
                      fit: BoxFit.scaleDown,
                    ),
                  )
                : buscaImagen
                    ? Container(
                        alignment: Alignment.center,
                        padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                        color: Color.fromARGB(255, 243, 124, 33),
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Image.asset("assets/images/imagenBusqueda.gif",
                            width: MediaQuery.of(context).size.width * 0.3,
                            fit: BoxFit.fitWidth))
                    : Container(
                        alignment: Alignment.center,
                        padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                        color: Color.fromARGB(255, 243, 124, 33),
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: (imagenBase64.isNotEmpty)
                            ? Image.memory(
                                base64Decode(imagenBase64),
                                fit: BoxFit.fitWidth,
                                errorBuilder: (context, objeto, error) =>
                                    Image.asset(
                                  "assets/images/articulos.png", //nofoto.png
                                  fit: BoxFit.fitWidth,
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                ),
                              )
                            : (imagenUrl.isNotEmpty)
                                ? ImagenURL(imagenUrl)
                                : Image.asset("assets/images/articulos.png",
                                    fit: BoxFit.fitWidth)),
 
  Expanded(
  child: Stack(
    children: [
      SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introducción
              Text(
                "Escribe o escanea la clave de un artículo para consultar su información.",
                style: GoogleFonts.getFont('Poppins', fontSize: 18, color: Colors.black, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 10),
              
              // Campo de búsqueda
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
                  ],
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Artículo",
                      style: GoogleFonts.getFont('Poppins', fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextFormField(
                      controller: claveArticuloController,
                      enabled: folioEnabled,
                      textCapitalization: TextCapitalization.characters,
                      onEditingComplete: _busqueda,
                      decoration: InputDecoration(
                        hintText: 'Escribe una clave de artículo aquí',
                        hintStyle: GoogleFonts.getFont('Poppins', color: Colors.grey),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        suffixIcon: IconButton(
                          icon: Icon(FontAwesomeIcons.barcode, color: folioColor, size: 25),
                          onPressed: _leerCodigoBarras,
                        ),
                      ),
                      style: GoogleFonts.getFont('Poppins', color: folioColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Mostrar secciones de información solo si se ha buscado y si tienen datos
              if (isSearched) ...[
                _buildInfoSection("Clave Artículo", clave_articulo),
                _buildInfoSection("Clave Alterna", claveAlterna),
                _buildInfoSection("Nombre", nombre_articulo),
                _buildInfoSection("Unidad de Medida", unidadMedida),
                _buildInfoSection("Existencias", existencias, isBold: true),
                _buildInfoSection("Disponible", disponible),
                _buildInfoSection("Comprometida", comprometida, isBold: true, onTap: _verArticulosComprometidos),
                _buildInfoSection("Última Entrada", ultimaEntrada, isBold: true),
                _buildInfoSection("Entrada", entrada),
                _buildInfoSection("Proveedor", proveedor),
                _buildInfoSection("Persona Confirmó", personaConfirmo),
                _buildInfoSection("Fecha Entrada", fechaEntrada),
                _buildInfoSection("Última Venta", ultimaVenta),
                _buildInfoSection("Surtido", surtido),
                _buildInfoSection("Último Inventario", ultimoInventario),
                _buildInfoSection("Último Traspaso", ultimoTraspaso),
              ],
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      
      // Cargando indicador
      buscando
          ? Container(
              color: Colors.black54.withOpacity(0.5),
              alignment: Alignment.center,
              child: SizedBox(
                  width: 125,
                  height: 125,
                  child: CircularProgressIndicator(strokeWidth: 22, color: Colors.blue)),
            )
          : Container(),
    ],
  ),
),
          ]),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(left: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              (clave_articulo != "")
                  ? FloatingActionButton(
                      heroTag: "limpiaArticulo",
                      onPressed: () {
                        _limpiar();
                      },
                      backgroundColor: Color.fromARGB(255, 243, 124, 33),
                      tooltip: "Limpiar",
                      child: const Icon(Icons.refresh),
                    )
                  : SizedBox(),
              Expanded(child: Container()),
              FloatingActionButton(
                heroTag: "buscaArticulo",
                onPressed: () {
                  if (claveArticuloController.value.text == "") {
                    MensajesProvider.mensaje(
                        context, 'Busca primero un artículo');
                  } else if (clave_articulo == "") {
                    _busqueda();
                  } else {
                    _tomaDeInventario(context);
                  }
                },
                backgroundColor: Color.fromARGB(255, 243, 124, 33),
                tooltip: tooltip,
                child: icono,
              ),
            ],
          ),
        ));
  }
  // Función para construir las secciones de información de manera más ordenada
// Función para construir las secciones de información de manera más ordenada
Widget _buildInfoSection(String label, String value, {bool isBold = false, Function() onTap}) {
  if (value.isEmpty) return Container(); // Solo mostrar si tiene datos

  return Padding(
    padding: EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.getFont('Poppins', fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: GoogleFonts.getFont('Poppins', fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}


}
