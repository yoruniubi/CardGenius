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
  String _selectedLayoutId = 'layout_classic';
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
      id: 'bg_asset_4',
      name:'图片背景 4',
      assetPath: 'assets/4.png',
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
    _BackgroundOption(
      id: 'bg_color_gray', 
      name: '浅灰色',
      color: const Color(0xFFE5E7EB)
    )
  ];

  final List<_LayoutOption> _layoutOptions = const [
    _LayoutOption(
      id: 'layout_classic',
      name: '经典商务型',
      description: '左上主信息，右上头像，下方纵向展示联系方式',
    ),
    _LayoutOption(
      id: 'layout_center',
      name: '居中简约型',
      description: '以中轴线排版，适合简洁个人名片展示',
    ),
    _LayoutOption(
      id: 'layout_bottom_bar',
      name: '底栏信息型',
      description: '上方展示身份信息，下方横向集中展示联系方式',
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
        final bool layoutExists = _layoutOptions.any((e) => e.id == savedLayout);
        _selectedLayoutId = layoutExists ? savedLayout : 'layout_classic';
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
    const double cardWidth = 320;
    // const double cardHeight = 200;

    const double left = 22;
    const double right = 22;
    const double top = 22;
    // const double bottom = 18;

    const double avatarClassicSize = 60;
    // const double avatarProfileSize = 78;
    const double avatarCenterSize = 56;
    const double avatarBottomBarSize = 54;

    const double iconSize = 15;
    const double iconGap = 8;
    const double lineGap = 20;

    final primaryTextColor =
        useLightText ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor =
        useLightText ? const Color(0xFFE5E7EB) : const Color(0xFF4B5563);
    final helperTextColor =
        useLightText ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280);
    final accentTextColor =
        useLightText ? const Color(0xFFDBEAFE) : const Color(0xFF1677FF);

    double centerTextX(double estimatedWidth) => (cardWidth - estimatedWidth) / 2;
    double rightAvatarX(double size) => cardWidth - right - size;

    List<CardElement> contactColumn({
      required double startX,
      required double startY,
      bool includeAddress = false,
      bool includeWebsite = true,
    }) {
      final double contactY = startY - 6;

      final elements = <CardElement>[
        IconElement(
          tag: 'phone_icon',
          icon: Icons.phone_outlined,
          x: startX,
          y: contactY,
          size: iconSize,
          color: helperTextColor,
        ),
        TextElement(
          tag: 'phone',
          content: '123-4567-8901',
          x: startX + iconSize + iconGap,
          y: contactY - 2,
          fontSize: 12,
          color: secondaryTextColor,
        ),
        IconElement(
          tag: 'email_icon',
          icon: Icons.email_outlined,
          x: startX,
          y: contactY + lineGap,
          size: iconSize,
          color: helperTextColor,
        ),
        TextElement(
          tag: 'email',
          content: 'example@mail.com',
          x: startX + iconSize + iconGap,
          y: contactY + lineGap - 2,
          fontSize: 12,
          color: secondaryTextColor,
        ),
      ];

      if (includeAddress) {
        elements.addAll([
          IconElement(
            tag: 'address_icon',
            icon: Icons.location_on_outlined,
            x: startX,
            y: contactY + lineGap * 2,
            size: iconSize,
            color: helperTextColor,
          ),
          TextElement(
            tag: 'address',
            content: '示例详细地址',
            x: startX + iconSize + iconGap,
            y: contactY + lineGap * 2 - 2,
            fontSize: 11,
            color: helperTextColor,
          ),
          IconElement(
            tag: 'website_icon',
            icon: Icons.language_outlined,
            x: startX,
            y: contactY + lineGap * 3,
            size: iconSize,
            color: helperTextColor,
          ),
          TextElement(
            tag: 'website',
            content: 'www.example.com',
            x: startX + iconSize + iconGap,
            y: contactY + lineGap * 3 - 2,
            fontSize: 11,
            color: accentTextColor,
          ),
        ]);
      } else if (includeWebsite) {
        elements.addAll([
          IconElement(
            tag: 'website_icon',
            icon: Icons.language_outlined,
            x: startX,
            y: contactY + lineGap * 2,
            size: iconSize,
            color: helperTextColor,
          ),
          TextElement(
            tag: 'website',
            content: 'www.example.com',
            x: startX + iconSize + iconGap,
            y: contactY + lineGap * 2 - 2,
            fontSize: 11,
            color: accentTextColor,
          ),
        ]);
      }

      return elements;
    }

    switch (layoutId) {
      case 'layout_center':
        const double contactX = 94;

        return [
          ImageElement(
            tag: 'avatar',
            x: (cardWidth - avatarCenterSize) / 2,
            y: 14,
            imageUrl: '',
            width: avatarCenterSize,
            height: avatarCenterSize,
          ),
          TextElement(
            tag: 'name',
            content: l10n.name,
            x: centerTextX(80),
            y: 72,
            fontSize: 22,
            isBold: true,
            color: primaryTextColor,
          ),
          TextElement(
            tag: 'title',
            content: l10n.jobTitle,
            x: centerTextX(84),
            y: 106,
            fontSize: 13,
            color: secondaryTextColor,
          ),
          TextElement(
            tag: 'company',
            content: l10n.company,
            x: centerTextX(106),
            y: 130,
            fontSize: 15,
            isBold: true,
            color: primaryTextColor,
          ),
          IconElement(
            tag: 'phone_icon',
            icon: Icons.phone_outlined,
            x: contactX,
            y: 156,
            size: iconSize,
            color: helperTextColor,
          ),
          TextElement(
            tag: 'phone',
            content: '123-4567-8901',
            x: contactX + iconSize + iconGap,
            y: 155,
            fontSize: 12,
            color: secondaryTextColor,
          ),
        ];

      case 'layout_bottom_bar':
        return [
          TextElement(
            tag: 'name',
            content: l10n.name,
            x: left,
            y: 28,
            fontSize: 24,
            isBold: true,
            color: primaryTextColor,
          ),
          TextElement(
            tag: 'title',
            content: l10n.jobTitle,
            x: left,
            y: 58,
            fontSize: 13,
            color: secondaryTextColor,
          ),
          TextElement(
            tag: 'company',
            content: l10n.company,
            x: left,
            y: 80,
            fontSize: 16,
            isBold: true,
            color: primaryTextColor,
          ),
          ImageElement(
            tag: 'avatar',
            x: rightAvatarX(avatarBottomBarSize),
            y: 24,
            imageUrl: '',
            width: avatarBottomBarSize,
            height: avatarBottomBarSize,
          ),
          IconElement(
            tag: 'phone_icon',
            icon: Icons.phone_outlined,
            x: 24,
            y: 125,
            size: 14,
            color: helperTextColor,
          ),
          TextElement(
            tag: 'phone',
            content: '123-4567-8901',
            x: 44,
            y: 125,
            fontSize: 11,
            color: secondaryTextColor,
          ),
          IconElement(
            tag: 'email_icon',
            icon: Icons.email_outlined,
            x: 140,
            y: 125,
            size: 14,
            color: helperTextColor,
          ),
          TextElement(
            tag: 'email',
            content: 'example@mail.com',
            x: 160,
            y: 125,
            fontSize: 11,
            color: secondaryTextColor,
          ),
          IconElement(
            tag: 'website_icon',
            icon: Icons.language_outlined,
            x: 24,
            y: 152,
            size: 14,
            color: helperTextColor,
          ),
          TextElement(
            tag: 'website',
            content: 'www.example.com',
            x: 44,
            y: 152,
            fontSize: 11,
            color: accentTextColor,
          ),
          IconElement(
            tag: 'address_icon',
            icon: Icons.location_on_outlined,
            x: 140,
            y: 152,
            size: 14,
            color: helperTextColor,
          ),
          TextElement(
            tag: 'address',
            content: '示例详细地址',
            x: 160,
            y: 152,
            fontSize: 11,
            color: secondaryTextColor,
          ),
        ];

      case 'layout_classic':
      default:
        return [
          TextElement(
            tag: 'name',
            content: l10n.name,
            x: left,
            y: top,
            fontSize: 24,
            isBold: true,
            color: primaryTextColor,
          ),
          TextElement(
            tag: 'title',
            content: l10n.jobTitle,
            x: left,
            y: top + 32,
            fontSize: 13,
            color: secondaryTextColor,
          ),
          TextElement(
            tag: 'company',
            content: l10n.company,
            x: left,
            y: top + 54,
            fontSize: 16,
            isBold: true,
            color: primaryTextColor,
          ),
          ...contactColumn(
            startX: left,
            startY: 108,
            includeAddress: true,
          ),
          ImageElement(
            tag: 'avatar',
            x: rightAvatarX(avatarClassicSize),
            y: top + 2,
            imageUrl: '',
            width: avatarClassicSize,
            height: avatarClassicSize,
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
          if (option.id == 'layout_classic') ...[
            Positioned(
              left: 8,
              top: 8,
              child: Container(width: 24, height: 5, color: const Color(0xFF111827)),
            ),
            Positioned(
              left: 8,
              top: 18,
              child: Container(width: 18, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              left: 8,
              top: 27,
              child: Container(width: 20, height: 4, color: const Color(0xFF111827)),
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
              bottom: 16,
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
              bottom: 17,
              child: Container(width: 28, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              left: 8,
              bottom: 7,
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
              child: Container(width: 34, height: 4, color: const Color(0xFF6B7280)),
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
              left: 29,
              top: 27,
              child: Container(width: 34, height: 5, color: const Color(0xFF111827)),
            ),
            Positioned(
              left: 33,
              top: 36,
              child: Container(width: 26, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              left: 31,
              top: 44,
              child: Container(width: 30, height: 4, color: const Color(0xFF111827)),
            ),
            // Positioned(
            //   left: 29,
            //   bottom: 10,
            //   child: Container(
            //     width: 6,
            //     height: 6,
            //     decoration: const BoxDecoration(
            //       color: Color(0xFF9CA3AF),
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),
            // Positioned(
            //   left: 39,
            //   bottom: 11,
            //   child: Container(width: 25, height: 4, color: const Color(0xFF6B7280)),
            // ),
          ],
          if (option.id == 'layout_bottom_bar') ...[
            Positioned(
              left: 8,
              top: 8,
              child: Container(width: 24, height: 5, color: const Color(0xFF111827)),
            ),
            Positioned(
              left: 8,
              top: 18,
              child: Container(width: 18, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              left: 8,
              top: 27,
              child: Container(width: 20, height: 4, color: const Color(0xFF111827)),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            Positioned(
              left: 8,
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
              left: 18,
              bottom: 11,
              child: Container(width: 22, height: 4, color: const Color(0xFF6B7280)),
            ),
            Positioned(
              left: 48,
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
              left: 58,
              bottom: 11,
              child: Container(width: 20, height: 4, color: const Color(0xFF6B7280)),
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
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: _customBackgroundPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_customBackgroundPath!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: Color(0xFF1677FF),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: Text(
                          _customBackgroundPath == null ? '上传背景' : '已选自定义背景',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
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