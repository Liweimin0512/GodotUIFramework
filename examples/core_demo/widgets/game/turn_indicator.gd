extends MarginContainer

## 回合指示器
## 用于显示当前回合数和战斗状态

# 节点引用
@onready var label: Label = %Label

# 状态文本映射
const STATE_TEXT = {
	0: "准备战斗",  # BATTLE_STATE.INIT
	1: "玩家回合",  # BATTLE_STATE.PLAYER_TURN
	2: "敌人回合",  # BATTLE_STATE.ENEMY_TURN
	3: "战斗胜利",  # BATTLE_STATE.WIN
	4: "战斗失败"   # BATTLE_STATE.LOSE
}

func _ready() -> void:
	# 初始显示
	_update_display(1, 0)

func _setup(data: Dictionary) -> void:
	var turn_count = data.get("turn_count", 1)
	var state = data.get("state", 0)
	
	_update_display(turn_count, state)

## 刷新显示
func _refresh(data: Dictionary) -> void:
	# 获取回合数和状态
	var turn_count = data.get("turn_count", 1)
	var state = data.get("state", 0)
	
	_update_display(turn_count, state)

## 更新显示
func _update_display(turn_count: int, state: int) -> void:
	if not is_inside_tree(): return
	if not label: return
	
	# 获取状态文本
	var state_text = STATE_TEXT.get(state, "未知状态")
	
	# 更新显示
	if state == 0:  # INIT
		label.text = state_text
	else:
		label.text = "第%d回合\n%s" % [turn_count, state_text]

	# 根据状态设置颜色
	_update_state_color(state)    

## 根据状态设置颜色
func _update_state_color(state: int) -> void:
	match state:
		0:  # INIT
			modulate = Color.WHITE
		1:  # PLAYER_TURN
			modulate = Color.GREEN
		2:  # ENEMY_TURN
			modulate = Color.RED
		3:  # WIN
			modulate = Color.YELLOW
		4:  # LOSE
			modulate = Color.GRAY
		_:
			modulate = Color.WHITE
