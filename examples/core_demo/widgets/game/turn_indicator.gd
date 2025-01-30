extends UIViewComponent

## 回合指示器组件
## 负责显示当前回合和行动角色

## 战斗状态描述文本
const BATTLE_STATE_DESC : Array = [
	 "初始化",
	 "玩家行动",
	 "敌人行动",
	 "胜利",
	 "失败",
]

@onready var turn_label = %TurnLabel
@onready var state_label: Label = %StateLabel

func _update_turn_state(turn_state: int) -> void:
	state_label.text = BATTLE_STATE_DESC[turn_state]

func _update_turn_label(turn_count: int) -> void:
	turn_label.text = "当前回合数：" + str(turn_count)

func _on_initialized(data: Dictionary) -> void:
	_update_turn_label(data.turn_count)
	_update_turn_state(data.state)

func _on_updated(data: Dictionary) -> void:
	_update_turn_label(data.turn_count)
	_update_turn_state(data.state)
