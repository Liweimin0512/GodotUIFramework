extends MarginContainer

## 回合指示器
## 用于显示当前回合数和战斗状态

# 节点引用
@onready var label: Label = %Label
@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

# 状态文本映射
const STATE_TEXT = {
	0: "准备战斗",  # BATTLE_STATE.INIT
	1: "玩家回合",  # BATTLE_STATE.PLAYER_TURN
	2: "敌人回合",  # BATTLE_STATE.ENEMY_TURN
	3: "战斗胜利",  # BATTLE_STATE.WIN
	4: "战斗失败"   # BATTLE_STATE.LOSE
}

func _ready() -> void:
	ui_widget_component.initialized.connect(_on_initialized)
	ui_widget_component.data_updated.connect(_on_data_updated)

## 处理初始化
func _on_initialized(data: Dictionary) -> void:
	var turn_count = data.get("turn_count", 1)
	var state = data.get("state", 0)
	_update_display(turn_count, state)

## 处理数据更新
func _on_data_updated(path: String, value: Variant) -> void:
	match path:
		"turn_count":
			_update_display(value, ui_widget_component.get_data("state", 0))
		"state":
			_update_display(ui_widget_component.get_data("turn_count", 1), value)

## 刷新显示
func _update_display(turn_count: int, state: int) -> void:
	var state_text = STATE_TEXT.get(state, "未知状态")
	label.text = "第 %d 回合 - %s" % [turn_count, state_text]
