import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:business_card_ocr/models/business_card.dart';
import 'package:business_card_ocr/models/template.dart';
import 'package:business_card_ocr/models/element.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';
import 'package:antd_flutter_mobile/index.dart';

class CardEditorPage extends StatefulWidget {
  const CardEditorPage({
    super.key,
    this.card,
    this.template,
  });

  final BusinessCard? card;
  final BusinessCardTemplate? template;

  static Future<BusinessCard?> open(
    BuildContext context, {
    BusinessCard? card,
    BusinessCardTemplate? template,
  }) {
    return Navigator.push<BusinessCard>(
      context,
      MaterialPageRoute(
        builder: (context) => CardEditorPage(
          card: card,
          template: template,
        ),
      ),
    );
  }

  @override
  State<CardEditorPage> createState() => _CardEditorPageState();
}

class _CardEditorPageState extends State<CardEditorPage> {
  late BusinessCard _editingCard;

  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _notesController;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  bool _showPhone = true;
  bool _showEmail = true;
  bool _showAddress = true;
  bool _showWebsite = true;
  bool _showImage = false;

  List<CardElement> _previewElements = [];
  BusinessCardTemplate? _currentTemplate;

  @override
  void initState() {
    super.initState();

    _editingCard = widget.card ?? BusinessCard(name: '');
    _currentTemplate = widget.template;

    _nameController = TextEditingController(text: _editingCard.name);
    _titleController = TextEditingController(text: _editingCard.title ?? '');
    _companyController = TextEditingController(text: _editingCard.company ?? '');
    _phoneController = TextEditingController(text: _editingCard.phone ?? '');
    _emailController = TextEditingController(text: _editingCard.email ?? '');
    _addressController = TextEditingController(text: _editingCard.address ?? '');
    _websiteController = TextEditingController(text: _editingCard.website ?? '');
    _notesController = TextEditingController(text: _editingCard.notes ?? '');
    
    _showPhone = _editingCard.showPhone;
    _showEmail = _editingCard.showEmail;
    _showAddress = _editingCard.showAddress;
    _showWebsite = _editingCard.showWebsite;
    _showImage = _editingCard.showImage;
    
    if ((_editingCard.imagePath ?? '').isNotEmpty) {
      _pickedImage = XFile(_editingCard.imagePath!);
    }

    _rebuildPreviewElements();

    _nameController.addListener(_updatePreview);
    _titleController.addListener(_updatePreview);
    _companyController.addListener(_updatePreview);
    _phoneController.addListener(_updatePreview);
    _emailController.addListener(_updatePreview);
    _addressController.addListener(_updatePreview);
    _websiteController.addListener(_updatePreview);
    _notesController.addListener(_updatePreview);
    _updatePreview();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<CardElement> _cloneElements(List<CardElement> source) {
    return source.map((e) => CardElement.fromJson(e.toJson())).toList();
  }

  List<CardElement> _buildDefaultElements() {
    return [
      TextElement(
        content: '',
        tag: 'name',
        x: 22,
        y: 20,
        fontSize: 24,
        isBold: true,
        color: Colors.black,
      ),
      TextElement(
        content: '',
        tag: 'title',
        x: 22,
        y: 52,
        fontSize: 13,
        color: Colors.black87,
      ),
      TextElement(
        content: '',
        tag: 'company',
        x: 22,
        y: 74,
        fontSize: 16,
        isBold: true,
        color: Colors.black,
      ),
      IconElement(
        tag: 'phone_icon',
        icon: Icons.phone_outlined,
        x: 22,
        y: 108,
        size: 15,
        color: const Color(0xFF6B7280),
      ),
      TextElement(
        content: '',
        tag: 'phone',
        x: 44,
        y: 106,
        fontSize: 12,
        color: Colors.black87,
      ),
      IconElement(
        tag: 'email_icon',
        icon: Icons.email_outlined,
        x: 22,
        y: 128,
        size: 15,
        color: const Color(0xFF6B7280),
      ),
      TextElement(
        content: '',
        tag: 'email',
        x: 44,
        y: 126,
        fontSize: 12,
        color: Colors.black87,
      ),
      IconElement(
        tag: 'address_icon',
        icon: Icons.location_on_outlined,
        x: 22,
        y: 148,
        size: 15,
        color: const Color(0xFF6B7280),
      ),
      TextElement(
        content: '',
        tag: 'address',
        x: 44,
        y: 146,
        fontSize: 11,
        color: const Color(0xFF6B7280),
      ),
      IconElement(
        tag: 'website_icon',
        icon: Icons.language_outlined,
        x: 22,
        y: 168,
        size: 15,
        color: const Color(0xFF6B7280),
      ),
      TextElement(
        content: '',
        tag: 'website',
        x: 44,
        y: 166,
        fontSize: 11,
        color: const Color(0xFF1677FF),
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
  void _rebuildPreviewElements() {
    final templateElements = _currentTemplate?.elements;
    if (templateElements == null || templateElements.isEmpty) {
      _previewElements = _cloneElements(_buildDefaultElements());
    } else {
      _previewElements = _cloneElements(templateElements);
    }
  }
  void _updatePreview() {
    if (!mounted) return;

    setState(() {
      for (final element in _previewElements) {
        if (element is TextElement && element.tag != null) {
          switch (element.tag) {
            case 'name':
              element.content = _nameController.text.trim();
              break;
            case 'title':
              element.content = _titleController.text.trim();
              break;
            case 'company':
              element.content = _companyController.text.trim();
              break;
            case 'phone':
              element.content = _showPhone ? _phoneController.text.trim() : '';
              break;
            case 'email':
              element.content = _showEmail ? _emailController.text.trim() : '';
              break;
            case 'address':
              element.content = _showAddress ? _addressController.text.trim() : '';
              break;
            case 'website':
              element.content = _showWebsite ? _websiteController.text.trim() : '';
              break;
            // case 'notes':
            //   element.content = _notesController.text.trim();
            //   break;
          }
        }
      }

      final isCenterLayout = _currentTemplate?.id.contains('layout_center') ?? false;
      if (isCenterLayout) {
        IconElement? phoneIcon;
        TextElement? phoneText;
        IconElement? emailIcon;
        TextElement? emailText;

        for (final element in _previewElements) {
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

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _pickedImage = image;
      _showImage = true;
    });
    _updatePreview();
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.nameCannotBeEmpty),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _editingCard.name = _nameController.text.trim();
    _editingCard.title =
        _titleController.text.trim().isEmpty ? null : _titleController.text.trim();
    _editingCard.company =
        _companyController.text.trim().isEmpty ? null : _companyController.text.trim();
    _editingCard.phone =
        _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    _editingCard.email =
        _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
    _editingCard.address =
        _addressController.text.trim().isEmpty ? null : _addressController.text.trim();
    _editingCard.website =
        _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim();
    _editingCard.notes =
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    _editingCard.imagePath = _pickedImage?.path;

    _editingCard.showPhone = _showPhone;
    _editingCard.showEmail = _showEmail;
    _editingCard.showAddress = _showAddress;
    _editingCard.showWebsite = _showWebsite;
    _editingCard.showImage = _showImage;

    Navigator.pop(context, _editingCard);
  }

  Widget _buildPreviewCard() {
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

    return AspectRatio(
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
          children: _previewElements.map((element) {
            String _textByTag(String tag) {
              for (final e in _previewElements) {
                if (e is TextElement && e.tag == tag) {
                  return e.content.trim();
                }
              }
              return '';
            }
            if (element is TextElement) {
              if (element.content.isEmpty) {
                return const SizedBox.shrink();
              }

              return Positioned(
                left: element.x,
                top: element.y,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Text(
                    element.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: element.fontSize,
                      fontFamily: element.fontFamily,
                      color: element.color,
                      fontWeight:
                          element.isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle:
                          element.isItalic ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              );
            }

            if (element is IconElement) {
              final shouldHide = switch (element.tag) {
                'phone_icon' => !_showPhone || _textByTag('phone').isEmpty,
                'email_icon' => !_showEmail || _textByTag('email').isEmpty,
                'address_icon' => !_showAddress || _textByTag('address').isEmpty,
                'website_icon' => !_showWebsite || _textByTag('website').isEmpty,
                _ => false,
              };

              if (shouldHide) {
                return const SizedBox.shrink();
              }

              return Positioned(
                left: element.x,
                top: element.y,
                child: Icon(
                  element.icon,
                  size: element.size,
                  color: element.color,
                ),
              );
            }

            if (element is ImageElement) {
                if (element.tag == 'avatar') {
                    if (!_showImage || _pickedImage == null) {
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
                        File(_pickedImage!.path),
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
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: 1,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: const Color(0xFF9CA3AF),
                    size: 20,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1677FF)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1677FF),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(l10n.editDigitalCard),
        centerTitle: false,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: AntdButton(
            block: true,
            onTap: _save,
            child: Text(l10n.saveAndReturn),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SectionLabel(title: l10n.realtimePreview),
          const SizedBox(height: 8),
          _buildPreviewCard(),

          const SizedBox(height: 24),
          _SectionLabel(title: l10n.avatar),
          const SizedBox(height: 8),
          _Panel(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: _pickedImage != null
                      ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                      : const Icon(
                          Icons.account_circle_outlined,
                          size: 34,
                          color: Color(0xFF9CA3AF),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.avatarUploadHint,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AntdButton(
                  fill: AntdButtonFill.outline,
                  onTap: _pickImage,
                  child: Text(l10n.upload),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabel(title: l10n.basicInfo),
          const SizedBox(height: 8),
          _Panel(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInputField(
                  label: l10n.name,
                  hint: l10n.pleaseEnterName,
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: l10n.jobTitle,
                  hint: l10n.pleaseEnterTitle,
                  controller: _titleController,
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: l10n.company,
                  hint: l10n.pleaseEnterCompany,
                  controller: _companyController,
                  icon: Icons.apartment_outlined,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: l10n.notes,
                  hint: l10n.pleaseEnterNotes,
                  controller: _notesController,
                  maxLines: 3,
                  icon: Icons.sticky_note_2_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabel(title: l10n.contactInfo),
          const SizedBox(height: 8),
          _Panel(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInputField(
                  label: l10n.phone,
                  hint: l10n.pleaseEnterPhone,
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: l10n.email,
                  hint: l10n.pleaseEnterEmail,
                  controller: _emailController,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: l10n.website,
                  hint: l10n.pleaseEnterWebsite,
                  controller: _websiteController,
                  icon: Icons.language_outlined,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: l10n.address,
                  hint: l10n.pleaseEnterAddress,
                  controller: _addressController,
                  maxLines: 2,
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabel(title: l10n.displayContent),
          const SizedBox(height: 8),
          _Panel(
            child: Column(
              children: [
                _buildSwitchTile(
                  title: l10n.showPhone,
                  value: _showPhone,
                  onChanged: (value) {
                    setState(() => _showPhone = value);
                    _updatePreview();
                  },
                  icon: Icons.phone_outlined,
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: l10n.showEmail,
                  value: _showEmail,
                  onChanged: (value) {
                    setState(() => _showEmail = value);
                    _updatePreview();
                  },
                  icon: Icons.email_outlined,
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: l10n.showAddress,
                  value: _showAddress,
                  onChanged: (value) {
                    setState(() => _showAddress = value);
                    _updatePreview();
                  },
                  icon: Icons.location_on_outlined,
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: l10n.showWebsite,
                  value: _showWebsite,
                  onChanged: (value) {
                    setState(() => _showWebsite = value);
                    _updatePreview();
                  },
                  icon: Icons.language_outlined,
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: l10n.showAvatar,
                  value: _showImage,
                  onChanged: (value) {
                    setState(() => _showImage = value);
                    _updatePreview();
                  },
                  icon: Icons.account_circle_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final EdgeInsets padding;

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
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}