import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i_p_s_mant/components/info_widget.dart';
import 'package:i_p_s_mant/components/busqueda_de_articulos/busqueda_de_articulo_widget.dart';
import 'package:i_p_s_mant/components/connection_widget.dart';
import 'package:i_p_s_mant/components/toma_de_inventarios/toma_de_inventarios_widget.dart';
import 'package:i_p_s_mant/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login_page/login_page_widget.dart';

class HomePageWidget extends StatefulWidget {
  final user usuario;
  const HomePageWidget({Key key, this.usuario}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences preffs;
  String persona = "";
  String cliente_mds;
  ScrollController scrollbar;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    try {
      persona = widget.usuario.nombre_persona;
    } catch (e) {
      persona = "buen día";
    }

    cliente_mds = widget.usuario.nombre_cliente;
    scrollbar = ScrollController();
  }

  _openTomaDeInventarios() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TomaDeInventariosWidget(usuario: widget.usuario)));
  }

  _openInfo() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InfoWidget()));
  }

  _openConnection() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ConnectionWidget()));
  }

  _openBusquedaDeArticulos() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BusquedaDeArticuloWidget(usuario: widget.usuario)));
  }

  _logOut() async {
    preffs = await SharedPreferences.getInstance();
    preffs.remove("user");
    preffs.remove("password");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPageWidget()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 243, 124, 33), // Color naranja más suave
        title: Text(
          "Chachitos",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            iconSize: AppBar().preferredSize.height * 0.5,
            tooltip: 'Info',
            onPressed: () async {
              _openInfo();
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket),
            iconSize: AppBar().preferredSize.height * 0.5,
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              _logOut();
            },
          ),
        ],
        centerTitle: false,
      ),
      backgroundColor: FlutterFlowTheme.of(context).background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  Text(
                    "Hola, $persona",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Selecciona una herramienta disponible para tu usuario.",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: scrollbar,
                thumbVisibility: true,
                thickness: 8,
                radius: Radius.circular(25),
                child: SingleChildScrollView(
                  controller: scrollbar,
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildToolCard(
                          label: "Toma de Inventarios",
                          icon: 'assets/images/inventarios.png',
                          onTap: _openTomaDeInventarios,
                        ),
                        _buildToolCard(
                          label: "Toma instantánea",
                          icon: 'assets/images/articulos.png',
                          onTap: _openBusquedaDeArticulos,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({String label, String icon, VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ajuste de la imagen para que no se desborde
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(icon),
                    fit: BoxFit.cover, // Ajusta la imagen para que no sobrepase
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
