@tool
extends UIWidgetComponent
class_name UISceneComponent

## UI场景组件
## 提供场景管理和切换功能

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

#endregion
