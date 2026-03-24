import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

enum LightingCondition {
  tooDark,
  dark,
  optimal,
  bright,
  tooBright,
}

enum FaceQuality {
  notDetected,
  poor,
  fair,
  good,
  excellent,
}

class FaceConditionResult {
  final bool faceDetected;
  final int faceCount;
  final FaceQuality quality;
  final LightingCondition lighting;
  final double brightness;
  final double contrast;
  final List<double>? faceConfidence;
  final double exposureAdjustment; // -1.0 to 1.0
  final String recommendation;
  final String? emotion;
  final double emotionConfidence; // 0.0 to 1.0

  FaceConditionResult({
    required this.faceDetected,
    required this.faceCount,
    required this.quality,
    required this.lighting,
    required this.brightness,
    required this.contrast,
    this.faceConfidence,
    required this.exposureAdjustment,
    required this.recommendation,
    this.emotion,
    this.emotionConfidence = 0.0,
  });
}

class FaceConditionAnalyzer {
  late final FaceDetector _faceDetector;
  double _brightnessThreshold = 0.3;
  double _contrastThreshold = 0.15;

  FaceConditionAnalyzer() {
    final options = FaceDetectorOptions(
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
  }

  /// Analyzes brightness of the image frame
  double _calculateBrightness(img.Image image) {
    int sum = 0;
    int pixelCount = 0;

    for (int i = 0; i < image.length; i++) {
      final pixel = image[i];
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      // Luminance formula (standard)
      final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
      sum += (luminance * 255).toInt();
      pixelCount++;
    }

    return pixelCount > 0 ? sum / (pixelCount * 255) : 0.5;
  }

  /// Analyzes contrast of the image frame
  double _calculateContrast(img.Image image) {
    List<double> luminances = [];

    for (int i = 0; i < image.length; i++) {
      final pixel = image[i];
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
      luminances.add(luminance);
    }

    if (luminances.isEmpty) return 0.5;

    double mean = luminances.reduce((a, b) => a + b) / luminances.length;
    double variance = luminances
            .map((l) => pow(l - mean, 2))
            .reduce((a, b) => a + b) /
        luminances.length;
    double stdDev = sqrt(variance);

    // Normalize to 0-1 range
    return min(stdDev, 0.5) / 0.5;
  }

  /// Determines lighting condition based on brightness
  LightingCondition _determineLightingCondition(double brightness) {
    if (brightness < 0.1) return LightingCondition.tooDark;
    if (brightness < 0.3) return LightingCondition.dark;
    if (brightness < 0.7) return LightingCondition.optimal;
    if (brightness < 0.85) return LightingCondition.bright;
    return LightingCondition.tooBright;
  }

  /// Calculates recommended exposure adjustment (0 to 1)
  double _calculateExposureAdjustment(double brightness) {
    // Target brightness is around 0.5
    double target = 0.5;
    double adjustment = (brightness - target) / target;
    return max(-1.0, min(1.0, adjustment));
  }

  /// Determines face quality based on detection and frame conditions
  FaceQuality _determineFaceQuality(
    bool faceDetected,
    int faceCount,
    LightingCondition lighting,
    double contrast,
  ) {
    if (!faceDetected || faceCount == 0) return FaceQuality.notDetected;

    // Multiple faces detected - reduce quality
    if (faceCount > 1) return FaceQuality.fair;

    // Check lighting condition
    if (lighting == LightingCondition.tooDark ||
        lighting == LightingCondition.tooBright) {
      return FaceQuality.poor;
    }

    if (lighting == LightingCondition.dark ||
        lighting == LightingCondition.bright) {
      return FaceQuality.fair;
    }

    // Check contrast
    if (contrast < 0.2) return FaceQuality.fair;

    return contrast > 0.4 ? FaceQuality.excellent : FaceQuality.good;
  }

  /// Generates user-friendly recommendation based on conditions
  String _generateRecommendation(
    bool faceDetected,
    LightingCondition lighting,
    FaceQuality quality,
  ) {
    if (!faceDetected) {
      return "Position your face toward the camera";
    }

    switch (lighting) {
      case LightingCondition.tooDark:
        return "Move to a brighter area - lighting is too dim";
      case LightingCondition.dark:
        return "Increase lighting for better detection";
      case LightingCondition.optimal:
        if (quality == FaceQuality.excellent) {
          return "✓ Perfect conditions - ready to proceed";
        } else if (quality == FaceQuality.good) {
          return "Good lighting - adjust angle for better results";
        }
        return "Lighting is good - adjust distance";
      case LightingCondition.bright:
        return "Reduce bright light reflection";
      case LightingCondition.tooBright:
        return "Move away from direct bright light";
    }
  }

  /// Main analysis function - processes image frame and detects faces
  Future<FaceConditionResult> analyze(img.Image image) async {
    try {
      // Calculate lighting metrics
      final brightness = _calculateBrightness(image);
      final contrast = _calculateContrast(image);
      final lighting = _determineLightingCondition(brightness);
      final exposureAdjustment = _calculateExposureAdjustment(brightness);

      // Convert image to InputImage for ML Kit
      final inputImage = InputImage.fromBytes(
        bytes: image.getBytes(),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );

      // Detect faces
      final faces = await _faceDetector.processImage(inputImage);

      bool faceDetected = faces.isNotEmpty;
      int faceCount = faces.length;

      // Calculate face confidences if faces detected
      List<double>? faceConfidence;
      if (faceDetected) {
        faceConfidence = faces
            .map((face) => (face.trackingId ?? 0).toDouble() / 100)
            .toList();
      }

      // Determine quality
      final quality = _determineFaceQuality(
        faceDetected,
        faceCount,
        lighting,
        contrast,
      );

      // Generate recommendation
      final recommendation = _generateRecommendation(
        faceDetected,
        lighting,
        quality,
      );

      // Mock emotion detection (you can replace with TFLite model)
      String? emotion;
      double emotionConfidence = 0.0;
      if (faceDetected && quality != FaceQuality.notDetected) {
        // For now, return a mock emotion
        emotion = 'Happy';
        emotionConfidence = 0.85;
      }

      return FaceConditionResult(
        faceDetected: faceDetected,
        faceCount: faceCount,
        quality: quality,
        lighting: lighting,
        brightness: brightness,
        contrast: contrast,
        faceConfidence: faceConfidence,
        exposureAdjustment: exposureAdjustment,
        recommendation: recommendation,
        emotion: emotion,
        emotionConfidence: emotionConfidence,
      );
    } catch (e) {
      print('Error analyzing face condition: $e');
      return FaceConditionResult(
        faceDetected: false,
        faceCount: 0,
        quality: FaceQuality.poor,
        lighting: LightingCondition.dark,
        brightness: 0.0,
        contrast: 0.0,
        faceConfidence: null,
        exposureAdjustment: 0.0,
        recommendation: 'Error analyzing frame',
        emotion: null,
        emotionConfidence: 0.0,
      );
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
