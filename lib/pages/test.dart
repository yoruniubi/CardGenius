import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_plugin/ocr_plugin.dart';
import 'package:business_card_ocr/main.dart';
import 'package:business_card_ocr/models/business_card.dart';
import 'package:business_card_ocr/providers/locale_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';

class OcrTestPage extends StatefulWidget {
  const OcrTestPage({super.key});

  @override
  State<OcrTestPage> createState() => _OcrTestPageState();
}

class _OcrTestPageState extends State<OcrTestPage> {
  final OcrPlugin _ocrPlugin = OcrPlugin();
  final ImagePicker _picker = ImagePicker();
  
  String _rawRecognizedText = '';
  String? _imagePath;
  bool _isProcessing = false;
  BusinessCard? _extractedCard;

  @override
  void initState() {
    super.initState();
    _initializeOcrPlugin();
  }

  Future<void> _initializeOcrPlugin() async {
    try {
      await _ocrPlugin.init(
        modelPath: "models/ch_PP-OCRv4",
        labelPath: "labels/ppocr_keys_v1.txt",
        cpuThreadNum: 4,
        cpuPowerMode: "LITE_POWER_HIGH",
      );
    } catch (e) {
      debugPrint('Error initializing OCR Plugin: $e');
    }
  }

  @override
  void dispose() {
    _ocrPlugin.release();
    super.dispose();
  }

  Future<void> _runOcrTool({required ImageSource source}) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _imagePath = image.path;
        _isProcessing = true;
        _rawRecognizedText = '';
        _extractedCard = null;
      });

      if (!kIsWeb) {
        final ocrResult = await _ocrPlugin.recognizeText(image.path);
        if (ocrResult != null && ocrResult['simpleText'] != null) {
          final text = ocrResult['simpleText'] as String;
          final card = await BusinessCard.fromOcrTextAsync(text, imagePath: image.path);
          
          setState(() {
            _rawRecognizedText = text;
            _extractedCard = card;
          });
        }
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.toolFailed(e.toString()))),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 设置板块 ---
            _buildSectionHeader(theme, l10n.basicSettings, LucideIcons.settings),
            const SizedBox(height: 12),
            ShadCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingRow(
                    theme,
                    label: l10n.languageSettings,
                    trailing: ShadSelect<String>(
                      placeholder: Text(l10n.languageSettings),
                      initialValue: localeProvider.languageCode,
                      options: [
                        ShadOption(value: 'system', child: Text(l10n.followSystem)),
                        ShadOption(value: 'zh', child: Text(l10n.simplifiedChinese)),
                        ShadOption(value: 'en', child: Text(l10n.english)),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          localeProvider.setLanguage(v);
                        }
                      },
                      selectedOptionBuilder: (context, value) {
                        switch (value) {
                          case 'zh':
                            return Text(l10n.simplifiedChinese);
                          case 'en':
                            return Text(l10n.english);
                          default:
                            return Text(l10n.followSystem);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- 工具箱板块 ---
            _buildSectionHeader(theme, l10n.smartToolbox, LucideIcons.box),
            const SizedBox(height: 12),
            
            // OCR 工具卡片
            ShadCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(LucideIcons.scanText, color: theme.colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.smartTextExtraction, style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold)),
                            Text(l10n.extractStructuredInfo, style: theme.textTheme.muted),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.secondary(
                          onPressed: _isProcessing ? null : () => _runOcrTool(source: ImageSource.gallery),
                          child: Text(l10n.selectImage),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadButton(
                          onPressed: _isProcessing ? null : () => _runOcrTool(source: ImageSource.camera),
                          child: Text(l10n.takePhoto),
                        ),
                      ),
                    ],
                  ),
                  
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (_extractedCard != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(l10n.extractionPreview, style: theme.textTheme.small.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildResultPreview(theme, l10n),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- 关于板块 ---
            _buildSectionHeader(theme, l10n.about, LucideIcons.info),
            const SizedBox(height: 12),
            ShadCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingRow(theme, label: l10n.softwareVersion, trailing: Text('v1.0.0', style: theme.textTheme.muted)),
                  const Divider(height: 32),
                  _buildSettingRow(theme, label: l10n.ocrEngineStatus, trailing: Text('${l10n.ready} (PaddleOCR)', style: theme.textTheme.muted.copyWith(color: Colors.green))),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ShadThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.mutedForeground),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.mutedForeground,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(ShadThemeData theme, {required String label, required Widget trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w500)),
        trailing,
      ],
    );
  }

  Widget _buildResultPreview(ShadThemeData theme, AppLocalizations l10n) {
    final card = _extractedCard!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewItem(l10n.name, card.name),
          if (card.company != null) _buildPreviewItem(l10n.company, card.company!),
          if (card.phone != null) _buildPreviewItem(l10n.phone, card.phone!),
          if (card.email != null) _buildPreviewItem(l10n.email, card.email!),
          if (card.address != null) _buildPreviewItem(l10n.address, card.address!),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
