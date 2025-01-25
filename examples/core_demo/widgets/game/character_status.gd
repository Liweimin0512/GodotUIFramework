@tool
extends MarginContainer

## 角色状态组件
## 用于显示角色的状态信息，包括名称、等级、生命值和魔法值

const GameDataTypes = preload("res://addons/GodotUIFramework/examples/core_demo/data/game_data_types.gd")

@export_enum("player", "enemy") var character_type: String = "player":
	set(value):
		character_type = value
		if character_type == "enemy":
			mp_bar.hide()
# 节点引用
@onready var name_label: Label = %NameLabel
@onready var level_label: Label = %LevelLabel
# @onready var hp_bar: MarginContainer = %HPBar
@onready var mp_bar: MarginContainer = %MPBar

func _setup(data: Dictionary) -> void:
	var character_data := GameDataTypes.CharacterData.from_dict(data)
	if not character_data: 
		return
	_update_display(character_data)

func _refresh(data: Dictionary) -> void:
	var character_data := GameDataTypes.CharacterData.from_dict(data)
	_update_display(character_data)

func _update_display(character_data: GameDataTypes.CharacterData) -> void:
	name_label.text = character_data.name
	level_label.text = "Lv.%d" % character_data.level
