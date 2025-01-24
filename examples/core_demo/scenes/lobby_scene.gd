extends Control

## 大厅场景，复杂UI布局
const BattleTestData = preload("res://addons/GodotUIFramework/examples/core_demo/data/battle_test_data.gd")

@onready var player_info: MarginContainer = %PlayerInfo
@onready var button_container: HBoxContainer = %ButtonContainer

@export var _scene_types : Array[UISceneType] = []
# 当前选中的导航标签
var _current_tab: String = "home"
var _button_group: ButtonGroup = ButtonGroup.new()
# 按钮界面映射
var _button_scene_map: Dictionary[String, String] = {
	"Home" : "home_panel",
	"Shop" : "shop_panel",
	"Social" : "social_panel"
}

func _ready() -> void:
	_init_buttons()
	for scene_type in _scene_types:
		UIManager.scene_manager.register_scene_type(scene_type)

func _setup(_data: Dictionary) -> void:
	var home_button : Button = button_container.get_child(0)
	home_button.button_pressed = true

## 初始化按钮组
func _init_buttons() -> void:
	_button_group.pressed.connect(_on_button_group_pressed)
	for button in button_container.get_children():
		button.button_group = _button_group

func _on_button_group_pressed(button: Button) -> void:
	var button_text := button.text
	var button_panel: String = _button_scene_map.get(button_text, "")
	if button_panel.is_empty(): return
	var panel = await UIManager.scene_manager.switch_scene(button_panel)
	if panel == null: return

func _on_start_game_pressed() -> void:
	# 获取初始战斗数据
	var username = player_info.username
	var player_data : Dictionary = BattleTestData.get_player_init_data(username)
	var enemy_data : Dictionary = BattleTestData.get_random_enemy_data(player_data.level)
	
	# 切换到游戏场景，并传递初始数据
	UIManager.scene_manager.switch_scene("game_scene", {
		"player": player_data,
		"enemy": enemy_data,
		"turn_count": 1,
		"state": 0  # BATTLE_STATE.INIT
	})

func _on_player_info_pressed() -> void:
	print("_on_player_info_pressed")
