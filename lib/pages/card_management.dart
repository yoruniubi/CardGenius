import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:business_card_ocr/models/element.dart';
import 'package:business_card_ocr/pages/template_selection_page.dart';
// import 'package:business_card_ocr/models/business_card.dart';
import 'package:business_card_ocr/models/template.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:business_card_ocr/main.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  BusinessCardTemplate? _currentTemplate;
  List<CardElement> _cardElements = [];
  final ScreenshotController _screenshotController = ScreenshotController();

  // final BusinessCard _editingCard = BusinessCard(
  //   name: '',
  //   title: '',
  //   company: '',
  //   phone: '',
  //   email: '',
  // );

  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _titleController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _notesController;

  bool _isLoading = false;

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

    _cardElements = [
      TextElement(content: '', tag: 'name', x: 25, y: 15, fontSize: 26, isBold: true, color: Colors.black),
      TextElement(content: '', tag: 'title', x: 25, y: 48, fontSize: 14, color: Colors.black87),
      TextElement(content: '', tag: 'company', x: 25, y: 70, fontSize: 18, isBold: true, color: Colors.black),
      TextElement(content: '', tag: 'phone', x: 25, y: 95, fontSize: 12, color: Colors.black54),
      TextElement(content: '', tag: 'email', x: 25, y: 112, fontSize: 12, color: Colors.black54),
      TextElement(content: '', tag: 'address', x: 25, y: 130, fontSize: 11, color: Colors.black45),
      TextElement(content: '', tag: 'website', x: 25, y: 148, fontSize: 11, color: Colors.blue.shade700),
    ];
    _loadSavedCard();
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
      for (var element in _cardElements) {
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
              element.content = _phoneController.text.isEmpty ? '' : '${l10n.phone}: ${_phoneController.text}';
              break;
            case 'email':
              element.content = _emailController.text.isEmpty ? '' : '${l10n.email}: ${_emailController.text}';
              break;
            case 'address':
              element.content = _addressController.text.isEmpty ? '' : '${l10n.address}: ${_addressController.text}';
              break;
            case 'website':
              element.content = _websiteController.text.isEmpty ? '' : '${l10n.website}: ${_websiteController.text}';
              break;
          }
        }
      }
    });
  }

  void _loadTemplate(BusinessCardTemplate template) {
    setState(() {
      _currentTemplate = template;
      _cardElements = List.from(template.elements);
      _updatePreview();
      debugPrint('Loaded template: ${_currentTemplate!.name}');
    });
  }

  Future<void> _clearCardData() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmClear),
        content: Text(l10n.clearConfirmContent),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirmClear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('my_business_card');

        setState(() {
          _nameController.clear();
          _companyController.clear();
          _titleController.clear();
          _phoneController.clear();
          _emailController.clear();
          _addressController.clear();
          _websiteController.clear();
          _notesController.clear();
          _currentTemplate = null;
          _cardElements = [
            TextElement(content: '', tag: 'name', x: 25, y: 15, fontSize: 26, isBold: true, color: Colors.black),
            TextElement(content: '', tag: 'title', x: 25, y: 48, fontSize: 14, color: Colors.black87),
            TextElement(content: '', tag: 'company', x: 25, y: 70, fontSize: 18, isBold: true, color: Colors.black),
            TextElement(content: '', tag: 'phone', x: 25, y: 95, fontSize: 12, color: Colors.black54),
            TextElement(content: '', tag: 'email', x: 25, y: 112, fontSize: 12, color: Colors.black54),
            TextElement(content: '', tag: 'address', x: 25, y: 130, fontSize: 11, color: Colors.black45),
            TextElement(content: '', tag: 'website', x: 25, y: 148, fontSize: 11, color: Colors.blue.shade700),
          ];
        });

        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(l10n.dataCleared)),
        );
      } catch (e) {
        debugPrint('清空失败: $e');
      }
    }
  }

  Future<void> _loadSavedCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardJson = prefs.getString('my_business_card');
      if (cardJson != null) {
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
            final templateId = data['template_id'] as String;
            final previewPath = data['template_preview_path'] as String?;

            _currentTemplate = BusinessCardTemplate(
              id: templateId,
              name: data['template_name'] ?? '已保存模板',
              previewImagePath: previewPath,
              elements: [],
            );
          }

          if (data['elements'] != null) {
            var elementsList = data['elements'] as List;
            _cardElements = elementsList
                .map((e) => CardElement.fromJson(e as Map<String, dynamic>))
                .toList();

            // Ensure website element exists
            bool hasWebsite = _cardElements.any((e) => e is TextElement && e.tag == 'website');
            if (!hasWebsite) {
              _cardElements.add(TextElement(content: '', tag: 'website', x: 25, y: 148, fontSize: 11, color: Colors.blue.shade700));
            }
          }

          _updatePreview();
        });
      }
    } catch (e) {
      debugPrint('加载保存的名片失败: $e');
    }
  }

  Future<void> _saveCardToLocal() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterNameBeforeSaving),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

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
      };

      final success = await prefs.setString('my_business_card', json.encode(cardData));

      if (success) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.cardSavedLocally),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('保存名片失败: $e');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.saveFailed(e.toString())), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetLayout() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _cardElements = [
        TextElement(content: '', tag: 'name', x: 25, y: 15, fontSize: 26, isBold: true, color: Colors.black),
        TextElement(content: '', tag: 'title', x: 25, y: 48, fontSize: 14, color: Colors.black87),
        TextElement(content: '', tag: 'company', x: 25, y: 70, fontSize: 18, isBold: true, color: Colors.black),
        TextElement(content: '', tag: 'phone', x: 25, y: 95, fontSize: 12, color: Colors.black54),
        TextElement(content: '', tag: 'email', x: 25, y: 112, fontSize: 12, color: Colors.black54),
        TextElement(content: '', tag: 'address', x: 25, y: 130, fontSize: 11, color: Colors.black45),
        TextElement(content: '', tag: 'website', x: 25, y: 148, fontSize: 11, color: Colors.blue.shade700),
      ];
      _updatePreview();
    });
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(l10n.layoutReset)),
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

  Future<void> _exportAsJpg() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final Uint8List? imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = p.join(directory.path, 'business_card_${DateTime.now().millisecondsSinceEpoch}.jpg');
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        await Share.shareXFiles([XFile(imagePath)], text: l10n.shareMyCard);
      }
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
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreviewWidget() {
    // final theme = ShadTheme.of(context);
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
      child: ShadCard(
        padding: const EdgeInsets.all(0),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              image: decorationImage,
            ),
            child: Stack(
              children: _cardElements.map((element) {
                if (element is TextElement) {
                  if (element.content.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    left: element.x,
                    top: element.y,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          element.x += details.delta.dx;
                          element.y += details.delta.dy;
                        });
                      },
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            element.content,
                            style: TextStyle(
                              fontSize: element.fontSize,
                              fontFamily: element.fontFamily,
                              color: element.color,
                              fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
                              fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (element is ImageElement) {
                  return Positioned(
                    left: element.x,
                    top: element.y,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          element.x += details.delta.dx;
                          element.y += details.delta.dy;
                        });
                      },
                      child: Image.asset(
                        element.imageUrl,
                        width: element.width,
                        height: element.height,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          ShadButton.ghost(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: _resetLayout,
            child: Row(
              children: [
                Icon(Icons.refresh_rounded, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(l10n.reset, style: TextStyle(color: theme.colorScheme.primary)),
              ],
            ),
          ),
          ShadButton.ghost(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: _templateSetting,
            child: Row(
              children: [
                Icon(Icons.palette_outlined, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(l10n.template, style: TextStyle(color: theme.colorScheme.primary)),
              ],
            ),
          ),
          ShadButton.ghost(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: _exportAsJpg,
            child: Row(
              children: [
                Icon(Icons.download_outlined, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(l10n.export, style: TextStyle(color: theme.colorScheme.primary)),
              ],
            ),
          ),
          ShadButton.ghost(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: _shareViaQrCode,
            child: Row(
              children: [
                Icon(Icons.qr_code_outlined, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(l10n.share, style: TextStyle(color: theme.colorScheme.primary)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCardPreviewWidget(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(l10n.basicInfo, style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildInputField(label: l10n.name, placeholder: l10n.pleaseEnterName, controller: _nameController),
                  const SizedBox(height: 12),
                  _buildInputField(label: l10n.company, placeholder: l10n.pleaseEnterCompany, controller: _companyController),
                  const SizedBox(height: 12),
                  _buildInputField(label: l10n.jobTitle, placeholder: l10n.pleaseEnterTitle, controller: _titleController),
                  const SizedBox(height: 12),
                  _buildInputField(label: l10n.phone, placeholder: l10n.pleaseEnterPhone, controller: _phoneController),
                  const SizedBox(height: 12),
                  _buildInputField(label: l10n.email, placeholder: l10n.pleaseEnterEmail, controller: _emailController),
                  const SizedBox(height: 12),
                  _buildInputField(label: l10n.website, placeholder: l10n.pleaseEnterWebsite, controller: _websiteController),
                  const SizedBox(height: 12),
                  _buildInputField(label: l10n.address, placeholder: l10n.pleaseEnterAddress, controller: _addressController, maxLines: 2),
                  const SizedBox(height: 12),
                  _buildInputField(label: l10n.notes, placeholder: l10n.pleaseEnterNotes, controller: _notesController, maxLines: 3),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                          onPressed: _clearCardData,
                          child: Text(l10n.clearData),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShadButton(
                          onPressed: _isLoading ? null : _saveCardToLocal,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(l10n.saveCard),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        ShadInput(
          controller: controller,
          placeholder: Text(placeholder),
          maxLines: maxLines,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ],
    );
  }
}
