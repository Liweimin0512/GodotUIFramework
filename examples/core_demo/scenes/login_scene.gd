extends Control

## 登录场景：基础UI交互

@onready var line_edit_username: LineEdit = %LineEditUsername
@onready var line_edit_password: LineEdit = %LineEditPassword
@onready var label_message: Label = %LabelMessage

## 测试用登录数据
var login_data : Dictionary = {
	"username": "test",
	"password": "123456"
}

func _ready() -> void:
	label_message.hide()

## 登录
func _login() -> void:
	if line_edit_username.text.is_empty():
		label_message.show()
		label_message.text = "请输入用户名"
		return
	if login_data["username"] != line_edit_username.text:
		label_message.show()
		label_message.text = "用户名错误"
		return
	if login_data["password"] != line_edit_password.text:
		label_message.show()
		label_message.text = "密码错误"
		return
	_show_loading()
	await get_tree().create_timer(1.0).timeout
	await UIManager.scene_manager.switch_scene("lobby")
	label_message.hide()

func _show_loading() -> void:
	# 显示加载界面
	var loading = await UIManager.widget_manager.create_widget("loading")
	loading.show()
	
	# 模拟加载过程
	await get_tree().create_timer(2.0).timeout
	
	# 隐藏加载界面
	loading.hide()
	UIManager.widget_manager.recycle_widget(loading)

func _on_button_register_pressed() -> void:
	pass


func _on_button_login_pressed() -> void:
	_login()
