extends MarginContainer

@onready var scene_component : UISceneComponent = %UISceneComponent
@onready var grid_container : GridContainer = %GridContainer

func _ready() -> void:
	scene_component.initialized.connect(_on_initialized)
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()
	print("_ready")

func _on_initialized(_data: Dictionary = {}) -> void:
	for child in grid_container.get_children():
		UIManager.dispose_view(child)
	# 生成一个1~20之间的随机数
	var random_number = randi_range(1, 20)

	# 动态生成背包格子
	for i in range(random_number):
		var slot_data = {
			"slot_index": i
		}
		var slot = scene_component.create_widget("shop_item", grid_container, slot_data)
		slot.item_clicked.connect(_on_item_clicked)

func _on_item_clicked(slot_index: int) -> void:
	print("点击了物品：", slot_index)

func _on_child_entered_tree(node: Node) -> void:
	print("0......", node)
