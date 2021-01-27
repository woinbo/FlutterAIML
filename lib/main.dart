import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PickedFile _image;
  List _output;
  bool _loading = true;

  choseImage() async {
    PickedFile imagePicker =
        await ImagePicker().getImage(source: ImageSource.camera);
    if (imagePicker != null) {
      setState(() {
        _image = imagePicker;

        _loading = false;
      });
    }
    runTensorFlow(_image);
  }

  runTensorFlow(image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    if (output != null) {
      setState(() {
        _output = output;
      });
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    loadModel().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: _loading
                  ? CircularProgressIndicator()
                  : Image.file(File(_image.path)),
            ),
            Expanded(
              flex: 3,
              child: _output == null
                  ? Text("Nothing to show")
                  : Text("${_output[0]}"),
            ),
            Expanded(
              flex: 5,
              child: TextButton(
                child: Text("Upload Image"),
                onPressed: () {
                  choseImage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
