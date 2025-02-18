import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_button/group_button.dart';
import 'package:i_p_s_mant/backend/database_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/mensajes.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectionWidget extends StatefulWidget {
  const ConnectionWidget({
    Key key,
  }) : super(key: key);

  @override
  _ConnectionWidgetState createState() => _ConnectionWidgetState();
}

class _ConnectionWidgetState extends State<ConnectionWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GroupButtonController controller = GroupButtonController();
  String server = "No se ha registrado servidor.";
  TextEditingController servidorText = new TextEditingController();
  SharedPreferences preffs;
  @override
  void initState() {
    super.initState();
    controller.selectIndex(0);
    _getServer();
  }

  _getServer() async {
    preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server");
    if (tempServer != "") {
      setState(() {
        server = tempServer;
        servidorText.text = tempServer;
      });
    }
  }

  _accept() async {
    preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server");
    if (servidorText.text.isEmpty) {
      if (tempServer != "") {
        _testConnection();
      }
    } else {
      _saveServer();
    }
  }

  _saveServer() async {
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
    bool conecta =
        await DatabaseProvider.conecctionIntent(servidorText.value.text)
            .then((value) {
      return value;
    }).onError((error, stackTrace) {
      return false;
    });
    Navigator.of(context).pop();
    if (conecta) {
      MensajesProvider.mensajeExtendido(context, 'Conexión exitosa',
          'La conexión ha sido establecida y guardada con éxito');
      preffs = await SharedPreferences.getInstance();
      preffs.setString("server", servidorText.value.text);
      _getServer();
    } else {
      MensajesProvider.mensajeExtendido(
          context, 'Error', 'No se pudo establecer conexión con el servidor');
    }
  }

  _testConnection() async {
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
    bool conecta =
        await DatabaseProvider.conecctionIntent(servidorText.value.text)
            .then((value) {
      return value;
    }).onError((error, stackTrace) {
      return false;
    });
    Navigator.of(context).pop();
    if (conecta) {
      MensajesProvider.mensajeExtendido(context, 'Conexión exitosa', '');
    } else {
      MensajesProvider.mensajeExtendido(
          context, 'Error', 'No se puede establecer conexión con el servidor');
    }
  }

  _cancel() {
    Navigator.pop(context);
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
          "Conexión",
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
            width: MediaQuery.of(context).size.width,
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 18),
                  child: FaIcon(
                    FontAwesomeIcons.networkWired,
                    color: FlutterFlowTheme.of(context).background,
                    size: AppBar().preferredSize.height * 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(15, 0, 15, 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Cambiar configuración del servidor",
                                      style: GoogleFonts.getFont('Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      server != null
                                          ? "Servidor Actual: " + server
                                          : "No se ha registrado un servidor",
                                      style: GoogleFonts.getFont('Poppins',
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 20,
                                          color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ]),
                            ),
                          ),
                          TextField(
                            controller: servidorText,
                            decoration: InputDecoration(
                                iconColor: Color.fromARGB(255, 243, 124, 33),
                                prefixIcon:
                                    Icon(Icons.settings_ethernet_outlined)),
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 255, 159, 86),
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
                                            _accept();
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(12, 0, 12, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Aceptar',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style:
                                                            GoogleFonts.getFont(
                                                                'Poppins',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white),
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
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 200, 112, 45),
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
                                            _cancel();
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(2, 0, 12, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Salir',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style:
                                                            GoogleFonts.getFont(
                                                                'Poppins',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white),
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
                        ],
                      ),
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
