import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:i_p_s_mant/backend/database_connect.dart';
import 'package:i_p_s_mant/components/toma_de_inventarios/captura_articulos_widget.dart';
import 'package:i_p_s_mant/models/detallesTomaInventarioModel.dart';
import 'package:i_p_s_mant/models/tomasInventarioModel.dart';
import 'package:i_p_s_mant/models/userModel.dart';
import 'package:i_p_s_mant/models/variablesModel.dart';
import 'package:intl/intl.dart';
import '../../backend/mensajes.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommaTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,##0");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(',', '');
    if (newText.isNotEmpty) {
      double parsedValue = double.tryParse(newText) ?? 0.0;
      String formattedValue = _formatter.format(parsedValue);
      return TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    } else {
      return newValue.copyWith(text: '');
    }
  }
}

class TomaDeInventariosWidget extends StatefulWidget {
  final user usuario;
  const TomaDeInventariosWidget({Key key, this.usuario}) : super(key: key);

  @override
  _TomaDeInventariosWidgetState createState() =>
      _TomaDeInventariosWidgetState();
}

class _TomaDeInventariosWidgetState extends State<TomaDeInventariosWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController folioProcesoController;
  variables totalToma;
  List<tomasInventario> tomas_inventarios = [];
  List<detallesTomaInventario> detallesTomas = [];
  String fecha = "";
  String estado = "";
  String narticulos = "";
  String conjunto = "";
  String tooltip = "Buscar";
  Icon icono = Icon(Icons.done);
  Color folioColor = Colors.black;
  bool folioEnabled = true;

  NumberFormat numberFormat = NumberFormat("#,##0");

  @override
  void initState() {
    super.initState();
    folioProcesoController = TextEditingController();
  }

  _busqueda() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (folioProcesoController.value.text.isNotEmpty) {
      String cleanedText =
          folioProcesoController.value.text.replaceAll(",", "");

      if (int.tryParse(cleanedText) != null) {
        showDialog(
          context: context,
          builder: (context) {
            return Center(
                child: SizedBox(
                    width: 125,
                    height: 125,
                    child: CircularProgressIndicator(strokeWidth: 22)));
          },
        );

        DatabaseProvider.getTomasInventarios(
                int.parse(cleanedText), widget.usuario.usuario)
            .then((resultado) {
          Navigator.of(context).pop();
          setState(() {
            try {
              totalToma = resultado[0];
              tomas_inventarios = resultado[1];
              detallesTomas = resultado[2];
              if (totalToma.total != 0) {
                setState(() {
                  folioEnabled = false;
                  folioColor = FlutterFlowTheme.of(context).grayLight;
                  icono = Icon(Icons.assignment);
                  tooltip = "Captura de Artículos";
                  fecha = "Fecha: " + tomas_inventarios.first.fecha_registro;
                  estado = "Estado: " + tomas_inventarios.first.estado_actual;

                  narticulos = "No. Artículos: " +
                      numberFormat.format(double.parse(
                          tomas_inventarios.first.total_articulos.toString()));

                  conjunto = "Conjunto: " + tomas_inventarios.first.conjunto;
                });
              } else {
                MensajesProvider.mensaje(context,
                    'No se encontró o ya ha sido dado por terminado el folio de toma Inventario');
              }
            } catch (e) {
              print("Encontre un error");
            }
          });
        }).onError((error, stackTrace) {
          print(error);
          print(stackTrace);
          MensajesProvider.mensajeExtendido(context, "Error", error.toString());
        });
      } else {
        MensajesProvider.mensaje(context, 'Folio de proceso no válido');
      }
    }
  }

  _capturaArticulos() async {
    if (detallesTomas.isNotEmpty) {
      String cleanedText =
          folioProcesoController.value.text.replaceAll(",", "");

      if (int.tryParse(cleanedText) != null) {
        bool capturada = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CapturaArticulosWidget(
                    usuario: widget.usuario,
                    toma: int.parse(cleanedText),
                    detallesTomas: detallesTomas)));
        if (capturada != null && capturada) {
          MensajesProvider.mensaje(context, 'Detalles subidos con éxito');
          _limpiar();
        }
      } else {
        Fluttertoast.showToast(
            msg: "Folio de proceso no válido",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);
        _limpiar();
      }
    } else {
      Fluttertoast.showToast(
          msg: "Esta toma no tiene artículos registrados",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      _limpiar();
    }
  }

  _limpiar() {
    folioProcesoController.clear();
    setState(() {
      fecha = "";
      estado = "";
      narticulos = "";
      conjunto = "";
      tooltip = "Buscar";
      icono = Icon(Icons.done);
      folioColor = Colors.black;
      folioEnabled = true;
    });
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
            "Toma de Inventarios",
            style: GoogleFonts.getFont('Poppins',
                fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: FlutterFlowTheme.of(context).background,
        body: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 243, 124, 33),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x9B000000),
                    offset: Offset(0.0, 2.0),
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 18),
                    child: Image.asset(
                      'assets/images/inventarios.png',
                      width: AppBar().preferredSize.height * 1.8,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(15, 15, 15, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Toma",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.getFont('Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            onEditingComplete: () {
                              _busqueda();
                            },
                            controller: folioProcesoController,
                            enabled: folioEnabled,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CommaTextInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Escribe el folio de proceso aquí',
                              hintStyle: GoogleFonts.getFont(
                                'Poppins',
                                fontWeight: FontWeight.w500,
                                color: FlutterFlowTheme.of(context).grayLight,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: GoogleFonts.getFont('Poppins',
                                fontWeight: FontWeight.bold, color: folioColor),
                          ),
                          SizedBox(height: 15),
                          Text(
                            fecha,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.getFont('Poppins',
                                fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(height: 8),
                          Text(
                            estado,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.getFont('Poppins',
                                fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(height: 8),
                          Text(
                            narticulos,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.getFont('Poppins',
                                fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(height: 8),
                          Text(
                            conjunto,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.getFont('Poppins',
                                fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(left: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              (fecha != "")
                  ? FloatingActionButton(
                      heroTag: "limpiaToma",
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
                heroTag: "iniciaToma",
                onPressed: () {
                  if (folioProcesoController.value.text == "") {
                    MensajesProvider.mensaje(
                        context, 'Ingresa un folio de proceso');
                  } else if (fecha == "") {
                    _busqueda();
                  } else {
                    _capturaArticulos();
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
}
