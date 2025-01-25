@tool
extends UIWidgetComponent
class_name UISceneComponent

## UI场景组件
## 提供场景特有功能，如场景管理和分组行为

# 内部变量
var _group: UIGroupComponent:
	get:
		if not _group:
			push_warning("No UIGroupComponent found", self)
			_group = _find_group_component()
		return _group

func _init() -> void:
	config = UISceneType.new()

## 查找分组组件
func _find_group_component() -> UIGroupComponent:
	var node = get_parent()
	for child in node.get_children():
		if child is UIGroupComponent:
			return child
	push_error("No UIGroupComponent found by id : {0}".format([name]))
	return null

## 创建场景
## [param id] 场景ID
## [param data] 场景数据
## [return] 创建的场景实例
func create_scene(id: StringName, data: Dictionary = {}) -> Control:
	if id.is_empty():
		push_error("Scene ID cannot be empty")
		return null
	
	var scene_type := UIManager.get_view_type(id) as UISceneType
	if not scene_type:
		push_error("Scene type not found: %s" % id)
		return null
	
	# 根据分组行为处理场景创建
	match scene_type.group_behavior:
		UISceneType.GROUP_BEHAVIOR.FORCE_GROUP:
			if not _group:
				push_error("No UIGroupComponent found for FORCE_GROUP behavior")
				return null
			return _group.create_scene(id, data)
		
		UISceneType.GROUP_BEHAVIOR.ADDITIVE_GROUP:
			var scene = UIManager.create_view(id, null, data)
			if scene and _group:
				_group.add_scene(scene)
			return scene
		
		_: # RESPECT_SCENE
			if not _group:
				push_error("No UIGroupComponent found")
				return null
			return _group.create_scene(id, data)

## 关闭场景
## [param scene] 要关闭的场景，为空则关闭当前场景
func close_scene(scene: Control = null) -> void:
	if not _group:
		push_error("No UIGroupComponent found")
		return
	
	if scene:
		_group.close_scene(scene)
	else:
		var current = _group.get_current_scene()
		if current:
			_group.close_scene(current)

## 关闭当前场景
func close() -> void:
	recycle()

## 切换场景
## [param id] 场景ID
## [param data] 场景数据
## [return] 创建的场景实例
func switch_scene(id: StringName, data: Dictionary = {}) -> Control:
	var scene_type := UIManager.get_view_type(id) as UISceneType
	if not scene_type:
		push_error("Scene type not found: %s" % id)
		return null
	
	if not _group:
		push_error("cant switch scene: {0}, No UIGroupComponent found by {1}!".format([id, scene_type.group_id]))
		return null
	
	# 根据场景类型处理切换
	match scene_type.group_type:
		UISceneType.GROUP_TYPE.EXCLUSIVE:
			return _group.switch_scene(id, data)
		
		UISceneType.GROUP_TYPE.ADDITIVE:
			var scene = create_scene(id, data)
			if scene and scene_type.hide_others:
				_group.hide_other_scenes(scene)
			return scene
		
		UISceneType.GROUP_TYPE.INDEPENDENT:
			return create_scene(id, data)
		
		_:
			return _group.switch_scene(id, data)

## 获取当前场景
## [return] 当前场景实例
func get_current_scene() -> Control:
	if not _group:
		push_error("No UIGroupComponent found")
		return null
	return _group.get_current_scene()

## 关闭所有场景
func close_all_scenes() -> void:
	if not _group:
		push_error("No UIGroupComponent found")
		return
	_group.close_all_scenes()
