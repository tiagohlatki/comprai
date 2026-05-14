import 'package:flutter/material.dart';

void main() {
  runApp(const CompraiApp());
}

class CompraiApp extends StatelessWidget {
  const CompraiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'comprai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A6B3C)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('comprai — em construção')),
      ),
    );
  }
}
