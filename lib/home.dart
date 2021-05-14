import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  File _image;
  List _output;
  final picker = ImagePicker();

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _output = output;
      _loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  void _pickCameraImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.camera,
    );
    if (pickedImage == null) return null;
    final pickedImageFile = File(pickedImage.path);

    setState(() {
      _image = pickedImageFile;
    });
    classifyImage(_image);
  }

  void _pickGalleryImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return null;
    final pickedImageFile = File(pickedImage.path);

    setState(() {
      _image = pickedImageFile;
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEEFEA),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text('Teachable Machine CNN', style: TextStyle(fontSize: 18)),
            SizedBox(height: 6),
            Text(
              'Detect Flowers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Center(
              child: _loading
                  ? Container(
                child: Column(
                  children: [
                    Image.asset("assets/flower.png"),
                    SizedBox(height: 50),
                  ],
                ),
              )
                  : Container(
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      child: Image.file(_image,fit: BoxFit.cover,),
                    ),
                    SizedBox(height: 20),
                    _output != null
                        ? Text(
                      '${_output[0]['label']}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : Container(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FlatButton.icon(
                    height: 50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    icon: Icon(
                      Icons.image,
                      color: Color(0xffEEEFEA),
                    ),
                    onPressed: _pickCameraImage,
                    label: Text(
                      'Take a Photo',
                      style: TextStyle(color: Color(0xffEEEFEA), fontSize: 16),
                    ),
                    color: Color(0xFFE14A39),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FlatButton.icon(
                    height: 50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    icon: Icon(
                      Icons.image,
                      color: Color(0xffEEEFEA),
                    ),
                    onPressed: _pickGalleryImage,
                    label: Text(
                      'Import a Photo',
                      style: TextStyle(color: Color(0xffEEEFEA), fontSize: 16),
                    ),
                    color: Color(0xFFF0A25B),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
