import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'confidence.dart';
import 'package:tflite/tflite.dart';

class VideoPage extends StatefulWidget {
  static const String id = 'VideoPage';

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with WidgetsBindingObserver {
  videoLoadModel() async {
    await Tflite.loadModel(
      model: "assets/models/model.tflite",
      labels: "assets/models/labels.txt",
    );
  }

  runModelOnFrame(CameraImage img) {
    var run = Tflite.runModelOnFrame(
      bytesList: img.planes.map((Plane plane) {
        return plane.bytes;
      }).toList(),
      imageWidth: img.width,
      imageHeight: img.height,
      numResults: 2,
    );
    print('enter into videopage');
    return run;
  }

  CameraController _controller;
  bool _isDetecting = false;

  bool _rear = false;
  List<CameraDescription> _cameras = [];
  List<dynamic> _recognitions = [];

  loadModel() async {
    videoLoadModel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _setupCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadModel();
    _setupCamera();
  }

  void _setupCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras.isEmpty) {
      print('noCamera');
    } else {
      _controller = CameraController(
        _cameras[_rear ? 0 : 1],
        ResolutionPreset.max,
      );
      _controller.initialize().then((_) {
        if (_updateCamera()) {
          _readFrames();
        }
      });
    }
  }

  Future<void> _switchCameraLens() async {
    _rear = !_rear;
    await _controller?.dispose();
    _setupCamera();
  }

  bool _updateCamera() {
    if (!mounted) {
      return false;
    }
    setState(() {});
    return true;
  }

  void _updateRecognitions({
    List<dynamic> recognitions,
  }) {
    setState(() {
      _recognitions = recognitions;
    });
  }

  void _readFrames() {
    _controller.startImageStream(
      (CameraImage img) {
        if (!_isDetecting) {
          _isDetecting = true;
          runModelOnFrame(img).then((List<dynamic> recognitions) {
            _updateRecognitions(
              recognitions: recognitions,
            );
            _isDetecting = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Container();
    }

    final Size screen = MediaQuery.of(context).size;
    final double screenH = max(screen.height, screen.width);
    final double screenW = min(screen.height, screen.width);

    final Size previewSize = _controller.value.previewSize;
    final double previewH = max(previewSize.height, previewSize.width);
    final double previewW = min(previewSize.height, previewSize.width);
    final double screenRatio = screenH / screenW;
    final double previewRatio = previewH / previewW;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          OverflowBox(
            maxHeight: screenRatio > previewRatio
                ? screenH
                : screenW / previewW * previewH,
            maxWidth: screenRatio > previewRatio
                ? screenH / previewH * previewW
                : screenW,
            child: CameraPreview(_controller),
          ),
          ConfidenceMeter(
            results: _recognitions ?? <dynamic>[],
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80), color: Colors.green),
              child: GestureDetector(
                  onTap: () async => _switchCameraLens(),
                  child: Icon(
                    _rear ? Icons.camera_front : Icons.camera_rear,
                    size: 30,
                    color: Colors.white,
                  )),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80), color: Colors.red),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
