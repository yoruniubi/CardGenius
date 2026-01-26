import 'package:flutter/material.dart';
import 'package:business_card_ocr/models/template.dart';
import 'package:business_card_ocr/models/element.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';

class TemplateSelectionPage extends StatefulWidget {
  const TemplateSelectionPage({super.key});

  @override
  State<TemplateSelectionPage> createState() => _TemplateSelectionPageState();
}

class _TemplateSelectionPageState extends State<TemplateSelectionPage> {
  // Unified text element layout with tags for real-time updates
  List<CardElement> _getUnifiedElements(AppLocalizations l10n) {
    return [
      TextElement(x: 25, y: 15, content: l10n.name, tag: 'name', fontSize: 26, isBold: true, color: Colors.black),
      TextElement(x: 25, y: 48, content: l10n.jobTitle, tag: 'title', fontSize: 14, color: Colors.black87),
      TextElement(x: 25, y: 70, content: l10n.company, tag: 'company', fontSize: 18, isBold: true, color: Colors.black),
      TextElement(x: 25, y: 95, content: '${l10n.phone}: 123-4567-8901', tag: 'phone', fontSize: 12, color: Colors.black54),
      TextElement(x: 25, y: 112, content: '${l10n.email}: example@mail.com', tag: 'email', fontSize: 12, color: Colors.black54),
      TextElement(x: 25, y: 130, content: '${l10n.address}: 示例详细地址', tag: 'address', fontSize: 11, color: Colors.black45),
      TextElement(x: 25, y: 148, content: '${l10n.website}: www.example.com', tag: 'website', fontSize: 11, color: Colors.blue.shade700),
    ];
  }

  List<BusinessCardTemplate>? _availableTemplates;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_availableTemplates == null) {
      final l10n = AppLocalizations.of(context)!;
      // Initialize templates 1-7
      _availableTemplates = List.generate(7, (index) {
        final id = index + 1;
        return BusinessCardTemplate(
          id: 'template_$id',
          name: l10n.templateName(id.toString()),
          previewImagePath: 'assets/$id.png',
          elements: _getUnifiedElements(l10n),
        );
      });
    }
  }

  Future<void> _pickCustomBackground() async {
    final l10n = AppLocalizations.of(context)!;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      final customTemplate = BusinessCardTemplate(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: l10n.customBackground,
        previewImagePath: result.files.single.path,
        elements: _getUnifiedElements(l10n),
      );
      if (mounted) {
        Navigator.pop(context, customTemplate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final templates = _availableTemplates ?? [];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.selectTemplate,
          style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: templates.length + 1,
        itemBuilder: (context, index) {
          if (index == templates.length) {
            // Custom upload option
            return ShadCard(
              padding: const EdgeInsets.all(0),
              child: InkWell(
                onTap: _pickCustomBackground,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: theme.colorScheme.muted,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.uploadBackground,
                                style: theme.textTheme.small.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.customBackground,
                            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.useLocalImage,
                            style: theme.textTheme.muted.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final template = templates[index];
          return ShadCard(
            padding: const EdgeInsets.all(0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context, template);
              },
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        image: template.previewImagePath != null
                            ? DecorationImage(
                                image: AssetImage(template.previewImagePath!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: theme.colorScheme.muted,
                      ),
                      child: template.previewImagePath == null
                          ? Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.templateCount(template.elements.length),
                          style: theme.textTheme.muted.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
