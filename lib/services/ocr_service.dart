import 'package:flutter/foundation.dart';
import 'package:ocr_plugin/ocr_plugin.dart';

class OcrService extends ChangeNotifier {
  OcrService._();

  static final OcrService instance = OcrService._();

  final OcrPlugin _plugin = OcrPlugin();

  Future<bool>? _initFuture;
  bool _isInitialized = false;
  bool _isInitializing = false;

  bool get isInitialized => _isInitialized;

  Future<bool> ensureInitialized({bool retryOnFailure = true}) async {
    if (_isInitialized) return true;

    if (_initFuture != null) {
      return await _initFuture!;
    }

    _initFuture = _initialize();
    bool ok = await _initFuture!;

    if (!ok && retryOnFailure) {
      await Future.delayed(const Duration(milliseconds: 300));
      _initFuture = _initialize();
      ok = await _initFuture!;
    }

    return ok;
  }

  Future<bool> _initialize() async {
    if (_isInitializing) {
      return _initFuture ?? Future.value(_isInitialized);
    }

    _isInitializing = true;
    try {
      final bool? success = await _plugin.init(
        modelPath: 'models/ch_PP-OCRv4',
        labelPath: 'labels/ppocr_keys_v1.txt',
        cpuThreadNum: 4,
        cpuPowerMode: 'LITE_POWER_HIGH',
      );

      final newValue = success == true;
      if (_isInitialized != newValue) {
        _isInitialized = newValue;
        notifyListeners();
      } else {
        _isInitialized = newValue;
      }

      return _isInitialized;
    } catch (e) {
      if (_isInitialized != false) {
        _isInitialized = false;
        notifyListeners();
      } else {
        _isInitialized = false;
      }
      debugPrint('OCR init failed: $e');
      return false;
    } finally {
      _isInitializing = false;
      if (!_isInitialized) {
        _initFuture = null;
      }
    }
  }

  Future<dynamic> recognizeText(String imagePath) async {
    final ready = await ensureInitialized();
    if (!ready) return null;
    return _plugin.recognizeText(imagePath);
  }

  Future<void> release() async {
    _plugin.release();
    if (_isInitialized != false) {
      _isInitialized = false;
      notifyListeners();
    } else {
      _isInitialized = false;
    }
    _initFuture = null;
  }
}