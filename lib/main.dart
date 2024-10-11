import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Test App')),
        body: Center(
          child: ElevatedButton(
            onPressed: _getPath,
            child: Text('Get Path'),
          ),
        ),
      ),
    );
  }

  void _getPath() async {
    Directory dir = await getApplicationDocumentsDirectory();
    print('Path: ${dir.path}');
  }
}