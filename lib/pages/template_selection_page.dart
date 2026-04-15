import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:antd_flutter_mobile/index.dart';
import 'package:business_card_ocr/models/template.dart';
import 'package:business_card_ocr/models/element.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemplateSelectionPage extends StatefulWidget {
  const TemplateSelectionPage({super.key});

  @override
  State<TemplateSelectionPage> createState() => _TemplateSelectionPageState();
}

class _TemplateSelectionPageState extends State<TemplateSelectionPage> {
  String _selectedBackgroundId = 'bg_asset_1';
  String _selectedLayoutId = 'layout_left';
  String? _customBackgroundPath;

  static const String _bgKey = 'template_selected_background_id';
  static const String _layoutKey = 'template_selected_layout_id';
  static const String _customBgKey = 'template_custom_background_path';

  final List<_BackgroundOption> _backgroundOptions = [
    _BackgroundOption(
      id: 'bg_asset_1',
      name: '图片背景 1',
      assetPath: 'assets/1.png',
    ),
    _BackgroundOption(
      id: 'bg_asset_2',
      name: '图片背景 2',
      assetPath: 'assets/2.png',
    ),
    _BackgroundOption(
      id: 'bg_asset_3',
      name: '图片背景 3',
      assetPath: 'assets/3.png',
    ),
    _BackgroundOption(
      id: 'bg_color_blue',
      name: '纯色蓝',
      color: const Color(0xFF1677FF),
    ),
    _BackgroundOption(
      id: 'bg_color_dark',
      name: '深色灰',
      color: const Color(0xFF111827),
    ),
    _BackgroundOption(
      id: 'bg_color_green',
      name: '浅绿色',
      color: const Color(0xFFD1FAE5),
    ),
  ];

  final List<_LayoutOption> _layoutOptions = const [
    _LayoutOption(
      id: 'layout_left',
      name: '左上信息型',
      description: '左上突出姓名和公司，下方展示联系方式',
    ),
    _LayoutOption(
      id: 'layout_center',
      name: '居中简洁型',
      description: '整体信息居中，更适合简约名片',
    ),
    _LayoutOption(
      id: 'layout_split',
      name: '左文右图型',
      description: '左侧展示信息，右侧预留头像/图片区',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _restoreSelection();
  }

  Future<void> _restoreSelection() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBg = prefs.getString(_bgKey);
    final savedLayout = prefs.getString(_layoutKey);
    final savedCustomBg = prefs.getString(_customBgKey);

    if (!mounted) return;

    setState(() {
      if (savedBg != null && savedBg.isNotEmpty) {
        _selectedBackgroundId = savedBg;
      }
      if (savedLayout != null && savedLayout.isNotEmpty) {
        _selectedLayoutId = savedLayout;
      }
      if (savedCustomBg != null && savedCustomBg.isNotEmpty) {
        _customBackgroundPath = savedCustomBg;
      }
    });
  }

  Future<void> _pickCustomBackground() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;

      setState(() {
        _customBackgroundPath = path;
        _selectedBackgroundId = 'bg_custom';
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_customBgKey, path);
      await prefs.setString(_bgKey, 'bg_custom');
    }
  }

  List<CardElement> _buildLayout(
    AppLocalizations l10n,
    String layoutId,
    bool useLightText,
  ) {
    final primaryTextColor = useLightText ? Colors.white : Colors.black;
    final secondaryTextColor =
        useLightText ? const Color(0xFFE5E7EB) : Colors.black87;
    final helperTextColor =
        useLightText ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280);
    final accentTextColor =
        useLightText ? const Color(0xFFBFDBFE) : const Color(0xFF1677FF);

    switch (layoutId) {
      case 'layout_center':
        return [
          ImageElement(
            tag: 'avatar',
            x: 122,
            y: 16,
            imageUrl: '',
            width: 52,
            height: 52,
          ),
          TextElement(
            x: 108,
            y: 74,
            content: l10n.name,
            tag: 'name',
            fontSize: 22,
            isBold: true,
            color: primaryTextColor,
          ),
          TextElement(
            x: 96,
            y: 102,
            content: l10n.jobTitle,
            tag: 'title',
            fontSize: 13,
            color: secondaryTextColor,
          ),
          TextElement(
            x: 92,
            y: 122,
            content: l10n.company,
            tag: 'company',
            fontSize: 15,
            isBold: true,
            color: primaryTextColor,
          ),
          IconElement(
            tag: 'phone_icon',
            icon: Icons.phone_outlined,
            x: 52,
            y: 150,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 74,
            y: 148,
            content: '123-4567-8901',
            tag: 'phone',
            fontSize: 12,
            color: secondaryTextColor,
          ),
          IconElement(
            tag: 'email_icon',
            icon: Icons.email_outlined,
            x: 52,
            y: 170,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 74,
            y: 168,
            content: 'example@mail.com',
            tag: 'email',
            fontSize: 12,
            color: secondaryTextColor,
          ),
          IconElement(
            tag: 'website_icon',
            icon: Icons.language_outlined,
            x: 52,
            y: 190,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 74,
            y: 188,
            content: 'www.example.com',
            tag: 'website',
            fontSize: 11,
            color: accentTextColor,
          ),
        ];

      case 'layout_split':
        return [
          TextElement(
            x: 20,
            y: 22,
            content: l10n.name,
            tag: 'name',
            fontSize: 22,
            isBold: true,
            color: primaryTextColor,
          ),
          TextElement(
            x: 20,
            y: 50,
            content: l10n.jobTitle,
            tag: 'title',
            fontSize: 13,
            color: secondaryTextColor,
          ),
          TextElement(
            x: 20,
            y: 72,
            content: l10n.company,
            tag: 'company',
            fontSize: 15,
            isBold: true,
            color: primaryTextColor,
          ),
          IconElement(
            tag: 'phone_icon',
            icon: Icons.phone_outlined,
            x: 20,
            y: 116,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 42,
            y: 114,
            content: '123-4567-8901',
            tag: 'phone',
            fontSize: 12,
            color: secondaryTextColor,
          ),
          IconElement(
            tag: 'email_icon',
            icon: Icons.email_outlined,
            x: 20,
            y: 136,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 42,
            y: 134,
            content: 'example@mail.com',
            tag: 'email',
            fontSize: 12,
            color: secondaryTextColor,
          ),
          IconElement(
            tag: 'website_icon',
            icon: Icons.language_outlined,
            x: 20,
            y: 156,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 42,
            y: 154,
            content: 'www.example.com',
            tag: 'website',
            fontSize: 11,
            color: accentTextColor,
          ),
          ImageElement(
            tag: 'avatar',
            x: 214,
            y: 26,
            imageUrl: '',
            width: 82,
            height: 82,
          ),
        ];

      case 'layout_left':
      default:
        return [
          TextElement(
            x: 22,
            y: 20,
            content: l10n.name,
            tag: 'name',
            fontSize: 24,
            isBold: true,
            color: primaryTextColor,
          ),
          TextElement(
            x: 22,
            y: 52,
            content: l10n.jobTitle,
            tag: 'title',
            fontSize: 13,
            color: secondaryTextColor,
          ),
          TextElement(
            x: 22,
            y: 74,
            content: l10n.company,
            tag: 'company',
            fontSize: 16,
            isBold: true,
            color: primaryTextColor,
          ),
          IconElement(
            tag: 'phone_icon',
            icon: Icons.phone_outlined,
            x: 22,
            y: 108,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 44,
            y: 106,
            content: '123-4567-8901',
            tag: 'phone',
            fontSize: 12,
            color: secondaryTextColor,
          ),
          IconElement(
            tag: 'email_icon',
            icon: Icons.email_outlined,
            x: 22,
            y: 128,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 44,
            y: 126,
            content: 'example@mail.com',
            tag: 'email',
            fontSize: 12,
            color: secondaryTextColor,
          ),
          IconElement(
            tag: 'address_icon',
            icon: Icons.location_on_outlined,
            x: 22,
            y: 148,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 44,
            y: 146,
            content: '示例详细地址',
            tag: 'address',
            fontSize: 11,
            color: helperTextColor,
          ),
          IconElement(
            tag: 'website_icon',
            icon: Icons.language_outlined,
            x: 22,
            y: 168,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 44,
            y: 166,
            content: 'www.example.com',
            tag: 'website',
            fontSize: 11,
            color: accentTextColor,
          ),
          ImageElement(
            tag: 'avatar',
            x: 218,
            y: 20,
            imageUrl: '',
            width: 66,
            height: 66,
          ),
        ];
    }
  }

  Future<void> _applyTemplate() async {
    final l10n = AppLocalizations.of(context)!;

    final selectedBg = _selectedBackgroundId == 'bg_custom'
        ? _BackgroundOption(
            id: 'bg_custom',
            name: '自定义背景',
            filePath: _customBackgroundPath,
          )
        : _backgroundOptions.firstWhere((e) => e.id == _selectedBackgroundId);

    final bool useLightText =
        selectedBg.color != null &&
            selectedBg.color!.computeLuminance() < 0.4;

    final template = BusinessCardTemplate(
      id: '${selectedBg.id}_${_selectedLayoutId}',
      name:
          '${selectedBg.name} · ${_layoutOptions.firstWhere((e) => e.id == _selectedLayoutId).name}',
      previewImagePath: selectedBg.filePath ?? selectedBg.assetPath,
      backgroundColorValue: selectedBg.color?.value,
      elements: _buildLayout(l10n, _selectedLayoutId, useLightText),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bgKey, _selectedBackgroundId);
    await prefs.setString(_layoutKey, _selectedLayoutId);
    if (_customBackgroundPath != null && _customBackgroundPath!.isNotEmpty) {
      await prefs.setString(_customBgKey, _customBackgroundPath!);
    }

    if (!mounted) return;
    Navigator.pop(context, template);
  }

  Widget _buildBackgroundPreview(_BackgroundOption option) {
    if (option.assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          option.assetPath!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    if (option.filePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(option.filePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: option.color ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildBackgroundItem(_BackgroundOption option) {
    final bool selected = _selectedBackgroundId == option.id;

    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedBackgroundId = option.id;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_bgKey, option.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF1677FF) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          color: Colors.white,
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x141677FF),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: _buildBackgroundPreview(option),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                option.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniLayoutPreview(_LayoutOption option, bool selected) {
    return Container(
      width: 92,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? const Color(0xFF1677FF) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Stack(
        children: [
          if (option.id == 'layout_left') ...[
            Positioned(
              left: 8,
              top: 8,
              child: Container(width: 26, height: 5, color: const Color(0xFF111827)),
            ),
            Positioned(
              left: 8,
              top: 18,
              child: Container(width: 20, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 18,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: Container(width: 32, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 8,
              child: Container(width: 38, height: 4, color: const Color(0xFF6B7280)),
            ),
          ],
          if (option.id == 'layout_center') ...[
            Positioned(
              left: 38,
              top: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Positioned(
              left: 28,
              top: 28,
              child: Container(width: 34, height: 5, color: const Color(0xFF111827)),
            ),
            Positioned(
              left: 32,
              top: 38,
              child: Container(width: 26, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              left: 18,
              bottom: 10,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 28,
              bottom: 11,
              child: Container(width: 42, height: 4, color: const Color(0xFF6B7280)),
            ),
          ],
          if (option.id == 'layout_split') ...[
            Positioned(
              left: 8,
              top: 8,
              child: Container(width: 22, height: 5, color: const Color(0xFF111827)),
            ),
            Positioned(
              left: 8,
              top: 18,
              child: Container(width: 18, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 18,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: Container(width: 26, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 8,
              child: Container(width: 30, height: 4, color: const Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLayoutItem(_LayoutOption option) {
    final bool selected = _selectedLayoutId == option.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: () async {
          setState(() {
            _selectedLayoutId = option.id;
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_layoutKey, option.id);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF4F8FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFF1677FF) : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x141677FF),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              _buildMiniLayoutPreview(option, selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF1677FF),
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          l10n.selectTemplate,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text(
            '第一步：选择背景',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '可选择图片背景、纯色背景，或上传你自己的背景图片。',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ..._backgroundOptions.map(_buildBackgroundItem),
              GestureDetector(
                onTap: _pickCustomBackground,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedBackgroundId == 'bg_custom'
                          ? const Color(0xFF1677FF)
                          : const Color(0xFFE5E7EB),
                      width: _selectedBackgroundId == 'bg_custom' ? 2 : 1,
                    ),
                    boxShadow: _selectedBackgroundId == 'bg_custom'
                        ? const [
                            BoxShadow(
                              color: Color(0x141677FF),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : const [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Color(0xFF1677FF),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _customBackgroundPath == null ? '上传背景' : '已选自定义背景',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            '第二步：选择布局',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '布局决定姓名、公司与联系方式的排布方式。',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ..._layoutOptions.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLayoutItem(e),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: AntdButton(
            onTap: _applyTemplate,
            child: const Text('应用样式'),
          ),
        ),
      ),
    );
  }
}

class _BackgroundOption {
  const _BackgroundOption({
    required this.id,
    required this.name,
    this.assetPath,
    this.filePath,
    this.color,
  });

  final String id;
  final String name;
  final String? assetPath;
  final String? filePath;
  final Color? color;
}

class _LayoutOption {
  const _LayoutOption({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}