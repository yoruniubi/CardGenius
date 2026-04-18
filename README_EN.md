# CardGenius

![logo](./assets/logo.png)

English | [简体中文](./README.md)

**CardGenius** is an intelligent business card recognition and management app built with Flutter. Powered by OCR, it helps users extract structured information from physical cards and provides complete workflows for editing, template styling, sharing, and importing.

## 🚀 Key Features

-   **🔍 Smart OCR Extraction**: Integrated with PaddleOCR (via custom `ocr_plugin`), supporting recognition from camera captures and gallery images.
-   **📇 Card Management**: Full CRUD support for digital business cards, with local persistence for quick daily management.
-   **📄 Document Scanning & Import**: Built-in document scanning (`cunning_document_scanner`) to improve card image quality before recognition.
-   **🎨 Template Editing & Personalization**: Multiple templates, customizable layout styles, and custom background image import.
-   **🔗 Flexible Sharing**: Share via QR code, text link, or exported card image.
-   **📲 QR Import**: Built-in scanning (`mobile_scanner`) to import shared card links directly.
-   **🌐 Multi-language Support**: Supports Simplified Chinese and English, including “follow system” locale behavior.
-   **✨ Modern Mobile UI**: Built with `antd_flutter_mobile` for a consistent and clean mobile interaction experience.

## 🛠️ Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/)
-   **UI Components**: `antd_flutter_mobile`
-   **OCR Engine**: PaddleOCR (integrated via custom `ocr_plugin`)
-   **Scanning**: `cunning_document_scanner`, `mobile_scanner`
-   **Share & QR**: `share_plus`, `qr_flutter`, `app_links`
-   **Storage**: `shared_preferences`
-   **State Management**: Provider (`LocaleProvider`)
-   **Image & File**: `image_picker`, `file_picker`, `screenshot`

## 📦 Getting Started

### Prerequisites
-   Flutter SDK: `^3.8.1`
-   Android SDK / iOS Xcode (depending on target platform)

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/your-repo/business_card_ocr.git
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run
    ```
