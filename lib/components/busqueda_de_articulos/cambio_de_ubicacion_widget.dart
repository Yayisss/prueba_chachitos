import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:i_p_s_mant/backend/database_connect.dart';
import 'package:i_p_s_mant/models/ubicacionesSucursalModel.dart';
import 'package:i_p_s_mant/models/userModel.dart';
import '../../backend/mensajes.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CambioDeUbicacionWidget extends StatefulWidget {
  final user usuario;
  final int articulo;

  const CambioDeUbicacionWidget({Key key, this.usuario, this.articulo})
      : super(key: key);

  @override
  _CambioDeUbicacionWidgetState createState() =>
      _CambioDeUbicacionWidgetState();
}

class _CambioDeUbicacionWidgetState extends State<CambioDeUbicacionWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController ubicacionController;
  List<ubicacionesSucursal> ubicaciones = [];
  int ubicacion;
  bool buscando = true;

  @override
  void initState() {
    super.initState();
    ubicacionController = TextEditingController();
    _getUbicaciones();
  }

  _getUbicaciones() {
    DatabaseProvider.getComboUbicacionesSucursal(widget.usuario.usuario)
        .then((resultado) {
      setState(() {
        buscando = false;
        try {
          ubicaciones = resultado;
        } catch (e) {
          ubicaciones = resultado;
        }
      });
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      MensajesProvider.mensajeExtendido(context, "Error", error.toString());
    });
  }

  _guardarUbicacion() {
    if (ubicacion != null) {
      DatabaseProvider.guardaUbicacionArticulo(
              widget.usuario.usuario, widget.articulo, ubicacion)
          .then((value) {
        Navigator.pop(context, value);
      }).onError((error, stackTrace) {
        print(error);
        print(stackTrace);
        MensajesProvider.mensajeExtendido(context, "Error", error.toString());
      });
    }
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
            Navigator.pop(context, false);
          },
        ),
        title: Text(
          "Cambiar ubicación de artículo",
          style: GoogleFonts.getFont('Poppins',
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: FlutterFlowTheme.of(context).background,
      body: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Color.fromARGB(255, 243, 124, 33),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 18),
                  child: Image.asset(
                    'assets/images/mapa.png',
                    width: AppBar().preferredSize.height * 1.8,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.all(15),
                    child: Column(
                      children: [
                        Text(
                          "Selecciona una ubicación y presiona el botón de guardar.",
                          style: GoogleFonts.getFont('Poppins',
                              fontSize: 18, color: Colors.black),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  hint: Text(
                                    'Seleccionar ubicación',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  items: ubicaciones
                                      .map((item) => DropdownMenuItem<int>(
                                            value: item.ubicacion,
                                            child: Text(
                                              item.nombre_ubicacion,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: ubicacion,
                                  onChanged: (value) {
                                    setState(() {
                                      ubicacion = value;
                                    });
                                  },
                                  buttonHeight: 40,
                                  buttonWidth: 140,
                                  itemHeight: 40,
                                  searchController: ubicacionController,
                                  searchInnerWidgetHeight: 15,
                                  searchInnerWidget: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 10, 10, 0),
                                    child: TextFormField(
                                      controller: ubicacionController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelText: 'Busca la ubicación deseada',
                                        labelStyle: GoogleFonts.getFont(
                                          'Poppins',
                                          fontWeight: FontWeight.bold,
                                          color: FlutterFlowTheme.of(context)
                                              .grayLight,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  searchMatchFn: (item, searchValue) {
                                    String nombre = ubicaciones
                                            .firstWhere((element) =>
                                                element.ubicacion == item.value)
                                            .nombre_ubicacion ??
                                        "";
                                    return (nombre
                                        .toLowerCase()
                                        .contains(searchValue.toLowerCase()));
                                  },
                                  //This to clear the search value when you close the menu
                                  onMenuStateChange: (isOpen) {
                                    if (!isOpen) {
                                      ubicacionController.clear();
                                    }
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            _guardarUbicacion();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.07,
                            decoration: BoxDecoration(
                              color:Color.fromARGB(255, 243, 124, 33),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Guardar',
                              style: GoogleFonts.getFont('Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  buscando
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * .8,
                          color: Color(0x7B1E1E1E),
                          alignment: Alignment.center,
                          child: SizedBox(
                              width: 170,
                              height: 170,
                              child:
                                  CircularProgressIndicator(strokeWidth: 25)))
                      : Container(),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
