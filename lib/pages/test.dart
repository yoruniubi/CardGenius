import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:ocr_plugin/ocr_plugin.dart';
import 'package:business_card_ocr/providers/locale_provider.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';
import 'package:business_card_ocr/services/ocr_service.dart';
import 'package:antd_flutter_mobile/index.dart';

class OcrTestPage extends StatefulWidget {
  const OcrTestPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<OcrTestPage> createState() => _OcrTestPageState();
}

class _OcrTestPageState extends State<OcrTestPage> {
  final ImagePicker _picker = ImagePicker();
  final OcrPlugin _ocrPlugin = OcrPlugin();

  bool _isProcessing = false;
  String _ocrResult = '';
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _initLocalOcrPlugin();
  }

  Future<void> _initLocalOcrPlugin() async {
    try {
      await _ocrPlugin.init(
        modelPath: "models/ch_PP-OCRv4",
        labelPath: "labels/ppocr_keys_v1.txt",
        cpuThreadNum: 4,
        cpuPowerMode: "LITE_POWER_HIGH",
      );
    } catch (e) {
      debugPrint('OCR plugin init error: $e');
    }
  }

  @override
  void dispose() {
    _ocrPlugin.release();
    super.dispose();
  }

  Future<void> _pickAndRecognize(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isProcessing = true;
        _ocrResult = '';
        _selectedImagePath = image.path;
      });

      if (kIsWeb) {
        setState(() {
          _ocrResult = 'OCR is not supported on web.';
          _isProcessing = false;
        });
        return;
      }

      final result = await _ocrPlugin.recognizeText(image.path);

      String text = '';
      if (result != null && result['simpleText'] != null) {
        text = result['simpleText'] as String;
      }

      setState(() {
        _ocrResult = text.trim().isEmpty ? 'No text recognized.' : text.trim();
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _ocrResult = 'Recognition failed: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final body = _SettingsBody(
      isProcessing: _isProcessing,
      ocrResult: _ocrResult,
      selectedImagePath: _selectedImagePath,
      onUploadImage: () => _pickAndRecognize(ImageSource.gallery),
      onTakePhoto: () => _pickAndRecognize(ImageSource.camera),
    );

    if (!widget.showAppBar) {
      return ColoredBox(
        color: const Color(0xFFF5F6F8),
        child: SafeArea(
          top: false,
          child: body,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          l10n.settings,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: body,
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.isProcessing,
    required this.ocrResult,
    required this.selectedImagePath,
    required this.onUploadImage,
    required this.onTakePhoto,
  });

  final bool isProcessing;
  final String ocrResult;
  final String? selectedImagePath;
  final VoidCallback onUploadImage;
  final VoidCallback onTakePhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const SizedBox(height: 18),
        _SettingsSection(
          title: l10n.general,
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.language_outlined,
                title: l10n.languageSettings,
                subtitle: _languageSubtitle(context),
                onTap: () => _showLanguagePicker(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SettingsSection(
          title: l10n.recognitionEngine,
          child: AnimatedBuilder(
            animation: OcrService.instance,
            builder: (context, _) {
              final bool isOcrReady = OcrService.instance.isInitialized;
              return Column(
                children: [
                  _SettingTile(
                    icon: Icons.memory_outlined,
                    title: l10n.ocrEngineStatus,
                    trailing: _StatusBadge(
                      text: isOcrReady
                          ? '${l10n.ready} · PaddleOCR'
                          : l10n.notReady,
                      isReady: isOcrReady,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        _SettingsSection(
          title: l10n.ocrToolbox,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AntdButton(
                        block: true,
                        onTap: isProcessing ? null : onUploadImage,
                        child: Text(l10n.uploadImage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AntdButton(
                        block: true,
                        fill: AntdButtonFill.outline,
                        onTap: isProcessing ? null : onTakePhoto,
                        child: Text(l10n.takePhoto),
                      ),
                    ),
                  ],
                ),
                if (selectedImagePath != null) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: Image.file(
                        File(selectedImagePath!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  l10n.result,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 120),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          ocrResult.isEmpty
                              ? l10n.ocrResultPlaceholder
                              : ocrResult,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF374151),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _SettingsSection(
          title: l10n.aboutAppSection,
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.info_outline,
                title: l10n.softwareVersion,
                subtitle: l10n.currentVersion,
                trailing: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.help_outline,
                title: l10n.aboutThisApp,
                subtitle: l10n.viewAppIntro,
                onTap: () => _showAboutModal(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _languageSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (localeProvider.languageCode) {
      case 'zh':
        return l10n.simplifiedChinese;
      case 'en':
        return l10n.english;
      default:
        return l10n.followSystem;
    }
  }

  static void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Widget item({
          required String title,
          required String value,
        }) {
          final selected = localeProvider.languageCode == value;

          return InkWell(
            onTap: () {
              localeProvider.setLanguage(value);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF1677FF),
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.languageSettings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                item(title: l10n.followSystem, value: 'system'),
                const Divider(height: 1),
                item(title: l10n.simplifiedChinese, value: 'zh'),
                const Divider(height: 1),
                item(title: l10n.english, value: 'en'),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showAboutModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.credit_card_outlined,
                  color: Color(0xFF1677FF),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.appIntroDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              AntdButton(
                block: true,
                onTap: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.gotIt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0F1F3)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    this.subtitle,
    required this.trailing,
    required this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget trailing;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: trailing,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 19,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.text,
    required this.isReady,
  });

  final String text;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isReady ? const Color(0xFFEAF7EE) : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isReady ? const Color(0xFF15803D) : const Color(0xFFB45309),
        ),
      ),
    );
  }
}