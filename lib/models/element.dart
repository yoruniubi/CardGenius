import 'package:flutter/material.dart';

// Base class for all elements on the business card
abstract class CardElement {
  double x;
  double y;
  String type; // 'text' or 'image' or 'icon'
  String? tag; // Identifier for element purpose, e.g., 'name', 'company'

  CardElement({
    required this.x,
    required this.y,
    required this.type,
    this.tag,
  });

  // Factory constructor to create elements from a map
  factory CardElement.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type == 'text') {
      return TextElement.fromJson(json);
    } else if (type == 'image') {
      return ImageElement.fromJson(json);
    } else if (type == 'icon') {
      return IconElement.fromJson(json);
    }
    throw ArgumentError('Unknown element type: $type');
  }

  Map<String, dynamic> toJson();
}

// Text element specific properties
class TextElement extends CardElement {
  String content;
  double fontSize;
  String fontFamily;
  Color color;
  bool isBold;
  bool isItalic;

  TextElement({
    required super.x,
    required super.y,
    required this.content,
    super.tag,
    this.fontSize = 14.0,
    this.fontFamily = 'Roboto',
    this.color = Colors.black,
    this.isBold = false,
    this.isItalic = false,
  }) : super(type: 'text');

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      tag: json['tag'] as String?,
      content: json['content'] as String,
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 14.0,
      fontFamily: json['font_family'] as String? ?? 'Roboto',
      color: Color(json['color'] as int? ?? Colors.black.value),
      isBold: json['is_bold'] as bool? ?? false,
      isItalic: json['is_italic'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
      'tag': tag,
      'content': content,
      'font_size': fontSize,
      'font_family': fontFamily,
      'color': color.value,
      'is_bold': isBold,
      'is_italic': isItalic,
    };
  }
}

// Image element specific properties
class ImageElement extends CardElement {
  String imageUrl; // Can be asset path or network URL
  double width;
  double height;

  ImageElement({
    required super.x,
    required super.y,
    required this.imageUrl,
    super.tag,
    this.width = 100.0,
    this.height = 100.0,
  }) : super(type: 'image');

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    return ImageElement(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      tag: json['tag'] as String?,
      imageUrl: json['image_url'] as String,
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      height: (json['height'] as num?)?.toDouble() ?? 100.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
      'tag': tag,
      'image_url': imageUrl,
      'width': width,
      'height': height,
    };
  }
}

// Icon element specific properties
class IconElement extends CardElement {
  IconData icon;
  double size;
  Color color;

  IconElement({
    required super.x,
    required super.y,
    required this.icon,
    super.tag,
    this.size = 16.0,
    this.color = Colors.black54,
  }) : super(type: 'icon');

  factory IconElement.fromJson(Map<String, dynamic> json) {
    return IconElement(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      tag: json['tag'] as String?,
      icon: IconData(
        json['icon_code_point'] as int,
        fontFamily: json['icon_font_family'] as String? ?? 'MaterialIcons',
      ),
      size: (json['size'] as num?)?.toDouble() ?? 16.0,
      color: Color(json['color'] as int? ?? Colors.black54.value),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
      'tag': tag,
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'size': size,
      'color': color.value,
    };
  }
}