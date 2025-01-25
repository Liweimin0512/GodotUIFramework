extends MarginContainer

## 战斗日志容器
## 用于显示和管理战斗过程中的日志信息

const GameDataTypes = preload("res://addons/GodotUIFramework/examples/core_demo/data/game_data_types.gd")

# 节点引用
@onready var scroll: ScrollContainer = %Scroll
@onready var log_text: RichTextLabel = %LogText
@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

# 日志颜色映射
const LOG_COLORS = {
	"system": "white",     # 系统消息
	"player": "green",     # 玩家行动
	"enemy": "red",        # 敌人行动
	"damage": "red",       # 伤害信息
	"heal": "green",       # 治疗信息
	"warning": "yellow"    # 警告信息
}

func _ready() -> void:
	log_text.text = ""  # 清空初始文本
	ui_widget_component.initialized.connect(_on_initialized)
	ui_widget_component.data_updated.connect(_on_data_updated)

## 处理初始化
func _on_initialized(_data: Dictionary) -> void:
	log_text.text = ""  # 清空日志

## 处理数据更新
func _on_data_updated(path: String, value: Variant) -> void:
	if path == "battle_log":
		var log_data := GameDataTypes.BattleLogData.from_dict(value)
		if log_data:
			_add_log_entry(log_data)

## 添加日志条目
func _add_log_entry(log_data: GameDataTypes.BattleLogData) -> void:
	# 根据类型获取颜色
	var color = LOG_COLORS.get(log_data.type, "white")
	
	# 添加带颜色的文本
	log_text.append_text("[color=%s]%s[/color]\n" % [color, log_data.text])
	
	# 自动滚动到底部
	await get_tree().process_frame
	scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value
