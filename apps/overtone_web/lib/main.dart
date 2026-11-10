import 'package:flutter/material.dart';

void main() {
  runApp(const OvertoneApp());
}

class OvertoneApp extends StatelessWidget {
  const OvertoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Overtone',
      home: Scaffold(body: Center(child: Text('Overtone'))),
    );
  }
}
