import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_plugin/ocr_plugin.dart';
import 'package:ocr_plugin/ocr_plugin_platform_interface.dart';
import 'package:ocr_plugin/ocr_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockOcrPluginPlatform
    with MockPlatformInterfaceMixin
    implements OcrPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final OcrPluginPlatform initialPlatform = OcrPluginPlatform.instance;

  test('$MethodChannelOcrPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelOcrPlugin>());
  });

  test('getPlatformVersion', () async {
    OcrPlugin ocrPlugin = OcrPlugin();
    MockOcrPluginPlatform fakePlatform = MockOcrPluginPlatform();
    OcrPluginPlatform.instance = fakePlatform;

    expect(await ocrPlugin.getPlatformVersion(), '42');
  });
}
