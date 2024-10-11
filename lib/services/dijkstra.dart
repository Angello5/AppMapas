// ignore: unused_import
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:mapas_app/models/edge.dart';
import 'package:mapas_app/models/node.dart';

class Dijkstra {
  final List<Node> nodes;
  final List<Edge> edges;
  late Map<int, List<Edge>> listAdyacencia;

  Dijkstra({required this.nodes, required this.edges}){
    listAdyacencia = {};
    for(var edge in edges){
      listAdyacencia.putIfAbsent(edge.source, () => []).add(edge);

      //Si las carreteras son de ambos sentidos, se agrega reversa
      listAdyacencia.putIfAbsent(edge.target, () => []) .add(Edge(
        source: edge.target,
        target: edge.source,
        length: edge.length,
        geometry: edge.geometry,
      ));
    }
  }

  List<int> caminomasCorto(int startId, int endID){
    Map<int, double> distances = {};
    Map<int, int?> previo = {};

    for(var node in nodes){
      distances[node.id] = double.infinity;
      previo[node.id] = null;
    }

    distances[startId] = 0;

    //Priority queue es una dependencia para facilitar el proceso
    var queue = PriorityQueue<int>((a,b) => distances[a]!.compareTo(distances[b]!));
    queue.add(startId);

    while(queue.isNotEmpty){
      int actual = queue.removeFirst();

      if(actual == endID) break;

      for(var edge in listAdyacencia[actual] ?? []){
        double alt = distances[actual]! + edge.length;
        if(alt < distances[edge.target]!){
          distances[edge.target] = alt;
          previo[edge.target] = actual;
          queue.add(edge.target);
        }
      }
    }

    //Reconstruir el camino
    List<int> path = [];
    int? actual = endID;
    while(actual != null){
      path.insert(0, actual);
      actual = previo[actual];
    }
    if(path.first != startId){
      return []; //no existe ruta 
    }
    return path;
  }
}