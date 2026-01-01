import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ocr_plugin_platform_interface.dart';

/// An implementation of [OcrPluginPlatform] that uses method channels.
class MethodChannelOcrPlugin extends OcrPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ocr_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
