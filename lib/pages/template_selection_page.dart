import 'package:flutter/material.dart';
import 'package:business_card_ocr/models/template.dart';
import 'package:business_card_ocr/models/element.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:antd_flutter_mobile/index.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final templates = _availableTemplates ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          l10n.selectTemplate,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
            return _TemplateTile(
              onTap: _pickCustomBackground,
              preview: Container(
                color: const Color(0xFFF3F4F6),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: Color(0xFF1677FF),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.uploadBackground,
                        style: const TextStyle(
                          color: Color(0xFF1677FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: l10n.customBackground,
              subtitle: l10n.useLocalImage,
            );
          }

          final template = templates[index];
          return _TemplateTile(
            onTap: () => Navigator.pop(context, template),
            preview: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: template.previewImagePath != null
                    ? DecorationImage(
                        image: AssetImage(template.previewImagePath!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: const Color(0xFFF3F4F6),
              ),
              child: template.previewImagePath == null
                  ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Color(0xFF9CA3AF),
                      ),
                    )
                  : null,
            ),
            title: template.name,
            subtitle: l10n.templateCount(template.elements.length),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: AntdButton(
            fill: AntdButtonFill.outline,
            onTap: _pickCustomBackground,
            child: Text(l10n.uploadBackground),
          ),
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.onTap,
    required this.preview,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onTap;
  final Widget preview;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: preview),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
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
}
