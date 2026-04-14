import 'package:flutter/material.dart';
import 'package:business_card_ocr/providers/locale_provider.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';
import 'package:business_card_ocr/services/ocr_service.dart';

class OcrTestPage extends StatelessWidget {
  const OcrTestPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final content = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Text(
          '应用设置',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '管理语言、识别引擎状态与应用版本信息。',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        _Panel(
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.language_outlined,
                title: l10n.languageSettings,
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: localeProvider.languageCode,
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text(l10n.followSystem),
                      ),
                      DropdownMenuItem(
                        value: 'zh',
                        child: Text(l10n.simplifiedChinese),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(l10n.english),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        localeProvider.setLanguage(value);
                      }
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              AnimatedBuilder(
                animation: OcrService.instance,
                builder: (context, _) {
                  final bool isOcrReady = OcrService.instance.isInitialized;
                  return _SettingTile(
                    icon: Icons.memory_outlined,
                    title: l10n.ocrEngineStatus,
                    trailing: _StatusBadge(
                      text: isOcrReady
                          ? '${l10n.ready} · PaddleOCR'
                          : 'Not Ready',
                      isReady: isOcrReady,
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              const _SettingTile(
                icon: Icons.info_outline,
                title: '软件版本',
                trailing: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!showAppBar) {
      return const ColoredBox(
        color: Color(0xFFF5F6F8),
        child: SafeArea(
          top: false,
          child: _SettingsBody(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: false,
      ),
      body: content,
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _Panel(
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.language_outlined,
                title: l10n.languageSettings,
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: localeProvider.languageCode,
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text(l10n.followSystem),
                      ),
                      DropdownMenuItem(
                        value: 'zh',
                        child: Text(l10n.simplifiedChinese),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(l10n.english),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        localeProvider.setLanguage(value);
                      }
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              AnimatedBuilder(
                animation: OcrService.instance,
                builder: (context, _) {
                  final bool isOcrReady = OcrService.instance.isInitialized;
                  return _SettingTile(
                    icon: Icons.memory_outlined,
                    title: l10n.ocrEngineStatus,
                    trailing: _StatusBadge(
                      text: isOcrReady
                          ? '${l10n.ready} · PaddleOCR'
                          : 'Not Ready',
                      isReady: isOcrReady,
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              const _SettingTile(
                icon: Icons.info_outline,
                title: '软件版本',
                trailing: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.trailing,
    required this.icon,
  });

  final String title;
  final Widget trailing;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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