import 'dart:convert';  
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapas_app/models/edge.dart';
import 'package:mapas_app/models/node.dart';

class GraphService {
  List<Node> nodes = [];
  List<Edge> edges = [];

  Future<void> loadGraph() async{
    String data = await rootBundle.loadString('assets/graph.json');
    Map<String, dynamic> jsonResult = jsonDecode(data);

    //Parsear nodos
    nodes = (jsonResult['nodes'] as List)
    .map((nodeJson) => Node.fromJson(nodeJson))
    .toList();

    //Parsear aristas
    edges = (jsonResult['edeges'] as List)
    .map((edgeJson) => Edge.fromJson(edgeJson))
    .toList();

  }
}