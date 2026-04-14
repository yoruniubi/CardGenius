import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Card Maker'**
  String get appTitle;

  /// No description provided for @settingsAndToolbox.
  ///
  /// In en, this message translates to:
  /// **'Settings & Toolbox'**
  String get settingsAndToolbox;

  /// No description provided for @basicSettings.
  ///
  /// In en, this message translates to:
  /// **'Basic Settings'**
  String get basicSettings;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @simplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get simplifiedChinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @smartToolbox.
  ///
  /// In en, this message translates to:
  /// **'Smart Toolbox'**
  String get smartToolbox;

  /// No description provided for @smartTextExtraction.
  ///
  /// In en, this message translates to:
  /// **'Smart Text Extraction'**
  String get smartTextExtraction;

  /// No description provided for @extractStructuredInfo.
  ///
  /// In en, this message translates to:
  /// **'Extract structured contact info from images'**
  String get extractStructuredInfo;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @extractionPreview.
  ///
  /// In en, this message translates to:
  /// **'Extraction Preview'**
  String get extractionPreview;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @softwareVersion.
  ///
  /// In en, this message translates to:
  /// **'Software Version'**
  String get softwareVersion;

  /// No description provided for @ocrEngineStatus.
  ///
  /// In en, this message translates to:
  /// **'OCR Engine Status'**
  String get ocrEngineStatus;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @toolFailed.
  ///
  /// In en, this message translates to:
  /// **'Tool failed: {error}'**
  String toolFailed(String error);

  /// No description provided for @cardManagement.
  ///
  /// In en, this message translates to:
  /// **'Card Management'**
  String get cardManagement;

  /// No description provided for @myCards.
  ///
  /// In en, this message translates to:
  /// **'My Cards'**
  String get myCards;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search name, company or title...'**
  String get searchPlaceholder;

  /// No description provided for @noMatchFound.
  ///
  /// In en, this message translates to:
  /// **'No matching cards found'**
  String get noMatchFound;

  /// No description provided for @tryAnotherKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try searching with another keyword'**
  String get tryAnotherKeyword;

  /// No description provided for @startDigitalCardHolder.
  ///
  /// In en, this message translates to:
  /// **'Start your digital card holder'**
  String get startDigitalCardHolder;

  /// No description provided for @scanButtonDescription.
  ///
  /// In en, this message translates to:
  /// **'Click the button below to scan a business card, and we will automatically recognize and save the contact information for you.'**
  String get scanButtonDescription;

  /// No description provided for @importCard.
  ///
  /// In en, this message translates to:
  /// **'Import Card'**
  String get importCard;

  /// No description provided for @cameraImport.
  ///
  /// In en, this message translates to:
  /// **'Camera Import'**
  String get cameraImport;

  /// No description provided for @galleryImport.
  ///
  /// In en, this message translates to:
  /// **'Gallery Import'**
  String get galleryImport;

  /// No description provided for @manualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual Input'**
  String get manualInput;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card? This action cannot be undone.'**
  String get deleteConfirmContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Card deleted'**
  String get cardDeleted;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get jobTitle;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @fromApp.
  ///
  /// In en, this message translates to:
  /// **'From: Business Card Maker'**
  String get fromApp;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @errorProcessingImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image, please try again.'**
  String get errorProcessingImage;

  /// No description provided for @editCardInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Card Info'**
  String get editCardInfo;

  /// No description provided for @originalImage.
  ///
  /// In en, this message translates to:
  /// **'Original Image'**
  String get originalImage;

  /// No description provided for @clickToChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Click to change image'**
  String get clickToChangeImage;

  /// No description provided for @detailedInfo.
  ///
  /// In en, this message translates to:
  /// **'Detailed Info'**
  String get detailedInfo;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter title'**
  String get pleaseEnterTitle;

  /// No description provided for @pleaseEnterCompany.
  ///
  /// In en, this message translates to:
  /// **'Please enter company name'**
  String get pleaseEnterCompany;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterWebsite.
  ///
  /// In en, this message translates to:
  /// **'Please enter website'**
  String get pleaseEnterWebsite;

  /// No description provided for @pleaseEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter address'**
  String get pleaseEnterAddress;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @pleaseEnterNotes.
  ///
  /// In en, this message translates to:
  /// **'Please enter notes'**
  String get pleaseEnterNotes;

  /// No description provided for @saveAndReturn.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveAndReturn;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @confirmClear.
  ///
  /// In en, this message translates to:
  /// **'Confirm Clear'**
  String get confirmClear;

  /// No description provided for @clearConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'This will clear all current input and saved card data. Are you sure?'**
  String get clearConfirmContent;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'Card data cleared'**
  String get dataCleared;

  /// No description provided for @pleaseEnterNameBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least a name before saving'**
  String get pleaseEnterNameBeforeSaving;

  /// No description provided for @cardSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Card successfully saved locally'**
  String get cardSavedLocally;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveFailed(String error);

  /// No description provided for @layoutReset.
  ///
  /// In en, this message translates to:
  /// **'Layout reset to default positions'**
  String get layoutReset;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @shareMyCard.
  ///
  /// In en, this message translates to:
  /// **'Share my business card'**
  String get shareMyCard;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @scanToSaveContact.
  ///
  /// In en, this message translates to:
  /// **'Scan to save contact'**
  String get scanToSaveContact;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @saveCard.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveCard;

  /// No description provided for @templateCount.
  ///
  /// In en, this message translates to:
  /// **'{count} design elements'**
  String templateCount(int count);

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template {id}'**
  String templateName(String id);

  /// No description provided for @customBackground.
  ///
  /// In en, this message translates to:
  /// **'Custom Background'**
  String get customBackground;

  /// No description provided for @selectTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select Template'**
  String get selectTemplate;

  /// No description provided for @uploadBackground.
  ///
  /// In en, this message translates to:
  /// **'Upload Background'**
  String get uploadBackground;

  /// No description provided for @useLocalImage.
  ///
  /// In en, this message translates to:
  /// **'Use Local Image'**
  String get useLocalImage;

  /// No description provided for @ocrWebNotSupported.
  ///
  /// In en, this message translates to:
  /// **'OCR Plugin does not support Web platform.'**
  String get ocrWebNotSupported;

  /// No description provided for @cardPreview.
  ///
  /// In en, this message translates to:
  /// **'Card Preview'**
  String get cardPreview;

  /// No description provided for @backToEdit.
  ///
  /// In en, this message translates to:
  /// **'Back to Edit'**
  String get backToEdit;

  /// No description provided for @savedTemplate.
  ///
  /// In en, this message translates to:
  /// **'Saved Template'**
  String get savedTemplate;

  /// No description provided for @unknownName.
  ///
  /// In en, this message translates to:
  /// **'Unknown Name'**
  String get unknownName;

  /// No description provided for @clickPlusToImport.
  ///
  /// In en, this message translates to:
  /// **'Click the + button to import a card'**
  String get clickPlusToImport;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
