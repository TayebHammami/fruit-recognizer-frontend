import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:convert';
import 'dart:async';

import 'package:provider/provider.dart';

import 'Provider/detector_provider.dart';
import 'home_screen.dart';


late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // Fetch available cameras

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => DetectorProvider(cameras.first),
        ),
      ],
      child:  MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

//
// class BoundingBoxPainter extends CustomPainter {
//   final List<dynamic> predictions;
//
//   BoundingBoxPainter(this.predictions);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;
//
//     for (var prediction in predictions) {
//       final box = prediction['box'];
//       final left = box[0] * size.width;
//       final top = box[1] * size.height;
//       final right = box[2] * size.width;
//       final bottom = box[3] * size.height;
//
//       canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
//
//       final textPainter = TextPainter(
//         text: TextSpan(
//           text: '${prediction['label']} (${(prediction['confidence'] * 100).toStringAsFixed(1)}%)',
//           style: TextStyle(color: Colors.white, fontSize: 12),
//         ),
//         textDirection: TextDirection.ltr,
//       )..layout();
//       textPainter.paint(canvas, Offset(left, top - 10));
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
