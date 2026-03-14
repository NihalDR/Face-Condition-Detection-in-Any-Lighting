import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_live_emotion/home.dart';

List<CameraDescription>? cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize available cameras for front-facing face detection
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection in Any Lighting',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
