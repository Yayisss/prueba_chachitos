import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:i_p_s_mant/backend/database_connect.dart';
import 'package:i_p_s_mant/models/articulosComprometidosModel.dart';
import 'package:i_p_s_mant/models/userModel.dart';
import '../../backend/mensajes.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class ArticulosComprometidosWidget extends StatefulWidget {
  final String articulo;
  final user usuario;
  const ArticulosComprometidosWidget({Key key, this.articulo, this.usuario})
      : super(key: key);

  @override
  _ArticulosComprometidosWidgetState createState() =>
      _ArticulosComprometidosWidgetState();
}

class _ArticulosComprometidosWidgetState
    extends State<ArticulosComprometidosWidget> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _horizontal = ScrollController(),
      _vertical = ScrollController();
  List<articulosComprometidos> comprometidos = [];
  bool buscando = true;
  bool esChachitos = false;

  @override
  void dispose() {
    super.dispose();
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
          "Mercancia Comprometida",
          //"Integración de Mercancia Comprometida",
          style: GoogleFonts.getFont('Poppins',
              fontWeight: FontWeight.bold, fontSize: 21, color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: FlutterFlowTheme.of(context).background,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(5),
          height: MediaQuery.of(context).size.height, //-105
          child: buscando
              ? Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                  EdgeInsetsDirectional.fromSTEB(30, 35, 30, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/robotConsulta.gif",
                          height:
                          MediaQuery.of(context).size.height * 0.35,
                        ),
                      ]),
                ),
                Text(
                  "Búscando...",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont('Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 23,
                      color: FlutterFlowTheme.of(context).primaryColor),
                ),
              ])
              : comprometidos.isEmpty
              ? Padding(
              padding: EdgeInsetsDirectional.fromSTEB(30, 35, 30, 0),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/searching.gif",
                      height:
                      MediaQuery.of(context).size.height * 0.35,
                    ),
                    Text(
                      "No hay artículos para mostrar",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont('Poppins',
                          fontWeight: FontWeight.normal,
                          fontSize: 25,
                          color: FlutterFlowTheme.of(context)
                              .primaryColor),
                    ),
                  ]))
              : Scrollbar(
            controller: _vertical,
            thumbVisibility: true,
            trackVisibility: false,
            interactive: true,
            thickness: 8,
            radius: Radius.circular(25),
            child: Scrollbar(
              controller: _horizontal,
              thumbVisibility: true,
              trackVisibility: false,
              interactive: true,
              thickness: 8,
              radius: Radius.circular(25),
              child: DataTable2(
                  scrollController: _vertical,
                  horizontalScrollController: _horizontal,
                  columnSpacing: 10,
                  horizontalMargin: 13,
                  dataRowHeight: 70,
                  // border: TableBorder.all(),
                  minWidth: 575,
                  // minWidth: MediaQuery.of(context).size.width * 1.3,
                  // headingRowHeight: 70,
                  // headingRowColor:
                  // MaterialStateColor.resolveWith(
                  //       (states) => Colors.white,
                  // ),
                  columns: [(esChachitos)
                      ? DataColumn2(
                    label: Text(
                      '',
                      textAlign:
                      TextAlign
                          .left,
                      style: GoogleFonts
                          .getFont(
                        'Poppins',
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                    size: ColumnSize.M
                  )
                      : DataColumn(label: null),
                    DataColumn2(
                      label: Text(
                        'Tipo y \nFolio',
                        textAlign:
                        TextAlign.center,
                        style:
                        GoogleFonts.getFont(
                          'Poppins',
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                        size: ColumnSize.L
                    ),
                    DataColumn2(
                      label: Text(
                        'Fecha',
                        textAlign:
                        TextAlign.center,
                        style:
                        GoogleFonts.getFont(
                          'Poppins',
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text(
                        'Cte / Suc / \nDestino',
                        style:
                        GoogleFonts.getFont(
                          'Poppins',
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                        size: ColumnSize.L
                    ),
                    DataColumn2(
                        label: Text(
                          'Cant.',
                          textAlign:
                          TextAlign.center,
                          style: GoogleFonts
                              .getFont(
                            'Poppins',
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        size: ColumnSize.S,
                        numeric: true),
                    DataColumn2(
                      label: Text(
                        'F. \nProm.',
                        textAlign:
                        TextAlign.center,
                        style:
                        GoogleFonts.getFont(
                          'Poppins',
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      size: ColumnSize.S,
                    ),
                    DataColumn(
                      label: Text(
                        'Edo. Act.',
                        textAlign:
                        TextAlign.center,
                        style:
                        GoogleFonts.getFont(
                          'Poppins',
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  rows: comprometidos
                      .map((articulo) =>
                      DataRow(cells: [
                        (esChachitos)
                            ? DataCell(Text(
                          articulo
                              .informacion_surtido,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: FlutterFlowTheme.of(context).primaryColor),
                        ))
                            : DataCell(
                            SizedBox()),
                        DataCell(((esChachitos) &&
                            (articulo.tipo ==
                                "Pedido"))
                            ? Text(articulo.tipo
                             +
                            ' #' +
                            NumberFormat("#,###,###")
                                .format(articulo
                                .folio) +
                            " - " +
                            articulo.nombre_color
                                )
                            : Text(articulo.tipo
                            +
                            ' #' +
                            NumberFormat("#,###,###")
                                .format(articulo.folio))),
                        DataCell(Text(articulo
                            .fecha_texto
                            )),
                        DataCell(Text(articulo
                            .jefe
                            )),
                        DataCell(Text(NumberFormat(
                            "#,###,###")
                            .format(articulo
                            .cantidad))),
                        DataCell(Text(articulo
                            .promesa_texto
                            )),
                        DataCell(Text(articulo
                            .estado_actual
                            )),
                      ]))
                      .toList()),
            ),
          )
         
          //                         ? DataColumn(                  
          //                               ? DataCell(Text(                          
          //                               ? Text(articulo.tipo
        )
      ),
    );
  }
}
