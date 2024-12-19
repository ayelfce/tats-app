import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

Future<void> requestPermissions() async {
  var cameraStatus = await Permission.camera.request();
  var galleryStatus = await Permission.photos.request();

  if (cameraStatus.isGranted && galleryStatus.isGranted) {
    print("Kamera ve galeri izinleri verildi.");
  } else {
    print("Kamera veya galeri izinleri reddedildi.");
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TATS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 205, 83, 75)),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'TATS (Tray Analysis and\n      Detection System)',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _checkPermissionsAndProceed(Function onPermissionGranted) async {
    var cameraStatus = await Permission.camera.request();
    var galleryStatus = await Permission.photos.request();

    if (cameraStatus.isGranted && galleryStatus.isGranted) {
      onPermissionGranted();
    } else {
      if (!cameraStatus.isGranted) {
        print("Kamera izni verilmedi.");
      }
      if (!galleryStatus.isGranted) {
        print("Galeri izni verilmedi.");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen Kamera ve Galeri izinlerini verin.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            const Text(
              'Tepsi analizi için lütfen aşağıdaki\nseçeneklerden birini seçin:',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: () async {
                await _checkPermissionsAndProceed(_pickImageFromGallery);
              },
              child: const Text("Galeriden fotoğraf seç"),
            ),

            ElevatedButton(
              onPressed: () async {
                await _checkPermissionsAndProceed(_pickImageFromCamera);
              },
              child: const Text("Kamera ile çek"),
            ),

            SizedBox(height: 20),
            if (_imagePath != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                    File(_imagePath!)),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0),
              child: Table(
                border: TableBorder.all(),
                children: [
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Adet',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Yemek Adı',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Türü',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Kalori (KCAL)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Fiyat (TL)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ]),

                  for (int i = 0; i < 7; i++)
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Row ${i + 1} Col 1'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Row ${i + 1} Col 2'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Row ${i + 1} Col 3'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Row ${i + 1} Col 4'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Row ${i + 1} Col 5'),
                      ),
                    ]),
                ],
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0),
              child: Table(
                border: TableBorder.all(),
                children: [
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Toplam Kalori',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('?'),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Toplam Fiyat',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('?'),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Menü Türü',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('?'),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Menü Fiyatı',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('?'),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Tasarruf',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('?'),
                    ),
                  ]),
                ],
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0), 
              child: Table(
                border: TableBorder.all(), 
                children: [
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Aylık Toplam Kalori',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('?'),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Aylık Toplam Maliyet',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('?'),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Aylık Toplam Tasarruf',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('?'),
                    ),
                  ]),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
