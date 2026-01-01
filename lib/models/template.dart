import 'package:business_card_ocr/models/element.dart';

class BusinessCardTemplate {
  String id;
  String name;
  String? previewImagePath; // Path to a small preview image of the template
  List<CardElement> elements;

  BusinessCardTemplate({
    required this.id,
    required this.name,
    this.previewImagePath,
    required this.elements,
  });

  factory BusinessCardTemplate.fromJson(Map<String, dynamic> json) {
    var elementsList = json['elements'] as List;
    List<CardElement> elements = elementsList
        .map((e) => CardElement.fromJson(e as Map<String, dynamic>))
        .toList();

    return BusinessCardTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      previewImagePath: json['preview_image_path'] as String?,
      elements: elements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'preview_image_path': previewImagePath,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }
}
