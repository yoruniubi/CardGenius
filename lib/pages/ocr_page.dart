import 'dart:io'; // Import for File
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_plugin/ocr_plugin.dart'; // Import the OCR plugin
import 'package:cunning_document_scanner/cunning_document_scanner.dart'; // Import the Cunning Document Scanner
import 'package:business_card_ocr/models/business_card.dart'; // Import the BusinessCard model
import 'package:business_card_ocr/pages/editor_page.dart'; // Import the EditorPage
import 'package:business_card_ocr/main.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  final OcrPlugin _ocrPlugin = OcrPlugin(); // OCR插件实例
  final ImagePicker _picker = ImagePicker();
  final List<BusinessCard> _businessCards = []; // List to store business cards
  bool isGalleryImportAllowed = true;
  List<String> scannedImagesPath = [];

  @override
  void initState() {
    super.initState();
    _initializeOcrPlugin(); // 初始化OCR插件
  }

  Future<void> _initializeOcrPlugin() async {
    try {
      // 初始化OCR插件，可以根据需要传递配置参数
      final bool? success = await _ocrPlugin.init(
        modelPath: "models/ch_PP-OCRv4",
        labelPath: "labels/ppocr_keys_v1.txt",
        cpuThreadNum: 4,
        cpuPowerMode: "LITE_POWER_HIGH",
      );
      if (success == true) {
        debugPrint('OCR Plugin initialized successfully.');
      } else {
        debugPrint('OCR Plugin initialization failed.');
      }
    } catch (e) {
      debugPrint('Error initializing OCR Plugin: $e');
    }
  }

  @override
  void dispose() {
    _ocrPlugin.release(); // 释放OCR插件资源
    super.dispose();
  }

  Future<void> _pickAndProcessImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      String finalRecognizedText = '';

      if (!kIsWeb) {
        debugPrint('在移动端尝试 Paddle OCR...');
        try {
          final ocrResult = await _ocrPlugin.recognizeText(image.path);
          if (ocrResult != null && ocrResult['simpleText'] != null) {
            finalRecognizedText = ocrResult['simpleText'] as String;
            debugPrint("OCR Plugin 识别结果: $finalRecognizedText");
          } else {
            debugPrint("OCR Plugin 未识别到文本或返回格式不正确。");
          }
        } catch (e) {
          debugPrint('OCR Plugin 抛出异常: $e');
        }
      } else {
        finalRecognizedText = 'OCR Plugin 不支持Web平台。';
        debugPrint(finalRecognizedText);
      }

      // After OCR, navigate to EditorPage with the recognized text and image path
      if (finalRecognizedText.isNotEmpty && finalRecognizedText != 'OCR Plugin 不支持Web平台。') {
        await _navigateToEditorPage(recognizedText: finalRecognizedText, imagePath: image.path);
      } else {
        // If no text recognized or web platform, still allow manual input, potentially with image
        await _navigateToEditorPage(imagePath: image.path);
      }

      // No need to update _recognizedText or _pickedImage in OcrPage as they are not displayed here anymore.
      // The recognized text is passed directly to EditorPage.
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('处理图片失败，请重试。')),
      );
      debugPrint('处理图片时发生顶层错误: $e');
      // If an error occurs, still navigate to editor page for manual input
      await _navigateToEditorPage();
    }
  }

  Future<void> _scanDocument() async {
    final List<String>? newImagesPath = await CunningDocumentScanner.getPictures(
      noOfPages: 1, // Limit the number of pages to 1
      isGalleryImportAllowed: isGalleryImportAllowed, // Allow the user to also pick an image from his gallery
    );
    if (newImagesPath != null) {
      setState(() {
        scannedImagesPath = newImagesPath;
      });
      debugPrint('Scanned Images path: $scannedImagesPath');
      
      // Process the scanned image with OCR
      if (scannedImagesPath.isNotEmpty) {
        await _processScannedImage(scannedImagesPath.first);
      }
    }
  }

  Future<void> _processScannedImage(String imagePath) async {
    try {
      String finalRecognizedText = '';

      if (!kIsWeb) {
        debugPrint('处理扫描的图片，尝试 Paddle OCR...');
        try {
          final ocrResult = await _ocrPlugin.recognizeText(imagePath);
          if (ocrResult != null && ocrResult['simpleText'] != null) {
            finalRecognizedText = ocrResult['simpleText'] as String;
            debugPrint("OCR Plugin 识别结果: $finalRecognizedText");
          } else {
            debugPrint("OCR Plugin 未识别到文本或返回格式不正确。");
          }
        } catch (e) {
          debugPrint('OCR Plugin 抛出异常: $e');
        }
      } else {
        finalRecognizedText = 'OCR Plugin 不支持Web平台。';
        debugPrint(finalRecognizedText);
      }

      // After OCR, navigate to EditorPage with the recognized text and image path
      if (finalRecognizedText.isNotEmpty && finalRecognizedText != 'OCR Plugin 不支持Web平台。') {
        await _navigateToEditorPage(recognizedText: finalRecognizedText, imagePath: imagePath);
      } else {
        // If no text recognized or web platform, still allow manual input, potentially with image
        await _navigateToEditorPage(imagePath: imagePath);
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('处理扫描图片失败，请重试。')),
      );
      debugPrint('处理扫描图片时发生错误: $e');
      // If an error occurs, still navigate to editor page for manual input
      await _navigateToEditorPage(imagePath: imagePath);
    }
  }

  Future<void> _navigateToEditorPage({BusinessCard? card, String? recognizedText, String? imagePath}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(businessCard: card, recognizedText: recognizedText, imagePath: imagePath),
      ),
    );

    if (result != null && result is BusinessCard) {
      setState(() {
        // If editing an existing card, update it. Otherwise, add new.
        final index = _businessCards.indexWhere((element) => element == card);
        if (index != -1) {
          _businessCards[index] = result;
        } else {
          _businessCards.add(result);
        }
      });
    }
  }

  void _showImportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照导入'),
                onTap: () {
                  Navigator.pop(context);
                  _scanDocument(); // Use Cunning Document Scanner for better document scanning
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('从相册导入'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndProcessImage(source: ImageSource.gallery); // This will now navigate to editor after OCR
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('手动输入'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditorPage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('名片管理'),
      ),
      body: _businessCards.isEmpty
          ? const Center(
              child: Text('点击右下角加号导入名片'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _businessCards.length,
              itemBuilder: (context, index) {
                final card = _businessCards[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: card.imagePath != null && card.imagePath!.isNotEmpty
                        ? SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.file(
                              File(card.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.person),
                    title: Text(card.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (card.title != null && card.title!.isNotEmpty) Text(card.title!),
                        if (card.company != null && card.company!.isNotEmpty) Text(card.company!),
                        if (card.phone != null && card.phone!.isNotEmpty) Text(card.phone!),
                        if (card.email != null && card.email!.isNotEmpty) Text(card.email!),
                      ],
                    ),
                    onTap: () => _navigateToEditorPage(card: card), // Allow editing existing cards
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImportOptions,
        child: const Icon(Icons.add),
      ),
    );
  }
}
