extends Control

## 登录场景：基础UI交互

const BattleTestData = preload("res://addons/GodotUIFramework/examples/core_demo/data/battle_test_data.gd")

@onready var line_edit_username: LineEdit = %LineEditUsername
@onready var line_edit_password: LineEdit = %LineEditPassword
@onready var label_message: Label = %LabelMessage
@onready var ui_scene_component: UISceneComponent = $UISceneComponent

@export var widgets: Array[UIWidgetType] = []

var _loading_widget : Control

## 测试用登录数据
var login_data : Array = [
		{
			"username": "test",
			"password": "123456"
		},
		{
			"username": "test2",
			"password": "123"			
		}
	]

var _username : String = ""

func _ready() -> void:
	label_message.hide()

func _setup(_data: Dictionary) -> void:
	for widget in widgets:
		UIManager.widget_manager.register_widget_type(widget)

## 登录
func _login() -> void:
	if line_edit_username.text.is_empty():
		label_message.show()
		label_message.text = "请输入用户名！"
		return
	_username = line_edit_username.text
	var password : String = line_edit_password.text
	var can_login : bool = false
	for user in login_data:
		if user["username"] == _username and user["password"] == password:
			can_login = true
			break
	if not can_login:
		label_message.show()
		label_message.text = "用户名或密码错误!"
		return	

	# 显示加载界面
	var loading_data = {
		"tips": [
			"正在登录...",
			"验证账号信息...",
			"加载游戏数据..."
		],
		"min_display_time": 1.0,
		"on_completed": func():
			_on_login_completed()
	}
	_loading_widget = ui_scene_component.create_widget("loading", self, loading_data)
	_loading_widget.show_loading_screen()
	
	# 模拟登录过程
	var tween = create_tween()
	tween.tween_method(func(progress: float):
		_loading_widget.set_progress(progress), 0.0, 1.0, 1.5)

## 获取玩家信息
func _get_player_info(username: String) -> Dictionary:
	var player_data : Dictionary = BattleTestData.get_player_init_data(username)
	return player_data

## 登录完成回调
func _on_login_completed() -> void:
	ui_scene_component.recycle_widget(_loading_widget)
	ui_scene_component.switch_scene("lobby_scene", _get_player_info(_username))

func _on_button_register_pressed() -> void:
	pass

func _on_button_login_pressed() -> void:
	_login()
