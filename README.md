# CardGenius (名片智造)

![logo](./assets/logo.png)

[English](./README_EN.md) | 简体中文

**CardGenius (名片智造)** 是一款基于 Flutter 开发的智能名片识别与管理工具。它利用先进的 OCR 技术，帮助用户快速从纸质名片中提取结构化信息，并提供便捷的存储、编辑、分享及导出功能。

## 🚀 主要功能

-   **🔍 智能文字提取 (OCR)**：集成 PaddleOCR，支持从相册选择或直接拍照识别名片文字。
-   **📇 名片管理**：支持名片的增删改查，轻松管理您的数字名片夹。
-   **📄 文档扫描**：内置文档扫描功能，自动优化名片拍摄效果。
-   **🎨 模板与导出**：提供多种名片模板，支持将名片信息导出为图片或分享。
-   **📲 扫码保存**：自动生成联系人二维码，扫码即可快速保存到手机通讯录。
-   **🌐 多语言支持**：支持简体中文与英文，适配系统语言设置。
-   **✨ 现代 UI 设计**：基于 `shadcn_ui` 构建，提供简洁、美观且易用的交互体验。

## 🛠️ 技术栈

-   **Framework**: [Flutter](https://flutter.dev/)
-   **UI Components**: [Shadcn UI (Flutter)](https://shadcn-ui.com/)
-   **OCR Engine**: PaddleOCR (通过自定义 `ocr_plugin` 集成)
-   **Scanning**: `cunning_document_scanner`
-   **Storage**: `shared_preferences`
-   **State Management**: Provider (LocaleProvider)
-   **Icons**: Lucide Icons

## 📦 快速开始

### 环境要求
-   Flutter SDK: `^3.8.1`
-   Android SDK / iOS Xcode (根据目标平台)

### 安装步骤
1.  克隆仓库：
    ```bash
    git clone https://github.com/your-repo/business_card_ocr.git
    ```
2.  安装依赖：
    ```bash
    flutter pub get
    ```
3.  运行应用：
    ```bash
    flutter run
    ```

