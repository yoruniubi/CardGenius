// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '名片智造';

  @override
  String get settingsAndToolbox => '系统设置与工具箱';

  @override
  String get basicSettings => '基本设置';

  @override
  String get languageSettings => '语言设置';

  @override
  String get followSystem => '跟随系统';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get smartToolbox => '智能工具箱';

  @override
  String get smartTextExtraction => '智能文字提取';

  @override
  String get extractStructuredInfo => '从图片中提取结构化联系人信息';

  @override
  String get selectImage => '选择图片';

  @override
  String get takePhoto => '拍照提取';

  @override
  String get extractionPreview => '提取结果预览';

  @override
  String get about => '关于';

  @override
  String get softwareVersion => '软件版本';

  @override
  String get ocrEngineStatus => 'OCR 引擎状态';

  @override
  String get ready => '已就绪';

  @override
  String get name => '姓名';

  @override
  String get company => '公司';

  @override
  String get phone => '电话';

  @override
  String get email => '邮箱';

  @override
  String get address => '地址';

  @override
  String toolFailed(String error) {
    return '工具运行失败: $error';
  }

  @override
  String get cardManagement => '名片管理';

  @override
  String get myCards => '我的名片';

  @override
  String get systemSettings => '系统设置';

  @override
  String get searchPlaceholder => '搜索姓名、公司或职位...';

  @override
  String get noMatchFound => '未找到匹配的名片';

  @override
  String get tryAnotherKeyword => '尝试换个关键词搜索吧';

  @override
  String get startDigitalCardHolder => '开启您的数字名片夹';

  @override
  String get scanButtonDescription => '点击下方按钮扫描名片，我们将为您自动识别并保存联系人信息';

  @override
  String get importCard => '导入名片';

  @override
  String get cameraImport => '拍照导入';

  @override
  String get galleryImport => '相册导入';

  @override
  String get manualInput => '手动输入';

  @override
  String get home => '首页';

  @override
  String get cards => '名片';

  @override
  String get settings => '设置';

  @override
  String get deleteConfirmTitle => '确认删除';

  @override
  String get deleteConfirmContent => '确定要删除这张名片吗？此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get cardDeleted => '名片已删除';

  @override
  String get share => '分享';

  @override
  String get jobTitle => '职位';

  @override
  String get website => '网址';

  @override
  String get fromApp => '来自: 名片智造';

  @override
  String get confirm => '确认';

  @override
  String get errorProcessingImage => '处理图片失败，请重试。';

  @override
  String get editCardInfo => '名片信息编辑';

  @override
  String get originalImage => '名片原图';

  @override
  String get clickToChangeImage => '点击更换名片图片';

  @override
  String get detailedInfo => '详细信息';

  @override
  String get pleaseEnterName => '请输入姓名';

  @override
  String get pleaseEnterTitle => '请输入职位';

  @override
  String get pleaseEnterCompany => '请输入公司名称';

  @override
  String get pleaseEnterPhone => '请输入电话号码';

  @override
  String get pleaseEnterEmail => '请输入电子邮箱';

  @override
  String get pleaseEnterWebsite => '请输入网址';

  @override
  String get pleaseEnterAddress => '请输入详细地址';

  @override
  String get notes => '备注';

  @override
  String get pleaseEnterNotes => '请输入备注信息';

  @override
  String get saveAndReturn => '保存并返回';

  @override
  String get nameCannotBeEmpty => '姓名不能为空';

  @override
  String get confirmClear => '确认清空';

  @override
  String get clearConfirmContent => '这将清除当前输入的所有信息和已保存的名片数据，确定吗？';

  @override
  String get clearData => '清空数据';

  @override
  String get dataCleared => '名片数据已清空';

  @override
  String get pleaseEnterNameBeforeSaving => '请至少输入姓名再保存';

  @override
  String get cardSavedLocally => '名片已成功保存到本地';

  @override
  String saveFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String get layoutReset => '布局已重置为默认位置';

  @override
  String get reset => '重置';

  @override
  String get template => '模板';

  @override
  String get export => '导出';

  @override
  String get shareMyCard => '分享我的名片';

  @override
  String exportFailed(String error) {
    return '导出失败: $error';
  }

  @override
  String get scanToSaveContact => '扫码保存联系人';

  @override
  String get close => '关闭';

  @override
  String get basicInfo => '基本信息';

  @override
  String get saveCard => '保存名片';
}
