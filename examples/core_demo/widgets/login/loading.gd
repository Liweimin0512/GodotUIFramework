extends Control

## 加载界面
## 用于显示加载进度和提示信息

signal loading_completed

@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var label_message: Label = %LabelMessage
@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

## 进度
var _progress: float = 0.0
## 开始时间
var _start_time: float = 0.0
## 最小显示时间
var _min_display_time: float = 0.5
## 加载完成回调
var _on_completed_callback: Callable
## 提示信息
var _tips: Array[String] = []
## 当前提示索引
var _current_tip: int = 0
## 是否正在加载
var _is_loading: bool = false

func _ready() -> void:
	hide()
	modulate.a = 0.0

## 初始化加载界面
func _initialize(data: Dictionary) -> void:
	if data.has("min_display_time"):
		_min_display_time = data.min_display_time
	
	if data.has("tips"):
		for t in data.tips:
			_tips.append(t)
		if _tips.size() > 0:
			label_message.text = _tips[0]
	
	if data.has("on_completed"):
		_on_completed_callback = data.on_completed

## 显示加载界面
func show_loading_screen() -> void:
	_is_loading = true
	_start_time = Time.get_ticks_msec() / 1000.0
	_progress = 0.0
	_update_progress_display()
	
	if _tips.size() > 0:
		_cycle_tips()
	
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

## 隐藏加载界面
func hide_loading_screen() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	var elapsed_time = current_time - _start_time
	
	if elapsed_time < _min_display_time:
		await get_tree().create_timer(_min_display_time - elapsed_time).timeout
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	hide()
	_is_loading = false
	loading_completed.emit()
	
	if _on_completed_callback:
		_on_completed_callback.call()

## 设置加载进度
func set_progress(value: float) -> void:
	_progress = clamp(value, 0.0, 1.0)
	_update_progress_display()
	
	if _progress >= 1.0:
		hide_loading_screen()

## 更新进度显示
func _update_progress_display() -> void:
	_progress_bar.value = _progress * 100

## 循环显示提示文本
func _cycle_tips() -> void:
	if _tips.size() == 0:
		return
	
	var tween = create_tween()
	tween.tween_property(label_message, "modulate:a", 0.0, 0.5)
	await get_tree().create_timer(0.5).timeout
	
	_current_tip = (_current_tip + 1) % _tips.size()
	label_message.text = _tips[_current_tip]
	
	tween = create_tween()
	tween.tween_property(label_message, "modulate:a", 1.0, 0.5)
	
	if _is_loading:
		await get_tree().create_timer(3.0).timeout
		_cycle_tips()

func _on_ui_widget_component_initialized(data: Dictionary) -> void:
	_initialize(data)

func _on_ui_widget_component_widget_recycled(data: Dictionary) -> void:
	_progress = 0.0
	_start_time = 0.0
	_is_loading = false
	_current_tip = 0
	_on_completed_callback = Callable()
