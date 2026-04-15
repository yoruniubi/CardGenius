import 'package:flutter/material.dart';
import 'package:business_card_ocr/models/element.dart';

class BusinessCardTemplate {
  String id;
  String name;
  String? previewImagePath; // Path to a preview/background image
  int? backgroundColorValue; // Store Color as int for JSON serialization
  List<CardElement> elements;

  BusinessCardTemplate({
    required this.id,
    required this.name,
    this.previewImagePath,
    this.backgroundColorValue,
    required this.elements,
  });

  Color? get backgroundColor =>
      backgroundColorValue != null ? Color(backgroundColorValue!) : null;

  factory BusinessCardTemplate.fromJson(Map<String, dynamic> json) {
    final elementsList = json['elements'] as List;
    final List<CardElement> elements = elementsList
        .map((e) => CardElement.fromJson(e as Map<String, dynamic>))
        .toList();

    return BusinessCardTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      previewImagePath: json['preview_image_path'] as String?,
      backgroundColorValue: json['background_color_value'] as int?,
      elements: elements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'preview_image_path': previewImagePath,
      'background_color_value': backgroundColorValue,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }
}