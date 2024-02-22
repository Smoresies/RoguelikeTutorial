class_name InventoryMenu
extends CanvasLayer

signal item_selected(item)

const inventory_menu_item_scene := preload("res://src/Gui/InventoryMenu/inventory_menu_item.tscn")

@onready var inventory_list: VBoxContainer = $"%InventoryList"
@onready var title_label: Label = $"%TitleLabel"


func _ready() -> void:
	hide()
	


func button_pressed(item: Entity = null) -> void:
	item_selected.emit(item)
	queue_free()

# Registers an item and preps for the list. Takes Item and Index
func _register_item(index: int, item: Entity, is_equipped: bool) -> void:
	var item_button: Button = inventory_menu_item_scene.instantiate()
	var char: String = String.chr("a".unicode_at(0) + index)
	item_button.text = "( %s ) %s" % [char, item.get_entity_name()]
	if is_equipped:
		item_button.text += " (E)"
	var shortcut_event := InputEventKey.new()
	shortcut_event.keycode = KEY_A + index
	item_button.shortcut = Shortcut.new()
	item_button.shortcut.events = [shortcut_event]
	item_button.pressed.connect(button_pressed.bind(item))
	inventory_list.add_child(item_button)


func build(title_text: String, inventory: InventoryComponent) -> void:
	# Check to see if we actually have anything in the inventory
	# if not, then do error handling
	if inventory.items.is_empty():
		button_pressed.call_deferred()
		MessageLog.send_message("No items in inventory.", GameColors.IMPOSSIBLE)
		return
	var equipment: EquipmentComponent = inventory.entity.equipment_component
	# If we do have a button in inventory we...
	# Set the inventory label to the given title text
	title_label.text = title_text
	# For all items...
	for i in inventory.items.size():
		# Call our "register items" function
		var item: Entity = inventory.items[i]
		var is_equipped: bool = equipment.is_item_equipped(item)
		_register_item(i, inventory.items[i], is_equipped)
	# Then get reference to the first item in the children we just created
	# grab_focus will make this item highlighted
	inventory_list.get_child(0).grab_focus()
	# once it's all created we can finally show it!
	show()


# Our check each tick
func _physics_process(_delta: float) -> void:
	# if Esc/"ui_back" is pressed
	if Input.is_action_just_pressed("ui_back"):
		# We say we selected nothing before deleting instatiated menu.
		item_selected.emit(null)
		queue_free()
