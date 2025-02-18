import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:i_p_s_mant/models/userModel.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanEventWidget extends StatefulWidget {
  final user usuario;
  const ScanEventWidget({Key key, this.usuario}) : super(key: key);

  @override
  _ScanEventWidgetState createState() => _ScanEventWidgetState();
}

class _ScanEventWidgetState extends State<ScanEventWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  Barcode result;
  String codigo = "";
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Icon iconoFlash = Icon(Icons.flash_off);
  bool flashActivo = false;
  bool tieneFlash = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  _flash() {
    controller.toggleFlash();
    setState(() {
      flashActivo = !flashActivo;
      iconoFlash = flashActivo ? Icon(Icons.flash_on) : Icon(Icons.flash_off);
    });
  }

  _girarPantalla() {
    bool vertical = (MediaQuery.of(context).orientation.name == "portrait");
    if (vertical) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  _tieneFlash() async {
    SystemFeatures camara = await controller.getSystemFeatures();
    setState(() {
      tieneFlash = camara.hasFlash;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: EdgeInsets.only(top: 16),
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                fit: BoxFit.scaleDown,
              ),
            ),
            // Título
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "Leer código",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xFFF37C21),
                ),
              ),
            ),
            // Contenedor del QR
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: _buildQrView(context),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "MDS Sistemas",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: FlutterFlowTheme.of(context).background,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón para girar pantalla
          FloatingActionButton(
            heroTag: "girar",
            onPressed: () => _girarPantalla(),
            backgroundColor: Color(0xFFF37C21),
            tooltip: "Girar pantalla",
            child: Icon(Icons.screen_rotation, color: Colors.white),
          ),
          SizedBox(width: 10),
          // Botón para activar/desactivar flash si tiene flash
          if (tieneFlash)
            FloatingActionButton(
              heroTag: "flash",
              onPressed: () => _flash(),
              backgroundColor: Color(0xFFF37C21),
              tooltip: "Flash",
              child: iconoFlash,
            ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width * .7;
    var scanHeight = MediaQuery.of(context).size.height * .25;

    var formaVertical = QrScannerOverlayShape(
      borderColor: Color(0xFFF37C21),
      borderRadius: 15,
      borderLength: 30,
      borderWidth: 8,
      cutOutSize: scanArea,
    );
    var formaHorizontal = QrScannerOverlayShape(
      borderColor: Color(0xFFF37C21),
      borderRadius: 15,
      borderLength: 30,
      borderWidth: 8,
      cutOutHeight: scanHeight,
      cutOutWidth: scanArea,
    );

    bool horizontal = (MediaQuery.of(context).orientation.name == "landscape");

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: horizontal ? formaHorizontal : formaVertical,
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      _tieneFlash();
    });
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      setState(() {
        result = scanData;
        Fluttertoast.showToast(
            msg: result.code,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);

        if (Platform.isAndroid) {
          Navigator.pop(context, result.code);
        } else {
          if (codigo == "") {
            codigo = result.code;
            controller.resumeCamera();
          } else {
            if (codigo == result.code) {
              Navigator.pop(context, codigo);
            } else {
              codigo = result.code;
              controller.resumeCamera();
            }
          }
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tiene permiso para usar la cámara')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
