// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Business Card Maker';

  @override
  String get settingsAndToolbox => 'Settings & Toolbox';

  @override
  String get basicSettings => 'Basic Settings';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get followSystem => 'Follow System';

  @override
  String get simplifiedChinese => 'Simplified Chinese';

  @override
  String get english => 'English';

  @override
  String get smartToolbox => 'Smart Toolbox';

  @override
  String get smartTextExtraction => 'Smart Text Extraction';

  @override
  String get extractStructuredInfo =>
      'Extract structured contact info from images';

  @override
  String get selectImage => 'Select Image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get extractionPreview => 'Extraction Preview';

  @override
  String get about => 'About';

  @override
  String get softwareVersion => 'Software Version';

  @override
  String get ocrEngineStatus => 'OCR Engine Status';

  @override
  String get ready => 'Ready';

  @override
  String get name => 'Name';

  @override
  String get company => 'Company';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String toolFailed(String error) {
    return 'Tool failed: $error';
  }

  @override
  String get cardManagement => 'Card Management';

  @override
  String get myCards => 'My Cards';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get searchPlaceholder => 'Search name, company or title...';

  @override
  String get noMatchFound => 'No matching cards found';

  @override
  String get tryAnotherKeyword => 'Try searching with another keyword';

  @override
  String get startDigitalCardHolder => 'Start your digital card holder';

  @override
  String get scanButtonDescription =>
      'Click the button below to scan a business card, and we will automatically recognize and save the contact information for you.';

  @override
  String get importCard => 'Import Card';

  @override
  String get cameraImport => 'Camera Import';

  @override
  String get galleryImport => 'Gallery Import';

  @override
  String get manualInput => 'Manual Input';

  @override
  String get home => 'Home';

  @override
  String get cards => 'Cards';

  @override
  String get settings => 'Settings';

  @override
  String get deleteConfirmTitle => 'Confirm Delete';

  @override
  String get deleteConfirmContent =>
      'Are you sure you want to delete this card? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get cardDeleted => 'Card deleted';

  @override
  String get share => 'Share';

  @override
  String get jobTitle => 'Title';

  @override
  String get website => 'Website';

  @override
  String get fromApp => 'From: Business Card Maker';

  @override
  String get confirm => 'Confirm';

  @override
  String get errorProcessingImage =>
      'Failed to process image, please try again.';

  @override
  String get editCardInfo => 'Edit Card Info';

  @override
  String get originalImage => 'Original Image';

  @override
  String get clickToChangeImage => 'Click to change image';

  @override
  String get detailedInfo => 'Detailed Info';

  @override
  String get pleaseEnterName => 'Please enter name';

  @override
  String get pleaseEnterTitle => 'Please enter title';

  @override
  String get pleaseEnterCompany => 'Please enter company name';

  @override
  String get pleaseEnterPhone => 'Please enter phone number';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterWebsite => 'Please enter website';

  @override
  String get pleaseEnterAddress => 'Please enter address';

  @override
  String get notes => 'Notes';

  @override
  String get pleaseEnterNotes => 'Please enter notes';

  @override
  String get saveAndReturn => 'Save Card';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get confirmClear => 'Confirm Clear';

  @override
  String get clearConfirmContent =>
      'This will clear all current input and saved card data. Are you sure?';

  @override
  String get clearData => 'Clear Data';

  @override
  String get dataCleared => 'Card data cleared';

  @override
  String get pleaseEnterNameBeforeSaving =>
      'Please enter at least a name before saving';

  @override
  String get cardSavedLocally => 'Card successfully saved locally';

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get layoutReset => 'Layout reset to default positions';

  @override
  String get reset => 'Reset';

  @override
  String get template => 'Template';

  @override
  String get export => 'Export';

  @override
  String get shareMyCard => 'Share my business card';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get scanToSaveContact => 'Scan to save contact';

  @override
  String get close => 'Close';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get saveCard => 'Save Card';

  @override
  String templateCount(int count) {
    return '$count design elements';
  }

  @override
  String templateName(String id) {
    return 'Template $id';
  }

  @override
  String get customBackground => 'Custom Background';

  @override
  String get selectTemplate => 'Select Template';

  @override
  String get uploadBackground => 'Upload Background';

  @override
  String get useLocalImage => 'Use Local Image';

  @override
  String get ocrWebNotSupported => 'OCR Plugin does not support Web platform.';

  @override
  String get cardPreview => 'Card Preview';

  @override
  String get backToEdit => 'Back to Edit';

  @override
  String get savedTemplate => 'Saved Template';

  @override
  String get unknownName => 'Unknown Name';

  @override
  String get clickPlusToImport => 'Click the + button to import a card';

  @override
  String get stepOneSelectBackground => 'Step 1: Select Background';

  @override
  String get stepTwoSelectLayout => 'Step 2: Select Layout';

  @override
  String get backgroundStepDescription =>
      'Choose an image background, solid color, or upload your own background image.';

  @override
  String get layoutStepDescription =>
      'Layout determines how name, company, and contact info are arranged.';

  @override
  String get applyStyle => 'Apply Style';

  @override
  String get imageBackground1 => 'Image Background 1';

  @override
  String get imageBackground2 => 'Image Background 2';

  @override
  String get imageBackground3 => 'Image Background 3';

  @override
  String get imageBackground4 => 'Image Background 4';

  @override
  String get solidBlue => 'Solid Blue';

  @override
  String get darkGray => 'Dark Gray';

  @override
  String get lightGreen => 'Light Green';

  @override
  String get lightGray => 'Light Gray';

  @override
  String get customBackgroundSelected => 'Custom Background Selected';

  @override
  String get layoutClassic => 'Classic Business';

  @override
  String get layoutClassicDesc =>
      'Main info top-left, avatar top-right, contacts displayed vertically below';

  @override
  String get layoutCenter => 'Centered Minimalist';

  @override
  String get layoutCenterDesc =>
      'Centered layout, ideal for clean personal business cards';

  @override
  String get layoutBottomBar => 'Bottom Bar Info';

  @override
  String get layoutBottomBarDesc =>
      'Identity info at top, contacts displayed horizontally at bottom';

  @override
  String get layoutCustom => 'Custom Layout';

  @override
  String get layoutCustomDesc =>
      'Drag elements freely to create your personalized card layout';

  @override
  String get editDigitalCard => 'Edit Digital Card';

  @override
  String get realtimePreview => 'Real-time Preview';

  @override
  String get avatar => 'Avatar';

  @override
  String get avatarUploadHint =>
      'Upload to see avatar effect in the card preview in real-time.';

  @override
  String get upload => 'Upload';

  @override
  String get contactInfo => 'Contact Info';

  @override
  String get displayContent => 'Display Content';

  @override
  String get showPhone => 'Show Phone';

  @override
  String get showEmail => 'Show Email';

  @override
  String get showAddress => 'Show Address';

  @override
  String get showWebsite => 'Show Website';

  @override
  String get showAvatar => 'Show Avatar';

  @override
  String get sampleAddress => 'Sample Address';

  @override
  String get sourceImage => 'Source Image';

  @override
  String get sourceImageHint =>
      'Used to verify OCR results. Tap to choose another image.';

  @override
  String get coreInfo => 'Core Info';

  @override
  String get general => 'General';

  @override
  String get recognitionEngine => 'Recognition Engine';

  @override
  String get ocrEngineReadyDescription =>
      'The recognition engine is initialized and ready for business card recognition.';

  @override
  String get ocrEngineNotReadyDescription =>
      'The recognition engine is not ready yet. Please try again later.';

  @override
  String get notReady => 'Not Ready';

  @override
  String get aboutAppSection => 'About App';

  @override
  String get currentVersion => 'Current Installed Version';

  @override
  String get aboutThisApp => 'About This App';

  @override
  String get viewAppIntro => 'View app introduction and feature overview';

  @override
  String get appIntroDescription =>
      'An intelligent business card recognition and digital card management app based on Flutter, supporting OCR, template display, and QR/link import.';

  @override
  String get gotIt => 'Got it';

  @override
  String get completeDigitalCardInfoFirst =>
      'Please complete your digital business card information first';

  @override
  String get shareCardTitle => 'Share Card';

  @override
  String get qrShare => 'QR Code Share';

  @override
  String get qrShareDescription =>
      'Generate a QR code so others can scan it with CardGenius to import directly';

  @override
  String get textShare => 'Text Share';

  @override
  String get textShareDescription =>
      'Share card information as a text link, which can be imported by opening it in a browser';

  @override
  String get imageShare => 'Image Share';

  @override
  String get imageShareDescription =>
      'Export the current digital business card as an image and share it';

  @override
  String get scanToImportDirectly => 'Scan with CardGenius to import directly';

  @override
  String get edit => 'Edit';

  @override
  String get completeDigitalCardInfoPrompt =>
      'Complete your digital business card information first';

  @override
  String get completeDigitalCardInfoHint =>
      'Later you can add an avatar, adjust displayed fields, and choose different templates and background styles on the edit page.';

  @override
  String get cardManagementDescription =>
      'Used to display, share, and manage your digital business card presence.';

  @override
  String get templateEditShareHint =>
      'Templates control background and layout. The edit page controls avatar, displayed fields, and personalized content settings. Share lets you send your card information to others in different formats.';

  @override
  String get cameraImportDescription =>
      'Capture and auto-crop a business card to recognize contact information';

  @override
  String get galleryImportDescription =>
      'Choose an existing business card image from the gallery for recognition';

  @override
  String get manualInputDescription =>
      'Skip image recognition and add a contact manually';

  @override
  String get savedCards => 'Saved Cards';

  @override
  String get scan => 'Scan';

  @override
  String get ocrToolbox => 'OCR Toolbox';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get result => 'Result';

  @override
  String get ocrResultPlaceholder => 'OCR result will appear here.';

  @override
  String get create => 'Create';
}
