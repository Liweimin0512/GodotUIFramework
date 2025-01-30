extends MarginContainer

@onready var scene_component : UISceneComponent = %UISceneComponent
@onready var grid_container : GridContainer = %GridContainer

func _ready() -> void:
	scene_component.showing.connect(_on_showing)
	scene_component.shown.connect(_on_shown)
	scene_component.hiding.connect(_on_hiding)
	scene_component.hidden.connect(_on_hidden)
	scene_component.closing.connect(_on_closing)
	scene_component.closed.connect(_on_closed)
	
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()

func _on_item_clicked(slot_index: int) -> void:
	print("点击了物品：", slot_index)
	scene_component.update({
		"selected_index": slot_index
	})

#region 生命周期回调

## 场景即将显示
func _on_showing() -> void:
	print("商店界面即将显示")
	# 在这里可以准备数据、播放显示动画等

	# 生成一个1~20之间的随机数
	var random_number = randi_range(1, 20)

	# 动态生成背包格子
	for i in range(random_number):
		var slot_data = {
			"slot_index": i
		}
		var slot = scene_component.create_widget("shop_item", grid_container, slot_data)
		slot.item_clicked.connect(_on_item_clicked)

## 场景已经显示
func _on_shown() -> void:
	print("商店界面已经显示")
	# 在这里可以开始自动刷新、启动计时器等

## 场景即将隐藏
func _on_hiding() -> void:
	print("商店界面即将隐藏")
	# 在这里可以保存状态、播放隐藏动画等
	for child in grid_container.get_children():
		child.item_clicked.disconnect(_on_item_clicked)
		UIManager.dispose_view(child)

## 场景已经隐藏
func _on_hidden() -> void:
	print("商店界面已经隐藏")
	# 在这里可以暂停自动刷新、停止计时器等

## 场景即将关闭
func _on_closing() -> void:
	print("商店界面即将关闭")
	# 在这里可以保存数据、清理资源等

## 场景已经关闭
func _on_closed() -> void:
	print("商店界面已经关闭")
	# 在这里可以执行最终的清理工作

#endregion
