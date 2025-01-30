extends Control

## 语言选择器
@onready var language_selector = %LanguageSelector

## 文本示例
@onready var welcome_text = %WelcomeText

## 日期示例
@onready var short_date = %ShortDate
@onready var medium_date = %MediumDate
@onready var long_date = %LongDate

## 数字示例
@onready var number_label = %Number
@onready var currency_label = %Currency

## 本地化管理器引用
var localization_manager: UILocalizationManager

func _ready() -> void:
	# 初始化本地化管理器
	_init_localization_manager()
	
	# 连接信号
	_connect_signals()
	
	# 加载翻译文件
	_load_translations()
	localization_manager.current_locale = "en"
	
	# 初始化UI
	_update_ui()

## 初始化本地化管理器
func _init_localization_manager() -> void:
	localization_manager = UIManager.localization_manager
	if not localization_manager:
		push_error("Failed to get localization manager")
		return

## 连接信号
func _connect_signals() -> void:
	if not localization_manager:
		return
		
	# 连接语言选择器信号
	language_selector.item_selected.connect(_on_language_selected)
	# 监听语言变化
	localization_manager.locale_changed.connect(_on_locale_changed)

## 加载翻译文件
func _load_translations() -> void:
	if not localization_manager:
		return
		
	# 加载英文翻译
	localization_manager.load_translations("en", "res://addons/GodotUIFramework/examples/localization/translations/en.json")
	# 加载中文翻译
	localization_manager.load_translations("zh_CN", "res://addons/GodotUIFramework/examples/localization/translations/zh_CN.json")
	# 加载日文翻译
	localization_manager.load_translations("ja", "res://addons/GodotUIFramework/examples/localization/translations/ja.json")

## 更新UI显示
func _update_ui() -> void:
	if not localization_manager:
		return
		
	# 更新欢迎文本
	_update_welcome_text()
	
	# 更新日期格式示例
	_update_date_formats()
	
	# 更新数字格式示例
	_update_number_formats()

## 更新欢迎文本
func _update_welcome_text() -> void:
	#welcome_text.text = localization_manager.get_translation_str("welcome", {"name": "User"})
	pass

## 更新日期格式示例
func _update_date_formats() -> void:
	var current_time = Time.get_datetime_dict_from_system()
	
	var short_text = localization_manager.get_translation_str("short_date")
	var medium_text = localization_manager.get_translation_str("medium_date")
	var long_text = localization_manager.get_translation_str("long_date")
	
	short_date.text = "%s %s" % [short_text, localization_manager.format_date(current_time, "short")]
	medium_date.text = "%s %s" % [medium_text, localization_manager.format_date(current_time, "medium")]
	long_date.text = "%s %s" % [long_text, localization_manager.format_date(current_time, "long")]

## 更新数字格式示例
func _update_number_formats() -> void:
	var number = 1234567.89
	var number_text = localization_manager.get_translation_str("number")
	var currency_text = localization_manager.get_translation_str("currency")
	
	number_label.text = "%s %s" % [number_text, localization_manager.format_number(number)]
	currency_label.text = "%s %s" % [currency_text, localization_manager.format_number(number, "currency")]

## 语言选择处理
func _on_language_selected(index: int) -> void:
	var locale = ["en", "zh_CN", "ja"][index]
	localization_manager.current_locale = locale

## 语言变化处理
func _on_locale_changed(_locale: String) -> void:
	_update_ui()
