import 'dart:io';
import 'package:flutter/material.dart';
import 'package:business_card_ocr/models/business_card.dart';
import 'package:business_card_ocr/models/element.dart';
import 'package:business_card_ocr/models/template.dart';
import 'package:business_card_ocr/pages/template_selection_page.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';

class CardPreviewPage extends StatefulWidget {
  final List<CardElement> cardElements;
  final BusinessCardTemplate? currentTemplate;
  final Function(BusinessCardTemplate) onTemplateSelected;
  final BusinessCard businessCard;

  const CardPreviewPage({
    super.key,
    required this.cardElements,
    this.currentTemplate,
    required this.onTemplateSelected,
    required this.businessCard,
  });

  @override
  State<CardPreviewPage> createState() => _CardPreviewPageState();
}

class _CardPreviewPageState extends State<CardPreviewPage> {
  late List<CardElement> _previewElements;
  BusinessCardTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _previewElements = List.from(widget.cardElements);
    _selectedTemplate = widget.currentTemplate;
    _applyBusinessCardDataToElements();
  }

  void _applyBusinessCardDataToElements() {
    final l10n = AppLocalizations.of(context)!;
    for (var element in _previewElements) {
      if (element is TextElement && element.tag != null) {
        switch (element.tag) {
          case 'name':
            element.content = widget.businessCard.name;
            break;
          case 'title':
            element.content = widget.businessCard.title ?? '';
            break;
          case 'company':
            element.content = widget.businessCard.company ?? '';
            break;
          case 'phone':
            final phone = widget.businessCard.phone ?? '';
            element.content = phone.isEmpty ? '' : '${l10n.phone}: $phone';
            break;
          case 'email':
            final email = widget.businessCard.email ?? '';
            element.content = email.isEmpty ? '' : '${l10n.email}: $email';
            break;
          case 'address':
            final address = widget.businessCard.address ?? '';
            element.content = address.isEmpty ? '' : '${l10n.address}: $address';
            break;
          case 'website':
            final website = widget.businessCard.website ?? '';
            element.content = website.isEmpty ? '' : '${l10n.website}: $website';
            break;
        }
      }
    }
  }

  void _loadTemplate(BusinessCardTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _previewElements = List.from(template.elements);
      _applyBusinessCardDataToElements(); // Re-apply data after loading new template
    });
    widget.onTemplateSelected(template); // Notify parent about the selected template
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cardPreview),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9, // Common business card aspect ratio
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: _selectedTemplate?.previewImagePath != null
                        ? (_selectedTemplate!.previewImagePath!.startsWith('assets/')
                            ? DecorationImage(
                                image: AssetImage(_selectedTemplate!.previewImagePath!),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: FileImage(File(_selectedTemplate!.previewImagePath!)),
                                fit: BoxFit.cover,
                              ))
                        : null,
                  ),
                  child: Stack(
                    children: _previewElements.map((element) {
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
                              element.imageUrl, // Assuming asset images for now
                              width: element.width,
                              height: element.height,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }
                      return Container(); // Fallback for unknown element types
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _templateSetting,
                  child: Text(l10n.template),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(l10n.backToEdit),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
