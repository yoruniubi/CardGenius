import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:business_card_ocr/models/business_card.dart';

class ShareLinkService {
  ShareLinkService._();

  static const String _scheme = 'cardgenius';
  static const String _host = 'import';
  static const String _queryKey = 'data';
  static const String _sourceKey = 'source';
  static const String _sourceValue = 'share';

  static String buildLink(BusinessCard card) {
    final payload = _cardToPayload(card);
    final encoded = base64UrlEncode(utf8.encode(jsonEncode(payload)));

    return Uri(
      scheme: _scheme,
      host: _host,
      queryParameters: {
        _queryKey: encoded,
        _sourceKey: _sourceValue,
      },
    ).toString();
  }

  static BusinessCard? tryParseCard(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return null;

    Uri uri;
    try {
      uri = Uri.parse(input);
    } catch (_) {
      return null;
    }

    final isAppLink = uri.scheme == _scheme && uri.host == _host;
    if (!isAppLink) return null;

    final source = uri.queryParameters[_sourceKey];
    if (source != _sourceValue) return null;

    final encoded = uri.queryParameters[_queryKey];
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = utf8.decode(base64Url.decode(encoded));
      final map = jsonDecode(decoded);
      if (map is! Map<String, dynamic>) return null;

      final normalizedName = (map['name'] ?? '').toString().trim();
      final normalizedTitle = map['title']?.toString().trim();
      final normalizedCompany = map['company']?.toString().trim();
      final normalizedPhone = map['phone']?.toString().trim();
      final normalizedEmail = map['email']?.toString().trim().toLowerCase();
      final normalizedAddress = map['address']?.toString().trim();
      final normalizedWebsite = map['website']?.toString().trim();
      final normalizedNotes = map['notes']?.toString().trim();

      if (normalizedName.isEmpty) return null;

      final data = <String, dynamic>{
        'id': _buildStableId(
          name: normalizedName,
          company: normalizedCompany,
          phone: normalizedPhone,
          email: normalizedEmail,
        ),
        'name': normalizedName,
        'title': _nullIfEmpty(normalizedTitle),
        'company': _nullIfEmpty(normalizedCompany),
        'phone': _nullIfEmpty(normalizedPhone),
        'email': _nullIfEmpty(normalizedEmail),
        'address': _nullIfEmpty(normalizedAddress),
        'website': _nullIfEmpty(normalizedWebsite),
        'notes': _nullIfEmpty(normalizedNotes),
        'imagePath': null,
        'showPhone': map['showPhone'] ?? true,
        'showEmail': map['showEmail'] ?? true,
        'showAddress': map['showAddress'] ?? true,
        'showWebsite': map['showWebsite'] ?? true,
        'showImage': false,
      };

      return BusinessCard.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _cardToPayload(BusinessCard card) {
    return {
      'name': card.name.trim(),
      'title': _nullIfEmpty(card.title?.trim()),
      'company': _nullIfEmpty(card.company?.trim()),
      'phone': _nullIfEmpty(card.phone?.trim()),
      'email': _nullIfEmpty(card.email?.trim().toLowerCase()),
      'address': _nullIfEmpty(card.address?.trim()),
      'website': _nullIfEmpty(card.website?.trim()),
      'notes': _nullIfEmpty(card.notes?.trim()),
      'showPhone': card.showPhone,
      'showEmail': card.showEmail,
      'showAddress': card.showAddress,
      'showWebsite': card.showWebsite,
    };
  }

  static String _buildStableId({
    required String name,
    String? company,
    String? phone,
    String? email,
  }) {
    final raw = [
      name.trim().toLowerCase(),
      (company ?? '').trim().toLowerCase(),
      (phone ?? '').replaceAll(RegExp(r'\s+'), ''),
      (email ?? '').trim().toLowerCase(),
    ].join('|');

    return sha1.convert(utf8.encode(raw)).toString();
  }

  static String? _nullIfEmpty(String? value) {
    if (value == null) return null;
    final v = value.trim();
    return v.isEmpty ? null : v;
  }
}