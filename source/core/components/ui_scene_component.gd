@tool
extends UIWidgetComponent
class_name UISceneComponent

## UI场景组件
## 提供场景管理和切换功能

## 场景即将显示
signal showing
## 场景已经显示
signal shown
## 场景即将隐藏
signal hiding
## 场景已经隐藏
signal hidden
## 场景即将关闭
signal closing
## 场景已经关闭
signal closed

## 当前分组
var _group : UIGroupComponent

#region 公共接口

## 切换场景
## [param id] 场景类型ID
## [param data] 场景数据
## [returns] 新场景实例
func switch_scene(id: StringName, data: Dictionary = {}) -> Control:	
	# 获取分组
	if not _group:
		push_error("Group not found by scene id %s" % id)
		return null
	
	# 切换场景
	return _group.show_scene(id, data)

## 返回上一个场景
func back() -> void:
	if _group:
		_group.back_to_previous()

## 关闭当前场景
func close() -> void:
	if _group:
		_group.close_current_scene()

## 关闭所有场景
func close_all() -> void:
	if _group:
		_group.close_all_scenes()

#endregion

#region 生命周期回调

## 场景即将显示
func _on_showing() -> void:
	showing.emit()

## 场景已经显示
func _on_shown() -> void:
	shown.emit()

## 场景即将隐藏
func _on_hiding() -> void:
	hiding.emit()

## 场景已经隐藏
func _on_hidden() -> void:
	hidden.emit()

## 场景即将关闭
func _on_closing() -> void:
	closing.emit()

## 场景已经关闭
func _on_closed() -> void:
	closed.emit()

#endregion 生命周期回调
