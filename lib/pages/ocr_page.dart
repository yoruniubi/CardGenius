import 'dart:io'; // Import for File
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_plugin/ocr_plugin.dart'; // Import the OCR plugin
import 'package:cunning_document_scanner/cunning_document_scanner.dart'; // Import the Cunning Document Scanner
import 'package:business_card_ocr/models/business_card.dart'; // Import the BusinessCard model
import 'package:business_card_ocr/pages/editor_page.dart';
import 'package:business_card_ocr/main.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  final OcrPlugin _ocrPlugin = OcrPlugin();
  final ImagePicker _picker = ImagePicker();
  final List<BusinessCard> _businessCards = [];
  bool isGalleryImportAllowed = true;
  List<String> scannedImagesPath = [];

  @override
  void initState() {
    super.initState();
    _initializeOcrPlugin();
  }

  Future<void> _initializeOcrPlugin() async {
    try {
      // Initialize OCR plugin with configuration parameters
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
    _ocrPlugin.release();
    super.dispose();
  }

  Future<void> _pickAndProcessImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      String finalRecognizedText = '';

      if (!kIsWeb) {
        debugPrint('Attempting Paddle OCR on mobile...');
        try {
          final ocrResult = await _ocrPlugin.recognizeText(image.path);
          if (ocrResult != null && ocrResult['simpleText'] != null) {
            finalRecognizedText = ocrResult['simpleText'] as String;
            debugPrint("OCR Plugin recognition result: $finalRecognizedText");
          } else {
            debugPrint("OCR Plugin failed to recognize text or returned incorrect format.");
          }
        } catch (e) {
          debugPrint('OCR Plugin exception: $e');
        }
      } else {
        finalRecognizedText = 'OCR Plugin does not support Web platform.';
        debugPrint(finalRecognizedText);
      }

      final l10n = AppLocalizations.of(context)!;
      // After OCR, navigate to EditorPage with the recognized text and image path
      if (finalRecognizedText.isNotEmpty && finalRecognizedText != l10n.ocrWebNotSupported) {
        await _navigateToEditorPage(recognizedText: finalRecognizedText, imagePath: image.path);
      } else {
        // If no text recognized or web platform, still allow manual input, potentially with image
        await _navigateToEditorPage(imagePath: image.path);
      }

      // No need to update _recognizedText or _pickedImage in OcrPage as they are not displayed here anymore.
      // The recognized text is passed directly to EditorPage.
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.errorProcessingImage)),
      );
      debugPrint('Error during image processing: $e');
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
        debugPrint('Processing scanned image, attempting Paddle OCR...');
        try {
          final ocrResult = await _ocrPlugin.recognizeText(imagePath);
          if (ocrResult != null && ocrResult['simpleText'] != null) {
            finalRecognizedText = ocrResult['simpleText'] as String;
            debugPrint("OCR Plugin recognition result: $finalRecognizedText");
          } else {
            debugPrint("OCR Plugin failed to recognize text or returned incorrect format.");
          }
        } catch (e) {
          debugPrint('OCR Plugin exception: $e');
        }
      } else {
        finalRecognizedText = 'OCR Plugin does not support Web platform.';
        debugPrint(finalRecognizedText);
      }

      final l10n = AppLocalizations.of(context)!;
      // After OCR, navigate to EditorPage with the recognized text and image path
      if (finalRecognizedText.isNotEmpty && finalRecognizedText != l10n.ocrWebNotSupported) {
        await _navigateToEditorPage(recognizedText: finalRecognizedText, imagePath: imagePath);
      } else {
        // If no text recognized or web platform, still allow manual input, potentially with image
        await _navigateToEditorPage(imagePath: imagePath);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.errorProcessingImage)),
      );
      debugPrint('Error during scanned image processing: $e');
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
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.cameraImport),
                onTap: () {
                  Navigator.pop(context);
                  _scanDocument();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(l10n.galleryImport),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndProcessImage(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.manualInput),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cardManagement),
      ),
      body: _businessCards.isEmpty
          ? Center(
              child: Text(l10n.clickPlusToImport),
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
