// lib/models/edge.dart
class Edge {
  final int source;
  final int target;
  final double length;
  final List<List<double>> geometry; // Lista de coordenadas [lat, lon]

  Edge({
    required this.source, required this.target, required this.length, required this.geometry});

  factory Edge.fromJson(Map<String, dynamic> json) {
    return Edge(
      source: json['source'],
      target: json['target'],
      length: json['length'].toDouble(),
      geometry: (json['geometry'] as List)
          .map((coord) => List<double>.from(coord.map((c) => c.toDouble())))
          .toList(),
    );
  }
}
