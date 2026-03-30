# Face Condition Detection

## Overview

**Face Condition Detection in Any Lighting** is a sophisticated Flutter mobile application designed to detect human faces in real-time camera streams and intelligently analyze their condition while adapting to various lighting environments. The application provides comprehensive feedback on face detection quality, lighting conditions, brightness levels, and contrast analysis—making it ideal for quality assurance in face recognition pipelines, video conferencing optimization, biometric authentication systems, and accessibility applications.

This project is a **CCExtractor Organization Take-home Qualification Task for GSOC 2026**.

---

## Table of Contents

1. [Features](#features)
2. [System Requirements](#system-requirements)
3. [Installation Guide](#installation-guide)
4. [Usage Instructions](#usage-instructions)
5. [Application Interface](#application-interface)
6. [Supported Platforms](#supported-platforms)
7. [Camera Permissions](#camera-permissions)
8. [FAQ](#faq)
9. [Troubleshooting](#troubleshooting)
10. [Contributing](#contributing)
11. [License](#license)

---

## Features

### Core Functionality

#### 1. **Real-Time Face Detection**
- Continuous face detection using Google ML Kit
- Ultra-fast detection with minimal latency
- Simultaneous detection of multiple faces with individual quality assessment
- Face tracking capabilities for smoother detection results

#### 2. **Lighting Condition Analysis**
The application automatically categorizes lighting into 5 distinct levels:

| Lighting Condition | Brightness Range | Visual Indicator | Recommendation |
|---|---|---|---|
| **Too Dark** | < 10% | Dark Gray | Enable flash or increase ambient light |
| **Dark** | 10-30% | Gray | Move to brighter area |
| **Optimal** | 30-70% | Green | Perfect for face detection |
| **Bright** | 70-85% | Orange | Slightly reduce light exposure |
| **Too Bright** | > 85% | Red | Reduce light or reposition |

#### 3. **Quality Assessment System**
The app evaluates detected faces on a 5-level quality scale:

| Quality Level | Criteria | Status | Color Code |
|---|---|---|---|
| **Not Detected** | No face in frame | ❌ | Red |
| **Poor** | Multiple faces or extreme lighting | ⚠️ | Dark Red |
| **Fair** | Multiple faces or suboptimal lighting | ⚠️ | Orange |
| **Good** | Single face in good lighting | ✓ | Light Green |
| **Excellent** | Optimal conditions with high contrast | ✓✓ | Green |

#### 4. **Real-Time Metrics**
- **Brightness Percentage**: Live brightness level (0-100%)
- **Contrast Analysis**: Measurement of contrast quality (0-100%)
- **Exposure Adjustment**: Recommended adjustment on -1.0 to +1.0 scale
- **Face Count**: Number of faces detected in current frame
- **Confidence Scores**: ML Kit face detection confidence metrics

#### 5. **Intelligent Recommendations**
The app provides contextual, actionable recommendations based on detected conditions:
- Lighting adjustment suggestions
- Face positioning guidance
- Distance recommendations
- Multiple face detection alerts

#### 6. **User-Friendly Interface**
- Color-coded visual indicators for instant feedback
- Real-time metric display overlay
- Smooth animations and transitions
- Intuitive navigation and controls

---

## System Requirements

### Hardware Requirements

#### Android
- **Minimum SDK**: Android 5.0 (API Level 21)
- **Target SDK**: Android 12+ (API Level 31+)
- **RAM**: Minimum 2 GB (4 GB+ recommended)
- **Storage**: Minimum 100 MB free space
- **Camera**: Front-facing camera required
- **Processor**: Qualcomm Snapdragon 400 series or equivalent

#### iOS
- **Minimum iOS Version**: iOS 12.0
- **Target iOS Version**: iOS 15.0+
- **Device**: iPhone 6s or later (iPhone Xs or later recommended)
- **RAM**: Minimum 2 GB available
- **Storage**: Minimum 100 MB free space
- **Camera**: Front-facing camera required

### Development Requirements

#### For Building from Source
- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Version 3.0.0 or higher
- **Android Studio**: Version 2021.1.1 or later (for Android development)
- **Xcode**: Version 13.0 or later (for iOS development)
- **CocoaPods**: Version 1.11.0 or later (for iOS dependencies)

#### System Dependencies
- Java Development Kit (JDK) 11 or higher (for Android)
- Xcode Command Line Tools (for iOS)

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
git clone https://github.com/NihalDR/Face-Condition-Detection-in-Any-Lighting.git
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
##  Demo

<p align="center">
  <video width="630" height="300" src="https://github.com/user-attachments/assets/3aa1e451-f528-479f-9cab-c652cafb8424" controls></video>
  </a>
</p>

##  Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/284d2293-5b89-43d6-968e-ba83934dc54a" width="250"/>
  <img src="https://github.com/user-attachments/assets/342cc48b-855b-4f58-8af2-423d6089cfb3" width="250"/>
  <img src="https://github.com/user-attachments/assets/9bb57064-8fe3-4884-9466-d3864052f071" width="250"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/47c5a635-cab4-427b-a592-877d103db0c5" width="250"/>
</p>



## License

This project is provided as-is for educational and research purposes.

## Credits

Built with Flutter, Google ML Kit, and modern mobile development best practices.

## Support

For issues or feature requests, please open an issue on the repository.
