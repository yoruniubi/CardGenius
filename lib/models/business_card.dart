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
    debugPrint('--- ML Kit Entity Extraction 开始 ---');
    debugPrint('原始文本: $ocrText');

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
              debugPrint('ML Kit 匹配到邮箱: $email');
              break;
            case EntityType.phone:
              phone ??= annotation.text;
              debugPrint('ML Kit 匹配到电话: $phone');
              break;
            case EntityType.address:
              address ??= annotation.text;
              debugPrint('ML Kit 匹配到地址: $address');
              break;
            case EntityType.url:
              website ??= annotation.text;
              debugPrint('ML Kit 匹配到网址: $website');
              break;
            default:
              break;
          }
        }
      }
    } catch (e) {
      debugPrint('ML Kit Entity Extraction 出错: $e');
    } finally {
      entityExtractor.close();
    }

    // 使用改进后的同步逻辑作为补充和兜底
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
    debugPrint('--- OCR 解析开始 ---');
    String name = '';
    String? title;
    String? company;
    String? phone;
    String? email;
    String? address;
    String? website;

    // 1. 预处理：仅进行必要的标准化，不破坏原始文本结构
    String processedText = ocrText
        .replaceAll('：', ':')
        .replaceAll('　', ' ')
        .trim();

    // 按行拆分，保留空行以维持结构感
     List<String> lines = processedText.split(RegExp(r'\n+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    debugPrint('预处理后的行: $lines');

    // 2. 关键词定义
    final addressKeywords = ['add', 'address', '地址', '省', '市', '区', '路', '街', '号', '大厦', '楼', '工业园', '开发区', '广场', '胡同', '弄'];
    final companyKeywords = ['公司', '集团', '中心', '工作室', '有限', '股份', '厂', '部', '机构', '协会', '学校', '医院', 'co.', 'ltd.', 'inc.', 'corp.', '店', '行', '社', '馆', '院', '厅', 'university', 'association', 'office', 'studio'];
    final websiteKeywords = ['web', 'website', '网址', 'http', 'www', 'w:', '官网', 'site'];
    final titleKeywords = ['经理', '总监', '工程师', '创始人', 'ceo', '主任', '老师', '主管', '代表', '助理', '专员', '顾问', '设计', '会计', '销售', '业务', '店长', '厂长', '总裁', '主席', '主编', '技术员', 'engineer', 'manager', 'director', 'founder', 'president', 'vp', 'developer', 'designer', 'consultant', 'specialist'];

    List<String> remainingLines = [];

    // 3. 第一遍扫描：提取结构化信息 (Email, Phone, Website, Address)
    for (var line in lines) {
      bool matched = false;

      // 3.1 提取邮箱
      final emailMatch = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').firstMatch(line);
      if (emailMatch != null) {
        email ??= emailMatch.group(0);
        matched = true;
      }

      // 3.2 提取电话
      final phoneMatch = RegExp(r'(\+?86)?(1[3-9]\d{9})|(\d{3,4}-\d{7,8})').firstMatch(line.replaceAll(' ', ''));
      if (phoneMatch != null) {
        phone ??= phoneMatch.group(0);
        matched = true;
      }

      // 3.3 提取网址
      final webMatch = RegExp(r'(https?://)?(www\.)?[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+\.?').firstMatch(line);
      if (webMatch != null && (websiteKeywords.any((k) => line.toLowerCase().contains(k)) || line.contains('www.') || line.contains('.com'))) {
        website ??= webMatch.group(0);
        matched = true;
      }

      // 3.4 提取地址
      if (addressKeywords.any((k) => line.contains(k))) {
        address ??= line.replaceFirst(RegExp(r'^地址[:\s]*'), '').trim();
        matched = true;
      }

      if (!matched) {
        remainingLines.add(line);
      }
    }

    // 4. 第二遍扫描：从剩余行中提取 公司、职位、姓名
    
    // 4.1 提取公司
    for (int i = 0; i < remainingLines.length; i++) {
      if (companyKeywords.any((k) => remainingLines[i].toLowerCase().contains(k))) {
        company ??= remainingLines[i];
        remainingLines.removeAt(i);
        break;
      }
    }

    // 4.2 提取职位
    int titleIdx = -1;
    for (int i = 0; i < remainingLines.length; i++) {
      if (titleKeywords.any((k) => remainingLines[i].toLowerCase().contains(k))) {
        title ??= remainingLines[i];
        titleIdx = i;
        remainingLines.removeAt(i);
        break;
      }
    }

    // 4.3 提取姓名
    // 姓名通常在职位的前一行或后一行，或者是剩余行中最像姓名的（2-4个汉字）
    if (titleIdx != -1 && remainingLines.isNotEmpty) {
      // 检查职位原位置附近
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

    // 如果还没找到姓名，找剩余行中最短的纯中文行
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

    // 5. 兜底
    if (name.isEmpty) {
      name = remainingLines.isNotEmpty ? remainingLines[0] : '未知姓名';
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
    debugPrint('--- OCR 解析结果: $result ---');
    debugPrint('--- OCR 解析结束 ---');
    return result;
  }
  @override
  String toString() {
    return 'BusinessCard(id: $id, name: $name, title: $title, company: $company, phone: $phone, email: $email, address: $address, website: $website, notes: $notes, imagePath: $imagePath)';
  }
}
