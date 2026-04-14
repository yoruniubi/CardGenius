import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:ocr_plugin/ocr_plugin.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:business_card_ocr/models/business_card.dart';
import 'package:business_card_ocr/pages/editor_page.dart';
import 'package:business_card_ocr/pages/card_management.dart';
import 'package:business_card_ocr/pages/test.dart';
import 'package:business_card_ocr/providers/locale_provider.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';
import 'package:antd_flutter_mobile/index.dart';
import 'package:business_card_ocr/services/ocr_service.dart';
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
      ),
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

  @override
  void initState() {
    super.initState();
    // _ocrInitFuture = _initializeOcrPlugin();
    _loadBusinessCards();
    _filteredBusinessCards = _businessCards;
    _searchController.addListener(_onSearchChanged);
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
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _shareBusinessCard(BusinessCard card) {
    final l10n = AppLocalizations.of(context)!;
    final StringBuffer sb = StringBuffer();
    sb.writeln('${l10n.name}: ${card.name}');
    if (card.title != null && card.title!.isNotEmpty) sb.writeln('${l10n.jobTitle}: ${card.title}');
    if (card.company != null && card.company!.isNotEmpty) sb.writeln('${l10n.company}: ${card.company}');
    if (card.phone != null && card.phone!.isNotEmpty) sb.writeln('${l10n.phone}: ${card.phone}');
    if (card.email != null && card.email!.isNotEmpty) sb.writeln('${l10n.email}: ${card.email}');
    if (card.address != null && card.address!.isNotEmpty) sb.writeln('${l10n.address}: ${card.address}');
    if (card.website != null && card.website!.isNotEmpty) sb.writeln('${l10n.website}: ${card.website}');
    sb.writeln(l10n.fromApp);
    Share.share(sb.toString());
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
    _searchController.dispose();
    super.dispose();
  }

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
                  subtitle: '拍摄并自动裁切名片后识别联系人信息',
                  onTap: () {
                    Navigator.pop(context);
                    _scanDocument();
                  },
                ),
                _ActionSheetItem(
                  icon: Icons.photo_library_outlined,
                  title: l10n.galleryImport,
                  subtitle: '从相册选择已有名片图片进行识别',
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndProcessImage(source: ImageSource.gallery);
                  },
                ),
                _ActionSheetItem(
                  icon: Icons.edit_note_outlined,
                  title: l10n.manualInput,
                  subtitle: '不识别图片，直接手动新增联系人',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToEditorPage();
                  },
                ),
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
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '扫描导入名片',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _businessCards.isEmpty
                                    ? l10n.scanButtonDescription
                                    : '继续导入新的名片，并统一沉淀到本地联系人库。',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.document_scanner_outlined, color: Color(0xFF1677FF)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _showImportOptions,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          l10n.importCard,
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1677FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '已保存名片',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
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
            ],
          ),
        ),
        Expanded(
          child: displayCards.isEmpty
              ? _buildEmptyState(l10n)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                            ),
                            SlidableAction(
                              onPressed: (context) => _deleteBusinessCard(card),
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              icon: Icons.delete_outline,
                              label: l10n.delete,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
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
          _selectedIndex == 0 ? l10n.cardManagement : (_selectedIndex == 1 ? l10n.myCards : l10n.settings),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOcrList(),
          const CardPage(showAppBar: false),
          const OcrTestPage(showAppBar: false),
        ],
      ),
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
