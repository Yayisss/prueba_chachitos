import 'package:flutter/cupertino.dart';
import 'package:i_p_s_mant/backend/database_connect.dart';
import 'package:i_p_s_mant/components/connection_widget.dart';
import 'package:i_p_s_mant/home_page/home_page_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({Key key}) : super(key: key);

  @override
  _LoginPageWidgetState createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  TextEditingController emailAddressLoginController;
  TextEditingController passwordLoginController;
  bool passwordLoginVisibility;
  SharedPreferences preffs;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    emailAddressLoginController = TextEditingController();
    passwordLoginController = TextEditingController();
    passwordLoginVisibility = false;
    _currentSession();
  }

  _currentSession() async {
    preffs = await SharedPreferences.getInstance();
    String usuario = preffs.getString("user");
    String password = preffs.getString("password");
    String servidor = preffs.getString("server");
    Future.delayed(Duration(seconds: 1)).then((value) {
      if (servidor != null) {
        if (usuario != null && password != null) {
          DatabaseProvider.getUserByEmailPassword(usuario, password)
              .then((value) {
            if (value.exito == 1) {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  duration: Duration(milliseconds: 300),
                  reverseDuration: Duration(milliseconds: 300),
                  child: HomePageWidget(
                    usuario: value,
                  ),
                ),
              );
            }
          }).onError((error, stackTrace) {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: const Text('ERROR'),
                content: const Text(
                    'Error de conexión o busqueda en la base de datos'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Colors.orange, // Cambia el color del texto a naranja
                    ),
                  ),
                ],
              ),
            );
          });
        }
      } else {
        _changeConectionMessage();
      }
    });
  }

  _changeConection() {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => ConnectionWidget()))
        .then((value) {
      _currentSession();
    });
  }

  _changeConectionMessage() {
    showDialog<String>(
      context: this.context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Sin servidor'),
        content: const Text('Servidor no registrado'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConnectionWidget())).then((value) {
                _currentSession();
                Navigator.pop(context);
              });
            },
            child: const Text('Configuración de Servidor'),
            style: TextButton.styleFrom(
              foregroundColor:
                  Colors.orange, // Cambia el color del texto a naranja
            ),
          ),
        ],
      ),
    );
  }

  _initSession() async {
    // preffs = await SharedPreferences.getInstance();
    // String servidor = preffs.getString("server");
    // var splitServer = servidor.split(":");
    // String tempServer = splitServer.first;
    // String tempPuerto = splitServer.last;
    DatabaseProvider.getUserByEmailPassword(
            emailAddressLoginController.text, passwordLoginController.text)
        .then((value) {
      print(value.nombre_persona);
      if (value.mensaje != "") {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Ocurrio un problema'),
            content: Text(value.mensaje),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
                style: TextButton.styleFrom(
                  foregroundColor:
                      Colors.orange, // Cambia el color del texto a naranja
                ),
              ),
            ],
          ),
        );
      } else {
        preffs.setString("user", emailAddressLoginController.text);
        preffs.setString("password", passwordLoginController.text);

        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 300),
            reverseDuration: Duration(milliseconds: 300),
            child: HomePageWidget(
              usuario: value,
            ),
          ),
        );
      }
    }).onError((error, stackTrace) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('ERROR'),
          content:
              const Text('Error de conexión o busqueda en la base de datos'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.orange, // Cambia el color del texto a naranja
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(30, 90, 30, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/inventarios.png',
                width: MediaQuery.of(context).size.width * .5,
              ),
              SizedBox(height: 50),
              Text(
                'Toma de Inventarios Chachitos',
                style: GoogleFonts.getFont('Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: FlutterFlowTheme.of(context).grayDark),
              ),
              SizedBox(height: 15),
              Text(
                'Por favor, escribe tus datos de acceso.',
                style: GoogleFonts.getFont('Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: FlutterFlowTheme.of(context).grayLight),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailAddressLoginController,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Escribe tu usuario',
                  labelStyle: GoogleFonts.getFont(
                    'Poppins',
                    fontWeight: FontWeight.bold,
                    color: FlutterFlowTheme.of(context).grayLight,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).background,
                  prefixIcon: Icon(
                    Icons.supervised_user_circle_outlined,
                    color: FlutterFlowTheme.of(context).grayDark,
                    size: 25,
                  ),
                ),
                style: GoogleFonts.getFont(
                  'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                onEditingComplete: () {
                  _initSession();
                },
                controller: passwordLoginController,
                obscureText: !passwordLoginVisibility,
                decoration: InputDecoration(
                  labelText: 'Escribe tu contraseña',
                  labelStyle: GoogleFonts.getFont(
                    'Poppins',
                    fontWeight: FontWeight.bold,
                    color: FlutterFlowTheme.of(context).grayLight,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).background,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: FlutterFlowTheme.of(context).grayDark,
                    size: 25,
                  ),
                  suffixIcon: InkWell(
                    onTap: () => setState(
                      () => passwordLoginVisibility = !passwordLoginVisibility,
                    ),
                    child: Icon(
                      passwordLoginVisibility
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: FlutterFlowTheme.of(context).grayLight,
                      size: 20,
                    ),
                  ),
                ),
                style: GoogleFonts.getFont(
                  'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  _initSession();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Iniciar Sesión ',
                        style: GoogleFonts.getFont('Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white)),
                    Icon(Icons.login),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 243, 124, 33),
                  shape: StadiumBorder(),
                ),
              ),
              Text(
                "Versión " + DatabaseProvider.VERSION,
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont('Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    color: Color.fromARGB(255, 243, 124, 33)),
              ),
              Text(
                "MDS Sistemas",
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont('Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                    color: Color.fromARGB(255, 243, 124, 33)),
              ),
              SizedBox(height: 20),
             
            ],
          ),
        ),
      ),
    );
  }
}
