@tool
extends MarginContainer

## 状态进度条
## 用于显示HP/MP等状态值的进度条

# 导出变量
@export var status_name: String = "health"  # 状态名称
@export var progress_color: Color = Color.RED  # 进度条颜色

# 节点引用
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var value_label: Label = %ValueLabel
@onready var status_label: Label = %StatusLabel

# 常量
const STATUS_NAMES = {
	"health": "生命值",
	"mana": "魔法值"
}

func _ready() -> void:
	if progress_bar:
		progress_bar.modulate = progress_color
	
	if status_label:
		status_label.text = STATUS_NAMES.get(status_name, "未知")

## 初始化
func _setup(data: Dictionary) -> void:
	var char_data = data.get("player", {}) if get_parent().character_type == "player" else data.get("enemy", {})
	if not char_data: return
	
	var current_value = char_data.get("hp" if status_name == "health" else "mp", 0)
	var max_value = char_data.get("max_hp" if status_name == "health" else "max_mp", 100)
	
	# 设置最大值和当前值
	if progress_bar:
		progress_bar.max_value = max_value
		progress_bar.value = current_value
	
	# 更新显示
	_update_display(current_value, max_value)

## 刷新显示
func _refresh(data: Dictionary) -> void:
	var char_data = data.get("player", {}) if get_parent().character_type == "player" else data.get("enemy", {})
	if not char_data: return
	
	var current_value = char_data.get("hp" if status_name == "health" else "mp", 0)
	var max_value = char_data.get("max_hp" if status_name == "health" else "max_mp", 100)
	
	# 更新当前值
	if progress_bar:
		progress_bar.value = current_value
	
	# 更新显示
	_update_display(current_value, max_value)

## 更新显示
func _update_display(current: int, maximum: int) -> void:
	# 更新数值文本
	if value_label:
		value_label.text = "%d/%d" % [current, maximum]
	
	# 更新进度条颜色
	if progress_bar:
		var ratio = float(current) / maximum if maximum > 0 else 0
		var color = progress_color
		
		# 根据状态调整颜色
		if status_name == "health":
			# 生命值低于20%时闪烁红色警告
			if ratio <= 0.2:
				color = Color.RED if Time.get_ticks_msec() % 1000 < 500 else Color.DARK_RED
			# 生命值低于50%时显示黄色警告
			elif ratio <= 0.5:
				color = Color.YELLOW
		
		progress_bar.modulate = color
