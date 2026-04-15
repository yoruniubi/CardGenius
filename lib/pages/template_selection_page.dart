import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:antd_flutter_mobile/index.dart';
import 'package:business_card_ocr/models/template.dart';
import 'package:business_card_ocr/models/element.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';

class TemplateSelectionPage extends StatefulWidget {
  const TemplateSelectionPage({super.key});

  @override
  State<TemplateSelectionPage> createState() => _TemplateSelectionPageState();
}

class _TemplateSelectionPageState extends State<TemplateSelectionPage> {
  String _selectedBackgroundId = 'bg_asset_1';
  String _selectedLayoutId = 'layout_left';
  String? _customBackgroundPath;

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

  Future<void> _pickCustomBackground() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _customBackgroundPath = result.files.single.path;
        _selectedBackgroundId = 'bg_custom';
      });
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
          TextElement(
            x: 102,
            y: 24,
            content: l10n.name,
            tag: 'name',
            fontSize: 24,
            isBold: true,
            color: primaryTextColor,
          ),
          TextElement(
            x: 92,
            y: 54,
            content: l10n.jobTitle,
            tag: 'title',
            fontSize: 13,
            color: secondaryTextColor,
          ),
          TextElement(
            x: 86,
            y: 76,
            content: l10n.company,
            tag: 'company',
            fontSize: 15,
            isBold: true,
            color: primaryTextColor,
          ),

          IconElement(
            tag: 'phone_icon',
            icon: Icons.phone_outlined,
            x: 54,
            y: 112,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 76,
            y: 110,
            content: '123-4567-8901',
            tag: 'phone',
            fontSize: 12,
            color: secondaryTextColor,
          ),

          IconElement(
            tag: 'email_icon',
            icon: Icons.email_outlined,
            x: 54,
            y: 132,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 76,
            y: 130,
            content: 'example@mail.com',
            tag: 'email',
            fontSize: 12,
            color: secondaryTextColor,
          ),

          IconElement(
            tag: 'website_icon',
            icon: Icons.language_outlined,
            x: 54,
            y: 152,
            size: 15,
            color: helperTextColor,
          ),
          TextElement(
            x: 76,
            y: 150,
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

          // 右侧图片区占位
          ImageElement(
            x: 220,
            y: 28,
            imageUrl: 'assets/avatar_placeholder.png',
            width: 76,
            height: 76,
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
        ];
    }
  }

  void _applyTemplate() {
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
      onTap: () {
        setState(() {
          _selectedBackgroundId = option.id;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF1677FF) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          color: Colors.white,
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

  Widget _buildLayoutItem(_LayoutOption option) {
    final bool selected = _selectedLayoutId == option.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLayoutId = option.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF1677FF) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFEAF2FF)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.id == 'layout_left'
                    ? Icons.view_agenda_outlined
                    : option.id == 'layout_center'
                        ? Icons.align_horizontal_center_outlined
                        : Icons.dashboard_outlined,
                color: selected
                    ? const Color(0xFF1677FF)
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedBackgroundId == 'bg_custom'
                          ? const Color(0xFF1677FF)
                          : const Color(0xFFE5E7EB),
                      width: _selectedBackgroundId == 'bg_custom' ? 2 : 1,
                    ),
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