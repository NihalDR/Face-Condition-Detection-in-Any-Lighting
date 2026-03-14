# Technical Requirements Document (TRD)

## Face Condition Detection in Any Lighting

**Document Version**: 1.0  
**Date**: March 14, 2026  
**Status**: Active  
**Organization**: CCExtractor Organization (GSOC 2026)  
**Project Type**: Cross-Platform Mobile Application  

---

## 1. Executive Summary

### Technical Vision
Face Condition Detection in Any Lighting is a resource-efficient, privacy-preserving cross-platform mobile application built with Flutter that leverages Google ML Kit for real-time face detection. The architecture prioritizes performance, reliability, and maintainability while providing comprehensive image analysis capabilities across varied lighting environments.

### Technical Statement
*"Deliver a high-performance, locally-processing face detection application that provides real-time metrics and guidance through modular, maintainable architecture supporting both iOS and Android platforms."*

---

## 2. Architecture Overview

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                     │
│         (Flutter UI - widgets, screens, state mgmt)         │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      CONTROL LAYER                          │
│  (Home widget, state management providers, event handlers)  │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      BUSINESS LOGIC LAYER                   │
│  (FaceConditionAnalyzer, recommendation engine,             │
│   quality assessment, lighting analysis)                    │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER                          │
│  (CameraStreamHandler, ML Kit wrapper,                      │
│   image processing pipeline)                                │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      EXTERNAL SERVICES                      │
│  (Google ML Kit, Native Camera APIs, Device Hardware)       │
└─────────────────────────────────────────────────────────────┘
```

### Component Diagram

```
                          ┌─────────────────┐
                          │  Main.dart      │
                          │  (Entry Point)  │
                          └────────┬────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │                             │
              ┌─────▼─────┐            ┌─────────▼──┐
              │  Home.dart │            │ MyApp.dart │
              │ (UI Layer) │            │(Theme,etc.)│
              └─────┬─────┘            └────────────┘
                    │
      ┌─────────────┼─────────────┐
      │             │             │
 ┌────▼───┐  ┌──────▼──────┐  ┌──▼────────┐
 │Camera  │  │Permission   │  │Metrics UI │
 │Stream  │  │Management   │  │Display    │
 │Display │  └──────┬──────┘  └────┬──────┘
 └────┬───┘         │              │
      │        ┌────▼──────────────┘
      │        │
 ┌────▼───────▼───────────────────────┐
 │  CameraStreamHandler                │
 │  - Camera initialization            │
 │  - Frame streaming & conversion     │
 │  - Stream lifecycle management      │
 └────┬──────────────────────────────┬─┘
      │                              │
      │        ┌─────────────────────┘
      │        │
 ┌────▼────────▼───────────────────────┐
 │  FaceConditionAnalyzer              │
 │  - Face detection coordination      │
 │  - Brightness calculation           │
 │  - Contrast calculation             │
 │  - Lighting categorization          │
 │  - Quality determination            │
 │  - Recommendation generation        │
 │  - Exposure adjustment calculation  │
 └────┬──────────┬─────────┬──────────┬┘
      │          │         │          │
 ┌────▼┐  ┌─────▼┐  ┌────▼─┐  ┌────▼──┐
 │ML Kit│  │Image │  │Stats │  │Enum  │
 │Wrap  │  │Proc  │  │Math  │  │Defs  │
 └──────┘  └──────┘  └──────┘  └──────┘
```

---

## 3. Technology Stack

### Core Framework
| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Mobile Framework** | Flutter | ≥ 3.0.0 | Cross-platform development |
| **Language** | Dart | ≥ 3.0.0 | Primary programming language |
| **IDE** | Android Studio / Xcode / VS Code | Latest | Development environments |

### Libraries and Dependencies

#### Direct Dependencies
```
camera: ^0.10.8+1              # Camera access and streaming
google_mlkit_face_detection: ^0.8.0  # ML-based face detection
image: ^4.0.17                 # Image processing and manipulation
permission_handler: ^11.4.4    # Permission management
provider: ^6.0.0               # State management
cupertino_icons: ^1.0.2        # iOS-style icons
```

#### Platform-Specific Dependencies
- **Android**: 
  - AndroidX libraries
  - Google Play Services
  - TensorFlow Lite (bundled in ML Kit)
- **iOS**: 
  - Core ML Framework
  - Vision Framework
  - AVFoundation

#### Development Dependencies
```
flutter_test: [flutter sdk]    # Flutter testing framework
```

### External Services
- **Google ML Kit**: Face detection model inference
- **TensorFlow Lite**: Model runtime for face detection
- **Native Cameras**: Android Camera2 API, AVFoundation (iOS)

### Development Tools
| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | ≥ 3.0.0 | Development toolkit |
| Dart SDK | ≥ 3.0.0 | Programming language |
| Android SDK | 21-34 | Android development |
| Xcode | ≥ 13.0 | iOS development |
| Java/Kotlin | 11+ | Android build tools |
| CocoaPods | ≥ 1.11.0 | iOS dependency management |

---

## 4. Detailed Component Design

### 4.1 Main Application Entry Point (main.dart)

#### Responsibilities
- Initialize Flutter binding
- Discover available cameras
- Configure app theme and routing

#### Key Code Elements
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();  // Discover cameras at startup
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection in Any Lighting',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
```

#### Design Patterns
- Singleton pattern for camera discovery
- Global state for camera availability
- Material 3 design compliance

### 4.2 Home Screen (home.dart)

#### Responsibilities
- UI rendering and layout
- Permission request and handling
- Camera initialization coordination
- Real-time metrics display
- State management integration
- User interaction handling

#### Architecture Pattern: MVVM (Model-View-ViewModel)
```
Home (View)
  ├─ Permission handling (ViewModel)
  ├─ Camera initialization (ViewModel)
  └─ Analysis result display (View)
      ↓
  ValueNotifiers/Providers (ViewModel)
      ↓
  FaceConditionAnalyzer (Model)
```

#### Key Methods

**_requestPermissionsAndInitialize()**
- Checks camera permission status
- Requests permission if not already granted
- Initializes camera on permission grant
- Handles denial and permanent denial cases
- Navigates user to settings if needed

**_getLightingColor() / _getQualityColor()**
- Maps enum values to Material colors
- Provides visual feedback for status

#### State Management
```dart
class _HomeState extends State<Home> with WidgetsBindingObserver {
  late FaceConditionAnalyzer analyzer;
  late CameraStreamHandler cameraHandler;
  bool _isInitialized = false;
  String _permissionStatus = '';
}
```

#### UI Layout Structure
```
Column(
  children: [
    CameraPreview(),     // Camera feed
    LightingIndicator(), // Lighting status
    QualityIndicator(),  // Quality status  
    MetricsDisplay(),    // Real-time metrics
    RecommendationText() // Contextual guidance
  ]
)
```

### 4.3 Camera Stream Handler (camera_stream_handler.dart)

#### Responsibilities
- Camera controller lifecycle management
- Frame streaming and processing orchestration
- Camera image format conversion
- Result notification to UI
- Resource cleanup and disposal

#### Class Structure
```dart
class CameraStreamHandler {
  CameraController? _controller;
  final FaceConditionAnalyzer analyzer;
  bool _isProcessing = false;
  bool _isDisposed = false;
  ValueNotifier<FaceConditionResult?> resultNotifier;
}
```

#### Key Methods

**initialize(CameraDescription camera)**
- Creates CameraController with medium resolution
- Sets NV21 image format for efficiency
- Starts frame streaming
- Handles initialization errors

**_startFrameStream()**
- Initiates frame-by-frame image stream
- Implements backpressure handling (_isProcessing flag)
- Prevents frame accumulation

**_convertCameraImage(CameraImage image)**
- Converts platform-specific camera format to image.Image
- Supports NV21 (Android) and BGRA8888 (iOS)
- Handles format detection and conversion errors

#### Frame Processing Pipeline
```
Camera Hardware
    ↓
CameraController (native)
    ↓
CameraImage (platform format)
    ↓
_convertCameraImage()
    ↓
img.Image (unified format)
    ↓
analyzer.analyze()
    ↓
FaceConditionResult
    ↓
resultNotifier (updates UI)
```

#### Performance Considerations
- Frame skipping via _isProcessing flag prevents queue buildup
- Medium resolution balances accuracy and performance
- NV21 format on Android for efficiency

### 4.4 Face Condition Analyzer (face_condition_analyzer.dart)

#### Responsibilities
- Face detection coordination via ML Kit
- Brightness calculation
- Contrast calculation
- Lighting condition determination
- Face quality assessment
- Recommendation generation
- Exposure adjustment calculation

#### Data Models

**Enumerations**
```dart
enum LightingCondition {
  tooDark,    // < 10%
  dark,       // 10-30%
  optimal,    // 30-70%
  bright,     // 70-85%
  tooBright   // > 85%
}

enum FaceQuality {
  notDetected, // No face
  poor,        // Multiple faces or extreme lighting
  fair,        // Suboptimal conditions
  good,        // Single face, good lighting
  excellent    // Optimal conditions, high contrast
}
```

**Result Class**
```dart
class FaceConditionResult {
  final bool faceDetected;
  final int faceCount;
  final FaceQuality quality;
  final LightingCondition lighting;
  final double brightness;        // 0.0-1.0
  final double contrast;          // 0.0-1.0
  final List<double>? faceConfidence;
  final double exposureAdjustment; // -1.0 to 1.0
  final String recommendation;
}
```

#### Key Algorithms

**Brightness Calculation**
```dart
double _calculateBrightness(img.Image image) {
  // Uses standard luminance formula
  // Y = 0.299*R + 0.587*G + 0.114*B
  // Normalized to 0-1 range
  // O(n) where n = pixel count
}
```

**Contrast Calculation**
```dart
double _calculateContrast(img.Image image) {
  // 1. Calculate luminance for each pixel
  // 2. Compute mean luminance
  // 3. Calculate variance from mean
  // 4. Compute standard deviation
  // 5. Normalize to 0-1 range
  // O(n) where n = pixel count
}
```

**Lighting Categorization**
```
Brightness < 10%    → tooDark
Brightness < 30%    → dark
Brightness < 70%    → optimal
Brightness < 85%    → bright
Brightness >= 85%   → tooBright
```

**Quality Assessment Logic**
```
if (!faceDetected || faceCount == 0)
  → quality = notDetected

if (faceCount > 1)
  → quality = fair

if (lighting == tooDark || lighting == tooBright)
  → quality = poor

if (lighting == dark || lighting == bright)
  → quality = fair

if (contrast < 0.2)
  → quality = fair

if (contrast > 0.4)
  → quality = excellent

else
  → quality = good
```

**Exposure Adjustment Calculation**
```dart
// Target brightness = 0.5 (mid-range)
// Calculate adjustment relative to target
double adjustment = (brightness - target) / target
// Clamp to -1.0 to 1.0 range
adjustment = max(-1.0, min(1.0, adjustment))
```

#### ML Kit Integration

**FaceDetectorOptions Configuration**
```dart
FaceDetectorOptions(
  enableTracking: true,           // Smooth detection
  performanceMode: FaceDetectorMode.fast // Real-time performance
)
```

**Face Detection Process**
```
InputImage from img.Image
    ↓
FaceDetector.processImage()
    ↓
List<Face> objects
    ↓
Extract face count, bounds, confidence
    ↓
Combine with other metrics
    ↓
Generate FaceConditionResult
```

### 4.5 Recommendation Engine (embedded in FaceConditionAnalyzer)

#### Recommendation Generation Logic
```dart
String _generateRecommendation(
  FaceQuality quality,
  LightingCondition lighting,
  int faceCount,
  double brightness,
  double contrast
) {
  if (!faceDetected) return "No face detected. Position face towards camera.";
  
  if (faceCount > 1) return "Multiple faces detected. Keep only one face in frame.";
  
  switch (lighting) {
    case tooDark:
      return "Lighting too dark. Move to brighter area or enable light source.";
    case dark:
      return "Increase ambient light by moving closer to light source.";
    case bright:
      return "Reduce bright light or adjust angle to reduce glare.";
    case tooBright:
      return "Lighting too bright. Move away from direct light source.";
    case optimal:
      if (contrast < 0.2) return "Increase lighting contrast for better detection.";
      return "Perfect lighting conditions!";
  }
}
```

#### Recommendation Priority
1. Face detection status (highest)
2. Multiple face detection
3. Extreme lighting conditions
4. Suboptimal conditions
5. Specific metrics guidance (lowest)

---

## 5. Data Flow and Processing Pipeline

### End-to-End Processing Flow

```
┌─────────────────────────────────────────────────────┐
│ 1. FRAME CAPTURE                                    │
│    - Camera hardware captures frame at native format│
│    - Resolution: Medium (typically 720p)            │
│    - Frame rate: 30+ FPS                            │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ 2. FORMAT CONVERSION                                │
│    Android: NV21 → img.Image                        │
│    iOS: BGRA8888 → img.Image                        │
│    Latency: ~5ms                                    │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ 3. PARALLEL ANALYSIS (Multi-threaded)               │
│    ├─ Face Detection (ML Kit)                       │
│    ├─ Brightness Calculation                        │
│    ├─ Contrast Calculation                          │
│    └─ All complete in O(n) time                     │
│    Latency: ~30-40ms                                │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ 4. METRICS COMBINATION                              │
│    - Merge detection results with image metrics     │
│    - Calculate lighting condition                   │
│    - Determine face quality                         │
│    - Calculate exposure adjustment                  │
│    Latency: ~5-10ms                                 │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ 5. RECOMMENDATION GENERATION                        │
│    - Analyze combined metrics                       │
│    - Generate contextual recommendation             │
│    - Select most relevant guidance                  │
│    Latency: < 5ms                                   │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ 6. RESULT NOTIFICATION                              │
│    - Bundle all results in FaceConditionResult      │
│    - Update ValueNotifier                           │
│    - Trigger UI rebuild (if needed)                 │
│    Latency: < 5ms                                   │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ 7. UI RENDERING                                     │
│    - Update color indicators                        │
│    - Refresh metrics display                        │
│    - Update recommendation text                     │
│    - Re-render overlay on camera feed               │
│    Latency: ~16ms (60 FPS) + frame processing       │
└──────────────────────────────────────────────────────┘

TOTAL LATENCY: ~66-91ms (target < 100ms)
```

### Concurrent Processing Architecture

#### Thread Management
- **Main Thread**: UI updates, Flutter framework
- **Camera Stream Thread**: Native camera handling
- **Analyzer Thread**: Image processing and face detection
- **Dart Async**: Non-blocking I/O and coordination

#### Backpressure Handling
```dart
void _startFrameStream() {
  _controller?.startImageStream((image) async {
    if (_isProcessing || _isDisposed) return;  // Skip if busy
    
    _isProcessing = true;
    try {
      // Process frame
    } finally {
      _isProcessing = false;
    }
  });
}
```

---

## 6. Performance Requirements and Optimization

### Performance Targets

| Metric | Target | Rationale |
|--------|--------|-----------|
| Frame Rate | 30+ FPS | Real-time perception |
| Frame Latency | < 100ms | User perception of responsiveness |
| Face Detection | < 50ms | Per-frame overhead |
| Brightness Calc | < 15ms | Fast numerical operations |
| Contrast Calc | < 15ms | Standard deviation computation |
| Memory Usage | < 200MB | Mid-range device capability |
| App Startup | < 3 seconds | User patience threshold |
| Battery Drain | < 10% per hour | Acceptable usage duration |

### Optimization Strategies

#### Algorithm Optimization
1. **Brightness/Contrast**: Single-pass algorithms (O(n) complexity)
2. **Face Detection**: ML Kit pre-optimized for mobile
3. **Frame Skipping**: Backpressure to prevent queue accumulation
4. **Early Exit**: Avoid unnecessary processing

#### Memory Management
```dart
// Image disposal
_controller?.stopImageStream();
_controller?.dispose();
resultNotifier.dispose();

// Prevent memory leaks
_isDisposed flag prevents post-disposal updates
```

#### Resolution Management
- Medium resolution: ~720p (balance accuracy vs. performance)
- Downsampling on lower-end devices if needed
- Hardware acceleration for format conversion

#### Asynchronous Processing
```dart
// Non-blocking frame processing
_startFrameStream((image) async {
  // Process asynchronously
  // Never block main thread
});
```

#### Resource Pooling
- Reuse CameraController instance
- Single FaceDetector instance
- ValueNotifier for efficient updates

---

## 7. Error Handling and Resilience

### Exception Hierarchy
```
Exception
├─ CameraInitializationException
│  ├─ CameraAccessDeniedException
│  ├─ CameraNotAvailableException
│  └─ CameraConfigurationException
├─ FrameProcessingException
│  ├─ ImageConversionException
│  ├─ FaceDetectionException
│  └─ AnalysisException
└─ PermissionException
   ├─ PermissionDeniedException
   └─ PermissionPermanentlyDeniedException
```

### Error Handling Strategy

#### Camera Initialization Errors
```dart
try {
  await _controller!.initialize();
} on CameraException catch (e) {
  setState(() {
    _permissionStatus = 'Error initializing camera: ${e.code}';
  });
}
```

#### Permission Errors
```dart
final cameraStatus = await Permission.camera.request();

if (cameraStatus.isDenied) {
  // Normal denial - can re-request
  setState(() => _permissionStatus = 'Permission denied');
} else if (cameraStatus.isPermanentlyDenied) {
  // Permanent denial - guide to settings
  openAppSettings();
}
```

#### Frame Processing Errors
```dart
try {
  final result = await analyzer.analyze(convertedImage);
} catch (e) {
  print('Error processing frame: $e');
  // Continue to next frame - don't crash
}
```

### Graceful Degradation
1. Camera unavailable → Display message, disable app
2. Permission denied → Request and guide to settings
3. ML Kit error → Skip frame, continue processing
4. Memory pressure → Reduce resolution, skip frames
5. Device incompatibility → Display minimum viable UI

### Logging and Recovery
- Comprehensive print statements for debugging
- Error context captured (device, OS, frame data)
- Graceful continuation from errors
- No unhandled exceptions

---

## 8. Security and Privacy Design

### Privacy-First Principles
1. **Local Processing Only**
   - All computation on device
   - No cloud transmission
   - No external API calls for personal data
   - Offline functionality required

2. **No Data Persistence**
   - No face images stored
   - No detection results stored
   - No session data retained
   - Temporary processing buffers only

3. **Minimal Permissions**
   - Camera permission only
   - No storage, location, or contacts access
   - No background execution

### Security Implementation

#### Permission Management
```dart
// Explicit permission request
final cameraStatus = await Permission.camera.request();

// Verify before accessing camera
if (!cameraStatus.isGranted) {
  // Don't proceed
}
```

#### Data Handling
- Input: Raw camera frames (temporary, 30ms lifecycle)
- Processing: In-memory only
- Output: Aggregated metrics (brightness, contrast, quality)
- Disposal: Immediate after use

#### Platform-Specific Security
**Android**:
- Uses Scoped Storage (API 30+)
- Runtime permissions enforced
- SELinux policy compliance

**iOS**:
- Privacy manifest complimenting iOS 14+
- Privacy-focused camera framework
- Sandboxed execution

### GDPR/CCPA Compliance
- No personal data collection
- No third-party sharing
- No tracking or analytics
- User data ownership (if stored by user)
- Easy data deletion (uninstall)

---

## 9. Testing Strategy

### Unit Testing

#### Test Coverage Areas
1. **Brightness Calculation**
   - Test with known luminance values
   - Verify formula accuracy
   - Edge cases (all black, all white)

2. **Contrast Calculation**
   - Test standard deviation computation
   - Verify normalization
   - Edge cases (uniform images)

3. **Lighting Categorization**
   - Verify boundary conditions
   - Test all 5 categories
   - Verify threshold accuracy

4. **Quality Assessment**
   - Test all 5 quality levels
   - Verify combination logic
   - Test edge cases

5. **Recommendation Generation**
   - Test all recommendation paths
   - Verify appropriateness
   - Test error messages

#### Example Unit Tests
```dart
test('Brightness calculation accuracy', () {
  // Create test image with known luminance
  final image = createTestImage(targetLuminance: 128);
  
  final result = analyzer._calculateBrightness(image);
  
  expect(result, closeTo(0.5, 0.05));  // 50% brightness
});

test('Lighting categorization boundaries', () {
  expect(analyzer._determineLightingCondition(0.05), 
    LightingCondition.tooDark);
  expect(analyzer._determineLightingCondition(0.20), 
    LightingCondition.dark);
  expect(analyzer._determineLightingCondition(0.50), 
    LightingCondition.optimal);
  expect(analyzer._determineLightingCondition(0.80), 
    LightingCondition.bright);
  expect(analyzer._determineLightingCondition(0.90), 
    LightingCondition.tooBright);
});
```

### Integration Testing

#### Test Scenarios
1. **Camera Initialization**
   - Test successful initialization
   - Test permission denied recovery
   - Test device compatibility

2. **Frame Processing Pipeline**
   - End-to-end frame analysis
   - Verify timing meets targets
   - Test with real camera frames

3. **Permission Flows**
   - Initial permission request
   - Permission denial handling
   - Permission re-grant workflow

4. **UI Updates**
   - Verify metrics update in real-time
   - Verify color coding accuracy
   - Verify recommendation display

### Widget Testing

#### UI Component Tests
1. **Main Screen**
   - Camera preview rendering
   - Metrics display layout
   - Color indicator accuracy
   - Permission dialogs

2. **Status Indicators**
   - Color coding correctness
   - Visibility and readability
   - Accessibility support

3. **Responsive Design**
   - Portrait orientation layout
   - Landscape orientation layout
   - Tablet screen adaptation
   - Text scaling

### Performance Testing

#### Benchmarking
```dart
// Frame processing latency
final stopwatch = Stopwatch()..start();
final result = await analyzer.analyze(image);
stopwatch.stop();
print('Frame analysis: ${stopwatch.elapsedMilliseconds}ms');

// Target: < 100ms per frame
expect(stopwatch.elapsedMilliseconds, lessThan(100));
```

### End-to-End Testing

#### Device Testing Matrix
| Device | OS | RAM | Camera | Processor |
|--------|----|----|--------|-----------|
| Pixel 4a | Android 11 | 6GB | 12.2MP | Snapdragon 765G |
| Redmi Note 10 | Android 12 | 4GB | 13MP | Snapdragon 678 |
| iPhone SE | iOS 16 | 3GB | 12MP | Apple A13 |
| iPad Air | iPadOS 16 | 4GB | 12MP | Apple A14 |

#### Test Scenarios
1. Real-world lighting conditions
2. Multiple faces detection
3. Face occlusion handling
4. Device orientation changes
5. App backgrounding/foregrounding
6. Permission persistence

---

## 10. Deployment Architecture

### Build Configuration

#### Android Configuration
```gradle
// build.gradle (app level)
android {
  compileSdk 34
  
  defaultConfig {
    applicationId "com.example.flutter_live_emotion"
    minSdkVersion 21  // Android 5.0
    targetSdkVersion 34
  }
  
  buildTypes {
    release {
      minifyEnabled true
      shrinkResources true
    }
  }
}
```

#### iOS Configuration
```swift
// iOS minimum version
iOS Deployment Target: 12.0
```

### Build Artifacts

#### Android
- **Debug APK**: For development/testing
- **Release APK**: Optimized production build
- **App Bundle**: For Google Play distribution

#### iOS
- **Debug Build**: For testing on device
- **Release Archive**: For TestFlight/App Store

### CI/CD Pipeline

#### Build Process
```
Git Push
  ↓
GitHub Actions Trigger
  ↓
Android Build
  ├─ flutter build apk --release
  └─ Generate APK
  ↓
iOS Build
  ├─ flutter build ios --release
  └─ Generate Archive
  ↓
Test Execution
  ├─ flutter test
  └─ Device tests
  ↓
Build Artifacts Generated
  ↓
Ready for Distribution
```

### Distribution

#### Android
- **Google Play Store**: Primary distribution
- **Direct APK**: Beta builds, direct distribution
- **GitHub Releases**: OSS mirror

#### iOS
- **Apple App Store**: Primary distribution
- **TestFlight**: Beta distribution
- **GitHub Releases**: Build information

---

## 11. Monitoring and Analytics

### Performance Monitoring

#### Metrics to Track
- Frame processing latency (per frame)
- Face detection success rate
- Lighting categorization accuracy
- Memory usage over time
- Battery consumption rate
- App crash frequency

#### Local Analytics (Privacy-Preserving)
```dart
// Log latency for performance analysis (local only)
if (latency > 100) {
  print('Performance warning: Frame analysis took ${latency}ms');
}

// Track error patterns (local only)
try {
  // Process
} catch (e) {
  print('Error: $e at ${DateTime.now()}');
  // Could write to local log file for analysis
}
```

### Crash Reporting
- Comprehensive error logging
- Stack trace capture
- Device information logging
- Suggest user report feature

### No Remote Analytics
- Privacy requirement: no external analytics
- All metrics remain on device
- Optional user-initiated crash reporting

---

## 12. Maintenance and Support

### Code Maintenance

#### Repository Structure
```
Face-Condition-Detection-in-Any-Lighting/
├─ lib/                          # Source code
│  ├─ main.dart                 # Entry point
│  ├─ home.dart                 # Main UI
│  ├─ camera_stream_handler.dart    # Camera handling
│  └─ face_condition_analyzer.dart  # Analysis engine
├─ android/                     # Android native code
├─ ios/                         # iOS native code
├─ test/                        # Test code
├─ assets/                      # ML models, labels
├─ pubspec.yaml                # Dependencies
├─ README.md                    # User documentation
├─ PRD.md                       # Product requirements
└─ TRD.md                       # Technical requirements
```

#### Code Quality Standards
- Dart style guide compliance (`dartfmt`)
- Null safety enabled throughout
- Meaningful variable/function names
- Comprehensive code comments
- Analysis warnings addressed (dartanalyzer)

#### Documentation Standards
- Document public APIs
- Include usage examples
- Maintain inline comments for complex logic
- Keep README updated
- Version documentation changes

### Future Enhancement Paths

#### Version 1.1 (Refinement)
- Performance optimization
- Bug fixes from user feedback
- Enhanced error messages
- Additional test coverage

#### Version 2.0 (Advanced Features)
- Video recording capabilities
- Face landmarks detection
- Statistics dashboard
- Multi-language support
- Custom model support

#### Version 3.0 (Integration)
- Cloud integration options
- Face recognition capabilities
- API for third-party integration
- Enterprise features

---

## 13. Compliance and Standards

### Mobile Development Standards
- **Material Design 3**: Android UI compliance
- **Cupertino Design**: iOS UI compliance
- **Flutter Best Practices**: Code organization
- **Dart Style Guide**: Code formatting

### Accessibility Standards
- **WCAG 2.1 Level AA**: Accessibility compliance
- **Color Contrast**: 4.5:1 for normal text
- **Touch Target Size**: 48x48dp minimum
- **Screen Reader Support**: All interactive elements

### Privacy Standards
- **GDPR Compliance**: Zero personal data collection
- **CCPA Compliance**: No data sharing
- **App Store Privacy**: Minimal permissions
- **Platform Privacy Guidelines**: Both iOS and Android

### Testing Standards
- **Unit Test Coverage**: > 80% of business logic
- **Integration Testing**: All major workflows
- **Performance Testing**: Meets SLA targets
- **Device Testing**: Wide range of devices

---

## 14. Technology Decisions and Rationale

### Why Flutter?
1. **Cross-Platform**: Single codebase for iOS and Android
2. **Performance**: Near-native performance from Dart
3. **Hot Reload**: Fast development iteration
4. **Rich Ecosystem**: Extensive library support
5. **Community**: Strong and growing community
6. **Maintenance**: Google backing and active development

### Why Google ML Kit?
1. **Optimized**: Pre-optimized for mobile
2. **Accurate**: State-of-the-art face detection
3. **Privacy**: On-device processing
4. **Easy Integration**: Simple Flutter wrapper
5. **No Licensing**: Free to use in apps
6. **Reliability**: Proven in Google apps

### Why ValueNotifier for State?
1. **Lightweight**: Minimal overhead
2. **Real-Time**: Updates propagate immediately
3. **Built-in**: No additional dependency
4. **Reactive**: Observerable pattern
5. **Performance**: Efficient update propagation

### Why NV21 Format (Android)?
1. **Native Format**: Direct from camera
2. **Efficient**: No conversion overhead
3. **ML Kit Compatible**: Direct support
4. **Performance**: Minimal CPU usage

### Why BGRA8888 Format (iOS)?
1. **AVFoundation Native**: Direct from camera
2. **RGB Channels**: Simple color extraction
3. **Wide Support**: Image processing libs compatible

---

## 15. Troubleshooting and Debugging

### Development Setup Troubleshooting

#### Issue: Flutter installation fails
**Solution**: 
- Verify Java/Android SDK installation
- Check environment variables (ANDROID_HOME)
- Run `flutter doctor` to identify issues
- Follow official Flutter installation guide

#### Issue: Camera plugin won't install
**Solution**:
- Update pubspec.yaml to compatible version
- Clear pub cache: `flutter pub cache clean`
- Check Android/iOS SDK versions
- Verify native build tools installed

#### Issue: ML Kit initialization fails
**Solution**:
- Verify Google Play Services installed on device
- Check internet connection for model download
- Verify device storage space available
- Check 64-bit architecture support

### Runtime Troubleshooting

#### Issue: Face detection not working
**Debug Steps**:
```dart
// Add debug logging
print('Camera initialized: $_isInitialized');
print('Frames being processed: ${resultNotifier.value != null}');
print('Face detected: ${resultNotifier.value?.faceDetected}');
```

#### Issue: Performance degradation
**Analysis**:
```dart
// Monitor frame latency
final stopwatch = Stopwatch()..start();
// Processing...
stopwatch.stop();
if (stopwatch.elapsedMilliseconds > 100) {
  print('Slow frame: ${stopwatch.elapsedMilliseconds}ms');
}
```

#### Issue: Memory leak
**Investigation**:
- Monitor memory in Android Studio Profiler
- Check for unreleased camera controllers
- Verify disposal methods called
- Look for ValueNotifier memory leaks

---

## 16. Glossary of Technical Terms

| Term | Definition |
|------|-----------|
| **ML Kit** | Google's on-device machine learning library |
| **TensorFlow Lite** | Lightweight ML framework for mobile/edge devices |
| **FPS** | Frames Per Second - frame processing frequency |
| **Latency** | Time delay from input to output |
| **Luminance** | Perceived brightness of color (different from RGB) |
| **Variance** | Statistical measure of spread in data |
| **Standard Deviation** | Square root of variance; measure of variation |
| **Backpressure** | Flow control mechanism to prevent queue overflow |
| **ValueNotifier** | Flutter's reactive state holder |
| **NV21** | Image format: YUV planar (Android native) |
| **BGRA8888** | Image format: Blue-Green-Red-Alpha (iOS native) |
| **Early Exit** | Optimization: exit loops/functions early |
| **Resource Pooling** | Reuse expensive objects to reduce allocation |
| **Graceful Degradation** | Continue functioning with reduced capability |

---

## Appendix A: System Requirements Summary

### Minimum Device Requirements

#### Android
- API Level: 21 (Android 5.0)
- RAM: 2GB minimum (4GB recommended)
- Storage: 100MB free for installation
- Camera: Front-facing required
- Processor: Any modern ARM processor

#### iOS
- Version: 12.0+
- Device: iPhone 6s or later
- RAM: 2GB minimum
- Storage: 100MB free for installation
- Camera: Front-facing required

### Development Environment Requirements
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android SDK 21-34
- Xcode 13.0+ for iOS
- Java 11+ for Android
- CocoaPods 1.11.0+ for iOS

---

## Appendix B: API Reference

### FaceConditionAnalyzer API

```dart
// Initialize analyzer
analyzer = FaceConditionAnalyzer();

// Analyze a frame
Future<FaceConditionResult> analyze(img.Image image) async {
  // Returns FaceConditionResult with all metrics
}

// Access internals (private, for testing)
double _calculateBrightness(img.Image image)
double _calculateContrast(img.Image image)
LightingCondition _determineLightingCondition(double brightness)
FaceQuality _determineFaceQuality(bool faceDetected, int faceCount, 
  LightingCondition lighting, double contrast)
```

### CameraStreamHandler API

```dart
// Initialize with camera
Future<void> initialize(CameraDescription camera) async {}

// Get results stream
ValueNotifier<FaceConditionResult?> resultNotifier

// Get camera controller
CameraController? get controller => _controller

// Cleanup
Future<void> dispose() async {}
```

### Data Models

```dart
// Result of face condition analysis
class FaceConditionResult {
  final bool faceDetected;
  final int faceCount;
  final FaceQuality quality;
  final LightingCondition lighting;
  final double brightness;
  final double contrast;
  final List<double>? faceConfidence;
  final double exposureAdjustment;
  final String recommendation;
}

// Lighting categories
enum LightingCondition { tooDark, dark, optimal, bright, tooBright }

// Quality levels
enum FaceQuality { notDetected, poor, fair, good, excellent }
```

---

## Appendix C: Performance Profiling Results

### Expected Performance on Reference Devices

#### Pixel 4a (Mid-range Android)
- Frame latency: 45-60ms
- Memory usage: 80-120MB
- Battery drain: 8% per hour
- FPS sustained: 28-30 FPS

#### iPhone SE (Mid-range iOS)
- Frame latency: 40-55ms
- Memory usage: 70-100MB
- Battery drain: 7% per hour
- FPS sustained: 29-30 FPS

#### Low-End Device (Android 5.0, 2GB RAM)
- Frame latency: 80-120ms
- Memory usage: 150-180MB
- Battery drain: 12% per hour
- FPS sustained: 20-25 FPS

---

**Document ID**: TRD-FCDv1.0  
**Last Updated**: March 14, 2026  
**Status**: Active / Published
