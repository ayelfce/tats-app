// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:io';
// import 'package:camera/camera.dart';

// //  sonradan eklenen kodlar
// import 'dart:convert'; // JSON işlemleri için
// import 'package:http/http.dart' as http; // HTTP istekleri için

// Future<void> sendImageToRoboflow(String imagePath,  Function(List<Map<String, String>>) updateData) async {

//   const String apiUrl = "https://detect.roboflow.com";
//   const String apiKey = "EJcCn6LTSrJ4jUMPjFnW"; // Kendi API anahtarınızı buraya ekleyin
//   const String modelId = "food-k7fpo/3"; // Model kimliğiniz
 
//   try {
//     // Görsel dosyasını okuma
//     final file = File(imagePath);

//     // HTTP isteği oluşturma
//     final uri = Uri.parse('$apiUrl/$modelId?api_key=$apiKey');
//     final request = http.MultipartRequest('POST', uri)
//       ..files.add(await http.MultipartFile.fromPath('file', imagePath));

//     // Yanıtı bekleme
//     final response = await request.send();

//     // Yanıtı işleme
//     if (response.statusCode == 200) {
//       final responseBody = await response.stream.bytesToString();
//       final result = jsonDecode(responseBody);

//       if (result.containsKey('predictions')) {
//         List<Map<String, String>> foodList = [];
        
//         for (var prediction in result['predictions']) {
//           if (foodList.any((product) => product['class_id'].toString() == prediction['class_id'].toString())) {
//             // İlgili elemanı bul ve total değerini artır
//             for (var product in foodList) {
//               if (product['class_id'].toString() == prediction['class_id'].toString()) {
//                 product['total'] = (int.parse(product['total'] ?? '1') + 1).toString(); // Eğer 'total' yoksa varsayılan olarak 1 alır
//                 break; // İlk eşleşmeyi bulduktan sonra döngüyü sonlandır
//               }
//             }
//           }
//           else {
//             foodList.add({
//             'class_id': prediction['class_id'].toString(),
//             'foodName': prediction['class'],
//             'confidence': prediction['confidence'].toString(),
//             'total': "1",
//           });
//           }
          
//         }

//         print(result['predictions']);
//         // Tabloyu güncelleme
//         updateData(foodList);
//         print(foodList);
//       }
//     } else {
//       print("Hata: ${response.statusCode}, ${response.reasonPhrase}");
//     }

//   } catch (e) {
//     print("Bir hata oluştu: $e");
//   }
// }








// //  elifin bolumu
// Future<void> requestPermissions() async {
//   var cameraStatus = await Permission.camera.request();
//   var galleryStatus = await Permission.photos.request();

//   if (cameraStatus.isGranted && galleryStatus.isGranted) {
//     print("Kamera ve galeri izinleri verildi.");
//   } else {
//     print("Kamera veya galeri izinleri reddedildi.");
//   }
// }

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TATS',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//             seedColor: const Color.fromARGB(255, 205, 83, 75)),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(
//         title: 'TATS (Tray Analysis and\n      Detection System)',
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final ImagePicker _picker = ImagePicker();
//   String? _imagePath;
//   List<Map<String, String>> _foodResults = [];

//   Future<void> _pickImageFromGallery() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imagePath = pickedFile.path;
//       });
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _imagePath = pickedFile.path;
//       });
//     }
//   }

//   Future<void> _checkPermissionsAndProceed(Function onPermissionGranted) async {
//     var cameraStatus = await Permission.camera.request();
//     var galleryStatus = await Permission.photos.request();

//     if (cameraStatus.isGranted && galleryStatus.isGranted) {
//       onPermissionGranted();
//     } else {
//       if (!cameraStatus.isGranted) {
//         print("Kamera izni verilmedi.");
//       }
//       if (!galleryStatus.isGranted) {
//         print("Galeri izni verilmedi.");
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Lütfen Kamera ve Galeri izinlerini verin.'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(height: 20),
//             const Text(
//               'Tepsi analizi için lütfen aşağıdaki\nseçeneklerden birini seçin:',
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 5),
//             ElevatedButton(
//               onPressed: () async {
//                 await _checkPermissionsAndProceed(_pickImageFromGallery);
//               },
//               child: const Text("Galeriden fotoğraf seç"),
//             ),

//             ElevatedButton(
//               onPressed: () async {
//                 await _checkPermissionsAndProceed(_pickImageFromCamera);
//               },
//               child: const Text("Kamera ile çek"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_imagePath != null) {
//                   await sendImageToRoboflow(_imagePath!, (List<Map<String, String>> foodList) {
//                     setState(() {
//                       _foodResults = foodList;
//                     });
//                   });
//                 } else {
//                   print("Lütfen önce bir görsel seçin.");
//                 }
//               },
//               child: Text("Görseli Gönder"),
//             ),

            

//             SizedBox(height: 20),
//             if (_imagePath != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Image.file(
//                     File(_imagePath!)),
//               ),
              
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 20.0),
//               child: Table(
//                 border: TableBorder.all(),
//                 children: [
//                   TableRow(children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Adet',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 13)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Yemek Adı',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 13)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Türü',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 13)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Kalori (KCAL)',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 13)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Fiyat (TL)',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 13)),
//                     ),
//                   ]),

                  



//                   for (var result in _foodResults)
//                     TableRow(children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(result['total'] ?? 'Bilinmiyor'), // Örneğin, adet sabit bir değer olabilir
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(result['foodName'] ?? 'Bilinmiyor'),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('Türü'), // Türü burada yerleştirebilirsiniz
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('Kalori'), // Kalori bilgisi burada yerleştirilebilir
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('Fiyat'), // Fiyat bilgisi burada yerleştirilebilir
//                       ),
//                     ]),
//                 ],
//               ),
//             ),

//             SizedBox(height: 20),

//             Padding(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 20.0),
//               child: Table(
//                 border: TableBorder.all(),
//                 children: [
//                   TableRow(children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Toplam Kalori',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('?'),
//                     ),
//                   ]),
//                   TableRow(children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Toplam Fiyat',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('?'),
//                     ),
//                   ]),
//                   TableRow(children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Menü Türü',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('?'),
//                     ),
//                   ]),
//                   TableRow(children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Menü Fiyatı',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('?'),
//                     ),
//                   ]),
//                   TableRow(children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Tasarruf',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('?'),
//                     ),
//                   ]),
//                 ],
//               ),
//             ),

//             SizedBox(height: 20),

//             Padding(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 20.0), 
//               child: Table(
//                 border: TableBorder.all(), 
//                 children: [
//                   TableRow(children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Aylık Toplam Kalori',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('?'),
//                     ),
//                   ]),
//                   TableRow(children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Aylık Toplam Maliyet',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('?'),
//                     ),
//                   ]),
//                   TableRow(children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('Aylık Toplam Tasarruf',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('?'),
//                     ),
//                   ]),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// } 




import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; // JSON işlemleri için
import 'package:http/http.dart' as http; // HTTP istekleri için
import 'package:excel/excel.dart'; // Excel işlemleri için

// Excel verilerini yükleyen fonksiyon
Future<Map<String, Map<String, String>>> loadExcelData() async {
  final byteData = await rootBundle.load('assets/foodInfoTable.xlsx');
  var excel = Excel.decodeBytes(byteData.buffer.asUint8List());

  Map<String, Map<String, String>> excelData = {};
  
  for (var table in excel.tables.keys) {
    var rows = excel.tables[table]?.rows;
    for (var row in rows!) {
      print(row);
      if (row.isNotEmpty) {
        String yemekIsmi = row[0]?.value.toString() ?? '';
        String tur = row[1]?.value.toString() ?? '';
        String kalori = row[2]?.value.toString() ?? '';
        String fiyat = row[3]?.value.toString() ?? '';
        String classId = row[4]?.value.toString() ?? '';

        excelData[classId] = {
          'yemekIsmi': yemekIsmi,
          'Tür': tur,
          'Kalori': kalori,
          'Fiyat': fiyat,
        };
      }
    }
  }
  // print(excelData);
  return excelData;
}

// Görseli Roboflow'a gönderen fonksiyon
Future<void> sendImageToRoboflow(String imagePath, Function(String,String) menuType, Function(List<Map<String, String>>) updateData) async {
  const String apiUrl = "https://detect.roboflow.com";
  const String apiKey = "EJcCn6LTSrJ4jUMPjFnW";
  const String modelId = "food-k7fpo/5";

  try {
    final file = File(imagePath);
    final uri = Uri.parse('$apiUrl/$modelId?api_key=$apiKey');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));
    final response = await request.send();
    var mainFood = 0;
    var sideFood = 0;
    var withMeat = 0;
    var withoutMeat = 0;
    // String menuType = "";

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody);

      Map<String, Map<String, String>> excelData = await loadExcelData();
      // print(excelData);

      if (result.containsKey('predictions')) {
        List<Map<String, String>> foodList = [];

        for (var prediction in result['predictions']) {
          if (prediction['confidence'] < 0.50) {
            continue;
          }
          String classId = prediction['class_id'].toString() ?? '';

          if (excelData.containsKey(classId)) {
            var additionalData = excelData[classId];
            if (foodList.any((product) => product['class_id'].toString() == prediction['class_id'].toString())) {
              // İlgili elemanı bul ve total değerini artır
              for (var product in foodList) {

                product['Fiyat'] = additionalData?['Fiyat'].toString() ?? "0";
                product['Kalori'] = additionalData?['Kalori'].toString() ?? "0";

                if (product['class_id'].toString() == prediction['class_id'].toString()) {
                  product['total'] = (int.parse(product['total'] ?? '1') + 1).toString(); // Eğer 'total' yoksa varsayılan olarak 1 alır
                  product['Fiyat'] = (int.parse(product['Fiyat'] ?? '0') * int.parse(product['total'] ?? '1')).toString();
                  product['Kalori'] = (int.parse(product['Kalori'] ?? '0') * int.parse(product['total'] ?? '1')).toString();
                  break; // İlk eşleşmeyi bulduktan sonra döngüyü sonlandır
                }
              }
            }
            else {
              foodList.add({
                'class_id': prediction['class_id'].toString(),
                'foodName': additionalData?['yemekIsmi'].toString() ?? "Bilinmiyor",
                'confidence': prediction['confidence'].toString(),
                'Tür': additionalData?['Tür'] ?? 'Bilinmiyor',
                'Kalori': additionalData?['Kalori'].toString() ?? 'Bilinmiyor',
                'Fiyat': additionalData?['Fiyat'].toString() ?? 'Bilinmiyor',
                'total': "1",
              });

            }
            if(additionalData?['Tür'] == "Yardımcı Yemek"){
              sideFood++;
            }
            else if(additionalData?['Tür'] == "Etli Yemek"){
              withMeat++;
            }
            else if(additionalData?['Tür'] == "Etsiz Yemek"){
              withoutMeat++;
            }
            
          }
        }
        updateData(foodList);

        print(foodList);
        print(result['predictions']);
        print("Ana Yemek Sayısı: $mainFood" + " Yan Yemek Sayısı: $sideFood" + " Etli Yemek Sayısı: $withMeat" + " Etsiz Yemek Sayısı: $withoutMeat");

        if ((withMeat == 1 || withoutMeat== 1) && sideFood == 3){
          menuType("fix menü", "132");
        }
        else if(withMeat == 1 && sideFood == 1 && withoutMeat == 0){
          menuType("menü 1", "106");
        }
        else if(withoutMeat == 1 && sideFood == 1 && withMeat == 0){
          menuType("menü 2", "73");
        }
        else if(withoutMeat == 1 && sideFood == 0 && withMeat == 0){
          menuType("menü 3", "53");
        }
        else {
          menuType("Standart menülere uygun değil", "-");
        }
      }
    } else {
      print("Hata: ${response.statusCode}, ${response.reasonPhrase}");
    }
  } catch (e) {
    print("Bir hata oluştu: $e");
  }
}

// Uygulama başlangıç noktası
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
          seedColor: const Color.fromARGB(255, 205, 83, 75),
        ),
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
  String _menuType = "";
  String _menuPrice = "";
  var totalPrice = 0;
  var totalCalories = 0;

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
              onPressed: _pickImageFromGallery,
              child: const Text("Galeriden fotoğraf seç"),
            ),
            ElevatedButton(
              onPressed: _pickImageFromCamera,
              child: const Text("Kamera ile çek"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_imagePath != null) {
                  await sendImageToRoboflow(_imagePath!,  (String menuType, String menuPrice) {
                    setState(() {
                      _menuType = menuType;
                      _menuPrice = menuPrice;
                      totalPrice = 0;
                      totalCalories = 0;
                    });
                  } , (List<Map<String, String>> foodList) {
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
                child: Image.file(File(_imagePath!)),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      child: Text('Kalori',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Fiyat',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ]),
                  ..._foodResults.map((food) {
                    totalPrice += int.tryParse(food['Fiyat'] ?? '0') ?? 0;
                    totalCalories += int.tryParse(food['Kalori'] ?? '0') ?? 0;
                    return TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(food['total'] ?? '',
                            style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(food['foodName'] ?? '',
                            style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(food['Tür'] ?? '',
                            style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(food['Kalori'] ?? '',
                            style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        // child: Text(((int.tryParse(food['Fiyat'] ?? '') ?? 0) * (int.tryParse(food['total'] ?? '') ?? 0)).toString()  ?? '',
                        child: Text(food['Fiyat']  ?? '',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ]);
                  }).toList(),
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
                      child: Text(totalCalories.toString()),
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
                      child: Text(totalPrice.toString()),
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
                      child: Text(_menuType),
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
                      child: Text(_menuPrice),
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
                      child: Text(int.tryParse(_menuPrice) != null ? (((totalPrice - int.tryParse(_menuPrice)!) / totalPrice) * 100).toStringAsFixed(2) : ''),
                    ),
                  ]),
                  
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
