import 'package:flutter/foundation.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

class BusinessCard {
  String id; // Unique identifier
  String name;
  String? title;
  String? company;
  String? phone;
  String? email;
  String? address;
  String? website;
  String? notes;
  String? imagePath; // New field for image path

  BusinessCard({
    String? id,
    required this.name,
    this.title,
    this.company,
    this.phone,
    this.email,
    this.address,
    this.website,
    this.notes,
    this.imagePath, // Include in constructor
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Factory constructor to create a BusinessCard from a map (e.g., for JSON deserialization)
  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      id: json['id'] as String?,
      name: json['name'] as String,
      title: json['title'] as String?,
      company: json['company'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String?,
      notes: json['notes'] as String?,
      imagePath: json['imagePath'] as String?, // Include in fromJson
    );
  }

  // Method to convert a BusinessCard to a map (e.g., for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'company': company,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'notes': notes,
      'imagePath': imagePath, // Include in toJson
    };
  }

  // Helper to create a BusinessCard from OCR recognized text using ML Kit Entity Extraction
  static Future<BusinessCard> fromOcrTextAsync(String ocrText, {String? imagePath}) async {
    debugPrint('--- ML Kit Entity Extraction Start ---');
    debugPrint('Original text: $ocrText');

    String? phone;
    String? email;
    String? address;
    String? website;

    final entityExtractor = EntityExtractor(language: EntityExtractorLanguage.chinese);

    try {
      final List<EntityAnnotation> annotations = await entityExtractor.annotateText(ocrText);

      for (final annotation in annotations) {
        for (final entity in annotation.entities) {
          switch (entity.type) {
            case EntityType.email:
              email ??= annotation.text;
              debugPrint('ML Kit matched email: $email');
              break;
            case EntityType.phone:
              phone ??= annotation.text;
              debugPrint('ML Kit matched phone: $phone');
              break;
            case EntityType.address:
              address ??= annotation.text;
              debugPrint('ML Kit matched address: $address');
              break;
            case EntityType.url:
              website ??= annotation.text;
              debugPrint('ML Kit matched website: $website');
              break;
            default:
              break;
          }
        }
      }
    } catch (e) {
      debugPrint('ML Kit Entity Extraction error: $e');
    } finally {
      entityExtractor.close();
    }

    // Use improved sync logic as fallback
    final fallbackCard = BusinessCard.fromOcrText(ocrText, imagePath: imagePath);

    return BusinessCard(
      name: fallbackCard.name,
      title: fallbackCard.title,
      company: fallbackCard.company,
      phone: phone ?? fallbackCard.phone,
      email: email ?? fallbackCard.email,
      address: address ?? fallbackCard.address,
      website: website ?? fallbackCard.website,
      imagePath: imagePath,
    );
  }

  // Helper to create a BusinessCard from OCR recognized text
  factory BusinessCard.fromOcrText(String ocrText, {String? imagePath}) {
    debugPrint('--- OCR Parsing Start ---');
    String name = '';
    String? title;
    String? company;
    String? phone;
    String? email;
    String? address;
    String? website;

    // 1. Preprocessing: standardization without breaking structure
    String processedText = ocrText
        .replaceAll('：', ':')
        .replaceAll('　', ' ')
        .trim();

    // Split by lines, keep empty lines for structure
     List<String> lines = processedText.split(RegExp(r'\n+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    debugPrint('Processed lines: $lines');

    // 2. Keyword definitions
    final addressKeywords = ['add', 'address', '地址', '省', '市', '区', '路', '街', '号', '大厦', '楼', '工业园', '开发区', '广场', '胡同', '弄'];
    final companyKeywords = ['公司', '集团', '中心', '工作室', '有限', '股份', '厂', '部', '机构', '协会', '学校', '医院', 'co.', 'ltd.', 'inc.', 'corp.', '店', '行', '社', '馆', '院', '厅', 'university', 'association', 'office', 'studio'];
    final websiteKeywords = ['web', 'website', '网址', 'http', 'www', 'w:', '官网', 'site'];
    final titleKeywords = ['经理', '总监', '工程师', '创始人', 'ceo', '主任', '老师', '主管', '代表', '助理', '专员', '顾问', '设计', '会计', '销售', '业务', '店长', '厂长', '总裁', '主席', '主编', '技术员', 'engineer', 'manager', 'director', 'founder', 'president', 'vp', 'developer', 'designer', 'consultant', 'specialist'];

    List<String> remainingLines = [];

    // 3. First pass: extract structured info (Email, Phone, Website, Address)
    for (var line in lines) {
      bool matched = false;

      // 3.1 Extract email
      final emailMatch = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').firstMatch(line);
      if (emailMatch != null) {
        email ??= emailMatch.group(0);
        matched = true;
      }

      // 3.2 Extract phone
      final phoneMatch = RegExp(r'(\+?86)?(1[3-9]\d{9})|(\d{3,4}-\d{7,8})').firstMatch(line.replaceAll(' ', ''));
      if (phoneMatch != null) {
        phone ??= phoneMatch.group(0);
        matched = true;
      }

      // 3.3 Extract website
      final webMatch = RegExp(r'(https?://)?(www\.)?[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+\.?').firstMatch(line);
      if (webMatch != null && (websiteKeywords.any((k) => line.toLowerCase().contains(k)) || line.contains('www.') || line.contains('.com'))) {
        website ??= webMatch.group(0);
        matched = true;
      }

      // 3.4 Extract address
      if (addressKeywords.any((k) => line.contains(k))) {
        address ??= line.replaceFirst(RegExp(r'^地址[:\s]*'), '').trim();
        matched = true;
      }

      if (!matched) {
        remainingLines.add(line);
      }
    }

    // 4. Second pass: extract company, title, name
    
    // 4.1 Extract company
    for (int i = 0; i < remainingLines.length; i++) {
      if (companyKeywords.any((k) => remainingLines[i].toLowerCase().contains(k))) {
        company ??= remainingLines[i];
        remainingLines.removeAt(i);
        break;
      }
    }

    // 4.2 Extract title
    int titleIdx = -1;
    for (int i = 0; i < remainingLines.length; i++) {
      if (titleKeywords.any((k) => remainingLines[i].toLowerCase().contains(k))) {
        title ??= remainingLines[i];
        titleIdx = i;
        remainingLines.removeAt(i);
        break;
      }
    }

    // 4.3 Extract name
    // Name is usually near title or 2-4 Chinese characters
    if (titleIdx != -1 && remainingLines.isNotEmpty) {
      // Check near title position
      int searchStart = (titleIdx - 1).clamp(0, remainingLines.length - 1);
      int searchEnd = titleIdx.clamp(0, remainingLines.length - 1);
      
      for (int i = searchStart; i <= searchEnd; i++) {
        if (RegExp(r'^[\u4e00-\u9fa5]{2,4}$').hasMatch(remainingLines[i])) {
          name = remainingLines[i];
          remainingLines.removeAt(i);
          break;
        }
      }
    }

    // Fallback: find shortest pure Chinese line
    if (name.isEmpty && remainingLines.isNotEmpty) {
      remainingLines.sort((a, b) => a.length.compareTo(b.length));
      for (int i = 0; i < remainingLines.length; i++) {
        if (RegExp(r'^[\u4e00-\u9fa5]{2,4}$').hasMatch(remainingLines[i])) {
          name = remainingLines[i];
          remainingLines.removeAt(i);
          break;
        }
      }
    }

    // 5. Fallback
    if (name.isEmpty) {
      name = remainingLines.isNotEmpty ? remainingLines[0] : 'Unknown Name';
    }

    final result = BusinessCard(
      name: name,
      title: title,
      company: company,
      phone: phone,
      email: email,
      address: address,
      website: website,
      imagePath: imagePath,
    );
    debugPrint('--- OCR Parsing Result: $result ---');
    debugPrint('--- OCR Parsing End ---');
    return result;
  }
  @override
  String toString() {
    return 'BusinessCard(id: $id, name: $name, title: $title, company: $company, phone: $phone, email: $email, address: $address, website: $website, notes: $notes, imagePath: $imagePath)';
  }
}
