import 'dart:convert';

import 'package:business_card_ocr/models/business_card.dart';

class ShareLinkService {
  ShareLinkService._();

  static const String _scheme = 'cardgenius';
  static const String _host = 'import';
  static const String _queryKey = 'data';
  static const String _webHost = 'cardgenius.app';
  static const String _webPath = '/import';

  static String buildLink(BusinessCard card) {
    final payload = _cardToPayload(card);
    final encoded = base64UrlEncode(utf8.encode(jsonEncode(payload)));

    return Uri(
      scheme: _scheme,
      host: _host,
      queryParameters: {_queryKey: encoded},
    ).toString();
  }

  static BusinessCard? tryParseCard(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return null;

    Uri? uri;
    try {
      uri = Uri.parse(input);
    } catch (_) {
      return null;
    }

    final isAppLink = uri.scheme == _scheme && uri.host == _host;
    final isWebLink = uri.scheme.startsWith('http') &&
        uri.host == _webHost &&
        uri.path == _webPath;

    if (!isAppLink && !isWebLink) return null;

    final encoded = uri.queryParameters[_queryKey];
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = utf8.decode(base64Url.decode(encoded));
      final map = jsonDecode(decoded);
      if (map is! Map<String, dynamic>) return null;

      final data = <String, dynamic>{
        'name': (map['name'] ?? '').toString(),
        'title': map['title']?.toString(),
        'company': map['company']?.toString(),
        'phone': map['phone']?.toString(),
        'email': map['email']?.toString(),
        'address': map['address']?.toString(),
        'website': map['website']?.toString(),
        'notes': map['notes']?.toString(),
        'showPhone': map['showPhone'] ?? true,
        'showEmail': map['showEmail'] ?? true,
        'showAddress': map['showAddress'] ?? true,
        'showWebsite': map['showWebsite'] ?? true,
        'showImage': false,
      };

      if ((data['name'] as String).trim().isEmpty) return null;
      return BusinessCard.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _cardToPayload(BusinessCard card) {
    return {
      'name': card.name,
      'title': card.title,
      'company': card.company,
      'phone': card.phone,
      'email': card.email,
      'address': card.address,
      'website': card.website,
      'notes': card.notes,
      'showPhone': card.showPhone,
      'showEmail': card.showEmail,
      'showAddress': card.showAddress,
      'showWebsite': card.showWebsite,
    };
  }
}
