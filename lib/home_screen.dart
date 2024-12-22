import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fruits_detector/widget/custom_painter.dart';
import 'package:provider/provider.dart';
import '../Widget/animation_text_button.dart';
import 'Provider/detector_provider.dart';

class HomeScreen extends StatelessWidget {
  late Size size;

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<DetectorProvider>(context, listen: false);
    print(Provider.of<DetectorProvider>(context, listen: false).scanResults);
    Widget buildResult() {
      return Consumer<DetectorProvider>(
        builder: (context, result, child) {
          if (result.scanResults.isEmpty && result.isRecognizing == true) {
            return const Center(child: Text(''));
          }
          final previewSize = result.controller.value.previewSize;
          if (previewSize == null) {
            return const Center(child: Text('Waiting Camera.'));
          }

          final Size imageSize = Size(previewSize.height, previewSize.width);
          CustomPainter painter =
              ObjectDetectorPainter(imageSize, result.scanResults);

          return CustomPaint(
            painter: painter,
            child: Container(),
          );
        },
      );
    }

    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height,
        child: Consumer<DetectorProvider>(
          builder: (context, result, child) {
            // Check if the controller is initialized
            if (!result.controller.value.isInitialized) {
              // Show a loading spinner until the controller is ready
              return const Center(child: CircularProgressIndicator());
            }
            // Once initialized, render the CameraPreview
            return AspectRatio(
              aspectRatio: result.controller.value.aspectRatio,
              child: CameraPreview(result.controller),
            );
          },
        ),
      ),
    );

    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height,
        child: buildResult(),
      ),
    );

    stackChildren.add(const Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: AnimatedEllipsisTextButton(),
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Object Detector"),
        backgroundColor: Colors.pinkAccent,
      ),
      backgroundColor: Colors.black,
      body: Container(
        margin: const EdgeInsets.only(top: 0),
        color: Colors.black,
        child: Stack(children: stackChildren),
      ),
    );
  }
}
