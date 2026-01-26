import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:business_card_ocr/models/business_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';

class EditorPage extends StatefulWidget {
  final BusinessCard? businessCard;
  final String? recognizedText;
  final String? imagePath; // New: Pass image path from OCR page

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

  XFile? _pickedImage; // To store the picked image file
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _initializeCardData();
  }

  Future<void> _initializeCardData() async {
    debugPrint('EditorPage: Initializing data');
    if (widget.businessCard != null) {
      _editingCard = widget.businessCard!;
      if (_editingCard.imagePath != null) {
        _pickedImage = XFile(_editingCard.imagePath!);
      }
    } else if (widget.recognizedText != null && widget.recognizedText!.isNotEmpty) {
      // Use asynchronous ML Kit entity extraction logic
      _editingCard = await BusinessCard.fromOcrTextAsync(
        widget.recognizedText!,
        imagePath: widget.imagePath,
      );
      if (widget.imagePath != null) {
        _pickedImage = XFile(widget.imagePath!);
      }
    } else {
      _editingCard = BusinessCard(name: ''); // Default empty card
    }

    if (mounted) {
      setState(() {
        _nameController.text = _editingCard.name;
        _titleController.text = _editingCard.title ?? '';
        _companyController.text = _editingCard.company ?? '';
        _phoneController.text = _editingCard.phone ?? '';
        _emailController.text = _editingCard.email ?? '';
        _addressController.text = _editingCard.address ?? '';
        _websiteController.text = _editingCard.website ?? '';
        _notesController.text = _editingCard.notes ?? '';
      });
    }
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
      });
    }
  }

  void _saveBusinessCard() {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('EditorPage: Attempting to save card');
    if (_nameController.text.trim().isEmpty) {
      debugPrint('Save failed: Name is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.nameCannotBeEmpty),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _editingCard.name = _nameController.text;
    _editingCard.title = _titleController.text.isEmpty ? null : _titleController.text;
    _editingCard.company = _companyController.text.isEmpty ? null : _companyController.text;
    _editingCard.phone = _phoneController.text.isEmpty ? null : _phoneController.text;
    _editingCard.email = _emailController.text.isEmpty ? null : _emailController.text;
    _editingCard.address = _addressController.text.isEmpty ? null : _addressController.text;
    _editingCard.website = _websiteController.text.isEmpty ? null : _websiteController.text;
    _editingCard.notes = _notesController.text.isEmpty ? null : _notesController.text;
    _editingCard.imagePath = _pickedImage?.path;
    debugPrint('Save successful: $_editingCard');
    Navigator.pop(context, _editingCard);
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
        centerTitle: true,
        title: Text(
          l10n.editCardInfo,
          style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image picker and display
                  Text(
                    l10n.originalImage,
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.muted,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: theme.colorScheme.border,
                          width: 1,
                        ),
                      ),
                      child: _pickedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(
                                File(_pickedImage!.path),
                                fit: BoxFit.contain,
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.clickToChangeImage,
                                    style: theme.textTheme.muted,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.detailedInfo,
                    style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: l10n.name,
                    placeholder: l10n.pleaseEnterName,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: l10n.jobTitle,
                    placeholder: l10n.pleaseEnterTitle,
                    controller: _titleController,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: l10n.company,
                    placeholder: l10n.pleaseEnterCompany,
                    controller: _companyController,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: l10n.phone,
                    placeholder: l10n.pleaseEnterPhone,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: l10n.email,
                    placeholder: l10n.pleaseEnterEmail,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: l10n.website,
                    placeholder: l10n.pleaseEnterWebsite,
                    controller: _websiteController,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: l10n.address,
                    placeholder: l10n.pleaseEnterAddress,
                    controller: _addressController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: l10n.notes,
                    placeholder: l10n.pleaseEnterNotes,
                    controller: _notesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  ShadButton(
                    width: double.infinity,
                    onPressed: _saveBusinessCard,
                    child: Text(l10n.saveAndReturn),
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
