import 'package:flutter/foundation.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

class BusinessCard {
  String id;
  String name;
  String? title;
  String? company;
  String? phone;
  String? email;
  String? address;
  String? website;
  String? notes;
  String? imagePath;

  // 选择性展示
  bool showPhone;
  bool showEmail;
  bool showAddress;
  bool showWebsite;
  bool showImage;

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
    this.imagePath,
    this.showPhone = true,
    this.showEmail = true,
    this.showAddress = true,
    this.showWebsite = true,
    this.showImage = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

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
      imagePath: json['imagePath'] as String?,
      showPhone: json['showPhone'] as bool? ?? true,
      showEmail: json['showEmail'] as bool? ?? true,
      showAddress: json['showAddress'] as bool? ?? true,
      showWebsite: json['showWebsite'] as bool? ?? true,
      showImage: json['showImage'] as bool? ?? false,
    );
  }

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
      'imagePath': imagePath,
      'showPhone': showPhone,
      'showEmail': showEmail,
      'showAddress': showAddress,
      'showWebsite': showWebsite,
      'showImage': showImage,
    };
  }

  static Future<BusinessCard> fromOcrTextAsync(
    String ocrText, {
    String? imagePath,
  }) async {
    debugPrint('--- ML Kit Entity Extraction Start ---');
    debugPrint('Original text: $ocrText');

    String? phone;
    String? email;
    String? address;
    String? website;

    final entityExtractor =
        EntityExtractor(language: EntityExtractorLanguage.chinese);

    try {
      final List<EntityAnnotation> annotations =
          await entityExtractor.annotateText(ocrText);

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

    final fallbackCard = BusinessCard.fromOcrText(
      ocrText,
      imagePath: imagePath,
    );

    return BusinessCard(
      name: fallbackCard.name,
      title: fallbackCard.title,
      company: fallbackCard.company,
      phone: phone ?? fallbackCard.phone,
      email: email ?? fallbackCard.email,
      address: address ?? fallbackCard.address,
      website: website ?? fallbackCard.website,
      imagePath: imagePath,
      showPhone: true,
      showEmail: true,
      showAddress: true,
      showWebsite: true,
      showImage: false,
    );
  }

  factory BusinessCard.fromOcrText(String ocrText, {String? imagePath}) {
    debugPrint('--- OCR Parsing Start ---');
    String name = '';
    String? title;
    String? company;
    String? phone;
    String? email;
    String? address;
    String? website;

    String processedText = ocrText
        .replaceAll('：', ':')
        .replaceAll('　', ' ')
        .trim();

    List<String> lines = processedText
        .split(RegExp(r'\n+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    debugPrint('Processed lines: $lines');

    final addressKeywords = [
      'add',
      'address',
      '地址',
      '省',
      '市',
      '区',
      '路',
      '街',
      '号',
      '大厦',
      '楼',
      '工业园',
      '开发区',
      '广场',
      '胡同',
      '弄'
    ];
    final companyKeywords = [
      '公司',
      '集团',
      '中心',
      '工作室',
      '有限',
      '股份',
      '厂',
      '部',
      '机构',
      '协会',
      '学校',
      '医院',
      'co.',
      'ltd.',
      'inc.',
      'corp.',
      '店',
      '行',
      '社',
      '馆',
      '院',
      '厅',
      'university',
      'association',
      'office',
      'studio'
    ];
    final websiteKeywords = [
      'web',
      'website',
      '网址',
      'http',
      'www',
      'w:',
      '官网',
      'site'
    ];
    final titleKeywords = [
      '经理',
      '总监',
      '工程师',
      '创始人',
      'ceo',
      '主任',
      '老师',
      '主管',
      '代表',
      '助理',
      '专员',
      '顾问',
      '设计',
      '会计',
      '销售',
      '业务',
      '店长',
      '厂长',
      '总裁',
      '主席',
      '主编',
      '技术员',
      'engineer',
      'manager',
      'director',
      'founder',
      'president',
      'vp',
      'developer',
      'designer',
      'consultant',
      'specialist'
    ];

    List<String> remainingLines = [];

    for (var line in lines) {
      bool matched = false;

      final emailMatch = RegExp(
        r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
      ).firstMatch(line);
      if (emailMatch != null) {
        email ??= emailMatch.group(0);
        matched = true;
      }

      final phoneMatch = RegExp(
        r'(\+?86)?(1[3-9]\d{9})|(\d{3,4}-\d{7,8})',
      ).firstMatch(line.replaceAll(' ', ''));
      if (phoneMatch != null) {
        phone ??= phoneMatch.group(0);
        matched = true;
      }

      final webMatch = RegExp(
        r'(https?://)?(www\.)?[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+\.?',
      ).firstMatch(line);
      if (webMatch != null &&
          (websiteKeywords.any((k) => line.toLowerCase().contains(k)) ||
              line.contains('www.') ||
              line.contains('.com'))) {
        website ??= webMatch.group(0);
        matched = true;
      }

      if (addressKeywords.any((k) => line.contains(k))) {
        address ??= line.replaceFirst(RegExp(r'^地址[:\s]*'), '').trim();
        matched = true;
      }

      if (!matched) {
        remainingLines.add(line);
      }
    }

    for (int i = 0; i < remainingLines.length; i++) {
      if (companyKeywords.any(
        (k) => remainingLines[i].toLowerCase().contains(k),
      )) {
        company ??= remainingLines[i];
        remainingLines.removeAt(i);
        break;
      }
    }

    int titleIdx = -1;
    for (int i = 0; i < remainingLines.length; i++) {
      if (titleKeywords.any(
        (k) => remainingLines[i].toLowerCase().contains(k),
      )) {
        title ??= remainingLines[i];
        titleIdx = i;
        remainingLines.removeAt(i);
        break;
      }
    }

    if (titleIdx != -1 && remainingLines.isNotEmpty) {
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
      showPhone: true,
      showEmail: true,
      showAddress: true,
      showWebsite: true,
      showImage: false,
    );

    debugPrint('--- OCR Parsing Result: $result ---');
    debugPrint('--- OCR Parsing End ---');
    return result;
  }

  @override
  String toString() {
    return 'BusinessCard(id: $id, name: $name, title: $title, company: $company, phone: $phone, email: $email, address: $address, website: $website, notes: $notes, imagePath: $imagePath, showPhone: $showPhone, showEmail: $showEmail, showAddress: $showAddress, showWebsite: $showWebsite, showImage: $showImage)';
  }
}