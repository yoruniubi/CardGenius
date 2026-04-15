import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:business_card_ocr/models/business_card.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';
import 'package:antd_flutter_mobile/index.dart';

class EditorPage extends StatefulWidget {
  final BusinessCard? businessCard;
  final String? recognizedText;
  final String? imagePath;

  const EditorPage({
    super.key,
    this.businessCard,
    this.recognizedText,
    this.imagePath,
  });

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late BusinessCard _editingCard;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isInitializing = true;

  // 展示内容开关
  bool _showPhone = true;
  bool _showEmail = true;
  bool _showAddress = true;
  bool _showWebsite = true;
  bool _showImage = false;

  @override
  void initState() {
    super.initState();
    _initializeCardData();
  }

  Future<void> _initializeCardData() async {
    if (widget.businessCard != null) {
      _editingCard = widget.businessCard!;
      if (_editingCard.imagePath != null && _editingCard.imagePath!.isNotEmpty) {
        _pickedImage = XFile(_editingCard.imagePath!);
      }
    } else if (widget.recognizedText != null && widget.recognizedText!.isNotEmpty) {
      _editingCard = await BusinessCard.fromOcrTextAsync(
        widget.recognizedText!,
        imagePath: widget.imagePath,
      );
      if (widget.imagePath != null) {
        _pickedImage = XFile(widget.imagePath!);
      }
    } else {
      _editingCard = BusinessCard(name: '');
      if (widget.imagePath != null) {
        _pickedImage = XFile(widget.imagePath!);
      }
    }

    if (!mounted) return;

    setState(() {
      _nameController.text = _editingCard.name;
      _titleController.text = _editingCard.title ?? '';
      _companyController.text = _editingCard.company ?? '';
      _phoneController.text = _editingCard.phone ?? '';
      _emailController.text = _editingCard.email ?? '';
      _addressController.text = _editingCard.address ?? '';
      _websiteController.text = _editingCard.website ?? '';
      _notesController.text = _editingCard.notes ?? '';

      _showPhone = _editingCard.showPhone;
      _showEmail = _editingCard.showEmail;
      _showAddress = _editingCard.showAddress;
      _showWebsite = _editingCard.showWebsite;
      _showImage = _editingCard.showImage;

      _isInitializing = false;
    });
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
        _showImage = true;
      });
    }
  }

  void _saveBusinessCard() {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(l10n.editCardInfo),
        centerTitle: false,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: AntdButton(
            block: true,
            onTap: _isInitializing ? null : _saveBusinessCard,
            child: Text(l10n.saveAndReturn),
          ),
        ),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _SectionLabel(title: '来源图像'),
                const SizedBox(height: 8),
                _Panel(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: _pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_pickedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 32,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.clickToChangeImage,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '用于核对 OCR 识别结果，点击可重新选择图片。',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _SectionLabel(title: '核心信息'),
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
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _SectionLabel(title: '联系方式'),
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
                _SectionLabel(title: '展示内容'),
                const SizedBox(height: 8),
                _Panel(
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        title: '显示电话',
                        value: _showPhone,
                        onChanged: (value) {
                          setState(() => _showPhone = value);
                        },
                        icon: Icons.phone_outlined,
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: '显示邮箱',
                        value: _showEmail,
                        onChanged: (value) {
                          setState(() => _showEmail = value);
                        },
                        icon: Icons.email_outlined,
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: '显示地址',
                        value: _showAddress,
                        onChanged: (value) {
                          setState(() => _showAddress = value);
                        },
                        icon: Icons.location_on_outlined,
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: '显示网站',
                        value: _showWebsite,
                        onChanged: (value) {
                          setState(() => _showWebsite = value);
                        },
                        icon: Icons.language_outlined,
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: '显示头像',
                        value: _showImage,
                        onChanged: (value) {
                          setState(() => _showImage = value);
                        },
                        icon: Icons.account_circle_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _SectionLabel(title: '备注'),
                const SizedBox(height: 8),
                _Panel(
                  padding: const EdgeInsets.all(16),
                  child: _buildInputField(
                    label: l10n.notes,
                    hint: l10n.pleaseEnterNotes,
                    controller: _notesController,
                    maxLines: 4,
                    showLabel: false,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    bool showLabel = true,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: const Color(0xFF9CA3AF),
                    size: 20,
                  )
                : null,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
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