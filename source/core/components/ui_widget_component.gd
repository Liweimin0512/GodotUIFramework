# ui_widget_component.gd
extends UIViewComponent
class_name UIWidgetComponent

## UI控件组件，负责管理UI控件的生命周期和行为
## 通过UIWidgetType配置来初始化控件属性

## 控件准备好
signal widget_ready(widget: Control)
## 控件被回收
signal widget_recycled(widget: Control)

## 初始化控件
## [param data] 初始化数据
func initialize(data: Dictionary = {}) -> void:
	await super(data)
	widget_ready.emit(owner)

## 回收控件
func recycle() -> void:
	if not config or not (config is UIWidgetType):
		dispose()
		return
	
	var widget_config := config as UIWidgetType
	if not widget_config.reusable:
		dispose()
		return
	
	if owner.has_method("_on_recycle"):
		owner.call("_on_recycle")
	
	widget_recycled.emit(owner)
