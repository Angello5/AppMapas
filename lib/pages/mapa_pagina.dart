import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapas_app/services/dijkstra.dart';
import 'package:mapas_app/services/graph_service.dart';
import 'package:mapas_app/models/node.dart';
import 'package:mapas_app/services/geocoding_service.dart'; // Servicio de geocodificación
import 'dart:math';

class MapaPagina extends StatefulWidget {
  const MapaPagina({super.key});
  @override
  MapaPaginaState createState() => MapaPaginaState();
}

class MapaPaginaState extends State<MapaPagina> {
  final MapController mapController = MapController();
  List<Marker> markers = [];
  List<Polyline> polylines = [];
  final TextEditingController inicioController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();
  bool isLoading = false;

  late GraphService graphService;
  late Dijkstra dijkstra;

  @override
  void initState() {
    super.initState();
    graphService = GraphService();
    initializeGraph();
  }

  Future<void> initializeGraph() async {
    setState(() {
      isLoading = true;
    });
    try {
      await graphService.loadGraph();
      dijkstra = Dijkstra(nodes: graphService.nodes, edges: graphService.edges);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el grafo: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapas App'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/historial');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inicioController,
                    decoration: InputDecoration(
                      labelText: 'Dirección de inicio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: destinoController,
                    decoration: InputDecoration(
                      labelText: 'Dirección de destino',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    String inicio = inicioController.text;
                    String destino = destinoController.text;
                    if (inicio.isNotEmpty && destino.isNotEmpty) {
                      await buscarRuta(inicio, destino);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Por favor, ingresar ambas direcciones')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: LatLng(0, 0),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                       //attribution: '© OpenStreetMap contributors',
                      ),
                      MarkerLayer(
                        markers: markers,
                      ),
                      PolylineLayer(
                        polylines: polylines,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> buscarRuta(String inicio, String destino) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Geocodificar direcciones
      var geocodingService = GeocodingService();
      var inicioCoords = await geocodingService.geocodificarAsync(inicio);
      var destinoCoords = await geocodingService.geocodificarAsync(destino);

      // Encontrar los nodos más cercanos en el grafo a las coordenadas
      var startNodeId = encontrarMasCercano(inicioCoords.lat, inicioCoords.lon);
      var endNodeId = encontrarMasCercano(destinoCoords.lat, destinoCoords.lon);

      if (startNodeId == null || endNodeId == null) {
        throw Exception("No se encontró un nodo cercano en las direcciones");
      }

      // Usar Dijkstra
      List<int> path = dijkstra.caminomasCorto(startNodeId, endNodeId);

      if (path.isEmpty) {
        throw Exception("No se encontró una ruta entre los puntos seleccionados");
      }

      // Convertir IDs de nodos a coordenadas LatLng
      List<LatLng> rutaCoordenadas = path.map((nodeId) {
        Node node = graphService.nodes.firstWhere((n) => n.id == nodeId);
        return LatLng(node.lat, node.lon);
      }).toList();

      // Actualizar el mapa
      setState(() {
        markers = [
          Marker(
            width: 80.0,
            height: 80.0,
            point: rutaCoordenadas.first,
            child: Icon(
              Icons.location_on,
              color: Colors.green,
              size: 40.0,
            ),
          ),
          Marker(
            width: 80.0, 
            height: 80.0,
            point: rutaCoordenadas.last,
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        ];
        polylines = [
          Polyline(
            points: rutaCoordenadas,
            strokeWidth: 4.0,
            color: Colors.blue,
          ),
        ];

        // Centrarse en la ruta
       mapController.fitCamera(
        CameraFit.bounds(
           bounds: LatLngBounds.fromPoints(rutaCoordenadas),
          padding: EdgeInsets.all(12),
  ),
);

      });

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ruta encontrada y mostrada en el mapa')),
      );

    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar la ruta: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  int? encontrarMasCercano(double lat, double lon) {
    double minDistancia = double.infinity;
    int? closestNodeId;

    for (var node in graphService.nodes) {
      double distancia = distanciaBetween(lat, lon, node.lat, node.lon);
      if (distancia < minDistancia) {
        minDistancia = distancia;
        closestNodeId = node.id;
      }
    }
    return closestNodeId;
  }

  double distanciaBetween(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Radio de la Tierra en metros
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}
