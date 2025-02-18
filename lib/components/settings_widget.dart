import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i_p_s_mant/backend/database_connect.dart';
import 'package:i_p_s_mant/models/permiso_sucursal_model.dart';
import 'package:i_p_s_mant/models/sucursalesModel.dart';
import 'package:i_p_s_mant/models/userModel.dart';
import '../backend/mensajes.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsWidget extends StatefulWidget {
  final user usuario;
  const SettingsWidget({Key key, this.usuario}) : super(key: key);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  permisoSucursal permiso;
  List<sucursales> sucursalesCombo = [];
  String nombre_sucursal = "";
  bool tienePermiso = false;
  sucursales sucursal;

  @override
  void initState() {
    super.initState();
    _getPermiso();
  }

  _getPermiso() {
    DatabaseProvider.getConfiguraciones(widget.usuario.usuario)
        .then((resultado) {
      try {
        setState(() {
          permiso = resultado[0];
          sucursalesCombo = resultado[1];

          if (permiso.puede_cambiar_sucursal == 1) {
            tienePermiso = true;

            sucursalesCombo.forEach((element) {
              if (element.sucursal == permiso.sucursal) {
                sucursal = element;
              }
            });
          }

          nombre_sucursal = permiso.sucursal;
          sucursalesCombo.forEach((element) {
            if (element.sucursal == permiso.sucursal) {
              nombre_sucursal = element.nombre_sucursal.toString();
            }
          });
        });
      } catch (error) {
        Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);
      }
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      MensajesProvider.mensajeExtendido(
          context, 'Error', 'No se lograron consultar las configuraciones');
      Navigator.of(context).pop();
    });
  }

  _save() async {
    if (permiso.puede_cambiar_sucursal == 1) {
      showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: SizedBox(
                  width: 75,
                  height: 75,
                  child: CircularProgressIndicator(strokeWidth: 15)));
        },
      );
      int lnSucursal = int.parse(sucursal.sucursal.toString());
      bool guardado = await DatabaseProvider.saveConfiguraciones(
              widget.usuario.usuario, lnSucursal)
          .then((value) {
        return value;
      }).onError((error, stackTrace) {
        Fluttertoast.showToast(
            msg: error.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        return false;
      });
      Navigator.of(context).pop();
      if (guardado) {
        widget.usuario.sucursal = lnSucursal;
        MensajesProvider.mensajeExtendido(
            context, 'Guardado con éxito', 'Datos actualizados con éxito');
      } else {
        MensajesProvider.mensajeExtendido(
            context, 'Error', 'No se lograron guardar los cambios');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryColor,
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
          "Configuraciones",
          style: GoogleFonts.getFont('Poppins',
              fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: FlutterFlowTheme.of(context).background,
      body: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Color(0x9B000000),
                  offset: Offset(0.0, 0.0), //(x,y)
                  blurRadius: 5.0,
                ),
              ],
            ),
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 18),
            child: FaIcon(
              FontAwesomeIcons.gear,
              color: FlutterFlowTheme.of(context).background,
              size: AppBar().preferredSize.height * 2,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsetsDirectional.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Column(children: []),
                      ),
                    ),
                    Text(
                      "Sucursal",
                      style: GoogleFonts.getFont('Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    tienePermiso
                        ? DropdownButtonHideUnderline(
                            child: DropdownButton2<sucursales>(
                              isExpanded: true,
                              items: sucursalesCombo
                                  .map((sucursales value) =>
                                      DropdownMenuItem<sucursales>(
                                        value: value,
                                        child: Text(
                                          value.nombre_sucursal,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              value: sucursal,
                              onChanged: (value) {
                                setState(() {
                                  sucursal = value;
                                });
                              },
                              buttonHeight: 60,
                              buttonWidth: MediaQuery.of(context).size.width,
                              itemHeight: 60,
                            ),
                          )
                        : Text(
                            nombre_sucursal,
                            style: GoogleFonts.getFont('Poppins',
                                fontSize: 20, color: Colors.black),
                          ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: MediaQuery.of(context).size.height * 0.07,
                              decoration: BoxDecoration(
                                color:
                                    FlutterFlowTheme.of(context).primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x9B000000),
                                    offset: Offset(2.0, 2.0), //(x,y)
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  _save();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12, 0, 12, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Guardar',
                                              textAlign: TextAlign.start,
                                              style: GoogleFonts.getFont(
                                                  'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
