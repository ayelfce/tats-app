import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

//  sonradan eklenen kodlar
import 'dart:convert'; // JSON işlemleri için
import 'package:http/http.dart' as http; // HTTP istekleri için

Future<void> sendImageToRoboflow(String imagePath,  Function(List<Map<String, String>>) updateData) async {
  const String apiUrl = "https://detect.roboflow.com";
  const String apiKey = "EJcCn6LTSrJ4jUMPjFnW"; // Kendi API anahtarınızı buraya ekleyin
  const String modelId = "food-k7fpo/2"; // Model kimliğiniz
  
  try {
    // Görsel dosyasını okuma
    final file = File(imagePath);

    // HTTP isteği oluşturma
    final uri = Uri.parse('$apiUrl/$modelId?api_key=$apiKey');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    // Yanıtı bekleme
    final response = await request.send();

    // Yanıtı işleme
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody);

      if (result.containsKey('predictions')) {
        List<Map<String, String>> foodList = [];
        for (var prediction in result['predictions']) {
          foodList.add({
            'foodName': prediction['class'],
            'confidence': prediction['confidence'].toString(),
          });
        }

        print(result['predictions']);
        // Tabloyu güncelleme
        updateData(foodList);
      }
    } else {
      print("Hata: ${response.statusCode}, ${response.reasonPhrase}");
    }

  } catch (e) {
    print("Bir hata oluştu: $e");
  }
}

















//  elifin bolumu
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
  List<Map<String, String>> _foodResults = [];

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
            ElevatedButton(
              onPressed: () async {
                if (_imagePath != null) {
                  await sendImageToRoboflow(_imagePath!, (List<Map<String, String>> foodList) {
                    setState(() {
                      _foodResults = foodList;
                    });
                  });
                } else {
                  print("Lütfen önce bir görsel seçin.");
                }
              },
              child: Text("Görseli Gönder"),
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

                  for (var result in _foodResults)
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('1'), // Örneğin, adet sabit bir değer olabilir
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(result['foodName'] ?? 'Bilinmiyor'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Türü'), // Türü burada yerleştirebilirsiniz
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Kalori'), // Kalori bilgisi burada yerleştirilebilir
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Fiyat'), // Fiyat bilgisi burada yerleştirilebilir
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