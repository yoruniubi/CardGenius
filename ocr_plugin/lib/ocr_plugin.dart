import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class OcrPlugin {
  static const MethodChannel _channel = MethodChannel('ocr_plugin_channel');

  Future<bool?> init({
    String? modelPath,
    String? labelPath,
    int? cpuThreadNum,
    String? cpuPowerMode,
    double? scoreThreshold,
    int? detLongSize,
    String? detModelFilename,
    String? recModelFilename,
    String? clsModelFilename,
    bool? isRunDet,
    bool? isRunCls,
    bool? isRunRec,
    bool? isUseOpencl,
    bool? isDrwwTextPositionBox,
  }) async {
    try {
      final bool? result = await _channel.invokeMethod('init', {
        'modelPath': modelPath,
        'labelPath': labelPath,
        'cpuThreadNum': cpuThreadNum,
        'cpuPowerMode': cpuPowerMode,
        'scoreThreshold': scoreThreshold,
        'detLongSize': detLongSize,
        'detModelFilename': detModelFilename,
        'recModelFilename': recModelFilename,
        'clsModelFilename': clsModelFilename,
        'isRunDet': isRunDet,
        'isRunCls': isRunCls,
        'isRunRec': isRunRec,
        'isUseOpencl': isUseOpencl,
        'isDrwwTextPositionBox': isDrwwTextPositionBox,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to initialize OCR plugin: '${e.message}'.");
      return false;
    }
  }

  Future<Map<dynamic, dynamic>?> recognizeText(String imagePath) async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod('recognizeText', {
        'imagePath': imagePath,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to recognize text: '${e.message}'."); // Changed print to debugPrint
      return null;
    }
  }

  Future<bool?> release() async {
    try {
      final bool? result = await _channel.invokeMethod('release');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to release OCR plugin: '${e.message}'."); // Changed print to debugPrint
      return false;
    }
  }

  Future<String?> getPlatformVersion() async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
