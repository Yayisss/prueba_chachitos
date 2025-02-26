import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:i_p_s_mant/models/articulosComprometidosModel.dart';
import 'package:i_p_s_mant/models/entradasArticulosModel.dart';
import 'package:i_p_s_mant/models/ubicacionesSucursalModel.dart';
import '../models/articulosModel.dart';
import '../models/sucursalesModel.dart';
import '/models/detallesTomaInventarioModel.dart';
import '/models/tomasInventarioModel.dart';
import '/models/userModel.dart';
import '/models/variablesModel.dart';
import 'package:i_p_s_mant/models/permiso_sucursal_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DatabaseProvider {
  SharedPreferences preffs;

  static const VERSION = "1.0.0.0";

  static const ROOT = "https://alleatoapis.com/apis/api_chachitos.php";

  static Future<bool> conecctionIntent(String tempServer) async {
    Map data = {'db_host': '54.83.229.132,1464'};
    //encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      print(response.body);
      if (response.body == "") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<user> getUserByEmailPasswordFromMemory() async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server");
    String usuario = preffs.getString("user");
    String password = preffs.getString("password");
    Map data = {
      'db_host': tempServer,
      'action': "login",
      'usuario': usuario,
      'contrasena': password
    };
    //encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      print(response.body);
      user list = user.fromJson(json.decode(response.body));

      return list;
    } else {
      throw "No se logró establecer conexión";
    }
  }

  static Future<user> getUserByEmailPassword(
      String usuario, String password) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server");
    Map data = {
      'db_host': tempServer,
      'action': "login",
      'usuario': usuario,
      'contrasena': password
    };
    //encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      print(response.body);
      user list = user.fromJson(json.decode(response.body));

      return list;
    } else {
      throw "No se logró establecer conexión";
    }
  }

  static List<user> parseUser(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<user>((json) => user.fromJson(json)).toList();
  }

  //----------------------------------------------------------
  // SECCION DE TOMA DE INVENTARIOS
  //----------------------------------------------------------
  static Future<List<dynamic>> getTomasInventarios(
      int toma, int usuario) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server");
    Map data = {
      'db_host': tempServer,
      'action': "consulta_folio_toma",
      'toma': toma,
      'usuario': usuario
    };

    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      print(response.body);
      variables total = parseTotal(json.decode(response.body));
      List<tomasInventario> tomas_inventarios =
          parseTomasInventarios(json.decode(response.body));
      List<detallesTomaInventario> detallesTomas =
          parseDetallesTomas(json.decode(response.body));
      List<dynamic> resultado = [];
      resultado.add(total);
      resultado.add(tomas_inventarios);
      resultado.add(detallesTomas);
      return resultado;
    } else {
      throw "No se logró establecer conexión";
    }
  }

  static variables parseTotal(Map<String, dynamic> responseBody) {
    List<dynamic> detallesjson = responseBody['total'];
    return detallesjson
        .map<variables>((json) => variables.fromJson(json))
        .toList()
        .first;
  }

  static List<tomasInventario> parseTomasInventarios(
      Map<String, dynamic> responseBody) {
    List<dynamic> detallesjson = responseBody['tomas_inventarios'];
    return detallesjson
        .map<tomasInventario>((json) => tomasInventario.fromJson(json))
        .toList();
  }

  static List<detallesTomaInventario> parseDetallesTomas(
      Map<String, dynamic> responseBody) {
    List<dynamic> detallesjson = responseBody['detalles'];
    return detallesjson
        .map<detallesTomaInventario>(
            (json) => detallesTomaInventario.fromJson(json))
        .toList();
  }

  static Future<bool> guardaTomaInventario(
      int toma, int conteo, int usuario, String detalles) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server");
    Map data = {
      'db_host': tempServer,
      'action': "guarda_detalles_toma",
      'toma': toma,
      'conteo': conteo,
      'usuario': usuario,
      'detalles': detalles
    };
    //encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      print(response.body);

      return true;
    } else {
      return false;
    }
  }

  //----------------------------------------------------------
  // FIN DE SECCION DE TOMA DE INVENTARIOS
  //----------------------------------------------------------

  //----------------------------------------------------------
  // SECCION DE BUSQUEDA DE ARTICULOS
  //----------------------------------------------------------
  static Future<List<dynamic>> getArticulo(String articulo, int usuario) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server");
    Map data = {
      'db_host': tempServer,
      'action': "consulta_articulo",
      'articulo': articulo,
      'usuario': usuario
    };
    //encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      print(response.body);
      List<articulos> articulo = parseArticulos(json.decode(response.body));
      List<entradasArticulos> entradas =
          parseEntradasArticulos(json.decode(response.body));

      List<dynamic> resultado = [];
      resultado.add(articulo);
      resultado.add(entradas);

      return resultado;
    } else {
      throw "No se logró establecer conexión";
    }
  }

  // Obtener artículo
  static Future<List<dynamic>> getArticuloChachitos(
      String articulo, int usuario) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server") ??
        '54.83.229.132,1464'; // Si no existe, usa valor predeterminado

    Map data = {
      'db_host': tempServer,
      'action': "consulta_articulo",
      'articulo': articulo,
      'usuario': usuario
    };

    // Encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      print(response.body);
      var decodedResponse = json.decode(response.body);

      // Verifica si la clave 'articulos' existe y es una lista
      if (decodedResponse.containsKey('articulos') &&
          decodedResponse['articulos'] is List) {
        List<dynamic> articulosList = decodedResponse['articulos'];
        return articulosList; // Devuelves la lista de artículos
      } else {
        throw Exception(
            "La clave 'articulos' no se encuentra en la respuesta o no es una lista.");
      }
    } else {
      throw Exception("Error fetching articulo");
    }
  }

  // Parsear artículos
  static List<articulos> parseArticulos(Map<String, dynamic> responseBody) {
    List<dynamic> detallesjson = responseBody['articulos'];
    return detallesjson
        .map<articulos>((json) => articulos.fromJson(json))
        .toList();
  }

  // Parsear entradas de artículos
  static List<entradasArticulos> parseEntradasArticulos(
      Map<String, dynamic> responseBody) {
    List<dynamic> detallesjson = responseBody['entradas'];
    return detallesjson
        .map<entradasArticulos>((json) => entradasArticulos.fromJson(json))
        .toList();
  }

  // Obtener fotos de un artículo
  static Future<List<String>> getFotoArticulo(int articulo) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server") ??
        '54.83.229.132,1464'; // Si no existe, usa valor predeterminado

    Map data = {
      'db_host': tempServer,
      'action': "trae_foto_articulo",
      'articulo': articulo,
    };

    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      print(response.body);

      String texto_base64 = parseTextoBase64(json.decode(response.body));
      String url = parseURL(json.decode(response.body));

      List<String> foto = [];
      foto.add(texto_base64);
      foto.add(url);

      return foto;
    } else {
      return ["", ""];
    }
  }

  // Parsear texto base64
  static String parseTextoBase64(Map<String, dynamic> responseBody) {
    return responseBody['texto_base64'];
  }

  // Parsear URL de la foto
  static String parseURL(Map<String, dynamic> responseBody) {
    return responseBody['ubicacion_URL'];
  }

  // Guardar toma
  static Future<int> guardaToma(
      String articulo, int usuario, double existencia) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server") ??
        '54.83.229.132,1464'; // Si no existe, usa valor predeterminado

    Map data = {
      'db_host': tempServer,
      'action': "guarda_toma",
      'articulo': articulo,
      'usuario': usuario,
      'existencia': existencia
    };

    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      print(response.body);
      return parseToma(json.decode(response.body));
    } else {
      throw Exception("Error saving toma");
    }
  }

  // Parsear toma
  static int parseToma(Map<String, dynamic> responseBody) {
    return responseBody['toma'];
  }

  // Integrar comprometidos
  static Future<List<articulosComprometidos>> integraComprometidos(
      String articulo, String sucursal) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server") ??
        '54.83.229.132,1464'; // Si no existe, usa valor predeterminado

    Map data = {
      'db_host': tempServer,
      'action': "integra_comprometidos",
      "articulo": articulo,
      "sucursal": sucursal
    };

    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      print(response.body);
      List<articulosComprometidos> list =
          parseComprometidos(json.decode(response.body));
      return list;
    } else {
      throw Exception("No se logró establecer conexión");
    }
  }

  // Parsear comprometidos
  static List<articulosComprometidos> parseComprometidos(
      Map<String, dynamic> responseBody) {
    List<dynamic> detallesjson = responseBody['resultado'];
    return detallesjson
        .map<articulosComprometidos>(
            (json) => articulosComprometidos.fromJson(json))
        .toList();
  }

  // Obtener combo de ubicaciones de sucursal
  static Future<List<ubicacionesSucursal>> getComboUbicacionesSucursal(
      int usuario) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server") ??
        '54.83.229.132,1464'; // Si no existe, usa valor predeterminado

    Map data = {
      'db_host': tempServer,
      'action': "combo_ubicaciones_sucursal",
      'usuario': usuario
    };

    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      print(response.body);
      List<ubicacionesSucursal> list =
          parseComboUbicacionesSucursal(json.decode(response.body));
      return list;
    } else {
      throw Exception("No se logró establecer conexión");
    }
  }

  // Parsear combo de ubicaciones de sucursal
  static List<ubicacionesSucursal> parseComboUbicacionesSucursal(
      Map<String, dynamic> responseBody) {
    List<dynamic> detallesjson = responseBody['ubicaciones'];
    return detallesjson
        .map<ubicacionesSucursal>((json) => ubicacionesSucursal.fromJson(json))
        .toList();
  }

  // Guardar ubicación de artículo
  static Future<bool> guardaUbicacionArticulo(
      int usuario, int articulo, int ubicacion) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server") ??
        '54.83.229.132,1464'; // Si no existe, usa valor predeterminado

    Map data = {
      'db_host': tempServer,
      'action': "guarda_ubicacion_articulo",
      'usuario': usuario,
      'articulo': articulo,
      'ubicacion': ubicacion
    };

    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode == 200) {
      print(response.body);
      return true;
    } else {
      return false;
    }
  }
  //----------------------------------------------------------
  // FIN DE SECCION DE BUSQUEDA DE ARTICULOS
  //----------------------------------------------------------

  //----------------------------------------------------------
  // INICIO DE SECCION DE CONFIGURACIÓN
  //----------------------------------------------------------
  static Future<List<dynamic>> getConfiguraciones(int usuario) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server");
    Map data = {
      'db_host': tempServer,
      'action': "trae_configuraciones",
      'usuario': usuario
    };
    //encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      print(response.body);
      permisoSucursal permiso =
          parsePermisoSucursal(json.decode(response.body));
      List<sucursales> sucursalesLista =
          parseSucursales(json.decode(response.body));
      List<dynamic> resultado = [];
      resultado.add(permiso);
      resultado.add(sucursalesLista);
      return resultado;
    } else {
      throw "No se logró establecer conexión";
    }
  }

  static permisoSucursal parsePermisoSucursal(
      Map<String, dynamic> responseBody) {
    dynamic detallesjson = responseBody['permiso'];
    return permisoSucursal.fromJson(detallesjson);
  }

  static List<sucursales> parseSucursales(Map<String, dynamic> responseBody) {
    List<dynamic> detallesjson = responseBody['sucursales'];
    return detallesjson
        .map<sucursales>((json) => sucursales.fromJson(json))
        .toList();
  }

  static Future<bool> saveConfiguraciones(int usuario, int sucursal) async {
    var preffs = await SharedPreferences.getInstance();
    String tempServer = preffs.getString("server");
    Map data = {
      'db_host': tempServer,
      'action': "guarda_configuraciones",
      'usuario': usuario,
      'sucursal': sucursal
    };
    //encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(ROOT),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      print(response.body);

      return true;
    } else {
      return false;
    }
  }

  static obtenerDetallesToma(int toma) {}

  //----------------------------------------------------------
  // FIN DE SECCION DE CONFIGURACIÓN
  //----------------------------------------------------------
}
