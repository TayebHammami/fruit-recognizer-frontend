import 'package:flutter/material.dart';

class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(this.absoluteImageSize, this.objects);

  final Size absoluteImageSize;
  final List<dynamic> objects;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.pinkAccent;

    for (var detectedObject in objects) {
      final box = detectedObject['box'];
      final label = detectedObject['label'];
      final confidence = detectedObject['confidence'];

      canvas.drawRect(
        Rect.fromLTRB(
          box[1] * scaleX,
          box[0] * scaleY,
          box[3] * scaleX,
          box[2] * scaleY,
        ),
        paint,
      );

      TextSpan span = TextSpan(
        text: '$label (${(confidence * 100).toStringAsFixed(1)}%)',
        style: const TextStyle(fontSize: 15, color: Colors.blue),
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(box[1] * scaleX, box[0] * scaleY),
      );
    }
  }

  @override
  bool shouldRepaint(ObjectDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.objects != objects;
  }
}