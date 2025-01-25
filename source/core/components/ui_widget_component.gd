@tool
extends UIViewComponent
class_name UIWidgetComponent

## UI控件组件
## 提供控件特有功能，如对象池和批量操作

signal widget_recycled(data: Dictionary)

func _init() -> void:
	config = UIWidgetType.new()

## 回收控件
func recycle() -> void:
	var final_data := get_data()
	widget_recycled.emit(final_data)
	
	if owner:
		UIManager.recycle_to_pool(config.id, owner)

## 创建Widget
func create_widget(id: StringName, parent: Node = null, data: Dictionary = {}) -> Control:
	var widget_type := UIManager.get_view_type(id) as UIWidgetType
	if not widget_type:
		push_error("Widget type not found: %s" % id)
		return null
	
	# 从对象池获取实例
	var widget: Control = null
	if widget_type.reusable:
		widget = UIManager.get_from_pool(id)
	
	# 创建新实例或重用实例
	if not widget:
		# 新建实例时UIManager.create_view会自动初始化组件
		widget = UIManager.create_view(id, parent, data)
		if not widget:
			return null
	elif parent:
		parent.add_child(widget)
		var component = UIManager.get_widget_component(widget)
		if not component:
			push_error("Widget component not found: %s" % id)
			widget.queue_free()
			return null
		component.initialize(data)
	
	return widget

## 回收Widget
func recycle_widget(widget: Control) -> void:
	if not widget:
		return
	
	var component = UIManager.get_widget_component(widget)
	if not component:
		widget.queue_free()
		return
	
	# 获取widget类型
	var widget_type := component.config as UIWidgetType
	if not widget_type:
		widget.queue_free()
		return
	
	# 根据widget类型的缓存策略决定是回收还是销毁
	if widget_type.reusable:
		# 1. 从父节点移除
		if widget.get_parent():
			widget.get_parent().remove_child(widget)
		
		# 2. 重置组件状态
		component.recycle()
		
		# 3. 缓存到对象池
		UIManager.recycle_to_pool(widget_type.ID, widget)
	else:
		widget.queue_free()

## 批量创建Widget
func create_widgets(id: StringName, parent: Node, data_list: Array) -> Array[Control]:
	var widgets: Array[Control] = []
	for item_data in data_list:
		var widget = create_widget(id, parent, item_data)
		if widget:
			widgets.append(widget)
	return widgets

## 批量回收Widget
func recycle_widgets(widgets: Array) -> void:
	for widget in widgets:
		if widget is Control:
			recycle_widget(widget)

## 注册Widget类型
func register_widget_type(widget_type: UIWidgetType) -> void:
	register_view_type(widget_type)

## 获取组件数据
## [param widget] 组件实例
## [return] 组件数据
func get_widget_data(widget: Control) -> Dictionary:
	if not widget:
		return {}
	
	var component = UIManager.get_widget_component(widget)
	if not component:
		return {}
	
	return component.get_data()

## 更新组件数据
## [param widget] 组件实例
## [param data] 更新的数据
## [param paths] 更新路径列表
func update_widget_data(widget: Control, data: Dictionary, paths: Array[String] = []) -> void:
	if not widget:
		return
	
	var component = UIManager.get_widget_component(widget)
	if not component:
		return
	
	component.update_data(data, paths)
