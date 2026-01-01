# CardGenius

![logo](./assets/logo.png)

English | [简体中文](./README.md)

**CardGenius** is an intelligent business card recognition and management tool built with Flutter. Leveraging advanced OCR technology, it helps users quickly extract structured information from physical business cards and provides convenient features for storage, editing, sharing, and exporting.

## 🚀 Key Features

-   **🔍 Smart Text Extraction (OCR)**: Integrated with PaddleOCR, supporting text recognition from both gallery images and direct camera captures.
-   **📇 Card Management**: Full CRUD (Create, Read, Update, Delete) support to easily manage your digital card collection.
-   **📄 Document Scanning**: Built-in document scanner to automatically optimize business card photos for better recognition.
-   **🎨 Templates & Export**: Multiple card templates available. Export your card information as images or share them directly.
-   **📲 Scan to Save**: Automatically generates contact QR codes. Scan to quickly save contact details to your phone's address book.
-   **🌐 Multi-language Support**: Supports both Simplified Chinese and English, adapting to system language settings.
-   **✨ Modern UI Design**: Built with `shadcn_ui` for a clean, beautiful, and intuitive user experience.

## 🛠️ Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/)
-   **UI Components**: [Shadcn UI (Flutter)](https://shadcn-ui.com/)
-   **OCR Engine**: PaddleOCR (integrated via custom `ocr_plugin`)
-   **Scanning**: `cunning_document_scanner`
-   **Storage**: `shared_preferences`
-   **State Management**: Provider (LocaleProvider)
-   **Icons**: Lucide Icons

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

## 📂 Project Structure

-   `lib/models/`: Data models (BusinessCard, Element, Template, etc.).
-   `lib/pages/`: Application pages (Home, Editor, Management, Test, etc.).
-   `lib/providers/`: State management.
-   `lib/l10n/`: Internationalization (i18n) files.
-   `ocr_plugin/`: Custom OCR plugin implementation.

## 📝 Roadmap
- [ ] Add more professional card templates
- [ ] Cloud synchronization support
- [ ] Improve OCR recognition accuracy
- [ ] Add category tags for card organization

## 📄 License
This project is licensed under the [MIT License](LICENSE).
