# source/module/localization/components/ui_localized_text_component.gd
extends UILocalizationComponent
class_name UILocalizedTextComponent

## 目标文本属性
@export var text_property: String = "text"

## 参数绑定配置，格式为：
## {
##   "param_name": {
##     "node": NodePath,     # 目标节点路径
##     "property": String,   # 属性名称
##     "method": String,     # 方法名称（与property二选一）
##     "args": Array        # 方法参数（可选）
##   }
## }
@export var param_bindings: Dictionary = {}

## 参数值缓存
var _param_values: Dictionary = {}
## 绑定节点缓存
var _bound_nodes: Dictionary = {}

func _ready() -> void:
	super._ready()
	# 设置参数绑定
	_setup_bindings()

## 设置参数绑定
func _setup_bindings() -> void:
	for param_name in param_bindings:
		var binding = param_bindings[param_name]
		if not binding is Dictionary:
			push_error("Invalid binding configuration for parameter: " + param_name)
			continue
			
		# 获取目标节点
		var target_node: Node
		if "node" in binding:
			target_node = get_node_or_null(binding.node)
			if not target_node:
				push_error("Cannot find target node for parameter: " + param_name)
				continue
		else:
			target_node = _owner
			
		_bound_nodes[param_name] = target_node
		
		# 如果是属性绑定，连接属性变化信号
		if "property" in binding:
			if target_node.has_signal("property_list_changed"):
				target_node.property_list_changed.connect(
					func(): _update_param_value(param_name)
				)
			_update_param_value(param_name)

## 更新参数值
func _update_param_value(param_name: String) -> void:
	var binding = param_bindings[param_name]
	var target_node = _bound_nodes[param_name]
	
	if "property" in binding:
		# 属性绑定
		if target_node.has_method("get_" + binding.property):
			_param_values[param_name] = target_node.get(binding.property)
		else:
			_param_values[param_name] = target_node.get(binding.property)
	elif "method" in binding:
		# 方法绑定
		var args = binding.get("args", [])
		if target_node.has_method(binding.method):
			_param_values[param_name] = target_node.callv(binding.method, args)
	
	# 更新本地化
	if auto_update:
		update_localization()

## 获取当前参数值
func _get_current_params() -> Dictionary:
	var current_params = params.duplicate()
	# 合并动态参数值
	for param_name in _param_values:
		current_params[param_name] = _param_values[param_name]
	return current_params

## 更新本地化
func _update_localization() -> void:
	var translated_text = _localization_manager.get_translation_str(key, _get_current_params())
	if _owner.has_method("set_" + text_property):
		_owner.set(text_property, translated_text)

## 手动更新指定参数的值
## [param param_name] 参数名称
## [param force_update] 是否强制更新本地化
func update_param(param_name: String, force_update: bool = true) -> void:
	if param_name in param_bindings:
		_update_param_value(param_name)
	elif force_update:
		update_localization()

## 手动更新所有参数的值
func update_all_params() -> void:
	for param_name in param_bindings:
		_update_param_value(param_name)
