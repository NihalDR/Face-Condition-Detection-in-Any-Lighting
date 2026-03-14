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
        appBar: AppBar(
          title: const Text('Face Detection in Any Lighting'),
          backgroundColor: Colors.deepPurple[600],
          elevation: 0,
        ),
        body: _permissionStatus.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      _permissionStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : !_isInitialized
                ? const Center(child: CircularProgressIndicator())
                : _buildCameraPreview(),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Column(
      children: [
        // Camera Preview
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.black,
            child: cameraHandler.controller != null &&
                    cameraHandler.controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio:
                        cameraHandler.controller!.value.aspectRatio,
                    child: CameraPreview(cameraHandler.controller!),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),

        // Condition Indicators and Info
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: ValueListenableBuilder<FaceConditionResult?>(
              valueListenable: cameraHandler.resultNotifier,
              builder: (context, result, _) {
                if (result == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Face Detection Status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: result.faceDetected
                              ? Colors.green[100]
                              : Colors.red[100],
                          border: Border.all(
                            color: result.faceDetected
                                ? Colors.green[600]!
                                : Colors.red[600]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              result.faceDetected
                                  ? Icons.face
                                  : Icons.face_rounded,
                              color: result.faceDetected
                                  ? Colors.green[600]
                                  : Colors.red[600],
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.faceDetected
                                      ? 'Face Detected'
                                      : 'No Face Detected',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (result.faceDetected)
                                  Text(
                                    'Count: ${result.faceCount}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Quality Indicator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getQualityColor(result.quality)
                              .withOpacity(0.1),
                          border: Border.all(
                            color: _getQualityColor(result.quality),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: _getQualityColor(result.quality),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Quality: ${_getQualityLabel(result.quality)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getQualityColor(result.quality),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Lighting Condition
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getLightingColor(result.lighting)
                              .withOpacity(0.1),
                          border: Border.all(
                            color: _getLightingColor(result.lighting),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.light_mode,
                                  color: _getLightingColor(result.lighting),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Lighting: ${_getLightingLabel(result.lighting)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getLightingColor(result.lighting),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Brightness: ${(result.brightness * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Contrast: ${(result.contrast * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Recommendation
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          border: Border.all(color: Colors.blue[600]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.recommendation,
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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
