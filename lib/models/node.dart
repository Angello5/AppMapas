class Node {
  final int id;
  final double lat;
  final double lon;

  Node({required this.id, required this.lat, required this.lon});

  factory Node.fromJson(Map<String, dynamic> json){
    return Node(
      id: json['id'],
      lat: json['y'],
      lon: json['x'],
      );
  }
}