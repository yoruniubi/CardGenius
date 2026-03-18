# System Interface Composition and Functional Description

This chapter provides a detailed introduction to the main interface composition, functional responsibilities, and user interaction flow of the "CardGenius" system.

## 1. Main System Interface
![Main Interface](./images/主界面.jpg)
**Functional Description:**
This interface serves as the core entry point of the system, utilizing a bottom navigation architecture. The top section includes the page title and search entry, the middle section is a dynamic content display area, and the bottom provides switching between three major modules: "Home", "Cards", and "Settings". The Floating Action Button (FAB) acts as a high-frequency operation entry, guiding users to import business cards.

---

## 2. Business Card List Display
![Card List](./images/名片列表.jpg)
**Functional Description:**
This interface displays all business card information stored by the user. It adopts a card-style layout, intuitively showing key fields such as name, job title, and company. It supports real-time search filtering, allowing users to quickly locate target contacts within a large amount of data.

---

## 3. Quick Management Operations
![Card Share or Delete](./images/卡片分享或删除.jpg)
**Functional Description:**
The system integrates swipe operations (Slidable). By swiping a list item to the left, users can quickly trigger "Share" or "Delete" functions. This interaction method reduces click levels and improves management efficiency.

---

## 4. Business Card Import Options
![Import Options](./images/导入名片等相关选项.jpg)
**Functional Description:**
The bottom panel that pops up after clicking the import button. It provides three modes: "Camera Recognition", "Gallery Import", and "Manual Input". The system extracts text from captured or selected images by calling the PaddleOCR plugin, achieving automated information collection.

---

## 5. Business Card Information Editing
![Card Editing](./images/名片编辑.jpg)
**Functional Description:**
The editing interface is used to proofread and supplement the OCR recognition results. Users can perform fine-grained editing on structured fields such as name, phone number, email, company, and job title to ensure the accuracy of the entered information.

---

## 6. Information Confirmation After Import
![Import Editing](./images/导入编辑.jpg)
**Functional Description:**
After completing the image scanning and text recognition, the system automatically jumps to this interface. It carries the conversion result from "raw image" to "structured data" and is a key confirmation step before the user completes data entry.

---

## 7. Electronic Business Card Template Selection
![Template Selection](./images/模板选择界面.jpg)
**Functional Description:**
The system features a variety of built-in exquisite business card templates. Users can apply the recognized information to different styles of templates to generate beautiful electronic business cards, meeting the display needs of various business scenarios.

---

## 8. Personal Business Card Management
![Edit Personal Card](./images/编辑自己的电子名片.jpg)
**Functional Description:**
Users can maintain their personal information here. By setting up a personal electronic business card, they can easily generate an exclusive QR code for quick social sharing.

---

## 9. QR Code Sharing Function
![QR Code Sharing](./images/二维码分享.jpg)
**Functional Description:**
The system supports converting business card information into a standard format QR code. Other users can quickly save contact information to their address book by simply scanning the QR code with their mobile phones, achieving digital social connection.

---

## 10. System Settings
![Settings Interface](./images/设置界面.jpg)
**Functional Description:**
The settings interface provides multi-language switching (Chinese and English), OCR engine status viewing, and "About System" configuration options. Users can adjust system preferences according to their usage habits to ensure the application's adaptability in different environments.
