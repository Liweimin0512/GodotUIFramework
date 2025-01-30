extends RefCounted
class_name UILocalizationManager

## 当前语言
var current_locale: String:
	set(value):
		if current_locale != value:
			current_locale = value
			_apply_locale(value)
			locale_changed.emit(value)

## 支持的语言列表
var supported_locales: Array[String] = []
## 翻译数据
var _translations: Dictionary = {}
## 本地化资源
var _localized_resources: Dictionary = {}
## 数字格式化配置
var _number_formats: Dictionary = {}
## 日期格式化配置
var _date_formats: Dictionary = {}
## 字体映射
var _font_mappings: Dictionary = {}

signal locale_changed(new_locale: String)
signal translation_loaded(locale: String)

func _init() -> void:
	# 加载默认配置
	load_default_config()
	# 设置初始语言
	# current_locale = OS.get_locale()
	current_locale = "en"

## 加载默认配置
func load_default_config() -> void:
	# 加载支持的语言
	supported_locales = ["en", "zh_CN", "ja"]
	
	# 加载数字格式化配置
	_number_formats = {
		"en": {
			"decimal_separator": ".",
			"thousands_separator": ",",
			"currency_symbol": "$"
		},
		"zh_CN": {
			"decimal_separator": ".",
			"thousands_separator": ",",
			"currency_symbol": "¥"
		},
		"ja": {
			"decimal_separator": ".",
			"thousands_separator": ",",
			"currency_symbol": "¥"
		}
	}
	
	# 加载日期格式化配置
	_date_formats = {
		"en": {
			"short": "MM/DD/YYYY",
			"medium": "MMM DD, YYYY",
			"long": "MMMM DD, YYYY"
		},
		"zh_CN": {
			"short": "YYYY/MM/DD",
			"medium": "YYYY年MM月DD日",
			"long": "YYYY年MM月DD日"
		},
		"ja": {
			"short": "YYYY/MM/DD",
			"medium": "YYYY年MM月DD日",
			"long": "YYYY年MM月DD日"
		}
	}

## 加载翻译文件
## [param locale] 语言
## [param file_path] 文件路径
func load_translations(locale: String, file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json = JSON.parse_string(file.get_as_text())
		if json:
			_translations[locale] = json
			translation_loaded.emit(locale)

## 获取翻译文本
## [param key] 键
## [param params] 参数
## [return] 翻译文本
func get_translation_str(key: String, params: Dictionary = {}) -> String:
	if not params.is_empty():
		pass
	var translation = _get_translation(key)
	if translation:
		return _format_translation(translation, params)
	push_error("Translation not found: %s" % key)
	return key

## 获取本地化资源
## [param resource_key] 资源键
## [return] 本地化资源
func get_localized_resource(resource_key: String) -> Resource:
	var resources = _localized_resources.get(current_locale, {})
	return resources.get(resource_key)

## 加载本地化资源
## [param locale] 语言
## [param resource_key] 资源键
## [param resource_path] 资源路径
## [param type] 资源类型，可选值：texture, audio, style, font
func load_localized_resource(locale: String, resource_key: String, resource_path: String, type: String = "") -> void:
	# 确保语言的资源字典存在
	if not _localized_resources.has(locale):
		_localized_resources[locale] = {}
	
	# 根据类型加载资源
	var resource: Resource
	match type.to_lower():
		"texture":
			resource = load(resource_path) as Texture2D
		"audio":
			resource = load(resource_path) as AudioStream
		"style":
			resource = load(resource_path) as StyleBox
		"font":
			resource = load(resource_path) as Font
		_:
			# 默认直接加载资源
			resource = load(resource_path)
	
	if resource:
		_localized_resources[locale][resource_key] = resource
	else:
		push_error("Failed to load resource: %s as %s" % [resource_path, type])

## 批量加载本地化资源
## [param locale] 语言
## [param resources_config] 资源配置，格式为：
## {
##   "resource_key": {
##     "path": String,    # 资源路径
##     "type": String     # 资源类型（可选）
##   }
## }
func load_localized_resources(locale: String, resources_config: Dictionary) -> void:
	for resource_key in resources_config:
		var config = resources_config[resource_key]
		if config is Dictionary and config.has("path"):
			load_localized_resource(
				locale,
				resource_key,
				config.path,
				config.get("type", "")
			)

## 移除本地化资源
## [param locale] 语言
## [param resource_key] 资源键
func remove_localized_resource(locale: String, resource_key: String) -> void:
	if _localized_resources.has(locale):
		_localized_resources[locale].erase(resource_key)

## 清除指定语言的所有资源
## [param locale] 语言
func clear_localized_resources(locale: String) -> void:
	_localized_resources[locale] = {}

## 格式化数字
## [param number] 数字
## [param format] 格式
## [return] 格式化后的数字
func format_number(number: float, format: String = "default") -> String:
	var locale_format = _number_formats.get(current_locale, _number_formats["en"])
	var formatted = str(number)
	
	match format:
		"currency":
			return locale_format.currency_symbol + formatted
		"percent":
			return formatted + "%"
		_:
			return formatted

## 格式化日期
## [param date] 日期
## [param format] 格式, 默认为"medium", 可选"short", "long"
## [return] 格式化后的日期
func format_date(date: Dictionary, format: String = "medium") -> String:
	var locale_format = _date_formats.get(current_locale, _date_formats["en"])
	var pattern = locale_format.get(format, locale_format.medium)
	return _format_date(date, pattern)

## 获取本地化字体
func get_font(font_key: String) -> Font:
	var fonts = _font_mappings.get(current_locale, {})
	return fonts.get(font_key)

## 获取翻译文本
## [param key] 键
## [return] 翻译文本
func _get_translation(key: String) -> String:
	if _translations.has(current_locale):
		var translations = _translations.get(current_locale, {})
		return translations.get(key, key)
	push_error("No translation found for locale: " + current_locale)
	return key

## 格式化翻译文本
## [param text] 翻译文本
## [param params] 参数
## [return] 格式化后的翻译文本
func _format_translation(text: String, params: Dictionary) -> String:
	var result = text
	for key in params:
		result = result.replace("{" + key + "}", str(params[key]))
	return result

## 格式化日期
## [param date] 日期字典，包含year, month, day, hour, minute, second
## [param pattern] 格式模式，支持以下占位符：
## - YYYY: 四位年份
## - YY: 两位年份
## - MMMM: 完整月份名称
## - MMM: 缩写月份名称
## - MM: 两位月份
## - M: 一位月份
## - DD: 两位日期
## - D: 一位日期
## - HH: 两位24小时制
## - H: 一位24小时制
## - hh: 两位12小时制
## - h: 一位12小时制
## - mm: 两位分钟
## - m: 一位分钟
## - ss: 两位秒数
## - s: 一位秒数
## - a: AM/PM 标识
## [return] 格式化后的日期字符串
func _format_date(date: Dictionary, pattern: String) -> String:
	var result = pattern
	
	# 获取当前语言的月份名称
	var month_names = {
		"en": ["January", "February", "March", "April", "May", "June", 
			   "July", "August", "September", "October", "November", "December"],
		"zh_CN": ["一月", "二月", "三月", "四月", "五月", "六月",
				  "七月", "八月", "九月", "十月", "十一月", "十二月"],
		"ja": ["1月", "2月", "3月", "4月", "5月", "6月",
			   "7月", "8月", "9月", "10月", "11月", "12月"]
	}
	
	var month_names_short = {
		"en": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
			   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
		"zh_CN": ["1月", "2月", "3月", "4月", "5月", "6月",
				  "7月", "8月", "9月", "10月", "11月", "12月"],
		"ja": ["1月", "2月", "3月", "4月", "5月", "6月",
			   "7月", "8月", "9月", "10月", "11月", "12月"]
	}
	
	var am_pm = {
		"en": ["AM", "PM"],
		"zh_CN": ["上午", "下午"],
		"ja": ["午前", "午後"]
	}
	
	var locale_month_names = month_names.get(current_locale, month_names["en"])
	var locale_month_names_short = month_names_short.get(current_locale, month_names_short["en"])
	var locale_am_pm = am_pm.get(current_locale, am_pm["en"])
	
	# 年份
	result = result.replace("YYYY", str(date.year).pad_zeros(4))
	result = result.replace("YY", str(date.year % 100).pad_zeros(2))
	
	# 月份
	var month_index = date.month - 1  # 月份从0开始索引
	result = result.replace("MMMM", locale_month_names[month_index])
	result = result.replace("MMM", locale_month_names_short[month_index])
	result = result.replace("MM", str(date.month).pad_zeros(2))
	result = result.replace("M", str(date.month))
	
	# 日期
	result = result.replace("DD", str(date.day).pad_zeros(2))
	result = result.replace("D", str(date.day))
	
	# 时间
	var hour_24 = date.hour
	var hour_12 = hour_24 % 12
	if hour_12 == 0:
		hour_12 = 12
	var is_pm = hour_24 >= 12
	
	result = result.replace("HH", str(hour_24).pad_zeros(2))
	result = result.replace("H", str(hour_24))
	result = result.replace("hh", str(hour_12).pad_zeros(2))
	result = result.replace("h", str(hour_12))
	
	# 分钟
	result = result.replace("mm", str(date.minute).pad_zeros(2))
	result = result.replace("m", str(date.minute))
	
	# 秒数
	result = result.replace("ss", str(date.second).pad_zeros(2))
	result = result.replace("s", str(date.second))
	
	# AM/PM
	result = result.replace("a", locale_am_pm[1 if is_pm else 0])
	
	return result

## 应用本地化
## [param locale] 语言
func _apply_locale(locale: String) -> void:
	# 应用RTL设置
	if locale in ["ar", "he"]:
		_apply_rtl_layout(true)
	else:
		_apply_rtl_layout(false)
	
	# 应用字体
	_apply_fonts(locale)

## 应用RTL设置
## [param is_rtl] 是否为RTL
func _apply_rtl_layout(is_rtl: bool) -> void:
	# 设置UI方向
	for node in UIManager.get_tree().get_nodes_in_group("localizable"):
		if node is Control:
			node.set_layout_direction(
				Control.LAYOUT_DIRECTION_RTL if is_rtl 
				else Control.LAYOUT_DIRECTION_LTR
			)

## 应用字体
## [param locale] 语言
func _apply_fonts(locale: String) -> void:
	var fonts = _font_mappings.get(locale, {})
	for node in UIManager.get_tree().get_nodes_in_group("localizable"):
		if node is Control and "font_key" in node:
			var font = fonts.get(node.font_key)
			if font:
				node.add_theme_font_override("font", font)
			else:
				printerr("Font not found: " + node.font_key + " in " + locale)
