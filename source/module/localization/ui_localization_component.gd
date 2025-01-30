extends Node
class_name UILocalizationComponent

## 本地化键
@export var key: String = ""
## 本地化参数
@export var params: Dictionary = {}
## 自动更新
@export var auto_update: bool = true
## 所有者
var _owner: Node:
	get:
		return get_parent()
## 本地化管理器
var _localization_manager: UILocalizationManager

func _ready() -> void:
	if not _owner:
		push_error("UILocalizationComponent must be child of a Node")
		return
		
	if not UIManager.is_module_enabled("localization"):
		push_error("Localization module is not enabled")
		return

	_localization_manager = UIManager.localization_manager
	if not _localization_manager:
		push_error("No localization manager found")
		return
	_localization_manager.locale_changed.connect(_on_locale_changed)
	if auto_update:
		# 更新一次
		await _localization_manager.locale_changed
		update_localization()

## 更新本地化
func update_localization() -> void:
	if not _localization_manager:
		push_error("无法更新本地化, No localization manager found")
		return
	
	if not _owner:
		push_error("无法更新本地化, No owner found")
		return

	if not key:
		push_error("无法更新本地化, No key found")
		return
		
	_update_localization()

## 语言变化回调
## [param locale] 语言
func _on_locale_changed(_locale: String) -> void:
	if auto_update:
		update_localization()

## 设置本地化键
## [param new_key] 新的本地化键
## [param new_params] 新的本地化参数
func set_localization_key(new_key: String, new_params: Dictionary = {}) -> void:
	key = new_key
	params = new_params
	update_localization()

## 更新本地化，子类实现
func _update_localization() -> void:
	pass
