import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _imageData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('This crashes with WASM'),
            if (_imageData != null)
              Image.memory(_imageData!, width: 300, height: 300),
            ElevatedButton(
              onPressed: () async {
                final image = await _loadUiImage('assets/test.png');

                final bd = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );

                image.dispose();

                if (bd != null) {
                  _imageData = bd.buffer.asUint8List();

                  setState(() {});
                }
              },
              child: const Text('Crash Me'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<ui.Image> _loadUiImage(String imageAssetPath) async {
    final data = await rootBundle.load(imageAssetPath);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (img) {
      return completer.complete(img);
    });

    return completer.future;
  }
}
