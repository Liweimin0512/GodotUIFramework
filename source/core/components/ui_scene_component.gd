extends UIViewComponent
class_name UISceneComponent

## UI场景组件，负责管理UI场景的生命周期和行为
## 通过UISceneType配置来初始化场景属性

## 场景打开信号
signal scene_opened(scene: Control)
## 场景关闭信号
signal scene_closed(scene: Control)

## 模态遮罩节点
var _modal_blocker: ColorRect

func _ready() -> void:
	# 确保有配置
	if not config:
		config = UISceneType.new()
	
	# 如果是模态场景，设置遮罩
	if (config as UISceneType).is_modal:
		_setup_modal_blocker()

## 初始化场景
## [param data] 初始化数据
func initialize(data: Dictionary = {}) -> void:
	if not config:
		config = UISceneType.new()
	
	if (config as UISceneType).is_modal:
		_setup_modal_blocker()
	
	await super.initialize(data)
	scene_opened.emit(owner)

## 销毁场景
func dispose() -> void:
	await super()
	
	# 清理遮罩
	if _modal_blocker:
		_modal_blocker.queue_free()
		_modal_blocker = null
	
	# 发送场景关闭信号
	scene_closed.emit(owner)

## 设置是否阻挡输入
func set_block_input(value: bool) -> void:
	if not config or not (config is UISceneType):
		return
		
	(config as UISceneType).block_input = value
	_update_modal_blocker()

## 设置是否为模态场景
func set_modal(value: bool) -> void:
	if not config or not (config is UISceneType):
		return
		
	(config as UISceneType).is_modal = value
	_update_modal_blocker()

## 应用配置
func _apply_config() -> void:
	super()
	if not config or not (config is UISceneType):
		return
	
	_update_modal_blocker()

## 设置模态遮罩
func _setup_modal_blocker() -> void:
	if _modal_blocker:
		return
		
	_modal_blocker = ColorRect.new()
	_modal_blocker.name = "ModalBlocker"
	_modal_blocker.color = Color(0, 0, 0, 0.5)
	_modal_blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	owner.add_child(_modal_blocker)
	_update_modal_blocker()
	
	# 确保遮罩和场景在最前
	_modal_blocker.move_to_front()
	owner.move_to_front()

## 更新模态遮罩状态
func _update_modal_blocker() -> void:
	if not config or not (config is UISceneType):
		return
		
	var scene_config := config as UISceneType
	
	if not _modal_blocker:
		if scene_config.is_modal:
			_setup_modal_blocker()
		return
	
	# 更新遮罩状态
	_modal_blocker.visible = scene_config.is_modal
	_modal_blocker.mouse_filter = Control.MOUSE_FILTER_STOP if scene_config.block_input else Control.MOUSE_FILTER_IGNORE
