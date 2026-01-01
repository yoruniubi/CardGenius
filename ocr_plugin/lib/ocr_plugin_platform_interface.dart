import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ocr_plugin_method_channel.dart';

abstract class OcrPluginPlatform extends PlatformInterface {
  /// Constructs a OcrPluginPlatform.
  OcrPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static OcrPluginPlatform _instance = MethodChannelOcrPlugin();

  /// The default instance of [OcrPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelOcrPlugin].
  static OcrPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [OcrPluginPlatform] when
  /// they register themselves.
  static set instance(OcrPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
