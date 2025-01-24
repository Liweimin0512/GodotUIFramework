extends MarginContainer

## 战斗日志容器
## 用于显示和管理战斗过程中的日志信息

# 节点引用
@onready var scroll: ScrollContainer = %Scroll
@onready var log_text: RichTextLabel = %LogText

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
	# 清空初始文本
	log_text.text = ""

## 初始化
func _setup(_data: Dictionary) -> void:
	# 清空日志
	log_text.text = ""

## 刷新显示
func _refresh(data: Dictionary) -> void:
	# 获取日志数据
	var log_data = data.get("battle_log")
	if not log_data: return
	
	# 处理日志更新
	match log_data.get("type"):
		"append":
			add_log(log_data.text, log_data.get("color", "system"))
		"clear":
			clear_log()
		"set":
			set_log(log_data.text, log_data.get("color", "system"))

## 添加日志
## [param text] 日志文本
## [param color_type] 颜色类型，默认为system
func add_log(text: String, color_type: String = "system") -> void:
	if not log_text: return
	
	# 获取颜色
	var color = LOG_COLORS.get(color_type, "white")
	
	# 添加带颜色的文本
	log_text.append_text("[color=%s]%s[/color]\n" % [color, text])
	
	# 自动滚动到底部
	await get_tree().process_frame
	scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value

## 清空日志
func clear_log() -> void:
	if not log_text: return
	log_text.text = ""

## 设置日志
## [param text] 日志文本
## [param color_type] 颜色类型，默认为system
func set_log(text: String, color_type: String = "system") -> void:
	if not log_text: return
	
	# 获取颜色
	var color = LOG_COLORS.get(color_type, "white")
	
	# 设置带颜色的文本
	log_text.text = "[color=%s]%s[/color]\n" % [color, text]
	
	# 自动滚动到底部
	await get_tree().process_frame
	scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value
