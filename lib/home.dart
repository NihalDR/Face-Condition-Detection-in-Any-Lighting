import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_live_emotion/main.dart';
import 'face_condition_analyzer.dart';
import 'camera_stream_handler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  late FaceConditionAnalyzer analyzer;
  late CameraStreamHandler cameraHandler;
  bool _isInitialized = false;
  String _permissionStatus = 'Requesting permissions...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    analyzer = FaceConditionAnalyzer();
    cameraHandler = CameraStreamHandler(analyzer: analyzer);
    _requestPermissionsAndInitialize();
  }

  Future<void> _requestPermissionsAndInitialize() async {
    try {
      final cameraStatus = await Permission.camera.request();

      if (cameraStatus.isGranted) {
        if (cameras != null && cameras!.isNotEmpty) {
          // Use front camera if available
          final frontCamera = cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras![0],
          );

          await cameraHandler.initialize(frontCamera);

          if (mounted) {
            setState(() {
              _isInitialized = true;
              _permissionStatus = '';
            });
          }
        }
      } else if (cameraStatus.isDenied) {
        if (mounted) {
          setState(() {
            _permissionStatus = 'Camera permission denied. Please enable it.';
          });
        }
      } else if (cameraStatus.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            _permissionStatus =
                'Camera permission permanently denied. Open app settings.';
          });
        }
        openAppSettings();
      }
    } catch (e) {
      print('Error initializing: $e');
      if (mounted) {
        setState(() {
          _permissionStatus = 'Error initializing camera: $e';
        });
      }
    }
  }

  Color _getLightingColor(LightingCondition lighting) {
    switch (lighting) {
      case LightingCondition.tooDark:
        return Colors.grey[900]!;
      case LightingCondition.dark:
        return Colors.grey[700]!;
      case LightingCondition.optimal:
        return Colors.green[600]!;
      case LightingCondition.bright:
        return Colors.orange[600]!;
      case LightingCondition.tooBright:
        return Colors.red[600]!;
    }
  }

  Color _getQualityColor(FaceQuality quality) {
    switch (quality) {
      case FaceQuality.notDetected:
        return Colors.red[600]!;
      case FaceQuality.poor:
        return Colors.red[500]!;
      case FaceQuality.fair:
        return Colors.orange[600]!;
      case FaceQuality.good:
        return Colors.lightGreen[600]!;
      case FaceQuality.excellent:
        return Colors.green[600]!;
    }
  }

  String _getLightingLabel(LightingCondition lighting) {
    switch (lighting) {
      case LightingCondition.tooDark:
        return 'Too Dark';
      case LightingCondition.dark:
        return 'Dark';
      case LightingCondition.optimal:
        return 'Optimal';
      case LightingCondition.bright:
        return 'Bright';
      case LightingCondition.tooBright:
        return 'Too Bright';
    }
  }

  String _getQualityLabel(FaceQuality quality) {
    switch (quality) {
      case FaceQuality.notDetected:
        return 'Not Detected';
      case FaceQuality.poor:
        return 'Poor';
      case FaceQuality.fair:
        return 'Fair';
      case FaceQuality.good:
        return 'Good';
      case FaceQuality.excellent:
        return 'Excellent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await cameraHandler.dispose();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _permissionStatus.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_outlined,
                        size: 64, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _permissionStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              )
            : !_isInitialized
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _buildCameraPreview(),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        // Camera Preview
        Container(
          color: Colors.black,
          child: cameraHandler.controller != null &&
                  cameraHandler.controller!.value.isInitialized
              ? CameraPreview(cameraHandler.controller!)
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
        ),

        // Header with LIVE indicator
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.face, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Emotion AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Info Panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<FaceConditionResult?>(
            valueListenable: cameraHandler.resultNotifier,
            builder: (context, result, _) {
              if (result == null) {
                return const SizedBox.shrink();
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Face Detected Row
                    _buildInfoRow(
                      icon: Icons.face,
                      label: 'Face Detected',
                      value: result.faceDetected ? 'Yes' : 'No',
                      valueColor: result.faceDetected
                          ? Colors.green
                          : Colors.grey[600]!,
                      iconColor:
                          result.faceDetected ? Colors.green : Colors.grey[600]!,
                    ),

                    const SizedBox(height: 16),

                    // Emotion Row
                    _buildInfoRow(
                      icon: Icons.sentiment_satisfied_alt,
                      label: 'Emotion',
                      value: result.emotion ?? 'Unknown',
                      valueColor: Colors.grey[400]!,
                      iconColor: Colors.grey[400]!,
                    ),

                    const SizedBox(height: 16),

                    // Confidence Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.confidence_level,
                              color: Colors.purple,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Confidence',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${(result.emotionConfidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Lighting Row
                    _buildInfoRow(
                      icon: Icons.wb_sunny,
                      label: 'Lighting',
                      value: _getLightingLabel(result.lighting),
                      valueColor: _getLightingColor(result.lighting),
                      iconColor: _getLightingColor(result.lighting),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required Color iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: valueColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: valueColor.withOpacity(0.5),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      cameraHandler.controller?.stopImageStream();
    } else if (state == AppLifecycleState.resumed) {
      if (cameraHandler.controller != null &&
          !cameraHandler.controller!.value.isStreamingImages) {
        cameraHandler.controller?.startImageStream((image) async {
          // Frame stream will be handled by CameraStreamHandler
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    analyzer.dispose();
    cameraHandler.dispose();
    super.dispose();
  }
}
