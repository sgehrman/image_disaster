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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Is Broken on WASM'),
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

  static const String _instructions = '''
This crashes when compiled with WASM\n
Use VSCode to run two targets: "image_disaster" and "image_disaster_wasm"
WASM crashes when loading image from memory.\n
Steps to reproduce:\n
1. In VSCode, run "image_disaster_wasm"
1. Click "Crash Me" button
2. Observe crash\n
3. In VSCode, run "image_disaster"
4. Click "Crash Me" button
5. Observe no crash
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(_instructions, style: TextStyle(fontSize: 22)),

            Text('Image from asset:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Image.asset('assets/test.png', width: 600, height: 300),

            if (_imageData != null) ...[
              const SizedBox(height: 12),
              Text('Image from memory:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),

              Image.memory(_imageData!, width: 600, height: 300),
            ],
            const SizedBox(height: 20),
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
              child: const Text('Load Image'),
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
