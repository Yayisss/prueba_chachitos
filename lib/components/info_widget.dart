import 'package:flutter/cupertino.dart';
import 'package:i_p_s_mant/backend/database_connect.dart';
import 'package:i_p_s_mant/models/userModel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoWidget extends StatefulWidget {
  const InfoWidget({Key key}) : super(key: key);

  @override
  _InfoWidgetState createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
          "Chachitos",
          style: GoogleFonts.getFont('Poppins',
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
      ),
      backgroundColor: FlutterFlowTheme.of(context).background,
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(30, 30, 30, 0),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(40, 50, 40, 30),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/logo.png",
                                width: MediaQuery.of(context).size.width,
                              ),
                            ]),
                      ),
                      Text(
                        "Versión " + DatabaseProvider.VERSION,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont('Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Color.fromARGB(255, 243, 124, 33)),
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Desarrollado por:",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont('Poppins',
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "MDS Sistemas",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont('Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      IconButton(
                        icon: Image.asset(
                          "assets/images/icons-internet.gif",
                        ),
                        iconSize: 50,
                        tooltip: 'Visitar página web',
                        onPressed: () async {
                          launch("https://mds-sistemas.com");
                        },
                      ),
                    ]))),
      ),
    );
  }
}
