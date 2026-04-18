# CardGenius (名片智造)

![logo](./assets/logo.png)

[English](./README_EN.md) | 简体中文

**CardGenius (名片智造)** 是一款基于 Flutter 开发的智能名片识别与管理工具。它利用先进的 OCR 技术，帮助用户快速从纸质名片中提取结构化信息，并提供便捷的存储、编辑、分享及导出功能。

## 🚀 主要功能

-   **🔍 智能文字提取 (OCR)**：集成 PaddleOCR（通过自定义 `ocr_plugin`），支持拍照、相册图片识别名片文字。
-   **📇 名片管理**：支持名片新增、编辑、删除、列表管理，并持久化保存本地数据。
-   **📄 文档扫描与图片导入**：内置文档扫描（`cunning_document_scanner`），可快速获取更清晰的名片图像。
-   **🎨 模板编辑与应用**：支持模板选择、样式调整与自定义背景图导入，快速生成个性化电子名片。
-   **🔗 多方式分享**：支持二维码分享、文本链接分享、名片图片导出分享。
-   **📲 扫码导入**：内置扫码能力（`mobile_scanner`），可直接导入他人分享的名片链接。
-   **🌐 多语言支持**：支持简体中文/英文，并支持跟随系统语言。
-   **✨ 现代化 UI**：基于 `antd_flutter_mobile` 构建移动端风格界面，交互统一、体验简洁。

## 🛠️ 技术栈

-   **Framework**: [Flutter](https://flutter.dev/)
-   **UI Components**: `antd_flutter_mobile`
-   **OCR Engine**: PaddleOCR（通过自定义 `ocr_plugin` 集成）
-   **Scanning**: `cunning_document_scanner`, `mobile_scanner`
-   **Share & QR**: `share_plus`, `qr_flutter`, `app_links`
-   **Storage**: `shared_preferences`
-   **State Management**: Provider (`LocaleProvider`)
-   **Image & File**: `image_picker`, `file_picker`, `screenshot`

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

