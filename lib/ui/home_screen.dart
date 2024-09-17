import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  List? _results;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  loadModel() async {
    String? s = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
    print("ssss:  $s");
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectImage(file!);
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
  }

  Future detectImage(File image) async {
    print("$image");
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.0,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    if (recognitions != null) {
      setState(() {
        _results = recognitions;
      });
    }
    print("res : $_results");
    if (kDebugMode) {
      print(_results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.photo),
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height,
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.sizeOf(context).height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _image == null
                    ? const SizedBox(
                        height: 200,
                        width: 200,
                      )
                    : SizedBox(
                        height: 200,
                        width: 200,
                        child: Image.file(file!),
                      ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  child: Column(
                    children: (_image != null) && (_results != null)
                        ? _results!.map((result) {
                            return Card(
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                child: Text(
                                  "${result['label']} - ${((result['confidence']*100).toStringAsFixed(1))}%",
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 20),
                                ),
                              ),
                            );
                          }).toList()
                        : [],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
