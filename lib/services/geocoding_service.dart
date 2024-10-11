import 'dart:convert';
import 'package:http/http.dart' as http;


// Clase que representa el resultado de la geocodificación
class GeocodingResult {
  final double lat;
  final double lon;

  GeocodingResult({required this.lat, required this.lon});
}

// Servicio de Geocodificación que utiliza la API de Nominatim
class GeocodingService {
  // Método para geocodificar una dirección
  Future<GeocodingResult> geocodificarAsync(String direccion) async {
    var cliente = http.Client();
    try {
      // Construir la URL de la solicitud
      var url =
          "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(direccion)}&format=json&limit=1";

      // Realizar la solicitud GET con el encabezado User-Agent personalizado
      var respuesta = await cliente.get(Uri.parse(url), headers: {
        'User-Agent': 'MapasApp/1.0 (llerena-gomez@hotmail.com))' //correo de contacto
      });

      // Verificar el estado de la respuesta
      if (respuesta.statusCode == 200) {
        var data = jsonDecode(respuesta.body) as List<dynamic>;
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lon = double.parse(data[0]['lon']);
          return GeocodingResult(lat: lat, lon: lon);
        } else {
          throw Exception("Direccion no encontrada.");
        }
      } else {
        throw Exception("Error en la solicitud: ${respuesta.statusCode}");
      }
    } catch (e) {
      // Manejo de excepciones
      throw Exception("Error en la geocodificación: $e");
    } finally {
      // Cerrar el cliente HTTP
      cliente.close();
    }
  }
}