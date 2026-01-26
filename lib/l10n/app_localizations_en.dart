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
  String get saveAndReturn => 'Save and Return';

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
}
