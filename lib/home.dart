import 'package:flutter/material.dart';
import 'components/button.dart';
import 'components/resusable.dart';
import 'components/bottombar.dart';
import 'components/animatedtext.dart';
import 'package:tflite/tflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'video.dart';

const urlString = 'https://github.com/aizafathima/facemaskdetection';
const Color colorText = Color(0XFF565B64);
const Color colorBg = Color(0XFF8FDADD);

class Home extends StatefulWidget {
  static const String id = 'Home';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String bottomTitle = 'Add Image';
  File image;
  bool loading;
  List _output;
  ImagePicker _picker = ImagePicker();
  String text = "";
  PickedFile imageFile;
  bool maskStatus = true;

  @override
  void initState() {
    super.initState();
    loading = true;
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() async {
    await Tflite.close();
    super.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/models/model.tflite",
      labels: "assets/models/labels.txt",
    );
  }

  detectImage(File image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    return prediction;
  }

  String getOutput() {
    if (_output != null) {
      String resultText = _output[0]['label'];
      if (resultText != 'Mask') {
        maskStatus = false;
      }
      double confidence = _output[0]['confidence'];
      String confidenceToString = (confidence * 100).toStringAsFixed(2);
      print('$resultText - $confidenceToString');
      return '$resultText - $confidenceToString';
    }
  }

  getImage() {
    if (image == null) {
      return AssetImage('assets/images/default.png');
    } else {
      return FileImage(image);
    }
  }

  getImageFromCamera() async {
    imageFile = await _picker.getImage(source: ImageSource.camera);
    if (imageFile == null) return;
    setState(() {
      loading = false;
      image = File(imageFile.path);
    });
    predictImage(image);
  }

  getImageFromGallery() async {
    imageFile = await _picker.getImage(source: ImageSource.gallery);
    if (imageFile == null) return;
    setState(() {
      loading = false;
      image = File(imageFile.path);
    });
    predictImage(image);
  }

  predictImage(File image) async {
    var recognitions = await detectImage(image);
    setState(() {
      _output = recognitions;
      text = _output[0]['label'];
      bottomTitle = getOutput();
    });
  }

  getCode() async {
    if (await canLaunch(urlString)) {
      await launch(urlString);
    } else {
      throw "Unable to launch the URL : $urlString";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.code,
              color: Color(0XFF565B64),
              size: 25,
              semanticLabel: 'Code',
            ),
            onPressed: () {
              getCode();
            },
          )
        ],
        title: Text(
          'Face Mask Detection',
          style: TextStyle(
            color: colorText,
          ),
        ),
        backgroundColor: colorBg,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image(
              image: maskStatus
                  ? AssetImage('assets/images/mask_happy.png')
                  : AssetImage('assets/images/mask_sad.png'),
              height: 140,
            ),
            AnimatedText(),
            RoundButton(
              buttonIcon: Icons.video_call,
              buttonName: 'Video',
              paddingVertical: 8.0,
              onTap: () {
                Navigator.pushNamed(context, VideoPage.id);
                setState(() {
                  bottomTitle = getOutput();
                });
              },
            ),
            RoundButton(
              buttonIcon: Icons.camera,
              buttonName: 'Camera',
              paddingVertical: 8.0,
              onTap: () {
                getImageFromCamera();
                Navigator.pushNamed(context, VideoPage.id);
                setState(() {
                  bottomTitle = getOutput();
                });
              },
            ),
            RoundButton(
              buttonIcon: Icons.photo_album_outlined,
              buttonName: 'Gallery',
              paddingVertical: 8.0,
              onTap: () {
                getImageFromGallery();
                setState(() {
                  bottomTitle = getOutput();
                });
              },
            ),
            Expanded(
              child: ReusableCard(
                colour: Colors.transparent,
                cardChild: Image(
                  image: getImage(),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0XFF8FDADD),
        child: BottomButton(
          buttonTitle: bottomTitle,
          onTap: () {
            if (loading == true) {
              getImageFromGallery();
            }
            setState(() {
              bottomTitle = getOutput();
            });
          },
        ),
      ),
    );
  }
}
