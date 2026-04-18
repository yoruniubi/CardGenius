import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:ocr_plugin/ocr_plugin.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app_links/app_links.dart';
import 'package:business_card_ocr/models/business_card.dart';
import 'package:business_card_ocr/pages/editor_page.dart';
import 'package:business_card_ocr/pages/card_management.dart';
import 'package:business_card_ocr/pages/test.dart';
import 'package:business_card_ocr/providers/locale_provider.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';
import 'package:antd_flutter_mobile/index.dart';
import 'package:business_card_ocr/services/ocr_service.dart';
import 'package:business_card_ocr/services/share_link_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    localeProvider.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    localeProvider.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AntdProvider(
      builder: (context, theme) => MaterialApp(
        title: '名片智造',
        debugShowCheckedModeBanner: false,
        locale: localeProvider.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        scaffoldMessengerKey: scaffoldMessengerKey,
        navigatorObservers: [AntdLayer.observer],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1677FF),
            brightness: Brightness.light,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F6F8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF5F6F8),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        routes: {
          '/': (context) => const HomePage(),
          '/cardManagement': (context) => const CardPage(),
          '/testPage': (context) => const OcrTestPage(),
        },
        initialRoute: '/',
      )
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // final OcrPlugin _ocrPlugin = OcrPlugin();
  // bool _isOcrInitialized = false;
  // Future<bool>? _ocrInitFuture;
  final ImagePicker _picker = ImagePicker();
  final List<BusinessCard> _businessCards = [];
  List<BusinessCard> _filteredBusinessCards = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool isGalleryImportAllowed = true;
  List<String> scannedImagesPath = [];
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  String? _lastHandledLink;
  DateTime? _lastHandledAt;

  @override
  void initState() {
    super.initState();
    _initOcrEngine();
    _loadBusinessCards();
    _filteredBusinessCards = _businessCards;
    _searchController.addListener(_onSearchChanged);
    _initAppLinks();
  }
  void _shareBusinessCardAsText(BusinessCard card) {
    final link = ShareLinkService.buildLink(card);
    Share.share(link);
  }
  Future<void> _initOcrEngine() async {
    if (kIsWeb) return;

    try {
      await OcrService.instance.ensureInitialized();
    } catch (e) {
      debugPrint('OCR 初始化失败: $e');
    }
  }
  void _showQrShareDialog(BusinessCard card) {
    final link = ShareLinkService.buildLink(card);

    final l10n = AppLocalizations.of(context)!;

    AntdModal.show(
      title: Text(l10n.qrShare),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: link,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.scanToImportDirectly,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      actions: [
        AntdModalAction(
          title: Text(l10n.close),
          onTap: (close) async {
            await close();
          },
        ),
      ],
    );
  }
  int _findExistingCardIndex(BusinessCard incoming) {
    String normalizePhone(String? value) =>
        (value ?? '').replaceAll(RegExp(r'\s+'), '').trim();

    String normalizeText(String? value) =>
        (value ?? '').trim().toLowerCase();

    for (int i = 0; i < _businessCards.length; i++) {
      final current = _businessCards[i];

      final samePhone = normalizePhone(current.phone).isNotEmpty &&
          normalizePhone(current.phone) == normalizePhone(incoming.phone);

      final sameEmail = normalizeText(current.email).isNotEmpty &&
          normalizeText(current.email) == normalizeText(incoming.email);

      final sameNameCompany =
          normalizeText(current.name) == normalizeText(incoming.name) &&
          normalizeText(current.company) == normalizeText(incoming.company) &&
          normalizeText(current.name).isNotEmpty;

      if (samePhone || sameEmail || sameNameCompany) {
        return i;
      }
    }

    return -1;
  }

  BusinessCard _mergeCard(BusinessCard oldCard, BusinessCard newCard) {
    return BusinessCard(
      id: oldCard.id,
      name: newCard.name.isNotEmpty ? newCard.name : oldCard.name,
      title: (newCard.title?.isNotEmpty ?? false) ? newCard.title : oldCard.title,
      company: (newCard.company?.isNotEmpty ?? false) ? newCard.company : oldCard.company,
      phone: (newCard.phone?.isNotEmpty ?? false) ? newCard.phone : oldCard.phone,
      email: (newCard.email?.isNotEmpty ?? false) ? newCard.email : oldCard.email,
      address: (newCard.address?.isNotEmpty ?? false) ? newCard.address : oldCard.address,
      website: (newCard.website?.isNotEmpty ?? false) ? newCard.website : oldCard.website,
      notes: (newCard.notes?.isNotEmpty ?? false) ? newCard.notes : oldCard.notes,
      imagePath: (newCard.imagePath?.isNotEmpty ?? false) ? newCard.imagePath : oldCard.imagePath,
      showPhone: newCard.showPhone,
      showEmail: newCard.showEmail,
      showAddress: newCard.showAddress,
      showWebsite: newCard.showWebsite,
      showImage: newCard.showImage,
    );
  }
  Future<void> _loadBusinessCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cardsJson = prefs.getString('business_cards');
    if (cardsJson != null) {
      final List<dynamic> decodedList = jsonDecode(cardsJson);
      setState(() {
        _businessCards
          ..clear()
          ..addAll(decodedList.map((e) => BusinessCard.fromJson(e)).toList());
        _filterCards(_searchController.text);
      });
    }
  }

  Future<void> _saveBusinessCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String cardsJson = jsonEncode(_businessCards.map((e) => e.toJson()).toList());
    await prefs.setString('business_cards', cardsJson);
  }

  void _deleteBusinessCard(BusinessCard card) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_outline,
                size: 34,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deleteConfirmTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.deleteConfirmContent,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1677FF),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        setState(() {
                          _businessCards.removeWhere((c) => c.id == card.id);
                          _filterCards(_searchController.text);
                        });

                        _saveBusinessCards();

                        scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(content: Text(l10n.cardDeleted)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.delete,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
}

  void _shareBusinessCard(BusinessCard card) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.shareCardTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 16),
                _ActionSheetItem(
                  icon: Icons.qr_code_2_outlined,
                  title: l10n.qrShare,
                  subtitle: l10n.scanToImportDirectly,
                  onTap: () {
                    Navigator.pop(context);
                    _showQrShareDialog(card);
                  },
                ),
                _ActionSheetItem(
                  icon: Icons.text_snippet_outlined,
                  title: l10n.textShare,
                  subtitle: l10n.textShareDescription,
                  onTap: () {
                    Navigator.pop(context);
                    _shareBusinessCardAsText(card);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSearchChanged() {
    _filterCards(_searchController.text);
  }

  void _filterCards(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBusinessCards = List.from(_businessCards);
      } else {
        _filteredBusinessCards = _businessCards
            .where((card) =>
                card.name.toLowerCase().contains(query.toLowerCase()) ||
                (card.company?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (card.title?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  // Future<bool> _initializeOcrPlugin() async {
  //   try {
  //     final bool? success = await _ocrPlugin.init(
  //       modelPath: 'models/ch_PP-OCRv4',
  //       labelPath: 'labels/ppocr_keys_v1.txt',
  //       cpuThreadNum: 4,
  //       cpuPowerMode: 'LITE_POWER_HIGH',
  //     );
  //     _isOcrInitialized = success == true;
  //   } catch (e) {
  //     _isOcrInitialized = false;
  //     debugPrint('Error initializing OCR Plugin: $e');
  //   }
  //   return _isOcrInitialized;
  // }

  // Future<bool> _ensureOcrInitialized({bool retryOnFailure = true}) async {
  //   _ocrInitFuture ??= _initializeOcrPlugin();
  //   bool isReady = await _ocrInitFuture!;

  //   if (!isReady && retryOnFailure) {
  //     await Future.delayed(const Duration(milliseconds: 300));
  //     _ocrInitFuture = _initializeOcrPlugin();
  //     isReady = await _ocrInitFuture!;
  //   }

  //   return isReady;
  // }

  @override
  void dispose() {
    // _ocrPlugin.release();
    _linkSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initAppLinks() async {
    if (kIsWeb) return;
    _appLinks = AppLinks();

    final initial = await _appLinks!.getInitialLink();
    if (initial != null) {
      _handleIncomingLink(initial.toString());
    }

    _linkSubscription = _appLinks!.uriLinkStream.listen((uri) {
      _handleIncomingLink(uri.toString());
    });
  }
  Future<void> _scanQrCode() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScanPage(
          onScanned: (value) async {
            Navigator.pop(context);
            _handleIncomingLink(value);
          },
        ),
      ),
    );
  }
  void _handleIncomingLink(String rawLink) async {
    if (!mounted || rawLink.trim().isEmpty) return;

    final now = DateTime.now();
    final isSameLink = _lastHandledLink == rawLink;
    final isTooSoon = _lastHandledAt != null &&
        now.difference(_lastHandledAt!).inSeconds < 2;

    if (isSameLink && isTooSoon) return;

    final card = ShareLinkService.tryParseCard(rawLink);
    if (card == null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('二维码内容无效或解析失败')),
      );
      return;
    }

    _lastHandledLink = rawLink;
    _lastHandledAt = now;

    final existingIndex = _findExistingCardIndex(card);
    final editingCard = existingIndex >= 0
        ? _mergeCard(_businessCards[existingIndex], card)
        : card;

    await _navigateToEditorPage(card: editingCard);
  }

  // Future<void> _showLinkImportDialog() async {
  //   final controller = TextEditingController();
  //   final result = await showDialog<String>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('通过链接导入'),
  //         content: TextField(
  //           controller: controller,
  //           minLines: 2,
  //           maxLines: 4,
  //           decoration: const InputDecoration(
  //             hintText: '粘贴名片分享链接',
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('取消'),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, controller.text.trim()),
  //             child: const Text('导入'),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (result == null || result.isEmpty) return;
  //   _handleIncomingLink(result);
  //   if (ShareLinkService.tryParseCard(result) == null) {
  //     scaffoldMessengerKey.currentState?.showSnackBar(
  //       const SnackBar(content: Text('链接无效，请检查后重试')),
  //     );
  //   }
  // }

  Future<void> _pickAndProcessImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      String finalRecognizedText = '';
      bool hasOcrText = false;
      if (!kIsWeb) {
        try {
          // final bool ocrReady = await _ensureOcrInitialized();
          final ocrResult = await OcrService.instance.recognizeText(image.path);
          if (ocrResult != null && ocrResult['simpleText'] != null) {
            finalRecognizedText = ocrResult['simpleText'] as String;
            hasOcrText = finalRecognizedText.trim().isNotEmpty;
          }
        } catch (e) {
          debugPrint('OCR Plugin exception: $e');
        }
      } else {
        finalRecognizedText = 'OCR Plugin does not support Web platform.';
      }

      if (hasOcrText) {
        await _navigateToEditorPage(
          recognizedText: finalRecognizedText,
          imagePath: image.path,
        );
      } else {
        await _navigateToEditorPage(imagePath: image.path);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.errorProcessingImage)),
      );
      await _navigateToEditorPage();
    }
  }

  Future<void> _scanDocument() async {
    final List<String>? newImagesPath = await CunningDocumentScanner.getPictures(
      noOfPages: 1,
      isGalleryImportAllowed: isGalleryImportAllowed,
    );
    if (newImagesPath != null) {
      setState(() {
        scannedImagesPath = newImagesPath;
      });
      if (scannedImagesPath.isNotEmpty) {
        await _processScannedImage(scannedImagesPath.first);
      }
    }
  }

  Future<void> _processScannedImage(String imagePath) async {
    try {
      String finalRecognizedText = '';
      bool hasOcrText = false;

      if (!kIsWeb) {
        try {
          final ocrResult = await OcrService.instance.recognizeText(imagePath);
          if (ocrResult != null && ocrResult['simpleText'] != null) {
            finalRecognizedText = ocrResult['simpleText'] as String;
            hasOcrText = finalRecognizedText.trim().isNotEmpty;
          }
        } catch (e) {
          debugPrint('OCR Plugin exception: $e');
        }
      }

      if (hasOcrText) {
        await _navigateToEditorPage(
          recognizedText: finalRecognizedText,
          imagePath: imagePath,
        );
      } else {
        await _navigateToEditorPage(imagePath: imagePath);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.errorProcessingImage)),
      );
      await _navigateToEditorPage(imagePath: imagePath);
    }
  }

  Future<void> _navigateToEditorPage({BusinessCard? card, String? recognizedText, String? imagePath}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(
          businessCard: card,
          recognizedText: recognizedText,
          imagePath: imagePath,
        ),
      ),
    );

    if (result != null) {
      if (result is BusinessCard) {
        setState(() {
          final index = _businessCards.indexWhere((element) => element.id == result.id);
          if (index != -1) {
            _businessCards[index] = result;
          } else {
            _businessCards.add(result);
          }
          _filterCards(_searchController.text);
        });
        _saveBusinessCards();
      } else if (result == 'delete' && card != null) {
        _deleteBusinessCard(card);
      }
    }
  }

  void _showImportOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.importCard,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 16),
                _ActionSheetItem(
                  icon: Icons.document_scanner_outlined,
                  title: l10n.cameraImport,
                  subtitle: l10n.cameraImportDescription,
                  onTap: () {
                    Navigator.pop(context);
                    _scanDocument();
                  },
                ),
                _ActionSheetItem(
                  icon: Icons.photo_library_outlined,
                  title: l10n.galleryImport,
                  subtitle: l10n.galleryImportDescription,
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndProcessImage(source: ImageSource.gallery);
                  },
                ),
                _ActionSheetItem(
                  icon: Icons.edit_note_outlined,
                  title: l10n.manualInput,
                  subtitle: l10n.manualInputDescription,
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToEditorPage();
                  },
                ),
                // _ActionSheetItem(
                //   icon: Icons.link_outlined,
                //   title: '链接导入',
                //   subtitle: '粘贴分享链接，一键导入别人分享的名片',
                //   onTap: () async {
                //     Navigator.pop(context);
                //     await _showLinkImportDialog();
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        _isSearching = false;
        _searchController.clear();
      }
    });
  }

  Widget _buildOcrList() {
    final l10n = AppLocalizations.of(context)!;
    final displayCards = _isSearching ? _filteredBusinessCards : _businessCards;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${displayCards.length}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.savedCards,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: const Color(0xFFE5E7EB),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.searchPlaceholder,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () => _searchController.clear(),
                              icon: const Icon(Icons.close, size: 18),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1677FF)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: displayCards.isEmpty
              ? _buildEmptyState(l10n)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: displayCards.length,
                  itemBuilder: (context, index) {
                    final card = displayCards[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Slidable(
                        key: ValueKey(card.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => _shareBusinessCard(card),
                              backgroundColor: const Color(0xFF1677FF),
                              foregroundColor: Colors.white,
                              icon: Icons.share_outlined,
                              label: l10n.share,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(14),
                              ),
                            ),
                            SlidableAction(
                              onPressed: (context) => _deleteBusinessCard(card),
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              icon: Icons.delete_outline,
                              label: l10n.delete,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(14),
                              ),
                            ),
                          ],
                        ),
                        child: _BusinessCardListTile(
                          card: card,
                          onTap: () => _navigateToEditorPage(card: card),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCEBFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF1677FF)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1677FF)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.contact_page_outlined, size: 34, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 18),
            Text(
              _searchController.text.isNotEmpty ? l10n.noMatchFound : l10n.startDigitalCardHolder,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty ? l10n.tryAnotherKeyword : l10n.scanButtonDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? l10n.cardManagement
              : (_selectedIndex == 1 ? l10n.myCards : l10n.settings),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        actions: _selectedIndex == 0
            ? [
                TextButton.icon(
                  onPressed: _scanQrCode,
                  icon: const Icon(Icons.qr_code_scanner_outlined, size: 20),
                  label: Text(
                    l10n.scan,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOcrList(),
          const CardPage(showAppBar: false),
          const OcrTestPage(showAppBar: false),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _showImportOptions,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1677FF),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x261677FF),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.importCard,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l10n.home,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.credit_card_outlined,
                  activeIcon: Icons.credit_card,
                  label: l10n.cards,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 2,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: l10n.settings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessCardListTile extends StatelessWidget {
  const _BusinessCardListTile({required this.card, required this.onTap});

  final BusinessCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: card.imagePath != null && card.imagePath!.isNotEmpty
                    ? Image.file(File(card.imagePath!), fit: BoxFit.cover)
                    : const Icon(Icons.person_outline, color: Color(0xFF6B7280)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    if ((card.title ?? '').isNotEmpty)
                      Text(
                        card.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                    if ((card.company ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          card.company!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSheetItem extends StatelessWidget {
  const _ActionSheetItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF1677FF)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class QrScanPage extends StatefulWidget {
  const QrScanPage({
    super.key,
    required this.onScanned,
  });

  final ValueChanged<String> onScanned;

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码导入'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_handled) return;
              final codes = capture.barcodes;
              for (final code in codes) {
                final raw = code.rawValue;
                if (raw != null && raw.trim().isNotEmpty) {
                  _handled = true;
                  widget.onScanned(raw);
                  break;
                }
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                '请将二维码放入框内，扫描后会自动进入编辑页',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}