class_name InteractAction
extends Action

var _inv_full: bool = false

func perform() -> bool:
	if pickup_action() or stairs_action():
		return true
	
	if not _inv_full:
		MessageLog.send_message("There is nothing to interact with here.", GameColors.IMPOSSIBLE)
	return false


func pickup_action() -> bool:
	if not entity.inventory_component:
		return false
	
	var inventory: InventoryComponent = entity.inventory_component
	var map_data: MapData = get_map_data()
	
	for item in map_data.get_items():
		if entity.grid_position == item.grid_position:
			if inventory.items.size() >= inventory.capacity:
				MessageLog.send_message("Your inventory is full.", GameColors.IMPOSSIBLE)
				_inv_full = true
				return false
			
			map_data.entities.erase(item)
			item.get_parent().remove_child(item)
			inventory.items.append(item)
			MessageLog.send_message(
				"You picked up the %s!" % item.get_entity_name(),
				Color.WHITE
			)
			return true
	
	# MessageLog.send_message("There is nothing here to pick up.", GameColors.IMPOSSIBLE)
	return false

func stairs_action() -> bool:
	if entity.grid_position == get_map_data().down_stairs_location:
		SignalBus.player_descended.emit()
		MessageLog.send_message("You descend the staircase.", GameColors.DESCEND)
	# else:
	# 	MessageLog.send_message("There are no stairs here.", GameColors.IMPOSSIBLE)
	return false
