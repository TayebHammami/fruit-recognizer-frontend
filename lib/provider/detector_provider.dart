import 'dart:convert';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class DetectorProvider with ChangeNotifier {
  bool isBusy = false;
  late List<dynamic> scanResults = [];
  final imageQueue = Queue<CameraImage>();
  String? _errorMessage;
  CameraDescription camera;
  final detectionStopwatch = Stopwatch();

  DetectorProvider(this.camera) {
    initializeCamera(camera);
  }

  String get processingTime => getTimeProcessing(detectionStopwatch.elapsed);
  late String fr;

  String get fff => fr;

  String? get errorMessage => _errorMessage;
  String _buttonText = 'Start Recognition';
  late CameraController controller;
  int _dots = 0;

  String get buttonText => _buttonText;

  bool get isRecognizing => isBusy;

  String getTimeProcessing(elapsed) {
    if (elapsed.inSeconds >= 1) {
      return '${elapsed.inSeconds} s';
    } else if (elapsed.inMilliseconds >= 1) {
      return '${elapsed.inMilliseconds} ms';
    } else {
      return '${elapsed.inMicroseconds} µs';
    }
  }

  void toggleRecognition() {
    isBusy = !isBusy;
    notifyListeners();

    if (isBusy == true) {
      _startEllipsisAnimation();
      startRecognition();
    } else {
      stopRecognition();
    }
    notifyListeners();
  }

  void startRecognition() async {
    if (!controller.value.isInitialized) {
      debugPrint("Camera is not initialized!");
      return;
    }

    if (isBusy == true) {
      detectionStopwatch.reset();
      scanResults.clear();
      notifyListeners();

      const minProcessingTime =
          Duration(milliseconds: 300); // Minimum time per frame
      DateTime lastProcessedTime = DateTime.now();

      controller.startImageStream((CameraImage image) async {
        lastProcessedTime = DateTime.now();

        imageQueue.add(image);
        notifyListeners();

        // Process the most recent image
        final lastImage = imageQueue.removeLast();
        imageQueue.clear();
        notifyListeners();

        try {
          detectionStopwatch.start();

          // Send the processed image to the server
          await _sendImageToBackend(lastImage);

          detectionStopwatch.stop();
          final elapsedTime =
              detectionStopwatch.elapsedMilliseconds; // Processing time
          debugPrint("Detection took: $elapsedTime ms");
          notifyListeners();
          // Handle results
        } catch (error) {
          debugPrint('Error during frame processing: $error');
        } finally {
          if (scanResults.isEmpty) {
            controller.startImageStream((CameraImage image) {
              imageQueue.add(image);
              isBusy = true;
            });
          }
          if (scanResults.isNotEmpty) {
            stopRecognition(); // Stop recognition if results are found
          }
          // Ensure the app is ready to process the next frame
          isBusy = false;
          notifyListeners();
        }
      });
    }
  }

  Future<void> _sendImageToBackend(CameraImage image) async {
    // Convert CameraImage to bytes (example assumes YUV420 format)
    final bytes = _convertYUV420ToBytes(image);

    // Convert to Base64
    final base64Image = base64Encode(bytes);

    notifyListeners();
    // Send image to backend
    final url = Uri.parse('http://172.28.0.12:5000/predict');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      scanResults =
          JsonEncoder(response.body as Object? Function(dynamic object)?)
              as List;
      notifyListeners();
    } else {
      print('Error sending image: ${response.statusCode}');
    }
  }

  Uint8List _convertYUV420ToBytes(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int yRowStride = image.planes[0].bytesPerRow;

    final List<int> yChannel = [];
    for (int row = 0; row < height; row++) {
      yChannel.addAll(image.planes[0].bytes
          .sublist(row * yRowStride, row * yRowStride + width));
    }

    return Uint8List.fromList(yChannel);
  }

  void _startEllipsisAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isBusy) {
        _dots = (_dots + 1) % 4;
        _buttonText = 'Recognizing' + '.' * _dots;
        _startEllipsisAnimation();
      }
      notifyListeners();
    });
  }

  //
  // void startRecognition() async {
  //   if (!controller.value.isInitialized) {
  //     debugPrint("Camera is not initialized!");
  //     return;
  //   }
  //
  //   if (isBusy == true) {
  //     detectionStopwatch.reset();
  //     scanResults.clear();
  //     notifyListeners();
  //
  //     const minProcessingTime =
  //     Duration(milliseconds: 300); // Minimum time per frame
  //     DateTime lastProcessedTime = DateTime.now();
  //
  //     controller.startImageStream((CameraImage image) async {
  //       // if (DateTime.now().difference(lastProcessedTime) < minProcessingTime) {
  //       //   // Skip this frame if minimum time hasn't elapsed
  //       //   return;
  //       // }
  //       lastProcessedTime = DateTime.now();
  //       imageQueue.add(image);
  //       notifyListeners();
  //
  //       final lastImage = imageQueue.removeLast();
  //       imageQueue.clear();
  //       notifyListeners();
  //
  //
  //       try {
  //         detectionStopwatch.start();
  //         await sendFrameToServer(
  //             lastImage); // Send frame to server for detection
  //         detectionStopwatch.stop();
  //
  //         final elapsedTime =
  //             detectionStopwatch.elapsedMilliseconds; // Processing time
  //         debugPrint("Detection took: $elapsedTime ms");
  //
  //         // Handle results
  //       } catch (error) {
  //         debugPrint('Error during frame processing: $error');
  //       } finally {
  //         if (scanResults.isEmpty) {
  //           controller.startImageStream((CameraImage image) {
  //             imageQueue.add(image);
  //             isBusy = true;
  //           });
  //         }
  //         // Ensure the app is ready to process the next frame
  //         if (scanResults.isNotEmpty) {
  //           stopRecognition(); // Stop recognition if results are found
  //         }
  //
  //         notifyListeners();
  //         detectionStopwatch.reset();
  //       }
  //     });
  //   }
  // }

  //  Capture an image and send it to Flask
  // Future<void> captureAndSendImage() async {
  //   try {
  //     // Capture image
  //     final XFile file = await controller!.takePicture();
  //     final bytes = await file.readAsBytes();
  //
  //     // Convert to Image using the image package
  //     img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
  //
  //     // Optionally, resize or process the image
  //     img.Image resized = img.copyResize(image, width: 224, height: 224);
  //
  //     // Send the image to Flask server
  //     await sendImageToFlask(resized);
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }
  //
  // // Send image to Flask
  // Future<void> sendImageToFlask(img.Image image) async {
  //   final bytes = Uint8List.fromList(img.encodeJpg(image));
  //
  //   final response = await http.post(
  //     Uri.parse('http://your_flask_server_url/upload'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'image': base64.encode(bytes),
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print('Image uploaded successfully!');
  //   } else {
  //     print('Failed to upload image');
  //   }
  // }

  void stopRecognition() async {
    controller.stopImageStream();
    imageQueue.clear();
    isBusy = false;
    _buttonText = 'Start Recognition';
    notifyListeners();
  }

  Future initializeCamera(camera) async {
    controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    await checkAndRequestCameraPermission().then((permissionGranted) async {
      if (!permissionGranted) {
        _handleError("Camera permission denied. Exiting initialization.");
        return;
      }

      await controller.initialize().then((_) {
        if (!controller.value.isInitialized) {
          _handleError("Camera initialization failed");
        } else {
          if (kDebugMode) {
            print("Camera initialized successfully.");
          }
        }
      }).catchError((error) {
        _handleError('Error initializing camera: $error');
      });
    });
  }

  void _handleError(String message) {
    _errorMessage = message;
    stopRecognition();
    notifyListeners();
    debugPrint('Error: $message');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> checkAndRequestCameraPermission() async {
    debugPrint("Checking camera permission...");
    var status = await Permission.camera.status;
    if (status.isGranted) {
      debugPrint("Camera permission already granted.");
      return true;
    } else {
      debugPrint("Requesting camera permission...");
      status = await Permission.camera.request();
      if (status.isGranted) {
        debugPrint("Camera permission granted after request.");
        return true;
      } else {
        debugPrint("Camera permission denied.");
        return false;
      }
    }
  }
}
