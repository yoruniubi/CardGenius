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
import 'package:business_card_ocr/models/business_card.dart';
import 'package:business_card_ocr/pages/card_editor_page.dart';
import 'package:business_card_ocr/services/share_link_service.dart';
import 'package:antd_flutter_mobile/index.dart';

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

  bool _showPhone = true;
  bool _showEmail = true;
  bool _showAddress = true;
  bool _showWebsite = true;
  bool _showImage = false;
  String? _editingImagePath;

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
    if (!mounted) return;

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
              element.content = _showPhone ? _phoneController.text : '';
              break;
            case 'email':
              element.content = _showEmail ? _emailController.text : '';
              break;
            case 'address':
              element.content = _showAddress ? _addressController.text : '';
              break;
            case 'website':
              element.content = _showWebsite ? _websiteController.text : '';
              break;
          }
        }
      }

      final isCenterLayout = _currentTemplate?.id.contains('layout_center') ?? false;
      if (isCenterLayout) {
        IconElement? phoneIcon;
        TextElement? phoneText;
        IconElement? emailIcon;
        TextElement? emailText;

        for (final element in _cardElements) {
          if (element is IconElement && element.tag == 'phone_icon') phoneIcon = element;
          if (element is TextElement && element.tag == 'phone') phoneText = element;
          if (element is IconElement && element.tag == 'email_icon') emailIcon = element;
          if (element is TextElement && element.tag == 'email') emailText = element;
        }

        if (phoneIcon != null && phoneText != null && emailIcon != null && emailText != null) {
          const double slot1IconY = 132;
          const double slot1TextY = 130;
          const double slot2IconY = 150;
          const double slot2TextY = 148;

          final bool phoneVisible = _showPhone && phoneText.content.trim().isNotEmpty;
          final bool emailVisible = _showEmail && emailText.content.trim().isNotEmpty;

          if (phoneVisible && emailVisible) {
            phoneIcon.y = slot1IconY;
            phoneText.y = slot1TextY;
            emailIcon.y = slot2IconY;
            emailText.y = slot2TextY;
          } else if (phoneVisible && !emailVisible) {
            phoneIcon.y = slot1IconY;
            phoneText.y = slot1TextY;
            emailIcon.y = slot2IconY;
            emailText.y = slot2TextY;
          } else if (!phoneVisible && emailVisible) {
            emailIcon.y = slot1IconY;
            emailText.y = slot1TextY;
            phoneIcon.y = slot2IconY;
            phoneText.y = slot2TextY;
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

      final hasPhoneIcon =
          _cardElements.any((e) => e is IconElement && e.tag == 'phone_icon');
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
    _updatePreview();
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
        _editingImagePath = data['imagePath'] as String?;
        _showPhone = data['showPhone'] as bool? ?? true;
        _showEmail = data['showEmail'] as bool? ?? true;
        _showAddress = data['showAddress'] as bool? ?? true;
        _showWebsite = data['showWebsite'] as bool? ?? true;
        _showImage = data['showImage'] as bool? ?? false;

        if (data['elements'] != null) {
          final elementsList = data['elements'] as List;
          _cardElements = elementsList
              .map((e) => CardElement.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        if (data['template_id'] != null) {
          _currentTemplate = BusinessCardTemplate(
            id: data['template_id'] as String,
            name: data['template_name'] ?? AppLocalizations.of(context)!.savedTemplate,
            previewImagePath: data['template_preview_path'] as String?,
            backgroundColorValue: data['template_background_color_value'] as int?,
            elements: _cardElements.map((e) => CardElement.fromJson(e.toJson())).toList(),
          );
        }

        final hasPhoneIcon =
            _cardElements.any((e) => e is IconElement && e.tag == 'phone_icon');
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

  BusinessCard _buildCurrentCard() {
    return BusinessCard(
      name: _nameController.text.trim(),
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      company: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      notes:
          _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      imagePath: _editingImagePath,
      showPhone: _showPhone,
      showEmail: _showEmail,
      showAddress: _showAddress,
      showWebsite: _showWebsite,
      showImage: _showImage,
    );
  }

  void _shareCard() {
    if (!_hasBasicCardInfo) {
      final l10n = AppLocalizations.of(context)!;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.completeDigitalCardInfoFirst)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.shareCardTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 16),
                _buildShareOptionItem(
                  icon: Icons.qr_code_2_outlined,
                  title: AppLocalizations.of(context)!.qrShare,
                  subtitle: AppLocalizations.of(context)!.qrShareDescription,
                  onTap: () {
                    Navigator.pop(context);
                    _showQrShareDialog();
                  },
                ),
                _buildShareOptionItem(
                  icon: Icons.text_snippet_outlined,
                  title: AppLocalizations.of(context)!.textShare,
                  subtitle: AppLocalizations.of(context)!.textShareDescription,
                  onTap: () {
                    Navigator.pop(context);
                    _shareAsText();
                  },
                ),
                _buildShareOptionItem(
                  icon: Icons.image_outlined,
                  title: AppLocalizations.of(context)!.imageShare,
                  subtitle: AppLocalizations.of(context)!.imageShareDescription,
                  onTap: () {
                    Navigator.pop(context);
                    _exportAsJpg();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQrShareDialog() {
    final card = _buildCurrentCard();
    final link = ShareLinkService.buildLink(card);

    final l10n = AppLocalizations.of(context)!;

    AntdModal.show(
      title: Text(l10n.qrShare),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: link,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.scanToImportDirectly,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      actions: [
        AntdModalAction(
          title: Text(l10n.close),
          onTap: (close) async {
            await close();
          },
        ),
      ],
    );
  }

  void _shareAsText() {
    final l10n = AppLocalizations.of(context)!;
    final card = _buildCurrentCard();
    final lines = <String>[
      if (card.name.trim().isNotEmpty) '${l10n.name}: ${card.name.trim()}',
      if ((card.title ?? '').trim().isNotEmpty) '${l10n.jobTitle}: ${card.title!.trim()}',
      if ((card.company ?? '').trim().isNotEmpty) '${l10n.company}: ${card.company!.trim()}',
      if ((card.phone ?? '').trim().isNotEmpty) '${l10n.phone}: ${card.phone!.trim()}',
      if ((card.email ?? '').trim().isNotEmpty) '${l10n.email}: ${card.email!.trim()}',
      if ((card.website ?? '').trim().isNotEmpty) '${l10n.website}: ${card.website!.trim()}',
    ];

    Share.share(lines.join('\n'));
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

  Future<void> _goToEditPage() async {
    final currentCard = _buildCurrentCard();

    final result = await CardEditorPage.open(
      context,
      card: currentCard,
      template: _currentTemplate,
    );

    if (result == null) return;

    setState(() {
      _nameController.text = result.name;
      _titleController.text = result.title ?? '';
      _companyController.text = result.company ?? '';
      _phoneController.text = result.phone ?? '';
      _emailController.text = result.email ?? '';
      _addressController.text = result.address ?? '';
      _websiteController.text = result.website ?? '';
      _notesController.text = result.notes ?? '';
      _showPhone = result.showPhone;
      _showEmail = result.showEmail;
      _showAddress = result.showAddress;
      _showWebsite = result.showWebsite;
      _showImage = result.showImage;
      _editingImagePath = result.imagePath;
    });

    _updatePreview();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cardData = {
        'name': _nameController.text,
        'company': _companyController.text,
        'title': _titleController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'website': _websiteController.text,
        'notes': _notesController.text,
        'template_id': _currentTemplate?.id,
        'template_name': _currentTemplate?.name,
        'template_preview_path': _currentTemplate?.previewImagePath,
        'elements': _cardElements.map((e) => e.toJson()).toList(),
        'template_background_color_value': _currentTemplate?.backgroundColorValue,
        'showPhone': _showPhone,
        'showEmail': _showEmail,
        'showAddress': _showAddress,
        'showWebsite': _showWebsite,
        'showImage': _showImage,
        'imagePath': _editingImagePath,
      };
      await prefs.setString('my_business_card', json.encode(cardData));
    } catch (e) {
      debugPrint('保存编辑后的电子名片失败: $e');
    }
  }

  Widget _buildCardPreviewWidget() {
    DecorationImage? decorationImage;
    Color backgroundColor = Colors.white;

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
    } else if (_currentTemplate?.backgroundColor != null) {
      backgroundColor = _currentTemplate!.backgroundColor!;
    }

    return Screenshot(
      controller: _screenshotController,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor,
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
              String _textByTag(String tag) {
                for (final e in _cardElements) {
                  if (e is TextElement && e.tag == tag) {
                    return e.content.trim();
                  }
                }
                return '';
              }

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
                        fontWeight: element.isBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontStyle: element.isItalic
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                );
              } else if (element is IconElement) {
                final shouldHide = switch (element.tag) {
                  'phone_icon' => !_showPhone || _textByTag('phone').isEmpty,
                  'email_icon' => !_showEmail || _textByTag('email').isEmpty,
                  'address_icon' => !_showAddress || _textByTag('address').isEmpty,
                  'website_icon' => !_showWebsite || _textByTag('website').isEmpty,
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
                if (element.tag == 'avatar') {
                  if (!_showImage || (_editingImagePath ?? '').isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    left: element.x,
                    top: element.y,
                    child: Container(
                      width: element.width,
                      height: element.height,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0x14000000),
                          width: 1,
                        ),
                      ),
                      child: Image.file(
                        File(_editingImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }

                if (element.imageUrl.isEmpty) {
                  return const SizedBox.shrink();
                }

                if (element.imageUrl.startsWith('assets/')) {
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

                return Positioned(
                  left: element.x,
                  top: element.y,
                  child: Image.file(
                    File(element.imageUrl),
                    width: element.width,
                    height: element.height,
                    fit: BoxFit.cover,
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1677FF),
                  size: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
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

  Widget _buildShareOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF1677FF)),
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
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
      child: Column(
        children: [
          const Icon(Icons.credit_card_outlined,
              size: 34, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.completeDigitalCardInfoPrompt,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.completeDigitalCardInfoHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
          const SizedBox(height: 6),
          Text(
            l10n.cardManagementDescription,
            style: const TextStyle(
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
                onTap: _shareCard,
              ),
              const SizedBox(width: 10),
              _buildActionItem(
                icon: Icons.edit_outlined,
                label: l10n.edit,
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
                    l10n.templateEditShareHint,
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