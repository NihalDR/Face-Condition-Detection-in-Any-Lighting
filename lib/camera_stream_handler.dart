import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'face_condition_analyzer.dart';

class CameraStreamHandler {
  CameraController? _controller;
  final FaceConditionAnalyzer analyzer;
  bool _isProcessing = false;
  bool _isDisposed = false;

  ValueNotifier<FaceConditionResult?> resultNotifier =
      ValueNotifier<FaceConditionResult?>(null);

  CameraStreamHandler({required this.analyzer});

  Future<void> initialize(CameraDescription camera) async {
    try {
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _controller!.initialize();

      // Start streaming frames for analysis
      _startFrameStream();
    } catch (e) {
      print('Error initializing camera: $e');
      rethrow;
    }
  }

  void _startFrameStream() {
    _controller?.startImageStream((image) async {
      if (_isProcessing || _isDisposed) return;

      _isProcessing = true;

      try {
        // Convert CameraImage to img.Image
        final convertedImage = _convertCameraImage(image);

        if (convertedImage != null) {
          // Analyze the frame
          final result = await analyzer.analyze(convertedImage);

          if (!_isDisposed) {
            resultNotifier.value = result;
          }
        }
      } catch (e) {
        print('Error processing frame: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }

  /// Converts CameraImage to img.Image
  img.Image? _convertCameraImage(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.nv21) {
        return img.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes[0].bytes.buffer,
        );
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        return img.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes[0].bytes.buffer,
          format: img.Format.uint8,
        );
      }
      return null;
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  CameraController? get controller => _controller;

  Future<void> dispose() async {
    _isDisposed = true;
    await _controller?.stopImageStream();
    await _controller?.dispose();
    resultNotifier.dispose();
  }
}
