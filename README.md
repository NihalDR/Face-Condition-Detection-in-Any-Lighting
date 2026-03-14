# Face Condition Detection in Any Lighting

A real-time Flutter app that detects faces and analyzes their condition in any lighting environment. This advanced system works seamlessly across **Android** and **iOS**, providing intelligent lighting adaptation and real-time feedback.

## Features

### Core Capabilities
- **Real-Time Face Detection**: Uses Google ML Kit for fast, accurate face detection
- **Lighting-Aware Analysis**: Automatically detects and adapts to different lighting conditions
  - **Too Dark**: Brightness < 10%
  - **Dark**: Brightness 10-30%
  - **Optimal**: Brightness 30-70%
  - **Bright**: Brightness 70-85%
  - **Too Bright**: Brightness > 85%

### Quality Assessment
The app evaluates face detection quality on a 5-level scale:
- **Not Detected**: No face in frame
- **Poor**: Faces in very poor lighting or multiple faces
- **Fair**: Multiple faces or suboptimal lighting
- **Good**: Single face in good lighting
- **Excellent**: Optimal conditions with high contrast

### Intelligent Features
- **Real-Time Metrics**:
  - Brightness percentage calculation
  - Contrast analysis for image quality
  - Exposure adjustment recommendations (-1.0 to 1.0 scale)
  
- **User-Friendly Guidance**:
  - Contextual recommendations for better detection
  - Color-coded status indicators
  - Live feedback on frame quality

## Technical Stack

### Dependencies
- `camera: ^0.10.8+1` - Camera stream access
- `google_mlkit_face_detection: ^0.8.0` - ML Kit face detection
- `image: ^4.0.17` - Image processing
- `permission_handler: ^11.4.4` - Runtime permission management
- `provider: ^6.0.0` - State management

### Architecture
1. **FaceConditionAnalyzer**: Core analysis engine
   - Brightness and contrast calculation
   - Lighting condition determination
   - Face quality assessment
   - Recommendation generation

2. **CameraStreamHandler**: Real-time pipeline
   - Camera initialization and lifecycle
   - Frame streaming and conversion
   - Non-blocking frame processing

3. **Home Screen UI**: Real-time visualization
   - Live camera preview
   - Status indicators
   - Quality metrics display
   - Adaptive recommendations

## Platform Requirements

### Android
- Min SDK: API 21 (5.0)
- Target SDK: API 33+
- Permissions required:
  - `CAMERA` - For real-time face detection
  - `INTERNET` - For ML Kit models

### iOS
- Min Deployment Target: 11.0
- Xcode 14+
- Permissions required:
  - `NSCameraUsageDescription` - Camera access explanation
  - `NSPhotoLibraryUsageDescription` - Photo library access (optional)

## Installation & Setup

1. **Clone the repository**:
```bash
git clone https://github.com/akmadan/flutter_live_emotion.git
cd flutter_live_emotion
```

2. **Install Flutter dependencies**:
```bash
flutter pub get
```

3. **Run on Android**:
```bash
flutter run -d android
```

4. **Run on iOS**:
```bash
flutter run -d ios
```

## How It Works

### Real-Time Detection Pipeline
1. **Camera Stream**: Captures frames from front-facing camera
2. **Brightness Analysis**: Calculates luminance across the frame
3. **Contrast Evaluation**: Measures pixel intensity distribution
4. **Face Detection**: Uses ML Kit to detect faces with high precision
5. **Quality Assessment**: Combines all metrics to determine face quality
6. **User Feedback**: Displays real-time status and recommendations

### Lighting Adaptation
The system automatically:
- Suggests moving to better-lit areas when too dark
- Recommends reducing bright light when overexposed
- Provides optimal conditions feedback
- Calculates exposure adjustments for adaptive camera control

### Performance Optimization
- Asynchronous frame processing to prevent UI blocking
- Non-blocking image streaming pipeline
- Efficient ML model inference
- Minimal battery consumption during idle frames

## Usage

1. **Launch the app**: Tap to start face detection
2. **Position your face**: Face the front camera
3. **Observe feedback**: Real-time status shows:
   - Face detection status (detected/not detected)
   - Quality level (poor to excellent)
   - Lighting condition with brightness/contrast metrics
   - Personalized recommendations

4. **Adjust environment** as needed based on recommendations

## API Reference

### FaceConditionResult
```dart
FaceConditionResult {
  bool faceDetected;              // Is a face detected?
  int faceCount;                  // Number of faces detected
  FaceQuality quality;            // Overall quality assessment
  LightingCondition lighting;     // Current lighting condition
  double brightness;              // 0-1 brightness percentage
  double contrast;                // 0-1 contrast measurement
  double exposureAdjustment;      // -1.0 to 1.0 exposure adjustment
  String recommendation;          // User-friendly guidance
}
```

### Enums
```dart
enum LightingCondition {
  tooDark, dark, optimal, bright, tooBright
}

enum FaceQuality {
  notDetected, poor, fair, good, excellent
}
```

## Troubleshooting

### Camera Not Initializing
- Ensure camera permission is granted in app settings
- For iOS, check Info.plist camera usage description
- Restart the app after granting permissions

### Poor Detection Quality
- Increase ambient lighting in the room
- Avoid harsh shadows on face
- Keep face centered and at normal distance
- Reduce reflections from glasses or screens

### Performance Issues
- Reduce screen brightness if app lags
- Close background apps to free up resources
- Ensure sufficient device memory

## Development Notes

### File Structure
```
lib/
├── main.dart                      # App entry point
├── home.dart                      # Main UI screen
├── face_condition_analyzer.dart   # Core analysis engine
└── camera_stream_handler.dart     # Camera pipeline
```

### Key Algorithms

**Brightness Calculation**: Uses standard luminance formula
```
luminance = (0.299 * R + 0.587 * G + 0.114 * B) / 255.0
```

**Contrast Calculation**: Standard deviation of pixel luminances
```
contrast = stdDev(luminances) / 0.5  // Normalized to 0-1
```

## License

This project is provided as-is for educational and research purposes.

## Credits

Built with Flutter, Google ML Kit, and modern mobile development best practices.

## Support

For issues or feature requests, please open an issue on the repository.
