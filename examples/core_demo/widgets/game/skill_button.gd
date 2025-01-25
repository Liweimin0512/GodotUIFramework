extends Button

## 技能按钮
## 用于显示和触发技能

# 节点引用
@onready var icon_rect: TextureRect = %IconRect
@onready var cost_label: Label = %CostLabel
@onready var cooldown_label: Label = %CooldownLabel

# 属性
var skill_data: Dictionary:
	set(value):
		skill_data = value
		_update_display()

# 信号
signal skill_used(skill_data: Dictionary)	## 技能使用

func _ready() -> void:
	_update_display()

## 初始化
func _setup(data: Dictionary) -> void:
	skill_data = data
	_update_display()

## 刷新显示
func _refresh(data: Dictionary) -> void:
	var enabled = data.get("enabled", true)
	disabled = not enabled
	modulate = Color.WHITE if enabled else Color.DARK_GRAY

## 更新显示
func _update_display() -> void:
	if not is_inside_tree(): return
	
	# 更新图标
	if icon_rect and skill_data.has("icon"):
		icon_rect.texture = skill_data.icon
	
	# 更新技能名称
	text = skill_data.get("name", "未知技能")
	
	# 更新消耗
	if cost_label:
		var cost = skill_data.get("mp_cost", 0)
		cost_label.text = str(cost) if cost > 0 else ""
	
	# 更新冷却
	if cooldown_label:
		var cooldown = skill_data.get("cooldown", 0)
		cooldown_label.text = str(cooldown) if cooldown > 0 else ""
		cooldown_label.visible = cooldown > 0

## 按钮点击处理
func _on_pressed() -> void:
	if not disabled:
		skill_used.emit(skill_data)
