import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:audioplayers/audio_cache.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'teldetector',
            style: TextStyle(fontSize: 60, color: Colors.purple),
          ),
        ),
        body: Container(
          child: Column(
            children: [
              _image == null ? Container() : Image.file(_image),
              SizedBox(
                height: 20,
              ),
              _outputs != null ? Text("${_outputs[0]["label"]}") : Container(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: predictImagePicker,
          child: Icon(Icons.camera),
        ),
      ),
    );
  }

  predictImagePicker() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    final player = AudioCache();
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 7,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
      if (_outputs != null) {
        if (_outputs[0]["label"] == "0 100 baisa") {
          player.play('vocal-1-.m4a');
        }
        if (_outputs[0]["label"] == "1 500 baisa") {
          player.play('vocal-2-.m4a');
        }
        if (_outputs[0]["label"] == "2 1 OR") {
          player.play('vocal-3-.m4a');
        }
        if (_outputs[0]["label"] == "3 5 OR") {
          player.play('vocal-4-.m4a');
        }
        if (_outputs[0]["label"] == "4 10 OR") {
          player.play('vocal-5-.m4a');
        }
        if (_outputs[0]["label"] == "5 20 OR") {
          player.play('vocal-6-.m4a');
        }
        if (_outputs[0]["label"] == "6 50 OR") {
          player.play('vocal-7-.m4a');
        }
        if (_outputs[0]["label"] == "7 NOT SUPP") {
          player.play('vocal-8-.m4a');
        }
      }
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
