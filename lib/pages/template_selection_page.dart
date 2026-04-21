import 'dart:io';
import 'dart:convert';
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
  List<BusinessCardTemplate> _savedCustomLayouts = [];
  String? _selectedCustomLayoutId;

  static const String _bgKey = 'template_selected_background_id';
  static const String _layoutKey = 'template_selected_layout_id';
  static const String _customBgKey = 'template_custom_background_path';
  static const String _customLayoutsKey = 'template_saved_custom_layouts';
  static const String _selectedCustomLayoutKey = 'template_selected_custom_layout_id';

  List<_BackgroundOption> _backgroundOptions(AppLocalizations l10n) {
    return [
      _BackgroundOption(
        id: 'bg_asset_1',
        name: l10n.imageBackground1,
        assetPath: 'assets/2.png',
      ),
      _BackgroundOption(
        id: 'bg_asset_2',
        name: l10n.imageBackground2,
        assetPath: 'assets/3.png',
      ),
      _BackgroundOption(
        id: 'bg_asset_3',
        name: l10n.imageBackground3,
        assetPath: 'assets/4.png',
      ),
      _BackgroundOption(
        id: 'bg_asset_4',
        name: l10n.imageBackground4,
        assetPath: 'assets/5.png',
      ),
      _BackgroundOption(
        id: 'bg_color_blue',
        name: l10n.solidBlue,
        color: const Color(0xFF1677FF),
      ),
      _BackgroundOption(
        id: 'bg_color_dark',
        name: l10n.darkGray,
        color: const Color(0xFF111827),
      ),
      _BackgroundOption(
        id: 'bg_color_green',
        name: l10n.lightGreen,
        color: const Color(0xFFD1FAE5),
      ),
      _BackgroundOption(
        id: 'bg_color_gray',
        name: l10n.lightGray,
        color: const Color(0xFFE5E7EB)
      )
    ];
  }

  List<_LayoutOption> _getLayoutOptions(AppLocalizations l10n) {
    return [
      _LayoutOption(
        id: 'layout_classic',
        name: l10n.layoutClassic,
        description: l10n.layoutClassicDesc,
      ),
      _LayoutOption(
        id: 'layout_center',
        name: l10n.layoutCenter,
        description: l10n.layoutCenterDesc,
      ),
      _LayoutOption(
        id: 'layout_bottom_bar',
        name: l10n.layoutBottomBar,
        description: l10n.layoutBottomBarDesc,
      ),
    ];
  }

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
    final savedCustomLayoutId = prefs.getString(_selectedCustomLayoutKey);
    final rawCustomLayouts = prefs.getString(_customLayoutsKey);

    List<BusinessCardTemplate> customLayouts = [];
    if (rawCustomLayouts != null && rawCustomLayouts.isNotEmpty) {
      try {
        final decoded = json.decode(rawCustomLayouts) as List<dynamic>;
        customLayouts = decoded
            .map((e) => BusinessCardTemplate.fromJson(e as Map<String, dynamic>))
            .where((e) => e.id.startsWith('layout_custom_'))
            .toList();
      } catch (_) {
        customLayouts = [];
      }
    }

    if (!mounted) return;

    setState(() {
      if (savedBg != null && savedBg.isNotEmpty) {
        _selectedBackgroundId = savedBg;
      }
      if (savedLayout != null && savedLayout.isNotEmpty) {
        const layoutIds = {
          'layout_classic',
          'layout_center',
          'layout_bottom_bar',
          'layout_custom',
        };
        final bool layoutExists = layoutIds.contains(savedLayout);
        _selectedLayoutId = layoutExists ? savedLayout : 'layout_classic';
      }
      if (savedCustomBg != null && savedCustomBg.isNotEmpty) {
        _customBackgroundPath = savedCustomBg;
      }

      _savedCustomLayouts = customLayouts;

      if (savedCustomLayoutId != null &&
          _savedCustomLayouts.any((e) => e.id == savedCustomLayoutId)) {
        _selectedCustomLayoutId = savedCustomLayoutId;
      } else {
        _selectedCustomLayoutId = _savedCustomLayouts.isNotEmpty
            ? _savedCustomLayouts.first.id
            : null;
      }

      if (_selectedLayoutId == 'layout_custom' && _selectedCustomLayoutId == null) {
        _selectedLayoutId = 'layout_classic';
      }
    });
  }

  Future<void> _saveCustomLayouts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _customLayoutsKey,
      json.encode(_savedCustomLayouts.map((e) => e.toJson()).toList()),
    );

    if (_selectedCustomLayoutId != null) {
      await prefs.setString(_selectedCustomLayoutKey, _selectedCustomLayoutId!);
    } else {
      await prefs.remove(_selectedCustomLayoutKey);
    }
  }

  Future<void> _createCustomLayout() async {
    final l10n = AppLocalizations.of(context)!;

    final selectedBg = _selectedBackgroundId == 'bg_custom'
        ? _BackgroundOption(
            id: 'bg_custom',
            name: l10n.customBackground,
            filePath: _customBackgroundPath,
          )
        : _backgroundOptions(l10n).firstWhere(
            (e) => e.id == _selectedBackgroundId,
            orElse: () => _backgroundOptions(l10n).first,
          );

    final bool useLightText =
        selectedBg.color != null && selectedBg.color!.computeLuminance() < 0.4;

    final baseLayoutId = (_selectedLayoutId != 'layout_custom')
        ? _selectedLayoutId
        : 'layout_classic';

    final created = BusinessCardTemplate(
      id: 'layout_custom_${DateTime.now().millisecondsSinceEpoch}',
      name: '${l10n.layoutCustom} ${_savedCustomLayouts.length + 1}',
      previewImagePath: selectedBg.filePath ?? selectedBg.assetPath,
      backgroundColorValue: selectedBg.color?.toARGB32(),
      elements: _buildLayout(l10n, baseLayoutId, useLightText),
    );

    setState(() {
      _savedCustomLayouts = [created, ..._savedCustomLayouts];
      _selectedLayoutId = 'layout_custom';
      _selectedCustomLayoutId = created.id;
    });

    await _saveCustomLayouts();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_layoutKey, _selectedLayoutId);
  }

  Future<void> _deleteCustomLayout(String id) async {
    setState(() {
      _savedCustomLayouts = _savedCustomLayouts.where((e) => e.id != id).toList();
      if (_selectedCustomLayoutId == id) {
        _selectedCustomLayoutId = _savedCustomLayouts.isNotEmpty
            ? _savedCustomLayouts.first.id
            : null;
      }
      if (_savedCustomLayouts.isEmpty && _selectedLayoutId == 'layout_custom') {
        _selectedLayoutId = 'layout_classic';
      }
    });

    await _saveCustomLayouts();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_layoutKey, _selectedLayoutId);
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
            content: l10n.sampleAddress,
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
            content: l10n.sampleAddress,
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

    final backgroundOptions = _backgroundOptions(l10n);
    final layoutOptions = _getLayoutOptions(l10n);

    final selectedBg = _selectedBackgroundId == 'bg_custom'
        ? _BackgroundOption(
            id: 'bg_custom',
            name: l10n.customBackground,
            filePath: _customBackgroundPath,
          )
        : backgroundOptions.firstWhere(
            (e) => e.id == _selectedBackgroundId,
            orElse: () => backgroundOptions.first,
          );

    final bool useLightText =
        selectedBg.color != null && selectedBg.color!.computeLuminance() < 0.4;

    List<CardElement> elements;
    String layoutName;
    String finalLayoutId;

    if (_selectedLayoutId == 'layout_custom' &&
        _selectedCustomLayoutId != null &&
        _savedCustomLayouts.isNotEmpty) {
      final custom = _savedCustomLayouts.firstWhere(
        (e) => e.id == _selectedCustomLayoutId,
        orElse: () => _savedCustomLayouts.first,
      );
      elements = custom.elements
          .map((e) => CardElement.fromJson(e.toJson()))
          .toList();
      layoutName = custom.name;
      finalLayoutId = custom.id;
    } else {
      elements = _buildLayout(l10n, _selectedLayoutId, useLightText);
      layoutName = layoutOptions
          .firstWhere((e) => e.id == _selectedLayoutId, orElse: () => layoutOptions.first)
          .name;
      finalLayoutId = _selectedLayoutId;
    }

    final template = BusinessCardTemplate(
      id: '${selectedBg.id}_$finalLayoutId',
      name: '${selectedBg.name} · $layoutName',
      previewImagePath: selectedBg.filePath ?? selectedBg.assetPath,
      backgroundColorValue: selectedBg.color?.toARGB32(),
      elements: elements,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bgKey, _selectedBackgroundId);
    await prefs.setString(_layoutKey, _selectedLayoutId);
    if (_selectedCustomLayoutId != null) {
      await prefs.setString(_selectedCustomLayoutKey, _selectedCustomLayoutId!);
    }
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

  Widget _buildCustomCreateCard(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _createCustomLayout,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 92,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFEAF2FF),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Center(
                child: Icon(Icons.add, color: Color(0xFF1677FF), size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.create,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.layoutCustomDesc,
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

  Widget _buildMiniCustomLayoutPreview(BusinessCardTemplate template, bool selected) {
    final borderColor = selected ? const Color(0xFF1677FF) : const Color(0xFFE5E7EB);
    final bgColor = template.backgroundColor ?? const Color(0xFFF9FAFB);

    final visibleElements = template.elements.take(14).toList();

    return Container(
      width: 92,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgColor,
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Stack(
          children: visibleElements.map((e) {
            final dx = (e.x / 320.0 * 92.0).clamp(2.0, 84.0);
            final dy = (e.y / 180.0 * 58.0).clamp(2.0, 52.0);

            if (e is TextElement) {
              return Positioned(
                left: dx,
                top: dy,
                child: Container(
                  width: 18,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }

            if (e is IconElement) {
              return Positioned(
                left: dx,
                top: dy,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }

            if (e is ImageElement) {
              return Positioned(
                left: dx,
                top: dy,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSavedCustomLayoutCard(
    AppLocalizations l10n,
    BusinessCardTemplate template,
  ) {
    final bool selected =
        _selectedLayoutId == 'layout_custom' && _selectedCustomLayoutId == template.id;

    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedLayoutId = 'layout_custom';
          _selectedCustomLayoutId = template.id;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_layoutKey, 'layout_custom');
        await prefs.setString(_selectedCustomLayoutKey, template.id);
      },
      child: Stack(
        children: [
          Container(
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
                _buildMiniCustomLayoutPreview(template, selected),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.layoutCustom,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
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
          ),
          Positioned(
            right: 6,
            top: 6,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _deleteCustomLayout(template.id),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backgroundOptions = _backgroundOptions(l10n);
    final layoutOptions = _getLayoutOptions(l10n);
 
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
          Text(
            l10n.stepOneSelectBackground,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.backgroundStepDescription,
            style: const TextStyle(
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
              ...backgroundOptions.map(_buildBackgroundItem),
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
                          _customBackgroundPath == null
                              ? l10n.uploadBackground
                              : l10n.customBackgroundSelected,
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
          Text(
            l10n.stepTwoSelectLayout,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.layoutStepDescription,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...layoutOptions.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLayoutItem(e),
            );
          }),
          const SizedBox(height: 8),
          Text(
            l10n.layoutCustom,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          _buildCustomCreateCard(l10n),
          if (_savedCustomLayouts.isNotEmpty) const SizedBox(height: 12),
          ..._savedCustomLayouts.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSavedCustomLayoutCard(l10n, e),
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
            child: Text(l10n.applyStyle),
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
