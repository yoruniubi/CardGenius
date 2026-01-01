import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_plugin/ocr_plugin.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:business_card_ocr/models/business_card.dart';
import 'package:business_card_ocr/pages/editor_page.dart';
import 'package:business_card_ocr/pages/card_management.dart'; // 导入名片管理页面
import 'package:business_card_ocr/pages/test.dart'; // 导入测试页面
import 'package:business_card_ocr/providers/locale_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart'; // 导入 shadcn_ui 库
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:business_card_ocr/l10n/app_localizations.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// MyApp Widget 只负责创建 MaterialApp
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
    return ShadApp(
      title: '名片智造',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return ScaffoldMessenger(
          key: scaffoldMessengerKey,
          child: child!,
        );
      },
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadColorScheme(
          background: Colors.white,
          foreground: Color(0xFF020817),
          card: Colors.white,
          cardForeground: Color(0xFF020817),
          popover: Colors.white,
          popoverForeground: Color(0xFF020817),
          primary: Color(0xFF0F172A),
          primaryForeground: Color(0xFFF8FAFC),
          secondary: Color(0xFFF1F5F9),
          secondaryForeground: Color(0xFF0F172A),
          muted: Color(0xFFF1F5F9),
          mutedForeground: Color(0xFF64748B),
          accent: Color(0xFFF1F5F9),
          accentForeground: Color(0xFF0F172A),
          destructive: Color(0xFFEF4444),
          destructiveForeground: Color(0xFFF8FAFC),
          border: Color(0xFFE2E8F0),
          input: Color(0xFFE2E8F0),
          ring: Color(0xFF0F172A),
          selection: Color(0xFFCBD5E1),
        ),
      ),
      // 定义路由
      routes: {
        '/': (context) => const HomePage(),
        '/cardManagement': (context) => const CardPage(),
        '/testPage': (context) => const OcrTestPage(),
      },
      initialRoute: '/',
    );
  }
}

// 新建的 HomePage Widget，它包含了页面的实际内容
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final OcrPlugin _ocrPlugin = OcrPlugin();
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
    _initializeOcrPlugin();
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
        _businessCards.clear();
        _businessCards.addAll(decodedList.map((e) => BusinessCard.fromJson(e)).toList());
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

  Future<void> _initializeOcrPlugin() async {
    try {
      final bool? success = await _ocrPlugin.init(
        modelPath: "models/ch_PP-OCRv4",
        labelPath: "labels/ppocr_keys_v1.txt",
        cpuThreadNum: 4,
        cpuPowerMode: "LITE_POWER_HIGH",
      );
      if (success == true) {
        debugPrint('OCR Plugin initialized successfully.');
      } else {
        debugPrint('OCR Plugin initialization failed.');
      }
    } catch (e) {
      debugPrint('Error initializing OCR Plugin: $e');
    }
  }

  @override
  void dispose() {
    _ocrPlugin.release();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcessImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      String finalRecognizedText = '';
      if (!kIsWeb) {
        debugPrint('在移动端尝试 Paddle OCR...');
        try {
          final ocrResult = await _ocrPlugin.recognizeText(image.path);
          if (ocrResult != null && ocrResult['simpleText'] != null) {
            finalRecognizedText = ocrResult['simpleText'] as String;
            debugPrint("OCR Plugin 识别结果: $finalRecognizedText");
          } else {
            debugPrint("OCR Plugin 未识别到文本或返回格式不正确。");
          }
        } catch (e) {
          debugPrint('OCR Plugin 抛出异常: $e');
        }
      } else {
        finalRecognizedText = 'OCR Plugin 不支持Web平台。';
        debugPrint(finalRecognizedText);
      }

      if (finalRecognizedText.isNotEmpty && finalRecognizedText != 'OCR Plugin 不支持Web平台。') {
        await _navigateToEditorPage(recognizedText: finalRecognizedText, imagePath: image.path);
      } else {
        await _navigateToEditorPage(imagePath: image.path);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.errorProcessingImage)),
      );
      debugPrint('处理图片时发生顶层错误: $e');
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
      debugPrint('Scanned Images path: $scannedImagesPath');
      if (scannedImagesPath.isNotEmpty) {
        await _processScannedImage(scannedImagesPath.first);
      }
    }
  }

  Future<void> _processScannedImage(String imagePath) async {
    try {
      String finalRecognizedText = '';

      if (!kIsWeb) {
        debugPrint('处理扫描的图片，尝试 Paddle OCR...');
        try {
          final ocrResult = await _ocrPlugin.recognizeText(imagePath);
          if (ocrResult != null && ocrResult['simpleText'] != null) {
            finalRecognizedText = ocrResult['simpleText'] as String;
            debugPrint("OCR Plugin 识别结果: $finalRecognizedText");
          } else {
            debugPrint("OCR Plugin 未识别到文本或返回格式不正确。");
          }
        } catch (e) {
          debugPrint('OCR Plugin 抛出异常: $e');
        }
      } else {
        finalRecognizedText = 'OCR Plugin 不支持Web平台。';
        debugPrint(finalRecognizedText);
      }

      if (finalRecognizedText.isNotEmpty && finalRecognizedText != 'OCR Plugin 不支持Web平台。') {
        await _navigateToEditorPage(recognizedText: finalRecognizedText, imagePath: imagePath);
      } else {
        await _navigateToEditorPage(imagePath: imagePath);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.errorProcessingImage)),
      );
      debugPrint('处理扫描图片时发生错误: $e');
      await _navigateToEditorPage(imagePath: imagePath);
    }
  }

  Future<void> _navigateToEditorPage({BusinessCard? card, String? recognizedText, String? imagePath}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(businessCard: card, recognizedText: recognizedText, imagePath: imagePath),
      ),
    );

    if (result != null) {
      if (result is BusinessCard) {
        // Save or Update
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
        // Delete
        _deleteBusinessCard(card);
      }
    }
  }

  void _showImportOptions() {
    final theme = ShadTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.importCard,
                  style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildImportOption(
                      icon: Icons.camera_alt_rounded,
                      label: l10n.cameraImport,
                      onTap: () {
                        Navigator.pop(context);
                        _scanDocument();
                      },
                    ),
                    _buildImportOption(
                      icon: Icons.image_rounded,
                      label: l10n.galleryImport,
                      onTap: () {
                        Navigator.pop(context);
                        _pickAndProcessImage(source: ImageSource.gallery);
                      },
                    ),
                    _buildImportOption(
                      icon: Icons.edit_note_rounded,
                      label: l10n.manualInput,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToEditorPage();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImportOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 30,
              color: theme.colorScheme.primaryForeground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.small.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
        ],
      ),
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
    final theme = ShadTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final displayCards = _isSearching ? _filteredBusinessCards : _businessCards;

    if (displayCards.isEmpty) {
      if (_isSearching && _searchController.text.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noMatchFound,
                style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tryAnotherKeyword,
                style: theme.textTheme.muted,
              ),
            ],
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.contact_page_outlined,
                size: 48,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.startDigitalCardHolder,
              style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                l10n.scanButtonDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.muted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: displayCards.length,
      itemBuilder: (context, index) {
        final card = displayCards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Slidable(
            key: ValueKey(card.id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => _shareBusinessCard(card),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.primaryForeground,
                  icon: Icons.share_rounded,
                  label: l10n.share,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(0)),
                ),
                SlidableAction(
                  onPressed: (context) => _deleteBusinessCard(card),
                  backgroundColor: theme.colorScheme.destructive,
                  foregroundColor: theme.colorScheme.destructiveForeground,
                  icon: Icons.delete_rounded,
                  label: l10n.delete,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                ),
              ],
            ),
            child: ShadCard(
              padding: const EdgeInsets.all(0),
              child: InkWell(
                onTap: () => _navigateToEditorPage(card: card),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: theme.colorScheme.muted,
                          border: Border.all(color: theme.colorScheme.border, width: 0.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: card.imagePath != null && card.imagePath!.isNotEmpty
                            ? Image.file(
                                File(card.imagePath!),
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.person, color: theme.colorScheme.mutedForeground),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            if (card.title != null && card.title!.isNotEmpty)
                              Text(
                                card.title!,
                                style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground),
                              ),
                            if (card.company != null && card.company!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  card.company!,
                                  style: theme.textTheme.small.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = _buildOcrList();
        break;
      case 1:
        body = const CardPage();
        break;
      case 2:
        body = const OcrTestPage();
        break;
      default:
        body = _buildOcrList();
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        centerTitle: false,
        title: _isSearching && _selectedIndex == 0
            ? ShadInput(
                controller: _searchController,
                placeholder: Text(l10n.searchPlaceholder),
                autofocus: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.search_rounded, size: 18, color: theme.colorScheme.mutedForeground),
                ),
                trailing: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: Icon(Icons.cancel_rounded, size: 18, color: theme.colorScheme.mutedForeground),
                      )
                    : null,
              )
            : Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _selectedIndex == 0 ? l10n.cardManagement : (_selectedIndex == 1 ? l10n.myCards : l10n.systemSettings),
                  style: theme.textTheme.h3.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchController.clear();
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedIndex == 0
          ? ShadButton(
              width: 180,
              height: 54,
              onPressed: _showImportOptions,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.document_scanner_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(l10n.importCard, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_rounded),
              activeIcon: const Icon(Icons.grid_view_rounded),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.credit_card_rounded),
              activeIcon: const Icon(Icons.credit_card_rounded),
              label: l10n.cards,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              activeIcon: const Icon(Icons.settings_rounded),
              label: l10n.settings,
            ),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: theme.colorScheme.background,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.mutedForeground,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
