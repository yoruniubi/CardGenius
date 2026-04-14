import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:business_card_ocr/models/element.dart';
import 'package:business_card_ocr/pages/template_selection_page.dart';
import 'package:business_card_ocr/models/template.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:business_card_ocr/main.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  BusinessCardTemplate? _currentTemplate;
  List<CardElement> _cardElements = [];
  final ScreenshotController _screenshotController = ScreenshotController();

  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _titleController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _companyController = TextEditingController();
    _titleController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _websiteController = TextEditingController();
    _notesController = TextEditingController();

    _nameController.addListener(_updatePreview);
    _companyController.addListener(_updatePreview);
    _titleController.addListener(_updatePreview);
    _phoneController.addListener(_updatePreview);
    _emailController.addListener(_updatePreview);
    _addressController.addListener(_updatePreview);
    _websiteController.addListener(_updatePreview);

    _cardElements = _buildDefaultElements();
    _loadSavedCard();
  }

  List<CardElement> _buildDefaultElements() {
    return [
      TextElement(
        content: '',
        tag: 'name',
        x: 24,
        y: 22,
        fontSize: 24,
        isBold: true,
        color: Colors.black,
      ),
      TextElement(
        content: '',
        tag: 'title',
        x: 24,
        y: 54,
        fontSize: 13,
        color: Colors.black87,
      ),
      TextElement(
        content: '',
        tag: 'company',
        x: 24,
        y: 76,
        fontSize: 16,
        isBold: true,
        color: Colors.black,
      ),
      TextElement(
        content: '',
        tag: 'phone',
        x: 52,
        y: 108,
        fontSize: 12,
        color: Colors.black87,
      ),
      TextElement(
        content: '',
        tag: 'email',
        x: 52,
        y: 128,
        fontSize: 12,
        color: Colors.black87,
      ),
      TextElement(
        content: '',
        tag: 'address',
        x: 52,
        y: 148,
        fontSize: 11,
        color: Colors.black54,
      ),
      TextElement(
        content: '',
        tag: 'website',
        x: 52,
        y: 168,
        fontSize: 11,
        color: const Color(0xFF1677FF),
      ),
      IconElement(
        tag: 'phone_icon',
        icon: Icons.phone_outlined,
        x: 24,
        y: 106,
        size: 16,
        color: const Color(0xFF6B7280),
      ),
      IconElement(
        tag: 'email_icon',
        icon: Icons.email_outlined,
        x: 24,
        y: 126,
        size: 16,
        color: const Color(0xFF6B7280),
      ),
      IconElement(
        tag: 'address_icon',
        icon: Icons.location_on_outlined,
        x: 24,
        y: 146,
        size: 16,
        color: const Color(0xFF6B7280),
      ),
      IconElement(
        tag: 'website_icon',
        icon: Icons.language_outlined,
        x: 24,
        y: 166,
        size: 16,
        color: const Color(0xFF6B7280),
      ),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _titleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    setState(() {
      for (final element in _cardElements) {
        if (element is TextElement && element.tag != null) {
          switch (element.tag) {
            case 'name':
              element.content = _nameController.text;
              break;
            case 'title':
              element.content = _titleController.text;
              break;
            case 'company':
              element.content = _companyController.text;
              break;
            case 'phone':
              element.content = _phoneController.text;
              break;
            case 'email':
              element.content = _emailController.text;
              break;
            case 'address':
              element.content = _addressController.text;
              break;
            case 'website':
              element.content = _websiteController.text;
              break;
          }
        }
      }
    });
  }

  void _loadTemplate(BusinessCardTemplate template) {
    setState(() {
      _currentTemplate = template;
      final oldTexts = <String, String>{
        'name': _nameController.text,
        'title': _titleController.text,
        'company': _companyController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'website': _websiteController.text,
      };

      _cardElements = List.from(template.elements);

      final hasPhoneIcon = _cardElements.any((e) => e is IconElement && e.tag == 'phone_icon');
      if (!hasPhoneIcon) {
        _cardElements.addAll([
          IconElement(
            tag: 'phone_icon',
            icon: Icons.phone_outlined,
            x: 24,
            y: 106,
            size: 16,
            color: const Color(0xFF6B7280),
          ),
          IconElement(
            tag: 'email_icon',
            icon: Icons.email_outlined,
            x: 24,
            y: 126,
            size: 16,
            color: const Color(0xFF6B7280),
          ),
          IconElement(
            tag: 'address_icon',
            icon: Icons.location_on_outlined,
            x: 24,
            y: 146,
            size: 16,
            color: const Color(0xFF6B7280),
          ),
          IconElement(
            tag: 'website_icon',
            icon: Icons.language_outlined,
            x: 24,
            y: 166,
            size: 16,
            color: const Color(0xFF6B7280),
          ),
        ]);
      }

      for (final element in _cardElements) {
        if (element is TextElement && element.tag != null) {
          element.content = oldTexts[element.tag] ?? '';
        }
      }
    });
  }

  Future<void> _loadSavedCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardJson = prefs.getString('my_business_card');
      if (cardJson == null) return;

      final Map<String, dynamic> data = json.decode(cardJson);

      setState(() {
        _nameController.text = data['name'] ?? '';
        _companyController.text = data['company'] ?? '';
        _titleController.text = data['title'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _emailController.text = data['email'] ?? '';
        _addressController.text = data['address'] ?? '';
        _websiteController.text = data['website'] ?? '';
        _notesController.text = data['notes'] ?? '';

        if (data['template_id'] != null) {
          _currentTemplate = BusinessCardTemplate(
            id: data['template_id'] as String,
            name: data['template_name'] ?? '已保存模板',
            previewImagePath: data['template_preview_path'] as String?,
            elements: [],
          );
        }

        if (data['elements'] != null) {
          final elementsList = data['elements'] as List;
          _cardElements = elementsList
              .map((e) => CardElement.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        final hasPhoneIcon = _cardElements.any((e) => e is IconElement && e.tag == 'phone_icon');
        if (!hasPhoneIcon) {
          _cardElements.addAll([
            IconElement(
              tag: 'phone_icon',
              icon: Icons.phone_outlined,
              x: 24,
              y: 106,
              size: 16,
              color: const Color(0xFF6B7280),
            ),
            IconElement(
              tag: 'email_icon',
              icon: Icons.email_outlined,
              x: 24,
              y: 126,
              size: 16,
              color: const Color(0xFF6B7280),
            ),
            IconElement(
              tag: 'address_icon',
              icon: Icons.location_on_outlined,
              x: 24,
              y: 146,
              size: 16,
              color: const Color(0xFF6B7280),
            ),
            IconElement(
              tag: 'website_icon',
              icon: Icons.language_outlined,
              x: 24,
              y: 166,
              size: 16,
              color: const Color(0xFF6B7280),
            ),
          ]);
        }

        _updatePreview();
      });
    } catch (e) {
      debugPrint('加载保存的名片失败: $e');
    }
  }

  Future<void> _exportAsJpg() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final Uint8List? imageBytes = await _screenshotController.capture();
      if (imageBytes == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = p.join(
        directory.path,
        'business_card_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(imagePath)], text: l10n.shareMyCard);
    } catch (e) {
      debugPrint('导出失败: $e');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.exportFailed(e.toString()))),
      );
    }
  }

  String _generateVCard() {
    return 'BEGIN:VCARD'
        'VERSION:3.0'
        'FN:${_nameController.text}'
        'ORG:${_companyController.text}'
        'TITLE:${_titleController.text}'
        'TEL;TYPE=CELL:${_phoneController.text}'
        'EMAIL:${_emailController.text}'
        'ADR;TYPE=WORK:;;${_addressController.text};;;;'
        'END:VCARD';
  }

  void _shareViaQrCode() {
    final l10n = AppLocalizations.of(context)!;
    final vCardData = _generateVCard();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scanToSaveContact),
        content: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: QrImageView(
              data: vCardData,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _templateSetting() async {
    final selectedTemplate = await Navigator.push<BusinessCardTemplate>(
      context,
      MaterialPageRoute(builder: (context) => const TemplateSelectionPage()),
    );

    if (selectedTemplate != null) {
      _loadTemplate(selectedTemplate);
    }
  }

  void _goToEditPage() {
    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('下一步这里接入独立编辑页'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildCardPreviewWidget() {
    DecorationImage? decorationImage;
    if (_currentTemplate?.previewImagePath != null) {
      final path = _currentTemplate!.previewImagePath!;
      if (path.startsWith('assets/')) {
        decorationImage = DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        );
      } else {
        decorationImage = DecorationImage(
          image: FileImage(File(path)),
          fit: BoxFit.cover,
        );
      }
    }

    return Screenshot(
      controller: _screenshotController,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
            image: decorationImage,
          ),
          child: Stack(
            children: _cardElements.map((element) {
              if (element is TextElement) {
                if (element.content.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  left: element.x,
                  top: element.y,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(
                      element.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: element.fontSize,
                        fontFamily: element.fontFamily,
                        color: element.color,
                        fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                );
              } else if (element is IconElement) {
                final shouldHide = switch (element.tag) {
                  'phone_icon' => _phoneController.text.trim().isEmpty,
                  'email_icon' => _emailController.text.trim().isEmpty,
                  'address_icon' => _addressController.text.trim().isEmpty,
                  'website_icon' => _websiteController.text.trim().isEmpty,
                  _ => false,
                };
                if (shouldHide) return const SizedBox.shrink();

                return Positioned(
                  left: element.x,
                  top: element.y,
                  child: Icon(
                    element.icon,
                    size: element.size,
                    color: element.color,
                  ),
                );
              } else if (element is ImageElement) {
                return Positioned(
                  left: element.x,
                  top: element.y,
                  child: Image.asset(
                    element.imageUrl,
                    width: element.width,
                    height: element.height,
                    fit: BoxFit.contain,
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF1677FF), size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.credit_card_outlined, size: 34, color: Color(0xFF9CA3AF)),
          SizedBox(height: 10),
          Text(
            '先完善你的电子名片信息',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6),
          Text(
            '后续可在编辑页中添加头像、调整展示字段，并选择不同模板与背景风格。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasBasicCardInfo {
    return _nameController.text.trim().isNotEmpty ||
        _companyController.text.trim().isNotEmpty ||
        _titleController.text.trim().isNotEmpty ||
        _phoneController.text.trim().isNotEmpty ||
        _emailController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的电子名片',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '用于展示、分享和管理你的数字名片形象。',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          _hasBasicCardInfo ? _buildCardPreviewWidget() : _buildEmptyHint(),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildActionItem(
                icon: Icons.palette_outlined,
                label: l10n.template,
                onTap: _templateSetting,
              ),
              const SizedBox(width: 10),
              _buildActionItem(
                icon: Icons.share_outlined,
                label: l10n.share,
                onTap: _shareViaQrCode,
              ),
              const SizedBox(width: 10),
              _buildActionItem(
                icon: Icons.edit_outlined,
                label: '编辑',
                onTap: _goToEditPage,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '模板负责控制背景与排版。编辑页将负责头像、展示字段和个性化内容设置。',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _exportAsJpg,
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.export),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1677FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return ColoredBox(
        color: const Color(0xFFF5F6F8),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        centerTitle: false,
        title: Text(l10n.myCards),
      ),
      body: content,
    );
  }
}

// class IconElement extends CardElement {
//   IconElement({
//     required this.icon,
//     required this.size,
//     required this.color,
//     super.tag,
//     required super.x,
//     required super.y,
//   });

//   final IconData icon;
//   final double size;
//   final Color color;

//   @override
//   Map<String, dynamic> toJson() => {
//         'type': 'icon',
//         'tag': tag,
//         'x': x,
//         'y': y,
//         'iconCodePoint': icon.codePoint,
//         'iconFontFamily': icon.fontFamily,
//         'size': size,
//         'color': color.value,
//       };
// }