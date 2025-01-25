extends MarginContainer

## 角色状态组件
## 用于显示角色的状态信息，包括名称、等级、生命值和魔法值

const GameDataTypes = preload("res://addons/GodotUIFramework/examples/core_demo/data/game_data_types.gd")

@export_enum("player", "enemy") var character_type: String = "player":
	set(value):
		character_type = value
		#if character_type == "enemy":
			#mp_bar.hide()

# 节点引用
@onready var name_label: Label = %NameLabel
@onready var level_label: Label = %LevelLabel
@onready var hp_bar: MarginContainer = %HPBar
@onready var mp_bar: MarginContainer = %MPBar
@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

var game_data: GameDataTypes.GameSceneData

func _enter_tree() -> void:
	ui_widget_component = $UIWidgetComponent
	ui_widget_component.data_paths = [character_type]

func _ready() -> void:
	ui_widget_component.initialized.connect(_on_initialized)
	ui_widget_component.data_updated.connect(_on_data_updated)
	if character_type == "enemy":
		mp_bar.hide()

## 处理初始化
func _on_initialized(data: Dictionary) -> void:
	game_data = GameDataTypes.GameSceneData.from_dict(data)
	var character_data : GameDataTypes.CharacterData
	if character_type == "player":
		character_data = game_data.player
	else:
		character_data = game_data.enemy
	if not character_data:
		return
	_update_display(character_data)

## 处理数据更新
func _on_data_updated(path: String, value: Variant) -> void:
	var data = ui_widget_component.get_data()
	game_data = GameDataTypes.GameSceneData.from_dict(data)
	var character_data : GameDataTypes.CharacterData
	if character_type == "player":
		character_data = game_data.player
	else:
		character_data = game_data.enemy
	if not character_data:
		return
	match path:
		"name", "level", "hp", "max_hp", "mp", "max_mp":
			_update_display(character_data)

## 更新显示
func _update_display(character_data: GameDataTypes.CharacterData) -> void:
	if not is_inside_tree() or Engine.is_editor_hint():
		return
		
	# 更新基本信息
	name_label.text = character_data.name
	if character_type == "enemy":
		level_label.hide()
	else:
		level_label.text = "等级 %d" % character_data.level
